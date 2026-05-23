import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/olcu_parser.dart';
import '../../core/pricing_engine.dart' show PricingEngine, PricingResult;
import '../../data/ee_olcu_catalog.dart';
import '../../data/local/profile_store.dart';
import '../../data/local/record_draft_store.dart';
import '../../data/records_store.dart';
import '../../data/remote/kayit_repository.dart';
import '../../models/islem_turu.dart';
import '../../models/product_catalog.dart';
import '../../models/worker_profile.dart';
import '../../theme/el_emegi_colors.dart';
import '../../theme/el_emegi_typography.dart';
import '../../widgets/currency_text.dart';
import '../../widgets/design/design_form_row.dart';
import '../../widgets/fabrika_gradient_button.dart';
import '../../widgets/premium_glow_card.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  String _urunCinsi = ProductCatalog.urunCinsleri.first;
  String _islemTuru = ProductCatalog.islemTurleri.first;
  late String _en = EeOlcuCatalog.enForIslem(_islemTuru).first;
  late String _boy = EeOlcuCatalog.boyForIslem(_islemTuru, _en).first;
  int _quantity = 1;
  bool _saving = false;
  bool _draftLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final draft = await RecordDraftStore.load();
    if (!mounted || draft == null) {
      setState(() => _draftLoaded = true);
      return;
    }
    setState(() {
      _urunCinsi = ProductCatalog.urunCinsleri.contains(draft.urunCinsi)
          ? draft.urunCinsi
          : _urunCinsi;
      _islemTuru = ProductCatalog.islemTurleri.contains(draft.islemTuru)
          ? draft.islemTuru
          : _islemTuru;
      _syncOlcuForIslem();
      final ens = EeOlcuCatalog.enForIslem(_islemTuru);
      if (ens.contains(draft.en)) _en = draft.en;
      final boys = EeOlcuCatalog.boyForIslem(_islemTuru, _en);
      if (boys.contains(draft.boy)) _boy = draft.boy;
      _quantity = draft.adet < 1 ? 1 : draft.adet;
      _draftLoaded = true;
    });
  }

  Future<void> _persistDraft() async {
    await RecordDraftStore.save(RecordDraft(
      urunCinsi: _urunCinsi,
      islemTuru: _islemTuru,
      en: _en,
      boy: _boy,
      adet: _quantity,
    ));
  }

  String get _measure => OlcuParser.formatLabel(_en, _boy);

  void _syncOlcuForIslem() {
    final ens = EeOlcuCatalog.enForIslem(_islemTuru);
    if (ens.isEmpty) return;
    if (!ens.contains(_en)) _en = ens.first;
    final boys = EeOlcuCatalog.boyForIslem(_islemTuru, _en);
    if (boys.isEmpty) return;
    if (!boys.contains(_boy)) _boy = boys.first;
  }

  PricingResult get _pricing {
    final tur = IslemTuru.fromIslemAdi(_islemTuru);
    final olcu = OlcuParser.fromEnBoy(_en, _boy);
    return PricingEngine.calculate(
      tur: tur,
      olcu: olcu,
      adet: _quantity,
      islemAdi: _islemTuru,
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final result = await RecordsStore.instance.save(
        KayitCreateInput(
          urunCinsi: _urunCinsi,
          islemTuru: _islemTuru,
          olcuLabel: _measure,
          adet: _quantity,
        ),
      );
      if (!mounted) return;
      final message = result.savedToCloud
          ? 'Kayıt kaydedildi'
          : 'Kayıt telefona kaydedildi — Firebase\'e gönderilemedi';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.cloudError != null && !result.savedToCloud
                ? '$message\n${result.cloudError}'
                : message,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ElEmegiColors.deepNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      widget.onSaved?.call();
      await _persistDraft();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt kaydedilemedi. Tekrar deneyin.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProfileStore.instance,
      builder: (context, _) {
        final profile = ProfileStore.instance.profile;
        if (profile == null || !_draftLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: ElEmegiColors.teal),
          );
        }
        return _buildContent(context, profile);
      },
    );
  }

  Widget _buildContent(BuildContext context, WorkerProfile profile) {
    final pricing = _pricing;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      children: [
        PremiumGlowCard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: ElEmegiColors.teal.withValues(alpha: 0.15),
                child: Text(
                  profile.adSoyad[0],
                  style: ElEmegiTypography.brandAccent(14),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Çalışan',
                      style: ElEmegiTypography.formLabel(context).copyWith(fontSize: 10),
                    ),
                    Text(
                      profile.adSoyad,
                      style: ElEmegiTypography.sectionInCard(context).copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        PremiumGlowCard(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ürün Bilgisi',
                style: ElEmegiTypography.sectionInCard(context).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 4),
              DesignFormRow(
                label: 'Ürün Cinsi',
                value: _urunCinsi,
                onTap: () => _pick(
                  context,
                  'Ürün cinsi',
                  ProductCatalog.urunCinsleri,
                  _urunCinsi,
                  (v) {
                    setState(() => _urunCinsi = v);
                    _persistDraft();
                  },
                ),
              ),
              DesignFormRow(
                label: 'İşçilik Türü',
                value: _islemTuru,
                onTap: () => _pick(
                  context,
                  'İşlem türü',
                  ProductCatalog.islemTurleri,
                  _islemTuru,
                  (v) {
                    setState(() {
                      _islemTuru = v;
                      _syncOlcuForIslem();
                    });
                    _persistDraft();
                  },
                ),
              ),
              _PairRow(
                _InlinePickerField(
                  label: 'En',
                  value: _en,
                  onTap: () => _pick(
                    context,
                    'En',
                    EeOlcuCatalog.enForIslem(_islemTuru),
                    _en,
                    (v) {
                      setState(() {
                        _en = v;
                        final boys = EeOlcuCatalog.boyForIslem(_islemTuru, _en);
                        if (!boys.contains(_boy)) _boy = boys.first;
                      });
                      _persistDraft();
                    },
                  ),
                ),
                _InlinePickerField(
                  label: 'Boy',
                  value: _boy,
                  onTap: () => _pick(
                    context,
                    'Boy',
                    EeOlcuCatalog.boyForIslem(_islemTuru, _en),
                    _boy,
                    (v) {
                      setState(() => _boy = v);
                      _persistDraft();
                    },
                  ),
                ),
              ),
              DesignFormRow(
                label: 'Ölçü',
                value: _measure,
                showChevron: false,
                onTap: null,
              ),
              _InlineQuantityField(
                quantity: _quantity,
                onChanged: (q) {
                  setState(() => _quantity = q);
                  _persistDraft();
                },
              ),
              DesignFormRow(
                label: 'Birim',
                value: '₺${pricing.birimFiyat.toStringAsFixed(2)}',
                showChevron: false,
                onTap: null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: ElEmegiColors.teal.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Toplam',
                        style: ElEmegiTypography.formLabel(context).copyWith(
                          color: ElEmegiColors.tealLight,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    CurrencyText(
                      pricing.tutar,
                      bold: true,
                      color: ElEmegiColors.tealLight,
                      style: ElEmegiTypography.sectionInCard(context).copyWith(
                        fontSize: 18,
                        color: ElEmegiColors.tealLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FabrikaGradientButton(
          label: 'Kaydet',
          loading: _saving,
          compact: true,
          onPressed: _save,
        ),
      ],
    );
  }

  Future<void> _pick(
    BuildContext context,
    String title,
    List<String> options,
    String current,
    ValueChanged<String> onSelected,
  ) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: ElEmegiColors.cardDark,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,
        minChildSize: 0.25,
        maxChildSize: 0.85,
        builder: (_, controller) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(title, style: ElEmegiTypography.sectionInCard(ctx)),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final o = options[i];
                  return ListTile(
                    title: Text(o, style: const TextStyle(color: Colors.white)),
                    trailing: o == current
                        ? const Icon(Icons.check, color: ElEmegiColors.teal)
                        : null,
                    onTap: () => Navigator.pop(ctx, o),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) onSelected(picked);
  }
}

class _PairRow extends StatelessWidget {
  const _PairRow(this.left, this.right);

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 6),
          Expanded(child: right),
        ],
      ),
    );
  }
}

/// En/Boy — yatay etiket + seçici (DesignFormRow ile uyumlu).
class _InlinePickerField extends StatelessWidget {
  const _InlinePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: ElEmegiColors.darkNavy.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ElEmegiColors.gold.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: ElEmegiTypography.formLabel(context).copyWith(fontSize: 11),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: ElEmegiTypography.formValue(context).copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ElEmegiColors.gold,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineQuantityField extends StatefulWidget {
  const _InlineQuantityField({
    required this.quantity,
    required this.onChanged,
  });

  static const maxAdet = 9999;

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  State<_InlineQuantityField> createState() => _InlineQuantityFieldState();
}

class _InlineQuantityFieldState extends State<_InlineQuantityField> {
  late final TextEditingController _controller;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _InlineQuantityField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity && !_focus.hasFocus) {
      final text = '${widget.quantity}';
      if (_controller.text != text) _controller.text = text;
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) _commitText(fallbackMin: true);
  }

  void _commitText({required bool fallbackMin}) {
    final raw = _controller.text.trim();
    final parsed = int.tryParse(raw);
    var value = parsed ?? (fallbackMin ? 1 : widget.quantity);
    value = value.clamp(1, _InlineQuantityField.maxAdet);
    _controller.text = '$value';
    if (value != widget.quantity) widget.onChanged(value);
  }

  void _step(int delta) {
    final next = (widget.quantity + delta).clamp(1, _InlineQuantityField.maxAdet);
    _controller.text = '$next';
    widget.onChanged(next);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              'Adet',
              style: ElEmegiTypography.formLabel(context).copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: ElEmegiColors.darkNavy.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ElEmegiColors.gold.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  _QtyIcon(
                    icon: Icons.remove,
                    size: 30,
                    onTap: widget.quantity > 1 ? () => _step(-1) : null,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: ElEmegiTypography.formValue(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        hintText: '1',
                      ),
                      onSubmitted: (_) => _commitText(fallbackMin: true),
                      onChanged: (v) {
                        if (v.isEmpty) return;
                        final n = int.tryParse(v);
                        if (n != null && n >= 1 && n <= _InlineQuantityField.maxAdet) {
                          widget.onChanged(n);
                        }
                      },
                    ),
                  ),
                  _QtyIcon(
                    icon: Icons.add,
                    size: 30,
                    onTap: widget.quantity < _InlineQuantityField.maxAdet
                        ? () => _step(1)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyIcon extends StatelessWidget {
  const _QtyIcon({required this.icon, this.onTap, this.size = 32});

  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ElEmegiColors.teal.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.5,
            color: onTap == null ? Colors.grey : ElEmegiColors.tealLight,
          ),
        ),
      ),
    );
  }
}

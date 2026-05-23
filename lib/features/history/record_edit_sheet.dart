import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/olcu_parser.dart';
import '../../core/pricing_engine.dart';
import '../../data/ee_olcu_catalog.dart';
import '../../data/records_store.dart';
import '../../data/remote/kayit_repository.dart';
import '../../models/islem_turu.dart';
import '../../models/product_catalog.dart';
import '../../models/work_record.dart';
import '../../theme/el_emegi_colors.dart';
import '../../theme/el_emegi_typography.dart';
import '../../widgets/currency_text.dart';
import '../../widgets/design/design_form_row.dart';
import '../../widgets/fabrika_gradient_button.dart';

Future<bool?> showRecordEditSheet(BuildContext context, WorkRecord record) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ElEmegiColors.cardDark,
    showDragHandle: true,
    builder: (ctx) => RecordEditSheet(record: record),
  );
}

class RecordEditSheet extends StatefulWidget {
  const RecordEditSheet({super.key, required this.record});

  final WorkRecord record;

  @override
  State<RecordEditSheet> createState() => _RecordEditSheetState();
}

class _RecordEditSheetState extends State<RecordEditSheet> {
  late String _urunCinsi = widget.record.urunCinsi;
  late String _islemTuru = widget.record.iscilikTuru;
  late String _measure = widget.record.olcuLabel;
  late int _quantity = widget.record.adet;
  bool _saving = false;

  List<String> get _olcuOptions => EeOlcuCatalog.forIslem(_islemTuru);

  double get _tutar {
    final tur = IslemTuru.fromIslemAdi(_islemTuru);
    return PricingEngine.calculate(
      tur: tur,
      olcu: OlcuParser.parse(_measure),
      adet: _quantity,
      islemAdi: _islemTuru,
    ).tutar;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final result = await RecordsStore.instance.update(
        KayitUpdateInput(
          kayitId: widget.record.kayitId,
          urunCinsi: _urunCinsi,
          islemTuru: _islemTuru,
          olcuLabel: _measure,
          adet: _quantity,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, result.savedToCloud);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.savedToCloud ? 'Kayıt güncellendi' : 'Telefonda güncellendi (Firebase: ${result.cloudError ?? '—'})',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('StateError: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Kaydı düzenle', style: ElEmegiTypography.sectionInCard(context)),
          const SizedBox(height: 12),
          DesignFormRow(
            label: 'Ürün Cinsi',
            value: _urunCinsi,
            onTap: () => _pick(context, 'Ürün cinsi', ProductCatalog.urunCinsleri, _urunCinsi, (v) => setState(() => _urunCinsi = v)),
          ),
          DesignFormRow(
            label: 'Ölçü',
            value: _measure,
            onTap: () => _pick(context, 'Ölçü', _olcuOptions, _measure, (v) => setState(() => _measure = v)),
          ),
          DesignFormRow(
            label: 'Adet',
            value: '$_quantity',
            showChevron: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _qtyBtn(Icons.remove, _quantity > 1 ? () => setState(() => _quantity--) : null),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('$_quantity', style: ElEmegiTypography.formValue(context)),
                ),
                _qtyBtn(Icons.add, () {
                  HapticFeedback.lightImpact();
                  setState(() => _quantity++);
                }),
              ],
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
              (v) => setState(() {
                _islemTuru = v;
                if (!_olcuOptions.contains(_measure)) {
                  _measure = _olcuOptions.first;
                }
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Toplam', style: ElEmegiTypography.formLabel(context)),
              const Spacer(),
              CurrencyText(_tutar, bold: true, color: ElEmegiColors.tealLight),
            ],
          ),
          const SizedBox(height: 16),
          FabrikaGradientButton(label: 'Kaydet', loading: _saving, onPressed: _save),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onTap) {
    return Material(
      color: ElEmegiColors.teal.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: onTap == null ? Colors.grey : ElEmegiColors.tealLight),
        ),
      ),
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
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: ElEmegiTypography.sectionInCard(ctx)),
            ),
            ...options.map(
              (o) => ListTile(
                title: Text(o, style: const TextStyle(color: Colors.white)),
                trailing: o == current ? const Icon(Icons.check, color: ElEmegiColors.teal) : null,
                onTap: () => Navigator.pop(ctx, o),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) onSelected(picked);
  }
}

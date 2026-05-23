import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/olcu_parser.dart';
import '../../core/pricing_engine.dart';
import '../../data/dashboard_store.dart';
import '../../data/ee_olcu_catalog.dart';
import '../../models/islem_turu.dart';
import '../../models/product_catalog.dart';
import '../../models/record_status.dart';
import '../../models/work_record.dart';
import '../../theme/el_emegi_colors.dart';
import '../../theme/el_emegi_typography.dart';
import '../../widgets/currency_text.dart';
import '../../widgets/design/design_form_row.dart';
import '../../widgets/fabrika_gradient_button.dart';

Future<bool?> showDashboardRecordEditSheet(BuildContext context, WorkRecord record) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ElEmegiColors.cardDark,
    showDragHandle: true,
    builder: (ctx) => DashboardRecordEditSheet(record: record),
  );
}

class DashboardRecordEditSheet extends StatefulWidget {
  const DashboardRecordEditSheet({super.key, required this.record});

  final WorkRecord record;

  @override
  State<DashboardRecordEditSheet> createState() => _DashboardRecordEditSheetState();
}

class _DashboardRecordEditSheetState extends State<DashboardRecordEditSheet> {
  late String _urunCinsi = widget.record.urunCinsi;
  late String _islemTuru = widget.record.iscilikTuru;
  late String _measure = widget.record.olcuLabel;
  late int _quantity = widget.record.adet;
  late RecordStatus _status = widget.record.status;
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

  WorkRecord get _updatedRecord {
    final tur = IslemTuru.fromIslemAdi(_islemTuru);
    final olcu = OlcuParser.parse(_measure);
    final pricing = PricingEngine.calculate(
      tur: tur,
      olcu: olcu,
      adet: _quantity,
      islemAdi: _islemTuru,
    );
    return WorkRecord(
      kayitId: widget.record.kayitId,
      ownerUid: widget.record.ownerUid,
      adSoyad: widget.record.adSoyad,
      workerKey: widget.record.workerKey,
      tarih: widget.record.tarih,
      dateKey: widget.record.dateKey,
      donemKey: widget.record.donemKey,
      islemTuru: tur.firestoreValue,
      urunCinsi: _urunCinsi,
      olcuLabel: olcu.label,
      en: olcu.en,
      boy: olcu.boy,
      adet: _quantity,
      iscilikTuru: _islemTuru,
      birimFiyat: pricing.birimFiyat,
      toplamMetre: pricing.toplamMetre,
      tutar: pricing.tutar,
      status: _status,
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final result = await DashboardStore.instance.adminUpdate(_updatedRecord);
      if (!mounted) return;
      Navigator.pop(context, result.savedToCloud);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.savedToCloud
                ? 'Kayıt güncellendi'
                : 'Güncellenemedi (${result.cloudError ?? '—'})',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.record.adSoyad,
              style: ElEmegiTypography.screenTitle(context).copyWith(fontSize: 18),
            ),
            Text(
              'Kayıt ID: ${widget.record.kayitId}',
              style: ElEmegiTypography.formLabel(context),
            ),
            const SizedBox(height: 16),
            DesignFormRow(
              label: 'Ürün cinsi',
              value: _urunCinsi,
              showChevron: false,
              child: DropdownButtonFormField<String>(
                value: ProductCatalog.urunCinsleri.contains(_urunCinsi)
                    ? _urunCinsi
                    : ProductCatalog.urunCinsleri.first,
                dropdownColor: ElEmegiColors.cardDark,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: ProductCatalog.urunCinsleri
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _urunCinsi = v ?? _urunCinsi),
              ),
            ),
            DesignFormRow(
              label: 'İşlem',
              value: _islemTuru,
              showChevron: false,
              child: DropdownButtonFormField<String>(
                value: ProductCatalog.islemTurleri.contains(_islemTuru)
                    ? _islemTuru
                    : ProductCatalog.islemTurleri.first,
                dropdownColor: ElEmegiColors.cardDark,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: ProductCatalog.islemTurleri
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _islemTuru = v ?? _islemTuru;
                    if (!_olcuOptions.contains(_measure) && _olcuOptions.isNotEmpty) {
                      _measure = _olcuOptions.first;
                    }
                  });
                },
              ),
            ),
            DesignFormRow(
              label: 'Ölçü',
              value: _measure,
              showChevron: false,
              child: DropdownButtonFormField<String>(
                value: _olcuOptions.contains(_measure)
                    ? _measure
                    : (_olcuOptions.isNotEmpty ? _olcuOptions.first : _measure),
                dropdownColor: ElEmegiColors.cardDark,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _olcuOptions
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _measure = v ?? _measure),
              ),
            ),
            DesignFormRow(
              label: 'Adet',
              value: '$_quantity',
              showChevron: false,
              child: TextFormField(
                initialValue: '$_quantity',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null && n > 0) setState(() => _quantity = n);
                },
              ),
            ),
            DesignFormRow(
              label: 'Durum',
              value: _status.label,
              showChevron: false,
              child: DropdownButtonFormField<RecordStatus>(
                value: _status,
                dropdownColor: ElEmegiColors.cardDark,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: RecordStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Tutar: ', style: ElEmegiTypography.formLabel(context)),
                CurrencyText(_tutar, bold: true, color: ElEmegiColors.tealLight),
              ],
            ),
            const SizedBox(height: 20),
            FabrikaGradientButton(
              label: _saving ? 'Kaydediliyor…' : 'Kaydet',
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

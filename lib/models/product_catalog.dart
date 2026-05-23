import '../data/ee_master_data.dart';
import '../data/ee_olcu_catalog.dart';
import 'islem_turu.dart';

/// Master veri — Firestore `ee_*_master` ile hizalı (Excel V3).
abstract final class ProductCatalog {
  static List<String> get urunCinsleri => EeMasterData.urunCinsleri;

  static List<String> get islemTurleri => EeMasterData.islemTurleri;

  static List<String> get olculer => EeOlcuCatalog.allLabels;

  static List<PriceListRow> get priceListRows {
    final rows = <PriceListRow>[];
    for (final islem in islemTurleri) {
      final tur = IslemTuru.fromIslemAdi(islem);
      if (tur == IslemTuru.sacak || tur == IslemTuru.kartela) {
        for (final o in ['30×30', '80×150', 'Q160']) {
          rows.add(PriceListRow(
            islem: islem,
            olcu: o,
            birimLabel: 'Excel V3 fiyat tablosu',
            not: EeMasterData.source,
          ));
        }
      } else {
        rows.add(PriceListRow(
          islem: islem,
          olcu: '—',
          birimLabel: _birimFiyatLabel(tur),
          not: EeMasterData.source,
        ));
      }
    }
    return rows;
  }

  static double? sacakBirimFiyat(String enKey, {String? olcuLabel}) {
    final key = (olcuLabel ?? enKey).trim().toUpperCase();
    if (key.startsWith('Q')) {
      return EeMasterData.sacakByQ[key];
    }
    final n = int.tryParse(enKey.replaceAll(RegExp(r'[^0-9]'), ''));
    if (n != null) return EeMasterData.sacakByEn[n];
    return null;
  }

  /// @deprecated [enKey] kullanın
  static double? sacakBirimFiyatByEn(double en, {String? olcuLabel}) =>
      sacakBirimFiyat('${en.round()}', olcuLabel: olcuLabel);

  static double etiketBirimFiyat() => EeMasterData.etiketBirim;
  static double overloguBirimFiyat() => EeMasterData.overloguBirim;
  static double kucukEtiketBirimFiyat() => EeMasterData.kucukEtiketBirim;
  static double kartelaBirimFiyat(double en) =>
      EeMasterData.kartelaBirim;

  static String _birimFiyatLabel(IslemTuru tur) {
    return switch (tur) {
      IslemTuru.etiket => '₺${EeMasterData.etiketBirim.toStringAsFixed(0)} / metre',
      IslemTuru.overlogu => '₺${EeMasterData.overloguBirim.toStringAsFixed(0)} / metre',
      IslemTuru.kucukEtiket => '₺${EeMasterData.kucukEtiketBirim.toStringAsFixed(0)} / adet',
      IslemTuru.kartela => '₺${EeMasterData.kartelaBirim.toStringAsFixed(0)} / metre',
      IslemTuru.sacak => 'En / Q — Excel V3',
      IslemTuru.tamir => 'Muhasebe onayı',
    };
  }
}

class PriceListRow {
  const PriceListRow({
    required this.islem,
    required this.olcu,
    required this.birimLabel,
    this.not,
  });

  final String islem;
  final String olcu;
  final String birimLabel;
  final String? not;
}

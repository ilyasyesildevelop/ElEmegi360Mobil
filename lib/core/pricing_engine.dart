import '../models/islem_turu.dart';
import '../models/product_catalog.dart';
import 'olcu_parser.dart';

class PricingResult {
  const PricingResult({
    required this.birimFiyat,
    required this.tutar,
    this.toplamMetre,
  });

  final double birimFiyat;
  final double? toplamMetre;
  final double tutar;
}

/// Excel V3 kuralları — fiyat tablosu şimdilik `ProductCatalog` (Firestore master sonra).
abstract final class PricingEngine {
  static PricingResult calculate({
    required IslemTuru tur,
    required OlcuParsed olcu,
    required int adet,
    required String islemAdi,
  }) {
    switch (tur) {
      case IslemTuru.sacak:
        final bf = ProductCatalog.sacakBirimFiyat(
              olcu.enKey.isNotEmpty ? olcu.enKey : '${olcu.en.round()}',
              olcuLabel: olcu.label,
            ) ??
            55;
        return PricingResult(birimFiyat: bf, tutar: adet * bf);

      case IslemTuru.etiket:
        final metre = adet * olcu.en * 2 / 100;
        final bf = ProductCatalog.etiketBirimFiyat();
        return PricingResult(
          birimFiyat: bf,
          toplamMetre: metre,
          tutar: metre * bf,
        );

      case IslemTuru.overlogu:
        final metre = (olcu.en + olcu.boy) * adet * 2 / 100;
        final bf = ProductCatalog.overloguBirimFiyat();
        return PricingResult(
          birimFiyat: bf,
          toplamMetre: metre,
          tutar: metre * bf,
        );

      case IslemTuru.kucukEtiket:
        final bf = ProductCatalog.kucukEtiketBirimFiyat();
        return PricingResult(birimFiyat: bf, tutar: adet * bf);

      case IslemTuru.kartela:
        final metre = olcu.en * adet * 2 / 100;
        final bf = ProductCatalog.kartelaBirimFiyat(olcu.en);
        return PricingResult(
          birimFiyat: bf,
          toplamMetre: metre,
          tutar: metre * bf,
        );

      case IslemTuru.tamir:
        return const PricingResult(birimFiyat: 0, tutar: 0);
    }
  }
}

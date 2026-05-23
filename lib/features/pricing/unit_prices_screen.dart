import 'package:flutter/material.dart';

import '../../models/product_catalog.dart';
import '../../theme/el_emegi_colors.dart';
import '../../widgets/fabrika_page_header.dart';
import '../../widgets/premium_glow_card.dart';

/// Bilgi amaçlı birim ücret listesi — master tablo bağlanınca Firestore’dan dolar.
class UnitPricesScreen extends StatelessWidget {
  const UnitPricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = ProductCatalog.priceListRows;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ElEmegiColors.darkNavy : const Color(0xFFF4F6FA),
      body: Column(
        children: [
          FabrikaPageHeader(
            title: 'Birim ücretler',
            subtitle: 'Bilgi amaçlı liste',
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PremiumGlowCard(
                  animate: false,
                  child: Text(
                    'Ücretler yönetim tarafından güncellenir. Kayıt ekranında tutar otomatik hesaplanır.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ElEmegiColors.olive,
                          height: 1.4,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                ...rows.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PremiumGlowCard(
                      animate: false,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.islem,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: ElEmegiColors.teal,
                                ),
                          ),
                          if (r.olcu != '—') ...[
                            const SizedBox(height: 4),
                            Text('Ölçü: ${r.olcu}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            r.birimLabel,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/app_meta.dart';
import '../../theme/el_emegi_colors.dart';
import '../../widgets/fabrika_page_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _usageSteps = '''
• Kayıt ekranından ürün, ölçü, adet ve işçilik türünü seçerek işinizi kaydedin.
• Ücretler, tanımlı birim fiyat kurallarına göre otomatik hesaplanır.
• Geçmiş ekranından kayıtlarınızı görüntüleyin; ödeme bekleyen kayıtları düzenleyebilir veya silebilirsiniz.
• Ücret ekranından dönem bazında hakediş özetinize bakın.
• Ayarlar → Yönetici paneli ile (yönetici girişi) tüm çalışanların kayıtlarını yönetebilir ve aylık rapor alabilirsiniz.
• Ayarlar ekranından IBAN bilginizi ve uygulama güncellemesini yönetin.''';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyColor = isDark ? ElEmegiColors.threadCream : ElEmegiColors.deepNavy;

    return Scaffold(
      backgroundColor: isDark ? ElEmegiColors.darkNavy : const Color(0xFFF4F6FA),
      body: Column(
        children: [
          FabrikaPageHeader(
            title: AppMeta.appName,
            subtitle: 'Hakkında',
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppMeta.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppMeta.displayVersion,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ElEmegiColors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppMeta.tagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ElEmegiColors.softBlueGray,
                      ),
                ),
                const SizedBox(height: 28),
                Text(
                  'El Emeği 360, ev işçiliği kayıtlarını mobil cihazdan tutmanız, '
                  'hakedişinizi takip etmeniz ve yöneticilerin tüm kayıtları merkezi '
                  'olarak görüntülemesini sağlayan Fabrika 360 Suite uygulamasıdır. '
                  'Verileriniz güvenli bulut altyapısında saklanır; yedekleme ve raporlama '
                  'işlemleri otomatik desteklenir.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: bodyColor.withValues(alpha: 0.92),
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Kullanım',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ElEmegiColors.tealLight,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  _usageSteps.trim(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: bodyColor.withValues(alpha: 0.88),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppMeta.developerCredit,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
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

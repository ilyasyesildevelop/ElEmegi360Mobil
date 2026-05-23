import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/el_emegi_colors.dart';
import '../currency_text.dart';

/// Ödeme ekranı toplam kartı (sabit kenar, ekran geneli animasyon yok).
class PremiumHeroCard extends StatelessWidget {
  const PremiumHeroCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.goldAmount = true,
  });

  final String title;
  final double amount;
  final String? subtitle;
  final bool goldAmount;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(18));

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ElEmegiColors.cardDark.withValues(alpha: 0.95),
            ElEmegiColors.deepNavy,
          ],
        ),
        border: Border.all(color: ElEmegiColors.gold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: ElEmegiColors.gold.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 88, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ElEmegiColors.softBlueGray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                CurrencyText(
                  amount,
                  bold: true,
                  color: goldAmount ? ElEmegiColors.goldLight : ElEmegiColors.tealLight,
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: ElEmegiColors.threadCream.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Positioned(
            right: 16,
            top: 12,
            bottom: 12,
            child: _SpoolIllustration(),
          ),
        ],
      ),
    );
  }
}

class _SpoolIllustration extends StatelessWidget {
  const _SpoolIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(56, 56),
      painter: _SpoolPainter(),
    );
  }
}

class _SpoolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final body = Paint()..color = ElEmegiColors.threadCream.withValues(alpha: 0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 36, height: 44),
        const Radius.circular(6),
      ),
      body,
    );
    canvas.drawCircle(Offset(cx, cy), 8, Paint()..color = ElEmegiColors.gold.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

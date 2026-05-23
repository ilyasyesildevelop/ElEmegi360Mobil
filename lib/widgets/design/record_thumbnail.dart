import 'package:flutter/material.dart';

import '../../theme/el_emegi_colors.dart';
import '../premium/gold_sparkle.dart';

/// Geçmiş kartı sol küçük görsel + altın parıltı.
class RecordThumbnail extends StatelessWidget {
  const RecordThumbnail({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [ElEmegiColors.deepNavy, ElEmegiColors.kilimRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Image.asset(
                'assets/images/app_icon.png',
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.texture, color: ElEmegiColors.threadCream),
                ),
              ),
            ),
          ),
          const Positioned(
            top: -4,
            left: -4,
            child: GoldSparkleIcon(size: 20),
          ),
        ],
      ),
    );
  }
}

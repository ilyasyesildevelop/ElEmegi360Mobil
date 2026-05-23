import 'package:flutter/material.dart';

import '../core/app_meta.dart';
import '../theme/el_emegi_colors.dart';
import '../theme/el_emegi_typography.dart';
import 'header_shimmer_title.dart';
import 'premium/header_sparkle_pattern.dart';

class ElEmegiBrandHeader extends StatelessWidget {
  const ElEmegiBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF12182C), ElEmegiColors.deepNavy, ElEmegiColors.headerEnd],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AppIconBadge(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          const HeaderShimmerTitle(
                            text: AppMeta.appName,
                            brandSplit: true,
                          ),
                          const SizedBox(height: 6),
                          Text(AppMeta.tagline, style: ElEmegiTypography.tagline(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppIconBadge extends StatelessWidget {
  const _AppIconBadge();

  static const ringSize = 56.0;
  static const _iconSize = 44.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: ElEmegiColors.goldMetallicGradient,
              boxShadow: [
                BoxShadow(
                  color: ElEmegiColors.gold.withValues(alpha: 0.28),
                  blurRadius: 14,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_icon.png',
                width: _iconSize,
                height: _iconSize,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: _iconSize,
                  height: _iconSize,
                  color: ElEmegiColors.cardDark,
                  child: const Icon(Icons.handyman, color: ElEmegiColors.tealLight, size: 22),
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: HeaderSparklePattern(ringSize: ringSize),
            ),
          ),
        ],
      ),
    );
  }
}

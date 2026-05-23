import 'package:flutter/material.dart';

import '../core/app_meta.dart';
import '../theme/el_emegi_colors.dart';
import 'fabrika_page_header.dart';
import 'header_shimmer_title.dart';

/// Suite header + sağda uygulama ikonu + başlık parıltısı.
class ElEmegiPageHeader extends StatelessWidget {
  const ElEmegiPageHeader({
    super.key,
    required this.subtitle,
  });

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return FabrikaPageHeader(
      title: AppMeta.appName,
      subtitle: subtitle,
      titleWidget: const HeaderShimmerTitle(
        text: AppMeta.appName,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      trailing: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ElEmegiColors.gold.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: ElEmegiColors.gold.withValues(alpha: 0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 44,
            height: 44,
            color: ElEmegiColors.teal.withValues(alpha: 0.25),
            child: const Icon(Icons.handyman, color: ElEmegiColors.tealLight),
          ),
        ),
        ),
      ),
    );
  }
}

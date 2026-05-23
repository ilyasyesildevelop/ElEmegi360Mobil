import 'package:flutter/material.dart';

import '../theme/el_emegi_typography.dart';

/// Marka başlığı (parıltı ayrı: [HeaderSparklePattern]).
class HeaderShimmerTitle extends StatelessWidget {
  const HeaderShimmerTitle({
    super.key,
    required this.text,
    this.style,
    this.brandSplit = true,
  });

  final String text;
  final TextStyle? style;
  final bool brandSplit;

  @override
  Widget build(BuildContext context) {
    if (brandSplit && text.contains('360')) {
      final parts = text.split('360');
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(text: parts.first.trimRight(), style: ElEmegiTypography.brandGold(22)),
            TextSpan(
              text: ' 360${parts.length > 1 ? parts[1] : ''}',
              style: ElEmegiTypography.brandAccent(22),
            ),
          ],
        ),
      );
    }
    return Text(text, style: style);
  }
}

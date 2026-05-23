import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/el_emegi_colors.dart';

class FabrikaGradientButton extends StatefulWidget {
  const FabrikaGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool compact;

  @override
  State<FabrikaGradientButton> createState() => _FabrikaGradientButtonState();
}

class _FabrikaGradientButtonState extends State<FabrikaGradientButton> {
  double _pressScale = 1;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    const radius = BorderRadius.all(Radius.circular(14));
    final height = widget.compact ? 44.0 : 50.0;

    return Transform.scale(
      scale: _pressScale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: enabled
              ? ElEmegiColors.ctaGradient
              : LinearGradient(
                  colors: [
                    ElEmegiColors.teal.withValues(alpha: 0.4),
                    ElEmegiColors.tealLight.withValues(alpha: 0.35),
                  ],
                ),
          border: Border.all(
            color: ElEmegiColors.gold.withValues(alpha: enabled ? 0.35 : 0.15),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: ElEmegiColors.teal.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled
                ? () {
                    HapticFeedback.mediumImpact();
                    widget.onPressed?.call();
                  }
                : null,
            onHighlightChanged: enabled
                ? (down) => setState(() => _pressScale = down ? 0.97 : 1)
                : null,
            borderRadius: radius,
            child: SizedBox(
              width: double.infinity,
              height: height,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.compact ? 14 : 18),
                child: enabled && !widget.loading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.white, size: widget.compact ? 18 : 20),
                            SizedBox(width: widget.compact ? 8 : 10),
                          ],
                          Text(
                            widget.label,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: widget.compact ? 14 : 15,
                                ),
                          ),
                          if (!widget.compact) ...[
                            const Spacer(),
                            Icon(
                              Icons.gesture_rounded,
                              color: Colors.white.withValues(alpha: 0.88),
                              size: 24,
                            ),
                          ],
                        ],
                      )
                    : Center(
                        child: widget.loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(widget.label),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

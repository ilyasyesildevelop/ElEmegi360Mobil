import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/el_emegi_colors.dart';

class ElEmegiBottomNav extends StatelessWidget {
  const ElEmegiBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(Icons.edit_note_outlined, Icons.edit_note, 'Kayıt'),
    _NavItem(Icons.history_outlined, Icons.history, 'Geçmiş'),
    _NavItem(Icons.payments_outlined, Icons.payments, 'Ücret'),
    _NavItem(Icons.settings_outlined, Icons.settings, 'Ayarlar'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark
        ? const Color(0xFF0A0E1A).withValues(alpha: 0.96)
        : Colors.white.withValues(alpha: 0.98);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: barColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(index);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        width: 50,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: selected
                              ? ElEmegiColors.teal.withValues(alpha: 0.22)
                              : Colors.transparent,
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: ElEmegiColors.teal.withValues(alpha: 0.45),
                                    blurRadius: 16,
                                    spreadRadius: -2,
                                  ),
                                ]
                              : null,
                          border: selected
                              ? Border.all(
                                  color: ElEmegiColors.tealLight.withValues(alpha: 0.5),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Icon(
                          selected ? item.selected : item.outlined,
                          size: 22,
                          color: selected
                              ? ElEmegiColors.tealLight
                              : (isDark
                                  ? ElEmegiColors.softBlueGray
                                  : ElEmegiColors.deepNavy.withValues(alpha: 0.45)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? ElEmegiColors.tealLight
                              : (isDark
                                  ? ElEmegiColors.softBlueGray
                                  : ElEmegiColors.deepNavy.withValues(alpha: 0.5)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.outlined, this.selected, this.label);
  final IconData outlined;
  final IconData selected;
  final String label;
}

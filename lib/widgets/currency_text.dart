import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyText extends StatelessWidget {
  const CurrencyText(
    this.amount, {
    super.key,
    this.style,
    this.color,
    this.bold = false,
  });

  final double amount;
  final TextStyle? style;
  final Color? color;
  final bool bold;

  static final _format = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      _format.format(amount),
      style: (style ?? Theme.of(context).textTheme.titleLarge)?.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
    );
  }
}

import 'dart:math';

import 'turkish_text.dart';

/// Vardiya `RecordIdGenerator` ile uyumlu: `yyyyMMddHHmmss-XY-ZZZ`
abstract final class RecordId {
  static const _rnd = 'ABCDEFGHJKLMNPRSTUVWXYZ23456789';
  static final _random = Random();

  static String generate({
    required String adSoyad,
    DateTime? at,
  }) {
    final cal = at ?? DateTime.now();
    String pad(int n) => n.toString().padLeft(2, '0');
    final ts =
        '${cal.year}${pad(cal.month)}${pad(cal.day)}${pad(cal.hour)}${pad(cal.minute)}${pad(cal.second)}';

    final upper = TurkishText.toUpperCase(adSoyad);
    final parts = upper.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final initials = StringBuffer();
    for (final p in parts) {
      for (final code in p.runes) {
        final ch = String.fromCharCode(code);
        if (RegExp(r'[A-ZÇĞİÖŞÜ]').hasMatch(ch)) {
          initials.write(ch);
          break;
        }
      }
      if (initials.length >= 2) break;
    }
    final xy = initials.isEmpty ? 'XX' : initials.toString().substring(0, initials.length.clamp(0, 2));

    final rnd = List.generate(3, (_) => _rnd[_random.nextInt(_rnd.length)]).join();
    return '$ts-$xy-$rnd';
  }
}

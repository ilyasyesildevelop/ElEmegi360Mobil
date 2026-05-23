/// Türkçe büyük harf (i→İ, ı→I, ş→Ş, …).
abstract final class TurkishText {
  static String toUpperCase(String input) {
    final trimmed = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return '';

    final buffer = StringBuffer();
    for (final code in trimmed.runes) {
      final ch = String.fromCharCode(code);
      final lower = ch.toLowerCase();
      buffer.write(_toUpperChar(ch, lower));
    }
    return buffer.toString();
  }

  static String _toUpperChar(String ch, String lower) {
    if (_upperMap.containsKey(ch)) return _upperMap[ch]!;
    if (_upperMap.containsKey(lower)) return _upperMap[lower]!;
    return ch.toUpperCase();
  }

  /// Firestore / Sheet anahtarı: `AYŞE YILMAZ` → `AYSE_YILMAZ`
  static String toWorkerKey(String adSoyadUpper) {
    final normalized = adSoyadUpper
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .map((p) {
          final sb = StringBuffer();
          for (final code in p.runes) {
            final ch = String.fromCharCode(code);
            final lower = ch.toLowerCase();
            sb.write(_asciiUpper[ch] ?? _asciiUpper[lower] ?? _upperMap[lower] ?? ch.toUpperCase());
          }
          return sb.toString();
        })
        .join('_');
    return normalized.replaceAll(RegExp(r'[^A-Z0-9_]'), '');
  }

  static const _upperMap = {
    'i': 'İ',
    'ı': 'I',
    'ş': 'Ş',
    'ğ': 'Ğ',
    'ü': 'Ü',
    'ö': 'Ö',
    'ç': 'Ç',
    'İ': 'İ',
    'I': 'I',
    'Ş': 'Ş',
    'Ğ': 'Ğ',
    'Ü': 'Ü',
    'Ö': 'Ö',
    'Ç': 'Ç',
  };

  static const _asciiUpper = {
    'İ': 'I',
    'Ş': 'S',
    'Ğ': 'G',
    'Ü': 'U',
    'Ö': 'O',
    'Ç': 'C',
  };
}

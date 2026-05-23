class OlcuParsed {
  const OlcuParsed({
    required this.label,
    required this.en,
    required this.boy,
    this.enKey = '',
    this.olcuTipi = OlcuTipi.dikdortgen,
  });

  final String label;
  final double en;
  final double boy;
  /// Saçak VLOOKUP anahtarı — `120` veya `Q120`.
  final String enKey;
  final OlcuTipi olcuTipi;
}

enum OlcuTipi { dikdortgen, kare, q, enCm }

abstract final class OlcuParser {
  static String formatLabel(String enRaw, String boyRaw) {
    final en = enRaw.trim().toUpperCase();
    final boy = boyRaw.trim();
    if (en.startsWith('Q')) return en;
    final e = int.tryParse(en);
    final b = int.tryParse(boy);
    if (e != null && b != null) return '$e×$b';
    return enRaw.trim();
  }

  static OlcuParsed fromEnBoy(String enRaw, String boyRaw) =>
      parse(formatLabel(enRaw, boyRaw), enRaw: enRaw, boyRaw: boyRaw);

  static OlcuParsed parse(String raw, {String? enRaw, String? boyRaw}) {
    final label = raw.trim();
    final normalized = label
        .toUpperCase()
        .replaceAll('*', '×')
        .replaceAll('×', 'x')
        .replaceAll(RegExp(r'\s+'), '');

    final qMatch = RegExp(r'^Q(\d+)$').firstMatch(normalized);
    if (qMatch != null) {
      final n = double.parse(qMatch.group(1)!);
      return OlcuParsed(
        label: label.isEmpty ? 'Q${n.toInt()}' : label,
        en: n,
        boy: n,
        enKey: 'Q${n.toInt()}',
        olcuTipi: OlcuTipi.q,
      );
    }

    final parts = normalized.split('x').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      final en = double.tryParse(parts[0]) ?? 0;
      final boy = double.tryParse(parts[1]) ?? 0;
      return OlcuParsed(
        label: label,
        en: en,
        boy: boy,
        enKey: parts[0],
        olcuTipi: en == boy ? OlcuTipi.kare : OlcuTipi.dikdortgen,
      );
    }

    final enOnly = double.tryParse(parts.isNotEmpty ? parts[0] : normalized);
    if (enOnly != null) {
      final boyVal = double.tryParse(boyRaw ?? '') ?? enOnly;
      return OlcuParsed(
        label: label,
        en: enOnly,
        boy: boyVal,
        enKey: enRaw?.trim().isNotEmpty == true ? enRaw!.trim() : '${enOnly.toInt()}',
        olcuTipi: OlcuTipi.enCm,
      );
    }

    return OlcuParsed(label: label, en: 30, boy: 30, enKey: '30', olcuTipi: OlcuTipi.enCm);
  }
}

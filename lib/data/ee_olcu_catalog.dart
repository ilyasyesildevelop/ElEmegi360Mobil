import 'ee_master_data.dart';

/// Excel V3 — `Standart Ölçüler` + `Ölçüler` + `Fiyat` (saçak en / Q).
abstract final class EeOlcuCatalog {
  static List<String> get allLabels {
    final seen = <String>{};
    final out = <String>[];
    for (final label in [
      ...EeMasterData.sacakQEn,
      ...EeMasterData.sacakEnCm,
      ...EeMasterData.standartOlculer,
      ...EeMasterData.kareOlculer,
    ]) {
      if (seen.add(label)) out.add(label);
    }
    return out;
  }

  /// Eski tek alan seçici — düzenleme ekranları.
  static List<String> forIslem(String islemAdi) {
    final u = islemAdi.toLowerCase();
    if (u.contains('saçak') || u.contains('sacak')) {
      return [...EeMasterData.sacakQEn, ...EeMasterData.sacakEnCm, ...EeMasterData.standartOlculer];
    }
    if (u.contains('kartela') || u.contains('etiket') || u.contains('overlogu')) {
      return [...EeMasterData.sacakEnCm, ...EeMasterData.standartOlculer, ...EeMasterData.kareOlculer];
    }
    if (u.contains('tamir')) return allLabels;
    return allLabels;
  }

  /// Excel `En` sütunu — saçak: cm + Q; diğer işlemler: cm + standart en değerleri.
  static List<String> enForIslem(String islemAdi) {
    final u = islemAdi.toLowerCase();
    if (u.contains('saçak') || u.contains('sacak')) {
      return [...EeMasterData.sacakQEn, ...EeMasterData.sacakEnCm];
    }
    final ens = <String>{...EeMasterData.sacakEnCm};
    for (final label in [...EeMasterData.standartOlculer, ...EeMasterData.kareOlculer]) {
      final parts = _splitLabel(label);
      if (parts != null) ens.add(parts.$1);
    }
    final sorted = ens.toList()
      ..sort((a, b) {
        final qa = a.startsWith('Q');
        final qb = b.startsWith('Q');
        if (qa != qb) return qa ? -1 : 1;
        final na = int.tryParse(a) ?? 0;
        final nb = int.tryParse(b) ?? 0;
        return na.compareTo(nb);
      });
    return sorted;
  }

  /// Excel `Boy` sütunu — seçilen en ile uyumlu boy listesi.
  static List<String> boyForIslem(String islemAdi, String en) {
    final u = islemAdi.toLowerCase();
    final enNorm = en.trim().toUpperCase();

    if (enNorm.startsWith('Q')) {
      final n = enNorm.replaceFirst('Q', '');
      return [n, enNorm];
    }

    if (u.contains('saçak') || u.contains('sacak')) {
      final boys = <String>{en};
      for (final label in EeMasterData.standartOlculer) {
        final parts = _splitLabel(label);
        if (parts != null && parts.$1 == en) boys.add(parts.$2);
      }
      for (final label in EeMasterData.kareOlculer) {
        final parts = _splitLabel(label);
        if (parts != null && parts.$1 == en) boys.add(parts.$2);
      }
      if (boys.length == 1) {
        for (final label in EeMasterData.kareOlculer) {
          final parts = _splitLabel(label);
          if (parts != null && parts.$1 == en) boys.add(parts.$2);
        }
      }
      return _sortNumericStrings(boys.toList());
    }

    final boys = <String>{en};
    for (final label in [...EeMasterData.standartOlculer, ...EeMasterData.kareOlculer]) {
      final parts = _splitLabel(label);
      if (parts != null && parts.$1 == en) boys.add(parts.$2);
    }
    if (boys.length == 1) {
      for (final label in EeMasterData.kareOlculer) {
        final parts = _splitLabel(label);
        if (parts != null) boys.add(parts.$2);
      }
    }
    return _sortNumericStrings(boys.toList());
  }

  static (String, String)? _splitLabel(String label) {
    final norm = label.trim().toUpperCase().replaceAll('*', '×');
    if (norm.startsWith('Q')) return null;
    final parts = norm.split('×').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return (parts[0], parts[1]);
    return null;
  }

  static List<String> _sortNumericStrings(List<String> values) {
    final list = values.toList()
      ..sort((a, b) {
        final na = int.tryParse(a) ?? 0;
        final nb = int.tryParse(b) ?? 0;
        return na.compareTo(nb);
      });
    return list;
  }
}

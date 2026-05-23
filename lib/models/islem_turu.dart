/// Firestore `islemTuru` — işlem / işçilik adından türetilir.
enum IslemTuru {
  sacak('SACAK'),
  etiket('ETIKET'),
  overlogu('OVERLOGU'),
  kucukEtiket('KUCUK_ETIKET'),
  kartela('KARTELA'),
  tamir('TAMIR');

  const IslemTuru(this.firestoreValue);
  final String firestoreValue;

  static IslemTuru fromIslemAdi(String islemAdi) {
    final u = islemAdi.trim().toLowerCase();
    if (u.contains('tamir')) return IslemTuru.tamir;
    if (u.contains('overlogu')) return IslemTuru.overlogu;
    if (u.contains('küçük') || u.contains('kucuk')) return IslemTuru.kucukEtiket;
    if (u.contains('kartela')) return IslemTuru.kartela;
    if (u.contains('etiket')) return IslemTuru.etiket;
    if (u.contains('saçak') || u.contains('sacak')) return IslemTuru.sacak;
    return IslemTuru.sacak;
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/// Kayıt ekranı — son seçilen ürün / ölçü / adet.
class RecordDraftStore {
  static const _keyUrun = 'ee_draft_urun_cinsi';
  static const _keyIslem = 'ee_draft_islem_turu';
  static const _keyEn = 'ee_draft_en';
  static const _keyBoy = 'ee_draft_boy';
  static const _keyAdet = 'ee_draft_adet';

  static Future<RecordDraft?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final urun = prefs.getString(_keyUrun);
    final islem = prefs.getString(_keyIslem);
    final en = prefs.getString(_keyEn);
    final boy = prefs.getString(_keyBoy);
    if (urun == null || islem == null || en == null || boy == null) return null;
    return RecordDraft(
      urunCinsi: urun,
      islemTuru: islem,
      en: en,
      boy: boy,
      adet: prefs.getInt(_keyAdet) ?? 1,
    );
  }

  static Future<void> save(RecordDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUrun, draft.urunCinsi);
    await prefs.setString(_keyIslem, draft.islemTuru);
    await prefs.setString(_keyEn, draft.en);
    await prefs.setString(_keyBoy, draft.boy);
    await prefs.setInt(_keyAdet, draft.adet);
  }
}

class RecordDraft {
  const RecordDraft({
    required this.urunCinsi,
    required this.islemTuru,
    required this.en,
    required this.boy,
    required this.adet,
  });

  final String urunCinsi;
  final String islemTuru;
  final String en;
  final String boy;
  final int adet;
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/turkish_text.dart';
import '../../models/work_record.dart';
import '../../models/worker_profile.dart';
import 'records_cache.dart';

/// Telefon sahibi profili — yerel önbellek (Firestore ile senkron).
class ProfileStore extends ChangeNotifier {
  ProfileStore._();
  static final ProfileStore instance = ProfileStore._();

  static const _keyUid = 'owner_uid';
  static const _keyAdSoyad = 'ad_soyad';
  static const _keyWorkerKey = 'worker_key';
  static const _keyLocked = 'profile_locked';
  static const _keyRegisteredAt = 'registered_at_ms';
  static const _keyIban = 'iban';
  static const _keyNotifications = 'notifications_enabled';

  WorkerProfile? _profile;
  bool _loaded = false;

  WorkerProfile? get profile => _profile;
  bool get isLoaded => _loaded;
  bool get isRegistered => _profile != null && _profile!.locked;

  String get adSoyad => _profile?.adSoyad ?? '';
  String get workerKey => _profile?.workerKey ?? '';
  String get ownerUid => _profile?.ownerUid ?? '';
  String get iban => _profile?.iban ?? '';
  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_keyUid);
    final name = prefs.getString(_keyAdSoyad);
    final wKey = prefs.getString(_keyWorkerKey);
    final locked = prefs.getBool(_keyLocked) ?? false;
    final regMs = prefs.getInt(_keyRegisteredAt);

    if (uid != null && name != null && name.isNotEmpty && locked) {
      _profile = WorkerProfile(
        ownerUid: uid,
        adSoyad: name,
        workerKey: wKey ?? TurkishText.toWorkerKey(name),
        locked: true,
        registeredAt: regMs != null
            ? DateTime.fromMillisecondsSinceEpoch(regMs)
            : null,
        iban: prefs.getString(_keyIban),
      );
    } else {
      _profile = null;
    }
    _notificationsEnabled = prefs.getBool(_keyNotifications) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    notifyListeners();
  }

  /// İlk kurulum — yalnızca profil yokken çağrılır.
  Future<WorkerProfile> register({
    required String ownerUid,
    required String rawAdSoyad,
  }) async {
    if (isRegistered) {
      throw StateError('Profil zaten kilitli');
    }
    final adSoyad = TurkishText.toUpperCase(rawAdSoyad);
    if (adSoyad.length < 3) {
      throw ArgumentError('Ad soyad en az 3 karakter olmalı');
    }
    final workerKey = TurkishText.toWorkerKey(adSoyad);
    if (workerKey.length < 2) {
      throw ArgumentError('Geçerli bir ad soyad girin');
    }

    final now = DateTime.now();
    final registered = WorkerProfile(
      ownerUid: ownerUid,
      adSoyad: adSoyad,
      workerKey: workerKey,
      locked: true,
      registeredAt: now,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUid, ownerUid);
    await prefs.setString(_keyAdSoyad, adSoyad);
    await prefs.setString(_keyWorkerKey, workerKey);
    await prefs.setBool(_keyLocked, true);
    await prefs.setInt(_keyRegisteredAt, now.millisecondsSinceEpoch);

    _profile = registered;
    notifyListeners();
    return registered;
  }

  /// Firestore’dan gelen profil yereli günceller (ad değiştirilmez).
  Future<void> adoptFromRemote(WorkerProfile remote) async {
    if (!remote.locked || remote.adSoyad.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUid, remote.ownerUid);
    await prefs.setString(_keyAdSoyad, remote.adSoyad);
    await prefs.setString(_keyWorkerKey, remote.workerKey);
    await prefs.setBool(_keyLocked, true);
    if (remote.registeredAt != null) {
      await prefs.setInt(_keyRegisteredAt, remote.registeredAt!.millisecondsSinceEpoch);
    }
    final iban = prefs.getString(_keyIban);
    _profile = remote.iban != null && remote.iban!.isNotEmpty
        ? remote
        : remote.copyWith(iban: iban);
    notifyListeners();
  }

  /// Yerel profil uid → aktif Firebase Auth uid taşıma.
  Future<void> reconcileOwnerUid(String authUid) async {
    final p = _profile;
    if (p == null || authUid.isEmpty || p.ownerUid == authUid) return;

    final oldUid = p.ownerUid;
    final cached = await RecordsCache.load(oldUid);
    for (final r in cached) {
      await RecordsCache.upsert(
        authUid,
        WorkRecord(
          kayitId: r.kayitId,
          ownerUid: authUid,
          adSoyad: r.adSoyad,
          workerKey: r.workerKey,
          tarih: r.tarih,
          dateKey: r.dateKey,
          donemKey: r.donemKey,
          islemTuru: r.islemTuru,
          urunCinsi: r.urunCinsi,
          olcuLabel: r.olcuLabel,
          en: r.en,
          boy: r.boy,
          adet: r.adet,
          iscilikTuru: r.iscilikTuru,
          birimFiyat: r.birimFiyat,
          toplamMetre: r.toplamMetre,
          tutar: r.tutar,
          status: r.status,
        ),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUid, authUid);
    _profile = p.copyWith(ownerUid: authUid);
    notifyListeners();
  }

  Future<void> saveIban(String iban) async {
    final p = _profile;
    if (p == null) return;
    final trimmed = iban.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIban, trimmed);
    _profile = p.copyWith(iban: trimmed.isEmpty ? null : trimmed);
    notifyListeners();
    // Firestore hazır olunca: PersonProfileRepository.updateIban(...)
  }
}

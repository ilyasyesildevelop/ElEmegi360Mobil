import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/app_meta.dart';
import '../../models/worker_profile.dart';
import 'ee_sheets_service.dart';
import 'fabrika_firestore.dart';

/// `ee_person/{ownerUid}` — birincil kaynak Firestore; GS yalnızca yedek yazma.
class PersonProfileRepository {
  PersonProfileRepository({FirebaseFirestore? firestore}) : _db = firestore;

  final FirebaseFirestore? _db;
  static const collection = 'ee_person';
  static const legacyCollection = 'ee_cihaz';

  static PersonProfileRepository? tryCreate() {
    final db = FabrikaFirestore.instance;
    if (db == null) return null;
    return PersonProfileRepository(firestore: db);
  }

  Future<WorkerProfile?> fetch(String ownerUid) async {
    final db = _db;
    if (db == null) return null;
    try {
      final snap = await db.collection(collection).doc(ownerUid).get();
      if (snap.exists) {
        return WorkerProfile.fromMap(snap.data(), ownerUid);
      }
      final legacy = await db.collection(legacyCollection).doc(ownerUid).get();
      return WorkerProfile.fromMap(legacy.data(), ownerUid);
    } catch (e) {
      debugPrint('ee_person okuma: $e');
      return null;
    }
  }

  /// İlk kurulum / profil kaydı — Firestore birincil, Sheets arka planda yedek.
  Future<void> registerPerson({
    required WorkerProfile profile,
    required String platform,
    required String appVersion,
  }) async {
    await _persistToFirestore(profile, platform: platform, appVersion: appVersion);
    EeSheetsService.instance.backupRegisterPerson(profile);
  }

  /// Açılışta yalnızca Firestore lastSeenAt — Sheets'e dokunulmaz.
  Future<void> touchLastSeen(String ownerUid) async {
    final db = _db;
    if (db == null || ownerUid.isEmpty) return;
    try {
      final ref = db.collection(collection).doc(ownerUid);
      final existing = await ref.get();
      if (existing.exists) {
        await ref.update({'lastSeenAt': FieldValue.serverTimestamp()});
      }
    } catch (e) {
      debugPrint('ee_person touchLastSeen: $e');
    }
  }

  Future<void> updateIban(String ownerUid, String iban, WorkerProfile profile) async {
    final trimmed = iban.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final updated = profile.copyWith(iban: trimmed);
    final db = _db;
    if (db != null) {
      final ref = db.collection(collection).doc(ownerUid);
      final snap = await ref.get();
      if (!snap.exists) {
        await ref.set({
          ...updated.toFirestoreMap(
            platform: 'android',
            appVersion: AppMeta.versionName,
          ),
          'createdAt': FieldValue.serverTimestamp(),
          'ibanUpdatedAt': FieldValue.serverTimestamp(),
          'lastSeenAt': FieldValue.serverTimestamp(),
        });
      } else {
        await ref.update({
          'iban': trimmed,
          'ibanUpdatedAt': FieldValue.serverTimestamp(),
          'lastSeenAt': FieldValue.serverTimestamp(),
        });
      }
    }

    final sheets = EeSheetsService.instance;
    if (EeSheetsService.isConfigured) {
      sheets.backupRegisterPerson(updated);
      sheets.backupUpdateIban(ownerUid, trimmed);
    }
  }

  Future<void> _persistToFirestore(
    WorkerProfile profile, {
    required String platform,
    required String appVersion,
  }) async {
    final db = _db;
    if (db == null) return;

    final ref = db.collection(collection).doc(profile.ownerUid);
    final existing = await ref.get();
    if (!existing.exists) {
      await ref.set({
        ...profile.toFirestoreMap(platform: platform, appVersion: appVersion),
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeenAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({'lastSeenAt': FieldValue.serverTimestamp()});
    }
  }
}

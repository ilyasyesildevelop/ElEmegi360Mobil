import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/worker_profile.dart';
import 'fabrika_firestore.dart';

/// `ee_cihaz/{ownerUid}` — oluşturma tek seferlik.
class DeviceProfileRepository {
  DeviceProfileRepository({FirebaseFirestore? firestore})
      : _db = firestore;

  final FirebaseFirestore? _db;

  static const collection = 'ee_cihaz';

  static DeviceProfileRepository? tryCreate() {
    final db = FabrikaFirestore.instance;
    if (db == null) return null;
    return DeviceProfileRepository(firestore: db);
  }

  Future<WorkerProfile?> fetch(String ownerUid) async {
    final db = _db;
    if (db == null) return null;
    try {
      final snap = await db.collection(collection).doc(ownerUid).get();
      return WorkerProfile.fromMap(snap.data(), ownerUid);
    } catch (_) {
      return null;
    }
  }

  Future<void> createIfAbsent({
    required WorkerProfile profile,
    required String platform,
    required String appVersion,
  }) async {
    final db = _db;
    if (db == null) return;
    final ref = db.collection(collection).doc(profile.ownerUid);
    final existing = await ref.get();
    if (existing.exists) return;

    await ref.set({
      ...profile.toFirestoreMap(platform: platform, appVersion: appVersion),
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateIban(String ownerUid, String iban) async {
    final db = _db;
    if (db == null) return;
    await db.collection(collection).doc(ownerUid).update({
      'iban': iban,
      'ibanUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}

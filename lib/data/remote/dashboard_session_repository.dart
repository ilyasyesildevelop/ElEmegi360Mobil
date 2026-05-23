import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'fabrika_firestore.dart';

/// Spark plan — CF olmadan `dashboard_crud_sessions/{uid}` (Firestore kuralları ile).
class DashboardSessionRepository {
  DashboardSessionRepository({FirebaseFirestore? db}) : _db = db;

  final FirebaseFirestore? _db;
  static const collection = 'dashboard_crud_sessions';
  static const ttl = Duration(hours: 12);

  static DashboardSessionRepository? tryCreate() {
    final db = FabrikaFirestore.instance;
    if (db == null) return null;
    return DashboardSessionRepository(db: db);
  }

  Future<bool> issueSession(String uid) async {
    final db = _db;
    if (db == null) return false;
    try {
      final expires = Timestamp.fromDate(DateTime.now().add(ttl));
      await db.collection(collection).doc(uid).set({
        'expiresAt': expires,
        'issuedAt': FieldValue.serverTimestamp(),
        'source': 'mobile',
      });
      return true;
    } on FirebaseException catch (e) {
      debugPrint('dashboard_crud_sessions yazma (${e.code}): ${e.message}');
      return false;
    }
  }

  Future<bool> isSessionActive(String uid) async {
    final db = _db;
    if (db == null) return false;
    try {
      final snap = await db.collection(collection).doc(uid).get();
      if (!snap.exists) return false;
      final exp = snap.data()?['expiresAt'];
      if (exp is! Timestamp) return false;
      return exp.toDate().isAfter(DateTime.now());
    } catch (e) {
      debugPrint('dashboard_crud_sessions okuma: $e');
      return false;
    }
  }

  Future<void> revokeSession(String uid) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.collection(collection).doc(uid).delete();
    } on FirebaseException catch (e) {
      debugPrint('dashboard_crud_sessions silme (${e.code}): ${e.message}');
    }
  }
}

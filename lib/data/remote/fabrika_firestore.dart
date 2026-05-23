import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Suite ortak named DB — Vardiya `FabrikaFirestoreDb` ile aynı.
abstract final class FabrikaFirestore {
  static const databaseId = 'fabrika360';

  static FirebaseFirestore? _instance;

  static FirebaseFirestore? get instance {
    if (Firebase.apps.isEmpty) return null;
    _instance ??= FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: databaseId,
    );
    return _instance;
  }
}

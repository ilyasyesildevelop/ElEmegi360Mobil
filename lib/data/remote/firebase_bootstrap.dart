import 'dart:async';



import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/foundation.dart';



import '../admin_auth_service.dart';

import '../local/profile_store.dart';

import 'fabrika_firestore.dart';



abstract final class FirebaseBootstrap {

  static bool _initialized = false;
  static Future<void>? _initFuture;
  static String? _lastAuthError;

  static Future<String>? _ensureUidInFlight;



  static bool get isReady => _initialized && Firebase.apps.isNotEmpty;

  static String? get lastAuthError => _lastAuthError;



  static Future<void> initialize() async {
    if (_initialized) return;
    final inFlight = _initFuture;
    if (inFlight != null) return inFlight;

    final future = _initializeImpl();
    _initFuture = future;
    try {
      await future;
    } finally {
      if (identical(_initFuture, future)) _initFuture = null;
    }
  }

  /// Firebase henüz başlamadıysa bekler (main veya AppWarmup).
  static Future<void> ensureReady() async {
    if (_initialized) return;
    final inFlight = _initFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }
    await initialize();
  }

  static Future<void> _initializeImpl() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      FabrikaFirestore.instance;
      _initialized = true;
    } catch (e) {
      debugPrint('Firebase init: $e');
      _initialized = false;
    }
  }



  /// Kayıt öncesi oturum + profil uid hizalama.

  static Future<String?> alignProfileWithAuth() async {

    if (!isReady) return null;

    try {

      if (AdminAuthService.instance.isLoggedIn) {

        final workerUid = ProfileStore.instance.ownerUid;

        return workerUid.isNotEmpty ? workerUid : FirebaseAuth.instance.currentUser?.uid;

      }

      final uid = await ensureOwnerUid();

      await ProfileStore.instance.reconcileOwnerUid(uid);

      return uid;

    } catch (e) {

      debugPrint('Firebase alignProfile: $e');

      return null;

    }

  }



  /// Tek anonim oturum — eşzamanlı çağrılar aynı Future'ı paylaşır.

  static Future<String> ensureOwnerUid() {

    final inFlight = _ensureUidInFlight;

    if (inFlight != null) return inFlight;



    final future = _ensureOwnerUidImpl();

    _ensureUidInFlight = future;

    return future.whenComplete(() {

      if (identical(_ensureUidInFlight, future)) {

        _ensureUidInFlight = null;

      }

    });

  }



  static Future<String> _ensureOwnerUidImpl() async {

    _lastAuthError = null;

    if (!isReady) {

      throw StateError('Firebase hazır değil');

    }



    try {

      final auth = FirebaseAuth.instance;

      var user = auth.currentUser ?? await _waitForRestoredUser();



      if (user != null && !user.isAnonymous && !AdminAuthService.instance.isLoggedIn) {

        debugPrint(

          'Firebase: anonim olmayan oturum (${user.email ?? user.uid}) — '

          'işçi modu için anonim oturum tercih edilir',

        );

      }



      user ??= (await auth.signInAnonymously()).user;

      final uid = user?.uid;

      if (uid != null && uid.isNotEmpty) return uid;

      _lastAuthError = 'Anonymous oturum uid alınamadı';

    } catch (e) {

      _lastAuthError = e.toString();

      debugPrint('Firebase Auth: $e');

    }



    throw StateError(

      _lastAuthError ?? 'Firebase oturumu açılamadı (Anonymous Auth açık olmalı)',

    );

  }



  /// Kalıcı oturum geri yüklenene kadar bekle — gereksiz yeni anonymous oluşturmayı önler.

  static Future<User?> _waitForRestoredUser({

    Duration timeout = const Duration(seconds: 10),

  }) async {

    final auth = FirebaseAuth.instance;

    if (auth.currentUser != null) return auth.currentUser;



    try {

      return await auth

          .authStateChanges()

          .firstWhere((user) => user != null)

          .timeout(timeout);

    } on TimeoutException {

      return auth.currentUser;

    }

  }



  /// Firebase yoksa yerel geliştirme uid (emülatör / test).

  static Future<String> ensureOwnerUidOrLocal() async {

    if (!isReady) {

      return 'local-dev-${DateTime.now().millisecondsSinceEpoch}';

    }

    try {

      return await ensureOwnerUid();

    } catch (_) {

      return 'local-dev-${DateTime.now().millisecondsSinceEpoch}';

    }

  }

}



import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';



import '../../core/admin_credentials.dart';

import '../../models/app_user.dart';

import 'fabrika_firestore.dart';



class UsersRepository {

  UsersRepository({FirebaseFirestore? db}) : _db = db;



  final FirebaseFirestore? _db;

  static const collection = 'users';



  static UsersRepository? tryCreate() {

    final db = FabrikaFirestore.instance;

    if (db == null) return UsersRepository();

    return UsersRepository(db: db);

  }



  /// Varsayılan: `eko` / `eko2026` — ayrıca Firestore `users` tablosu.

  Future<AppUser?> verifyAdminCredentials(

    String username,

    String password,

  ) async {

    final login = username.trim();

    final em = login.toLowerCase();

    final pwd = password.trim();



    if (_isDefaultAdmin(login, pwd)) {

      return const AppUser(

        email: 'eko@greenlabs.local',

        rol: 'ADMIN',

        adSoyad: 'Yönetici',

      );

    }



    final db = _db;

    if (db == null) return null;



    try {

      final snap = await db.collection(collection).get();

      for (final doc in snap.docs) {

        final d = doc.data();

        final docPwd = (d['password'] as String?)?.trim() ?? '';

        if (docPwd != pwd) continue;



        if (!_loginMatches(d, em, login)) continue;



        return AppUser(

          email: d['email'] as String? ?? login,

          rol: _roleDisplay((d['role'] as String?) ?? ''),

          adSoyad: d['adSoyad'] as String? ?? '',

          whatsappNo: d['whatsappNo'] as String? ?? '',

        );

      }

    } catch (e) {

      debugPrint('users doğrulama: $e');

    }

    return null;

  }



  static bool _isDefaultAdmin(String username, String password) {

    return username.trim().toLowerCase() == AdminCredentials.defaultUsername &&

        password.trim() == AdminCredentials.defaultPassword;

  }



  static bool _loginMatches(Map<String, dynamic> d, String em, String rawLogin) {

    final docEmail = (d['email'] as String?)?.trim().toLowerCase() ?? '';

    final un = _docUsername(d);

    final local = docEmail.contains('@')

        ? docEmail.substring(0, docEmail.indexOf('@'))

        : docEmail;



    return (docEmail.isNotEmpty && docEmail == em) ||

        (un.isNotEmpty && un == em) ||

        (docEmail.isNotEmpty && local == em) ||

        (rawLogin.isNotEmpty && _normalizeLogin(rawLogin) == _normalizeLogin(local));

  }



  static String _normalizeLogin(String value) =>

      value.trim().toLowerCase().replaceAll(' ', '');



  static String _docUsername(Map<String, dynamic> d) {

    const keys = ['username', 'kullaniciAdi', 'kullaniciadi', 'userName', 'login'];

    for (final k in keys) {

      final v = (d[k] as String?)?.trim().toLowerCase() ?? '';

      if (v.isNotEmpty) return v;

    }

    return '';

  }



  static String _roleDisplay(String raw) {

    final r = raw.trim().isEmpty ? 'Kullanıcı' : raw.trim();

    return r.toUpperCase() == 'ADMIN' ? 'IT' : r;

  }

}


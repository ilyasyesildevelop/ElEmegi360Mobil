import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/admin_credentials.dart';
import 'remote/dashboard_session_repository.dart';
import 'remote/firebase_bootstrap.dart';
import 'remote/users_repository.dart';

/// Dashboard yönetici oturumu — Spark plan (Firestore, CF gerekmez).
class AdminAuthService extends ChangeNotifier {
  AdminAuthService._();
  static final AdminAuthService instance = AdminAuthService._();

  static const defaultUsername = AdminCredentials.defaultUsername;
  static const defaultPassword = AdminCredentials.defaultPassword;

  static const _keyLoggedIn = 'ee_admin_logged_in';
  static const _keyRemember = 'ee_admin_remember_me';
  static const _keyUsername = 'ee_admin_username';
  static const _keyPassword = 'ee_admin_password';
  static const _keyDisplayName = 'ee_admin_display_name';

  final _users = UsersRepository.tryCreate() ?? UsersRepository();
  final _sessions = DashboardSessionRepository.tryCreate();

  bool _loaded = false;
  bool _isLoggedIn = false;
  String _displayName = '';
  String _savedUsername = defaultUsername;
  String _savedPassword = defaultPassword;
  bool _rememberMe = true;
  String? _sessionError;

  bool get isLoaded => _loaded;
  bool get isLoggedIn => _isLoggedIn;
  String? get sessionError => _sessionError;
  String get displayName => _displayName;
  String get savedUsername =>
      _savedUsername.isNotEmpty ? _savedUsername : defaultUsername;
  String get savedPassword =>
      _savedPassword.isNotEmpty ? _savedPassword : defaultPassword;
  bool get rememberMe => _rememberMe;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool(_keyRemember) ?? true;
    _savedUsername = prefs.getString(_keyUsername) ?? defaultUsername;
    _savedPassword = prefs.getString(_keyPassword) ?? defaultPassword;
    _displayName = prefs.getString(_keyDisplayName) ?? '';
    _isLoggedIn = (prefs.getBool(_keyLoggedIn) ?? false) &&
        _rememberMe &&
        _savedUsername.isNotEmpty &&
        _savedPassword.isNotEmpty;
    _loaded = true;
    notifyListeners();
  }

  /// Firestore `dashboard_crud_sessions/{uid}` — ee_kayit tam okuma/yazma.
  Future<bool> ensureDashboardSession() async {
    if (!_isLoggedIn) return false;
    if (_savedPassword.isEmpty) {
      _sessionError = 'Oturum şifresi yok — tekrar giriş yapın';
      notifyListeners();
      return false;
    }

    final admin = await _users.verifyAdminCredentials(
      _savedUsername,
      _savedPassword,
    );
    if (admin == null || !admin.isAdmin) {
      _sessionError = 'Yönetici şifresi geçersiz';
      notifyListeners();
      return false;
    }

    final repo = _sessions;
    if (repo == null) {
      _sessionError = 'Firebase bağlantısı yok';
      notifyListeners();
      return false;
    }

    try {
      final uid = await FirebaseBootstrap.ensureOwnerUid();
      if (await repo.isSessionActive(uid)) {
        _sessionError = null;
        notifyListeners();
        return true;
      }
      final ok = await repo.issueSession(uid);
      if (ok) {
        _sessionError = null;
        notifyListeners();
        return true;
      }
      _sessionError =
          'Panel oturumu Firestore\'a yazılamadı — kurallar güncel mi kontrol edin';
    } catch (e) {
      _sessionError = FirebaseBootstrap.lastAuthError ??
          'Firebase oturumu açılamadı (Anonymous Auth etkin olmalı)';
    }

    notifyListeners();
    return false;
  }

  Future<bool> login(
    String username,
    String password, {
    bool rememberMe = true,
  }) async {
    final user = await _users.verifyAdminCredentials(username, password);
    if (user == null || !user.isAdmin) {
      _isLoggedIn = false;
      _sessionError =
          'Kullanıcı adı veya şifre hatalı ($defaultUsername / $defaultPassword)';
      notifyListeners();
      return false;
    }

    try {
      await FirebaseBootstrap.ensureOwnerUid();
    } catch (e) {
      _sessionError =
          FirebaseBootstrap.lastAuthError ?? 'Firebase oturumu açılamadı';
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    _displayName = user.adSoyad.trim().isNotEmpty
        ? user.adSoyad.trim()
        : (_displayName.isNotEmpty ? _displayName : username.trim());
    _rememberMe = rememberMe;
    _savedUsername =
        username.trim().isEmpty ? defaultUsername : username.trim();
    _savedPassword = password;

    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setBool(_keyRemember, rememberMe);
    await prefs.setString(_keyUsername, _savedUsername);
    await prefs.setString(_keyDisplayName, _displayName);
    if (rememberMe) {
      await prefs.setString(_keyPassword, password);
    } else {
      await prefs.remove(_keyPassword);
    }

    _isLoggedIn = true;
    final sessionOk = await ensureDashboardSession();
    if (!sessionOk) {
      debugPrint('Dashboard oturumu: $_sessionError');
    }
    notifyListeners();
    return sessionOk;
  }

  Future<void> logout() async {
    _sessionError = null;
    final repo = _sessions;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (repo != null && uid != null && uid.isNotEmpty) {
      await repo.revokeSession(uid);
    }

    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    await prefs.setBool(_keyLoggedIn, false);
    if (!_rememberMe) {
      await prefs.remove(_keyPassword);
      _savedPassword = defaultPassword;
    }
    notifyListeners();
  }

  void setDisplayName(String name) {
    _displayName = name.trim();
    SharedPreferences.getInstance().then(
      (p) => p.setString(_keyDisplayName, _displayName),
    );
    notifyListeners();
  }
}

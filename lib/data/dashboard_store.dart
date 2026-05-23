import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/date_keys.dart';
import '../models/work_record.dart';
import 'admin_auth_service.dart';
import 'remote/dashboard_session_repository.dart';
import 'remote/kayit_repository.dart';

/// Dashboard — ay + kişi filtresi, Vardiya360 benzeri.
class DashboardStore extends ChangeNotifier {
  DashboardStore._();
  static final DashboardStore instance = DashboardStore._();

  static const _keyWorker = 'ee_dashboard_worker';

  final _repo = KayitRepository.tryCreate();

  List<WorkRecord> _records = [];
  bool _loading = false;
  bool _hasLoadedOnce = false;
  Future<void>? _refreshInFlight;
  String? _error;
  DateTime _focusMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String? _selectedWorker;

  List<WorkRecord> get records => List.unmodifiable(_monthRecords);
  bool get loading => _loading;
  bool get initialLoading => _loading && !_hasLoadedOnce;
  bool get hasLoadedOnce => _hasLoadedOnce;
  String? get error => _error;
  DateTime get focusMonth => _focusMonth;
  String? get selectedWorker => _selectedWorker;

  String get monthLabel => DateFormat('MMMM yyyy', 'tr_TR').format(_focusMonth);

  String get focusDonemKey => DateKeys.donemKey(_focusMonth);

  List<String> get workerNames {
    final names = _records.map((r) => r.adSoyad).where((n) => n.isNotEmpty).toSet().toList()
      ..sort();
    return names;
  }

  double get filteredTotal => _monthRecords.fold(0.0, (s, r) => s + r.tutar);

  int get filteredCount => _monthRecords.length;

  List<WorkRecord> get _monthRecords {
    var list = _records.where((r) => r.donemKey == focusDonemKey).toList();
    if (_selectedWorker != null && _selectedWorker!.isNotEmpty) {
      list = list.where((r) => r.adSoyad == _selectedWorker).toList();
    }
    list.sort((a, b) => b.tarih.compareTo(a.tarih));
    return list;
  }

  void setSelectedWorker(String? value) {
    _selectedWorker = value;
    _persistWorker();
    notifyListeners();
  }

  void setFocusMonth(DateTime value) {
    _focusMonth = DateTime(value.year, value.month);
    notifyListeners();
  }

  void previousMonth() {
    setFocusMonth(DateTime(_focusMonth.year, _focusMonth.month - 1));
  }

  void nextMonth() {
    setFocusMonth(DateTime(_focusMonth.year, _focusMonth.month + 1));
  }

  Future<void> refresh() async {
    if (_refreshInFlight != null) return _refreshInFlight!;
    _refreshInFlight = _refreshImpl();
    try {
      await _refreshInFlight;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<void> _refreshImpl() async {
    if (!AdminAuthService.instance.isLoggedIn) {
      _records = [];
      _error = null;
      _loading = false;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = AdminAuthService.instance.sessionError;
    notifyListeners();

    final sessionOk = await AdminAuthService.instance.ensureDashboardSession();
    if (!sessionOk) {
      _error = AdminAuthService.instance.sessionError ??
          'Panel oturumu açılamadı. Çıkış yapıp tekrar giriş yapın.';
      _loading = false;
      _hasLoadedOnce = true;
      notifyListeners();
      return;
    }

    if (!await _waitForActiveSession()) {
      _error = 'Panel oturumu hazır değil — birkaç saniye sonra yenileyin.';
      _loading = false;
      _hasLoadedOnce = true;
      notifyListeners();
      return;
    }

    try {
      _records = await (_repo ?? KayitRepository()).fetchAll();
      _error = null;
      await _ensureWorkerSelected();
      if (_records.isEmpty) {
        debugPrint('Dashboard: ee_kayit listesi boş (oturum aktif)');
      }
    } on FirebaseException catch (e) {
      _error = e.code == 'permission-denied'
          ? 'Kayıtlar okunamadı. Oturum süresi dolmuş olabilir; çıkış yapıp tekrar girin.'
          : 'Kayıtlar yüklenemedi (${e.code})';
      _records = [];
    } catch (_) {
      _error = 'Kayıtlar yüklenemedi';
      _records = [];
    } finally {
      _loading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  Future<KayitSaveResult> adminUpdate(WorkRecord record) async {
    final result = await (_repo ?? KayitRepository()).adminUpdate(record);
    final idx = _records.indexWhere((r) => r.kayitId == record.kayitId);
    if (idx >= 0 && result.savedToCloud) {
      _records[idx] = record;
      notifyListeners();
    }
    return result;
  }

  Future<bool> adminDelete(String kayitId) async {
    final ok = await (_repo ?? KayitRepository()).adminDelete(kayitId);
    if (ok) {
      _records.removeWhere((r) => r.kayitId == kayitId);
      await _ensureWorkerSelected();
      notifyListeners();
    }
    return ok;
  }

  Future<void> _ensureWorkerSelected() async {
    final names = workerNames;
    final prefs = await SharedPreferences.getInstance();
    if (names.isEmpty) {
      _selectedWorker = prefs.getString(_keyWorker);
      return;
    }
    if (_selectedWorker != null && names.contains(_selectedWorker)) return;

    final saved = prefs.getString(_keyWorker);
    if (saved != null && names.contains(saved)) {
      _selectedWorker = saved;
      return;
    }
    _selectedWorker = names.first;
    await _persistWorker();
  }

  Future<void> _persistWorker() async {
    final prefs = await SharedPreferences.getInstance();
    final w = _selectedWorker;
    if (w == null || w.isEmpty) {
      await prefs.remove(_keyWorker);
    } else {
      await prefs.setString(_keyWorker, w);
    }
  }

  Future<bool> _waitForActiveSession() async {
    final repo = DashboardSessionRepository.tryCreate();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (repo == null || uid == null) return false;

    for (var attempt = 0; attempt < 3; attempt++) {
      if (await repo.isSessionActive(uid)) return true;
      if (attempt < 2) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }
    return false;
  }
}

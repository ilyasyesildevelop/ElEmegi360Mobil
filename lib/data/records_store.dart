import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/record_status.dart';
import '../models/work_record.dart';
import 'local/profile_store.dart';
import 'local/records_cache.dart';
import 'remote/kayit_repository.dart';

/// Kullanıcının kendi kayıtları — geçmiş ve ücret ekranları.
class RecordsStore extends ChangeNotifier {
  RecordsStore._();
  static final RecordsStore instance = RecordsStore._();

  final _repo = KayitRepository.tryCreate();

  List<WorkRecord> _records = [];
  bool _loading = false;
  String? _error;

  List<WorkRecord> get records => List.unmodifiable(_records);
  bool get loading => _loading;
  String? get error => _error;

  double get pendingTotal => _records
      .where((r) => r.isPayable)
      .fold(0.0, (sum, r) => sum + r.tutar);

  int get pendingRecordCount => _records.where((r) => r.isPayable).length;

  List<PaymentPeriod> get paymentPeriods {
    final byDonem = <String, List<WorkRecord>>{};
    for (final r in _records) {
      byDonem.putIfAbsent(r.donemKey, () => []).add(r);
    }
    final keys = byDonem.keys.toList()..sort((a, b) => b.compareTo(a));
    final monthFmt = DateFormat('MMMM yyyy', 'tr_TR');

    return keys.map((donemKey) {
      final list = byDonem[donemKey]!;
      final allPaid = list.every((r) => r.status == RecordStatus.odendi);
      final amount = list.fold(0.0, (s, r) => s + r.tutar);
      DateTime labelDate;
      try {
        final parts = donemKey.split('-');
        labelDate = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      } catch (_) {
        labelDate = list.first.tarih;
      }
      return PaymentPeriod(
        donemKey: donemKey,
        periodLabel: monthFmt.format(labelDate),
        amount: amount,
        paid: allPaid,
        recordCount: list.length,
      );
    }).toList();
  }

  Future<void> loadFromCache() async {
    final uid = ProfileStore.instance.ownerUid;
    if (uid.isEmpty) return;
    _records = await RecordsCache.load(uid);
    notifyListeners();
  }

  Future<void> refresh() async {
    final uid = ProfileStore.instance.ownerUid;
    if (uid.isEmpty) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await (_repo ?? KayitRepository()).fetchForOwner(uid);
    } catch (_) {
      _error = 'Kayıtlar yüklenemedi';
      _records = await RecordsCache.load(uid);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<KayitSaveResult> save(KayitCreateInput input) async {
    final result = await (_repo ?? KayitRepository()).create(input);
    final record = result.record;
    final idx = _records.indexWhere((r) => r.kayitId == record.kayitId);
    if (idx >= 0) {
      _records[idx] = record;
    } else {
      _records.insert(0, record);
    }
    _records.sort((a, b) => b.tarih.compareTo(a.tarih));
    notifyListeners();
    return result;
  }

  Future<KayitSaveResult> update(KayitUpdateInput input) async {
    final result = await (_repo ?? KayitRepository()).update(input);
    final record = result.record;
    final idx = _records.indexWhere((r) => r.kayitId == record.kayitId);
    if (idx >= 0) {
      _records[idx] = record;
    }
    _records.sort((a, b) => b.tarih.compareTo(a.tarih));
    notifyListeners();
    return result;
  }

  Future<bool> delete(String kayitId) async {
    final ok = await (_repo ?? KayitRepository()).delete(kayitId);
    if (ok) {
      _records.removeWhere((r) => r.kayitId == kayitId);
      notifyListeners();
    }
    return ok;
  }
}

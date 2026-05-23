import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/work_record.dart';

/// Firestore erişilemezken veya önbellek için yerel kayıt listesi.
class RecordsCache {
  static const _keyPrefix = 'ee_kayit_cache_';

  static String _key(String ownerUid) => '$_keyPrefix$ownerUid';

  static Future<List<WorkRecord>> load(String ownerUid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(ownerUid));
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => WorkRecord.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAll(String ownerUid, List<WorkRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_key(ownerUid), encoded);
  }

  static Future<void> upsert(String ownerUid, WorkRecord record) async {
    final all = await load(ownerUid);
    final idx = all.indexWhere((r) => r.kayitId == record.kayitId);
    if (idx >= 0) {
      all[idx] = record;
    } else {
      all.insert(0, record);
    }
    all.sort((a, b) => b.tarih.compareTo(a.tarih));
    await saveAll(ownerUid, all);
  }

  static Future<void> remove(String ownerUid, String kayitId) async {
    final all = await load(ownerUid);
    all.removeWhere((r) => r.kayitId == kayitId);
    await saveAll(ownerUid, all);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/date_keys.dart';
import '../../core/olcu_parser.dart';
import '../../core/pricing_engine.dart';
import '../../core/record_id.dart';
import '../../models/islem_turu.dart';
import '../../models/record_status.dart';
import '../../models/work_record.dart';
import '../../models/worker_profile.dart';
import '../local/profile_store.dart';
import '../local/records_cache.dart';
import 'ee_sheets_service.dart';
import 'fabrika_firestore.dart';
import 'firebase_bootstrap.dart';

class KayitCreateInput {
  const KayitCreateInput({
    required this.urunCinsi,
    required this.islemTuru,
    required this.olcuLabel,
    required this.adet,
    this.tarih,
  });

  final String urunCinsi;
  final String islemTuru;
  final String olcuLabel;
  final int adet;
  final DateTime? tarih;
}

class KayitUpdateInput {
  const KayitUpdateInput({
    required this.kayitId,
    required this.urunCinsi,
    required this.islemTuru,
    required this.olcuLabel,
    required this.adet,
  });

  final String kayitId;
  final String urunCinsi;
  final String islemTuru;
  final String olcuLabel;
  final int adet;
}

class KayitSaveResult {
  const KayitSaveResult({
    required this.record,
    required this.savedToCloud,
    this.cloudError,
  });

  final WorkRecord record;
  final bool savedToCloud;
  final String? cloudError;
}

class KayitRepository {
  KayitRepository({FirebaseFirestore? db}) : _db = db;

  final FirebaseFirestore? _db;
  static const collection = 'ee_kayit';

  static KayitRepository? tryCreate() {
    final db = FabrikaFirestore.instance;
    if (db == null) return KayitRepository();
    return KayitRepository(db: db);
  }

  Future<List<WorkRecord>> fetchForOwner(String ownerUid) async {
    await syncPendingRecords();

    final uid = ProfileStore.instance.ownerUid.isNotEmpty
        ? ProfileStore.instance.ownerUid
        : ownerUid;
    final local = await RecordsCache.load(uid);
    final db = _db;
    if (db == null) return local;

    try {
      final snap = await db
          .collection(collection)
          .where('ownerUid', isEqualTo: uid)
          .get();
      final remote = snap.docs
          .map((d) => WorkRecord.fromMap(d.data(), d.id))
          .whereType<WorkRecord>()
          .toList();

      final merged = _mergeRecords(local, remote);
      await RecordsCache.saveAll(uid, merged);
      return merged;
    } catch (e) {
      debugPrint('ee_kayit okuma: $e');
      return local;
    }
  }

  Future<int> syncPendingRecords() async {
    final db = _db;
    if (db == null) return 0;

    final authUid = await FirebaseBootstrap.alignProfileWithAuth();
    if (authUid == null) return 0;

    final uid = ProfileStore.instance.ownerUid;
    if (uid.isEmpty) return 0;

    final local = await RecordsCache.load(uid);
    var synced = 0;

    for (final record in local) {
      final payload = _withOwnerUid(record, uid);
      try {
        await db
            .collection(collection)
            .doc(payload.kayitId)
            .set(payload.toFirestoreMap());
        synced++;
      } on FirebaseException catch (e) {
        debugPrint('ee_kayit senkron (${payload.kayitId}, ${e.code}): ${e.message}');
        if (e.code == 'permission-denied') break;
      } catch (e) {
        debugPrint('ee_kayit senkron (${payload.kayitId}): $e');
      }
    }

    if (synced > 0) {
      debugPrint("ee_kayit: $synced kayıt Firestore'a gönderildi");
    }
    return synced;
  }

  Future<KayitSaveResult> create(KayitCreateInput input) async {
    final profile = ProfileStore.instance.profile;
    if (profile == null) throw StateError('Profil yok');

    final authUid = await FirebaseBootstrap.alignProfileWithAuth();
    final ownerUid = ProfileStore.instance.ownerUid;
    if (ownerUid.isEmpty) throw StateError('Profil uid yok');

    final record = _buildRecord(
      profile: profile,
      ownerUid: ownerUid,
      input: input,
      kayitId: RecordId.generate(adSoyad: profile.adSoyad, at: input.tarih),
    );

    await RecordsCache.upsert(ownerUid, record);
    return _persist(record, authUid);
  }

  Future<KayitSaveResult> update(KayitUpdateInput input) async {
    final profile = ProfileStore.instance.profile;
    if (profile == null) throw StateError('Profil yok');

    final authUid = await FirebaseBootstrap.alignProfileWithAuth();
    final ownerUid = ProfileStore.instance.ownerUid;
    if (ownerUid.isEmpty) throw StateError('Profil uid yok');

    final cached = await RecordsCache.load(ownerUid);
    final idx = cached.indexWhere((r) => r.kayitId == input.kayitId);
    if (idx < 0) throw StateError('Kayıt bulunamadı');
    final existing = cached[idx];
    if (!existing.canEdit) throw StateError('Bu kayıt düzenlenemez');

    final record = _buildRecord(
      profile: profile,
      ownerUid: ownerUid,
      input: KayitCreateInput(
        urunCinsi: input.urunCinsi,
        islemTuru: input.islemTuru,
        olcuLabel: input.olcuLabel,
        adet: input.adet,
        tarih: existing.tarih,
      ),
      kayitId: existing.kayitId,
      status: existing.status,
    );

    await RecordsCache.upsert(ownerUid, record);
    return _persistUpdate(record, authUid);
  }

  /// Dashboard — tüm işçilerin kayıtları (isDesktopAdmin gerekir).
  Future<List<WorkRecord>> fetchAll() async {
    final db = _db;
    if (db == null) return [];

    try {
      final snap = await db.collection(collection).get();
      final records = <WorkRecord>[];
      var skipped = 0;
      for (final doc in snap.docs) {
        final record = WorkRecord.fromMap(doc.data(), doc.id);
        if (record != null) {
          records.add(record);
        } else {
          skipped++;
        }
      }
      if (skipped > 0) {
        debugPrint('ee_kayit: $skipped kayıt ayrıştırılamadı (${snap.docs.length} doküman)');
      }
      records.sort((a, b) => b.tarih.compareTo(a.tarih));
      return records;
    } on FirebaseException catch (e) {
      debugPrint('ee_kayit tüm liste (${e.code}): ${e.message}');
      rethrow;
    }
  }

  Future<KayitSaveResult> adminUpdate(WorkRecord record) async {
    final db = _db;
    if (db == null) {
      return KayitSaveResult(
        record: record,
        savedToCloud: false,
        cloudError: 'Firebase bağlantısı yok',
      );
    }

    try {
      await db
          .collection(collection)
          .doc(record.kayitId)
          .update(record.toFirestoreUpdateMap());
      _syncToSheets(record);
      return KayitSaveResult(record: record, savedToCloud: true);
    } on FirebaseException catch (e) {
      debugPrint('ee_kayit admin güncelleme (${e.code}): ${e.message}');
      return KayitSaveResult(
        record: record,
        savedToCloud: false,
        cloudError: '${e.code}: ${e.message ?? ''}',
      );
    }
  }

  Future<bool> adminDelete(String kayitId) async {
    final db = _db;
    if (db == null) return false;

    try {
      await db.collection(collection).doc(kayitId).delete();
      _deleteFromSheets(kayitId);
      return true;
    } on FirebaseException catch (e) {
      debugPrint('ee_kayit admin silme (${e.code}): ${e.message}');
      return false;
    }
  }

  Future<bool> delete(String kayitId) async {
    final ownerUid = ProfileStore.instance.ownerUid;
    if (ownerUid.isEmpty) return false;

    final cached = await RecordsCache.load(ownerUid);
    final existing = cached.where((r) => r.kayitId == kayitId).firstOrNull;
    if (existing == null || !existing.canDelete) return false;

    await RecordsCache.remove(ownerUid, kayitId);

    final authUid = await FirebaseBootstrap.alignProfileWithAuth();
    final db = _db;
    if (db == null || authUid == null) return true;

    try {
      await db.collection(collection).doc(kayitId).delete();
      _deleteFromSheets(kayitId);
      return true;
    } on FirebaseException catch (e) {
      debugPrint('ee_kayit silme (${e.code}): ${e.message}');
      return false;
    }
  }

  WorkRecord _buildRecord({
    required WorkerProfile profile,
    required String ownerUid,
    required KayitCreateInput input,
    required String kayitId,
    RecordStatus status = RecordStatus.beklemede,
  }) {
    final tarih = input.tarih ?? DateTime.now();
    final olcu = OlcuParser.parse(input.olcuLabel);
    final tur = IslemTuru.fromIslemAdi(input.islemTuru);
    final pricing = PricingEngine.calculate(
      tur: tur,
      olcu: olcu,
      adet: input.adet,
      islemAdi: input.islemTuru,
    );

    return WorkRecord(
      kayitId: kayitId,
      ownerUid: ownerUid,
      adSoyad: profile.adSoyad,
      workerKey: profile.workerKey,
      tarih: tarih,
      dateKey: DateKeys.dateKey(tarih),
      donemKey: DateKeys.donemKey(tarih),
      islemTuru: tur.firestoreValue,
      urunCinsi: input.urunCinsi,
      olcuLabel: olcu.label,
      en: olcu.en,
      boy: olcu.boy,
      adet: input.adet,
      iscilikTuru: input.islemTuru,
      birimFiyat: pricing.birimFiyat,
      toplamMetre: pricing.toplamMetre,
      tutar: pricing.tutar,
      status: status,
    );
  }

  WorkRecord _withOwnerUid(WorkRecord record, String uid) {
    if (record.ownerUid == uid) return record;
    return WorkRecord(
      kayitId: record.kayitId,
      ownerUid: uid,
      adSoyad: record.adSoyad,
      workerKey: record.workerKey,
      tarih: record.tarih,
      dateKey: record.dateKey,
      donemKey: record.donemKey,
      islemTuru: record.islemTuru,
      urunCinsi: record.urunCinsi,
      olcuLabel: record.olcuLabel,
      en: record.en,
      boy: record.boy,
      adet: record.adet,
      iscilikTuru: record.iscilikTuru,
      birimFiyat: record.birimFiyat,
      toplamMetre: record.toplamMetre,
      tutar: record.tutar,
      status: record.status,
    );
  }

  Future<KayitSaveResult> _persist(WorkRecord record, String? authUid) async {
    final db = _db;
    if (db == null || authUid == null) {
      return KayitSaveResult(
        record: record,
        savedToCloud: false,
        cloudError: authUid == null
            ? (FirebaseBootstrap.lastAuthError ?? 'Firebase oturumu yok')
            : 'Firebase bağlantısı yok',
      );
    }

    try {
      await db.collection(collection).doc(record.kayitId).set(record.toFirestoreMap());
      _syncToSheets(record);
      return KayitSaveResult(record: record, savedToCloud: true);
    } on FirebaseException catch (e) {
      debugPrint('ee_kayit yazma (${e.code}): ${e.message}');
      return KayitSaveResult(
        record: record,
        savedToCloud: false,
        cloudError: '${e.code}: ${e.message ?? ''}',
      );
    }
  }

  Future<KayitSaveResult> _persistUpdate(WorkRecord record, String? authUid) async {
    final db = _db;
    if (db == null || authUid == null) {
      return KayitSaveResult(
        record: record,
        savedToCloud: false,
        cloudError: authUid == null
            ? (FirebaseBootstrap.lastAuthError ?? 'Firebase oturumu yok')
            : 'Firebase bağlantısı yok',
      );
    }

    try {
      await db
          .collection(collection)
          .doc(record.kayitId)
          .update(record.toFirestoreUpdateMap());
      _syncToSheets(record);
      return KayitSaveResult(record: record, savedToCloud: true);
    } on FirebaseException catch (e) {
      debugPrint('ee_kayit güncelleme (${e.code}): ${e.message}');
      return KayitSaveResult(
        record: record,
        savedToCloud: false,
        cloudError: '${e.code}: ${e.message ?? ''}',
      );
    }
  }

  static List<WorkRecord> _mergeRecords(
    List<WorkRecord> local,
    List<WorkRecord> remote,
  ) {
    final byId = <String, WorkRecord>{};
    for (final r in local) {
      byId[r.kayitId] = r;
    }
    for (final r in remote) {
      byId[r.kayitId] = r;
    }
    final merged = byId.values.toList()..sort((a, b) => b.tarih.compareTo(a.tarih));
    return merged;
  }

  void _syncToSheets(WorkRecord record) {
    EeSheetsService.instance.backupSaveRecord(record);
  }

  void _deleteFromSheets(String kayitId) {
    EeSheetsService.instance.backupDeleteRecord(kayitId);
  }
}

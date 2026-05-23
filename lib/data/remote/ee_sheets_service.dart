import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/app_config.dart';
import '../../core/app_meta.dart';
import '../../models/work_record.dart';
import '../../models/worker_profile.dart';

/// Google Sheets **yedek yazma** — Apps Script (`scripts/Code.gs`).
///
/// Birincil veri kaynağı Firestore (+ yerel önbellek). Bu servis yalnızca
/// kayıt / profil değişikliklerinde arka planda Sheets'e yazar; **okuma yok**.
class EeSheetsService {
  EeSheetsService({http.Client? client}) : _client = client ?? http.Client();

  static final EeSheetsService instance = EeSheetsService();

  final http.Client _client;

  static bool get isConfigured => AppConfig.sheetsWebAppUrl.isNotEmpty;

  /// Ana işlemi bekletmeden yedek yazmayı kuyruğa alır.
  static void enqueueBackup(Future<bool> operation) {
    if (!isConfigured) return;
    unawaited(
      operation.catchError((Object e) {
        debugPrint('GS yedek yazma: $e');
        return false;
      }).then((ok) {
        if (!ok) debugPrint('GS yedek yazma başarısız');
      }),
    );
  }

  void backupRegisterPerson(WorkerProfile profile, {String? iban}) {
    enqueueBackup(registerPerson(profile, iban: iban));
  }

  void backupUpdateIban(String ownerUid, String iban) {
    enqueueBackup(updateIban(ownerUid, iban));
  }

  void backupSaveRecord(WorkRecord record) {
    enqueueBackup(saveRecord(record));
  }

  void backupDeleteRecord(String kayitId) {
    enqueueBackup(deleteRecord(kayitId));
  }

  Future<bool> ping() async {
    try {
      final uri = Uri.parse(AppConfig.sheetsWebAppUrl).replace(
        queryParameters: {'action': 'ping'},
      );
      final resp = await _client.get(uri).timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) return false;
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return '${json['status']}'.toLowerCase() == 'success';
    } catch (e) {
      debugPrint('GS ping: $e');
      return false;
    }
  }

  Future<bool> registerPerson(WorkerProfile profile, {String? iban}) async {
    return _post({
      'action': 'registerPerson',
      'owner_uid': profile.ownerUid,
      'ownerUid': profile.ownerUid,
      'worker_key': profile.workerKey,
      'workerKey': profile.workerKey,
      'ad_soyad': profile.adSoyad,
      'adSoyad': profile.adSoyad,
      'iban': iban ?? profile.iban ?? '',
      'platform': 'android',
      'app_version': AppMeta.versionName,
      'appVersion': AppMeta.versionName,
    });
  }

  Future<bool> updateIban(String ownerUid, String iban) async {
    return _post({
      'action': 'updateIban',
      'owner_uid': ownerUid,
      'ownerUid': ownerUid,
      'iban': iban.replaceAll(RegExp(r'\s+'), '').toUpperCase(),
    });
  }

  Future<bool> saveRecord(WorkRecord record) async {
    return _post({
      'action': 'saveRecord',
      'kayit_id': record.kayitId,
      'kayitId': record.kayitId,
      'owner_uid': record.ownerUid,
      'ownerUid': record.ownerUid,
      'worker_key': record.workerKey,
      'workerKey': record.workerKey,
      'ad_soyad': record.adSoyad,
      'adSoyad': record.adSoyad,
      'tarih': record.tarih.toIso8601String(),
      'date_key': record.dateKey,
      'dateKey': record.dateKey,
      'donem_key': record.donemKey,
      'donemKey': record.donemKey,
      'urun_cinsi': record.urunCinsi,
      'urunCinsi': record.urunCinsi,
      'islem_turu': record.islemTuru,
      'islemTuru': record.islemTuru,
      'olcu_label': record.olcuLabel,
      'olcuLabel': record.olcuLabel,
      'en': record.en,
      'boy': record.boy,
      'adet': record.adet,
      'iscilik_turu': record.iscilikTuru,
      'iscilikTuru': record.iscilikTuru,
      'birim_fiyat': record.birimFiyat,
      'birimFiyat': record.birimFiyat,
      if (record.toplamMetre != null) 'toplam_metre': record.toplamMetre,
      if (record.toplamMetre != null) 'toplamMetre': record.toplamMetre,
      'tutar': record.tutar,
      'durum': record.status.firestoreValue,
    });
  }

  Future<bool> deleteRecord(String kayitId) async {
    return _post({
      'action': 'deleteRecord',
      'kayit_id': kayitId,
      'kayitId': kayitId,
    });
  }

  Future<bool> _post(Map<String, dynamic> payload) async {
    if (!isConfigured) return false;
    try {
      final resp = await _postWithRedirects(
        Uri.parse(AppConfig.sheetsWebAppUrl),
        jsonEncode(payload),
      );
      final body = resp.body;
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('GS HTTP ${resp.statusCode}: $body');
        return false;
      }
      final json = jsonDecode(body) as Map<String, dynamic>;
      if ('${json['status']}'.toLowerCase() != 'success') {
        debugPrint('GS hata: ${json['message'] ?? body}');
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('GS istek: $e');
      return false;
    }
  }

  /// Apps Script `/exec` POST → 302; varsayılan istemci gövdeyi kaybeder.
  Future<http.Response> _postWithRedirects(Uri uri, String body) async {
    const headers = {'Content-Type': 'application/json'};
    var response = await _client
        .post(uri, headers: headers, body: body)
        .timeout(const Duration(seconds: 45));

    for (var i = 0; i < 5; i++) {
      if (response.statusCode != 301 &&
          response.statusCode != 302 &&
          response.statusCode != 303 &&
          response.statusCode != 307 &&
          response.statusCode != 308) {
        break;
      }
      final location = response.headers['location'];
      if (location == null || location.isEmpty) break;
      uri = uri.resolve(location);
      response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 45));
    }
    return response;
  }
}

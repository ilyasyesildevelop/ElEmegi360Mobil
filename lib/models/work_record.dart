import 'package:cloud_firestore/cloud_firestore.dart';

import 'record_status.dart';

class WorkRecord {
  const WorkRecord({
    required this.kayitId,
    required this.ownerUid,
    required this.adSoyad,
    required this.workerKey,
    required this.tarih,
    required this.dateKey,
    required this.donemKey,
    required this.islemTuru,
    required this.urunCinsi,
    required this.olcuLabel,
    required this.en,
    required this.boy,
    required this.adet,
    required this.iscilikTuru,
    required this.birimFiyat,
    required this.tutar,
    required this.status,
    this.toplamMetre,
  });

  final String kayitId;
  final String ownerUid;
  final String adSoyad;
  final String workerKey;
  final DateTime tarih;
  final String dateKey;
  final String donemKey;
  final String islemTuru;
  final String urunCinsi;
  final String olcuLabel;
  final double en;
  final double boy;
  final int adet;
  final String iscilikTuru;
  final double birimFiyat;
  final double? toplamMetre;
  final double tutar;
  final RecordStatus status;

  String get id => kayitId;
  DateTime get date => tarih;
  String get productType => urunCinsi;
  String get measure => olcuLabel;
  int get quantity => adet;
  String get workType => iscilikTuru;
  double get totalAmount => tutar;

  bool get isPayable =>
      status == RecordStatus.beklemede || status == RecordStatus.onaylandi;

  bool get canEdit => status == RecordStatus.beklemede;

  bool get canDelete => status == RecordStatus.beklemede;

  Map<String, dynamic> toFirestoreMap() => {
        'kayitId': kayitId,
        'ownerUid': ownerUid,
        'adSoyad': adSoyad,
        'workerKey': workerKey,
        'tarih': Timestamp.fromDate(tarih),
        'dateKey': dateKey,
        'donemKey': donemKey,
        'islemTuru': islemTuru,
        'urunCinsi': urunCinsi,
        'olcuLabel': olcuLabel,
        'en': en,
        'boy': boy,
        'adet': adet,
        'iscilikTuru': iscilikTuru,
        'birimFiyat': birimFiyat,
        if (toplamMetre != null) 'toplamMetre': toplamMetre,
        'tutar': tutar,
        'durum': status.firestoreValue,
        'syncedToSheets': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  /// Güncelleme — createdAt dokunulmaz.
  Map<String, dynamic> toFirestoreUpdateMap() => {
        'kayitId': kayitId,
        'ownerUid': ownerUid,
        'adSoyad': adSoyad,
        'workerKey': workerKey,
        'tarih': Timestamp.fromDate(tarih),
        'dateKey': dateKey,
        'donemKey': donemKey,
        'islemTuru': islemTuru,
        'urunCinsi': urunCinsi,
        'olcuLabel': olcuLabel,
        'en': en,
        'boy': boy,
        'adet': adet,
        'iscilikTuru': iscilikTuru,
        'birimFiyat': birimFiyat,
        if (toplamMetre != null) 'toplamMetre': toplamMetre,
        'tutar': tutar,
        'durum': status.firestoreValue,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  static WorkRecord? fromMap(Map<String, dynamic> data, String docId) {
    final kayitId = (data['kayitId'] as String?) ?? docId;
    final ownerUid = data['ownerUid'] as String? ?? '';
    final tarih = _readDate(data['tarih']);
    if (tarih == null) return null;

    return WorkRecord(
      kayitId: kayitId,
      ownerUid: ownerUid,
      adSoyad: data['adSoyad'] as String? ?? '',
      workerKey: data['workerKey'] as String? ?? '',
      tarih: tarih,
      dateKey: data['dateKey'] as String? ?? '',
      donemKey: data['donemKey'] as String? ?? '',
      islemTuru: data['islemTuru'] as String? ?? '',
      urunCinsi: data['urunCinsi'] as String? ?? '',
      olcuLabel: data['olcuLabel'] as String? ?? '',
      en: (data['en'] as num?)?.toDouble() ?? 0,
      boy: (data['boy'] as num?)?.toDouble() ?? 0,
      adet: (data['adet'] as num?)?.toInt() ?? 0,
      iscilikTuru: data['iscilikTuru'] as String? ?? '',
      birimFiyat: (data['birimFiyat'] as num?)?.toDouble() ?? 0,
      toplamMetre: (data['toplamMetre'] as num?)?.toDouble(),
      tutar: (data['tutar'] as num?)?.toDouble() ?? 0,
      status: RecordStatus.fromFirestore(data['durum'] as String?),
    );
  }

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Map<String, dynamic> toJson() => {
        'kayitId': kayitId,
        'ownerUid': ownerUid,
        'adSoyad': adSoyad,
        'workerKey': workerKey,
        'tarih': tarih.toIso8601String(),
        'dateKey': dateKey,
        'donemKey': donemKey,
        'islemTuru': islemTuru,
        'urunCinsi': urunCinsi,
        'olcuLabel': olcuLabel,
        'en': en,
        'boy': boy,
        'adet': adet,
        'iscilikTuru': iscilikTuru,
        'birimFiyat': birimFiyat,
        'toplamMetre': toplamMetre,
        'tutar': tutar,
        'durum': status.firestoreValue,
      };

  factory WorkRecord.fromJson(Map<String, dynamic> json) {
    return WorkRecord(
      kayitId: json['kayitId'] as String,
      ownerUid: json['ownerUid'] as String,
      adSoyad: json['adSoyad'] as String,
      workerKey: json['workerKey'] as String,
      tarih: DateTime.parse(json['tarih'] as String),
      dateKey: json['dateKey'] as String,
      donemKey: json['donemKey'] as String,
      islemTuru: json['islemTuru'] as String,
      urunCinsi: json['urunCinsi'] as String,
      olcuLabel: json['olcuLabel'] as String,
      en: (json['en'] as num).toDouble(),
      boy: (json['boy'] as num).toDouble(),
      adet: json['adet'] as int,
      iscilikTuru: json['iscilikTuru'] as String,
      birimFiyat: (json['birimFiyat'] as num).toDouble(),
      toplamMetre: (json['toplamMetre'] as num?)?.toDouble(),
      tutar: (json['tutar'] as num).toDouble(),
      status: RecordStatus.fromFirestore(json['durum'] as String?),
    );
  }
}

class PaymentPeriod {
  const PaymentPeriod({
    required this.donemKey,
    required this.periodLabel,
    required this.amount,
    required this.paid,
    required this.recordCount,
  });

  final String donemKey;
  final String periodLabel;
  final double amount;
  final bool paid;
  final int recordCount;
}

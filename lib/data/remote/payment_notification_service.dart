import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'fabrika_firestore.dart';

/// Masaüstü ödeme onayı sonrası `ee_bildirim` dinleyicisi.
class PaymentNotificationService {
  PaymentNotificationService._();
  static final PaymentNotificationService instance = PaymentNotificationService._();

  static const defaultMessage = 'El emeğinizin ücreti hesabınıza yatırıldı';

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  final _shownBatchIds = <String>{};
  bool _primed = false;

  void Function(String message, double? tutar)? onPaymentDeposited;

  void start(String ownerUid) {
    stop();
    _primed = false;
    if (ownerUid.isEmpty) return;

    final db = FabrikaFirestore.instance;
    if (db == null) return;

    _sub = db
        .collection('ee_bildirim')
        .where('ownerUid', isEqualTo: ownerUid)
        .where('delivered', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .listen(_onSnapshot, onError: (e) => debugPrint('ee_bildirim: $e'));
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  Future<void> _onSnapshot(QuerySnapshot<Map<String, dynamic>> snap) async {
    final db = FabrikaFirestore.instance;
    if (db == null) return;

    // İlk yüklemede eski ödenmiş bildirimleri gösterme (yalnızca yeni ödemeler).
    if (!_primed) {
      _primed = true;
      for (final doc in snap.docs) {
        final data = doc.data();
        final batchId = data['odemeBatchId'] as String? ?? doc.id;
        _shownBatchIds.add(batchId);
      }
      return;
    }

    for (final change in snap.docChanges) {
      if (change.type != DocumentChangeType.added) continue;
      final data = change.doc.data();
      if (data == null) continue;
      if (data['delivered'] == true) continue;

      final batchId = data['odemeBatchId'] as String? ?? change.doc.id;
      if (_shownBatchIds.contains(batchId)) continue;
      _shownBatchIds.add(batchId);

      final message = (data['message'] as String?)?.trim();
      final tutar = (data['toplamTutar'] as num?)?.toDouble();
      onPaymentDeposited?.call(
        message?.isNotEmpty == true ? message! : defaultMessage,
        tutar,
      );

      await change.doc.reference.update({
        'delivered': true,
        'deliveredAt': FieldValue.serverTimestamp(),
      });
    }
  }
}

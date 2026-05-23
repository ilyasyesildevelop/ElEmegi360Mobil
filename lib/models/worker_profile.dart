class WorkerProfile {
  const WorkerProfile({
    required this.ownerUid,
    required this.adSoyad,
    required this.workerKey,
    required this.locked,
    this.registeredAt,
    this.iban,
  });

  final String ownerUid;
  final String adSoyad;
  final String workerKey;
  final bool locked;
  final DateTime? registeredAt;
  final String? iban;

  WorkerProfile copyWith({String? iban, String? ownerUid}) => WorkerProfile(
        ownerUid: ownerUid ?? this.ownerUid,
        adSoyad: adSoyad,
        workerKey: workerKey,
        locked: locked,
        registeredAt: registeredAt,
        iban: iban ?? this.iban,
      );

  Map<String, dynamic> toFirestoreMap({
    required String platform,
    required String appVersion,
  }) =>
      {
        'ownerUid': ownerUid,
        'adSoyad': adSoyad,
        'workerKey': workerKey,
        'locked': locked,
        'platform': platform,
        'appVersion': appVersion,
        if (iban != null && iban!.isNotEmpty) 'iban': iban,
      };

  static WorkerProfile? fromMap(Map<String, dynamic>? data, String uid) {
    if (data == null) return null;
    final name = (data['adSoyad'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;
    return WorkerProfile(
      ownerUid: uid,
      adSoyad: name,
      workerKey: (data['workerKey'] as String?) ?? '',
      locked: data['locked'] == true,
      iban: data['iban'] as String?,
    );
  }
}

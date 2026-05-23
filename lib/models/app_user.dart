/// Firestore `users` — yönetici oturum doğrulama.
class AppUser {
  const AppUser({
    required this.email,
    required this.rol,
    required this.adSoyad,
    this.whatsappNo = '',
  });

  final String email;
  final String rol;
  final String adSoyad;
  final String whatsappNo;

  bool get isAdmin {
    final upper = rol.toUpperCase();
    return upper == 'YÖNETİCİ' ||
        upper == 'IT' ||
        upper == 'ADMIN' ||
        upper == 'DIRECTOR' ||
        upper == 'DEPARTMENT MANAGER' ||
        upper.contains('MANAGER') ||
        upper == 'DEVELOPER' ||
        upper == 'IT MANAGER' ||
        upper == 'IT YÖNETİCİSİ' ||
        upper == 'DEPARTMAN YÖNETİCİSİ';
  }
}

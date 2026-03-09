class AccessControlService {
  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  /// Fungsi Gatekeeper untuk memvalidasi hak akses
  static bool canPerform(String role, String action, {bool isOwner = false}) {
    // ATURAN TASK 5 (Kedaulatan Data): 
    // Hak Edit dan Delete HANYA dimiliki oleh Pembuat Asli (Owner),
    // meskipun pengguna tersebut adalah 'Ketua'.
    if (action == actionUpdate || action == actionDelete) {
      return isOwner;
    }

    // Untuk membuat (Create) dan melihat (Read), semua role diizinkan
    if (action == actionCreate || action == actionRead) {
      return true;
    }

    return false;
  }
}
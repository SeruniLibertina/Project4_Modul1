import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController with ChangeNotifier {
  // --- TAMBAHAN MODUL 5: Simulasi Database Multi-User ---
  final List<Map<String, dynamic>> _mockUsers = [
    {
      'username': 'Seruni',
      'password': '123',
      'uid': 'user_001',
      'role': 'ketua',
      'teamId': 'team_A',
    },
    {
      'username': 'anggota1',
      'password': '123',
      'uid': 'user_002',
      'role': 'anggota',
      'teamId': 'team_A', 
    },
    {
      'username': 'anggota2',
      'password': '123',
      'uid': 'user_003',
      'role': 'anggota',
      'teamId': 'team_B', 
    }
  ];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Variabel untuk menyimpan data lengkap user yang sedang login
  Map<String, dynamic>? currentUserData;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulasi loading 1 detik
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Cari user yang cocok di "database" simulasi
      final user = _mockUsers.firstWhere(
        (u) => u['username'] == username && u['password'] == password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      // Simpan semua atribut Modul 5 ke SharedPreferences
      await prefs.setString('username', user['username']);
      await prefs.setString('uid', user['uid']);
      await prefs.setString('role', user['role']);
      await prefs.setString('teamId', user['teamId']);

      currentUserData = user; // Simpan di memory untuk di-passing ke LogView

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Masuk ke sini jika firstWhere tidak menemukan kecocokan (user/pass salah)
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    currentUserData = null;
    notifyListeners();
  }
}
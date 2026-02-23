import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  // ValueNotifier berfungsi sebagai 'Speaker' yang akan mengabari UI jika ada perubahan data
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  static const String _storageKey = 'user_logs_data';

  LogController() {
    // Saat Controller dipanggil, langsung muat data dari penyimpanan
    loadFromDisk();
  }

  // Fungsi Create (Tambah Data)
  void addLog(String title, String desc) {
    final newLog = LogModel(
      title: title, 
      description: desc, 
      date: DateTime.now().toString()
    );
    // Mengganti daftar lama dengan daftar baru yang ditambah newLog
    logsNotifier.value = [...logsNotifier.value, newLog];
    saveToDisk(); // Simpan permanen
  }

  // Fungsi Update (Edit Data)
  void updateLog(int index, String title, String desc) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs[index] = LogModel(
      title: title, 
      description: desc, 
      date: currentLogs[index].date // Pertahankan tanggal asli
    );
    logsNotifier.value = currentLogs;
    saveToDisk(); // Simpan permanen
  }

  // Fungsi Delete (Hapus Data)
  void removeLog(int index) {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(index);
    logsNotifier.value = currentLogs;
    saveToDisk(); // Simpan permanen
  }

  // Konversi List of Object -> JSON String -> Simpan ke SharedPreferences
  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(logsNotifier.value.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  // Ambil JSON String -> List of Map -> List of Object LogModel
  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    
    if (data != null) {
      final List decoded = jsonDecode(data);
      logsNotifier.value = decoded.map((e) => LogModel.fromMap(e)).toList();
    }
  }
}
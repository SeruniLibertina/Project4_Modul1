import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier<List<LogModel>>([]);

  List<LogModel> get logs => logsNotifier.value;

  // Constructor
  LogController() {
    // Kita tidak langsung memanggil loadFromDisk() di sini.
    // Pemanggilan akan dilakukan dari UI (LogView) agar bisa memunculkan animasi loading.
  }

  // MENGAMBIL DATA DARI CLOUD
  Future<void> loadFromDisk() async {
    try {
      final cloudData = await MongoService().getLogs();
      logsNotifier.value = cloudData;
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal load data dari Cloud - $e", level: 1);
    }
  }

  // MENAMBAH DATA KE CLOUD
  Future<void> addLog(String title, String desc, String category) async {
    final newLog = LogModel(
      id: ObjectId(), // Berikan ID unik otomatis
      title: title,
      description: desc,
      date: DateTime.now().toIso8601String(),
      category: category,
    );

    try {
      // 1. Simpan ke MongoDB Atlas (Tunggu konfirmasi Cloud)
      await MongoService().insertLog(newLog);

      // 2. Jika sukses, baru update tampilan di layar (Lokal)
      final currentLogs = List<LogModel>.from(logsNotifier.value);
      currentLogs.add(newLog);
      logsNotifier.value = currentLogs;

      await LogHelper.writeLog("SUCCESS: Tambah data '${newLog.title}'", source: "log_controller.dart");
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Add - $e", level: 1);
    }
  }

  // MENGUBAH DATA DI CLOUD
  Future<void> updateLog(int index, String newTitle, String newDesc, String newCategory) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id, // ID HARUS TETAP SAMA agar Cloud tahu dokumen mana yang diubah
      title: newTitle,
      description: newDesc,
      date: DateTime.now().toIso8601String(),
      category: newCategory,
    );

    try {
      await MongoService().updateLog(updatedLog);
      
      currentLogs[index] = updatedLog;
      logsNotifier.value = currentLogs;
      
      await LogHelper.writeLog("SUCCESS: Update '${oldLog.title}' Berhasil", source: "log_controller.dart");
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Update - $e", level: 1);
    }
  }

  // MENGHAPUS DATA DARI CLOUD
  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id == null) throw Exception("ID Log tidak ditemukan.");
      
      await MongoService().deleteLog(targetLog.id!);
      
      currentLogs.removeAt(index);
      logsNotifier.value = currentLogs;
      
      await LogHelper.writeLog("SUCCESS: Hapus '${targetLog.title}' Berhasil", source: "log_controller.dart");
    } catch (e) {
      await LogHelper.writeLog("ERROR: Gagal sinkronisasi Hapus - $e", level: 1);
    }
  }
}
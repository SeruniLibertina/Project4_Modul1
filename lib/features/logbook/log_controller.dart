import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;
import 'models/log_model.dart';
import '../../services/mongo_service.dart';
import '../../helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  
  // Mengakses box Hive yang sudah dibuka di main.dart
  final _myBox = Hive.box<LogModel>('offline_logs');

  /// 1. LOAD DATA (Offline-First Strategy)
  Future<void> loadLogs(String teamId) async {
    // Langkah 1: Ambil data dari Hive (Sangat Cepat/Instan)
    logsNotifier.value = _myBox.values.toList();

    // Langkah 2: Sync dari Cloud (Background Process)
    try {
      final cloudData = await MongoService().getLogs(teamId);

      // Update Hive dengan data terbaru dari Cloud agar sinkron
      await _myBox.clear();
      await _myBox.addAll(cloudData);

      // Update UI dengan data Cloud
      logsNotifier.value = cloudData;

      await LogHelper.writeLog("SYNC: Data berhasil diperbarui dari Atlas", level: 2);
    } catch (e) {
      await LogHelper.writeLog("OFFLINE: Menggunakan data cache lokal", level: 2);
    }
  }

  /// 2. ADD DATA (Instant Local + Background Cloud)
  Future<void> addLog(String title, String desc, String authorId, String teamId) async {
    final newLog = LogModel(
      id: ObjectId().oid, // Menggunakan .oid (String) untuk Hive
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      authorId: authorId,
      teamId: teamId,
    );

    // ACTION 1: Simpan ke Hive (Instan)
    await _myBox.add(newLog);
    logsNotifier.value = _myBox.values.toList(); // Refresh UI langsung

    // ACTION 2: Kirim ke MongoDB Atlas (Background)
    try {
      await MongoService().insertLog(newLog);
      await LogHelper.writeLog("SUCCESS: Data tersinkron ke Cloud", source: "log_controller.dart");
    } catch (e) {
      await LogHelper.writeLog("WARNING: Data tersimpan lokal, akan sinkron saat online", level: 1);
    }
  }

  /// 3. UPDATE DATA
  Future<void> updateLog(int index, String title, String desc) async {
    final logToUpdate = logsNotifier.value[index];
    final updatedLog = LogModel(
      id: logToUpdate.id,
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      authorId: logToUpdate.authorId,
      teamId: logToUpdate.teamId,
      isPublic: logToUpdate.isPublic,
    );

    // ACTION 1: Update Hive
    await _myBox.putAt(index, updatedLog);
    logsNotifier.value = _myBox.values.toList();

    // ACTION 2: Update Cloud
    try {
      await MongoService().updateLog(updatedLog);
    } catch (e) {
      await LogHelper.writeLog("WARNING: Update tersimpan lokal", level: 1);
    }
  }

  /// 4. REMOVE DATA
  Future<void> removeLog(int index) async {
    final logToRemove = logsNotifier.value[index];
    
    // ACTION 1: Hapus dari Hive
    await _myBox.deleteAt(index);
    logsNotifier.value = _myBox.values.toList();

    // ACTION 2: Hapus dari Cloud
    try {
      if (logToRemove.id != null) {
        await MongoService().deleteLog(logToRemove.id!);
      }
    } catch (e) {
      await LogHelper.writeLog("WARNING: Hapus secara offline", level: 1);
    }
  }
}
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

  /// 1. LOAD DATA (Offline-First + Privacy & Team Filter)
  Future<void> loadLogs(String teamId, String currentUserId) async {
    // Langkah 1: Ambil data dari Hive (Offline Cache) khusus untuk tim ini
    final localLogs = _myBox.values.where((log) => log.teamId == teamId).toList();
    
    // UI Offline: Tampilkan HANYA milik sendiri ATAU yang berstatus public
    logsNotifier.value = localLogs.where((log) => 
      log.authorId == currentUserId || log.isPublic == true
    ).toList();

    // Langkah 2: Sync dari Cloud (Background Process)
    try {
      final cloudData = await MongoService().getLogs(teamId);
      
      // VISIBILITY FILTER: Saring sesuai kepemilikan dan status publik
      final visibleLogs = cloudData.where((log) {
        return log.authorId == currentUserId || log.isPublic == true;
      }).toList();

      // Mencegah catatan offline yang belum tersinkronisasi ikut terhapus
      final cloudLogIds = cloudData.map((e) => e.id).toSet();
      final pendingOfflineLogs = localLogs.where((log) => !cloudLogIds.contains(log.id)).toList();

      // Saring juga catatan offline pending agar sesuai aturan privasi sebelum tampil di UI
      final visiblePendingLogs = pendingOfflineLogs.where((log) => 
        log.authorId == currentUserId || log.isPublic == true
      ).toList();

      // Gabungkan data cloud dan pending offline yang SAH/BOLEH dilihat oleh user ini
      final mergedVisibleLogs = [...visibleLogs, ...visiblePendingLogs];

      // Update Hive Cache: Simpan SEMUA data (termasuk private milik orang lain) 
      // agar jika orang tersebut login di HP yang sama saat offline, datanya tetap ada.
      await _myBox.clear();
      await _myBox.addAll([...cloudData, ...pendingOfflineLogs]);

      // Update UI HANYA dengan data yang diizinkan (mergedVisibleLogs)
      logsNotifier.value = mergedVisibleLogs;

      await LogHelper.writeLog("SYNC: Data berhasil diperbarui dari Atlas", level: 2);
      
      // (Opsional) Upload otomatis catatan offline ke cloud secara diam-diam
      for (var pendingLog in pendingOfflineLogs) {
        MongoService().insertLog(pendingLog).catchError((_) {});
      }

    } catch (e) {
      // Jika internet mati (Offline Mode), gunakan cache lokal yang sudah difilter
      logsNotifier.value = localLogs.where((log) => 
        log.authorId == currentUserId || log.isPublic == true
      ).toList();
      await LogHelper.writeLog("OFFLINE: Menggunakan data cache lokal", level: 2);
    }
  }

  /// 2. ADD DATA (Instant Local + Background Cloud)
  Future<void> addLog(String title, String desc, String authorId, String teamId, String category, {bool isPublic = true}) async {
    final newLog = LogModel(
      id: ObjectId().oid, // Generate ID unik untuk Hive/MongoDB
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      authorId: authorId,
      teamId: teamId,
      category: category, 
      isPublic: isPublic, // Menyimpan status privasi
    );

    // ACTION 1: Simpan ke Hive (Instan)
    await _myBox.add(newLog);
    
    // Refresh UI langsung (Saring untuk tim dan visibilitas saat ini)
    final localLogs = _myBox.values.where((log) => log.teamId == teamId).toList();
    logsNotifier.value = localLogs.where((log) => 
      log.authorId == authorId || log.isPublic == true
    ).toList();

    // ACTION 2: Kirim ke MongoDB Atlas (Background)
    try {
      await MongoService().insertLog(newLog);
      await LogHelper.writeLog("SUCCESS: Data tersinkron ke Cloud", source: "log_controller.dart");
    } catch (e) {
      await LogHelper.writeLog("WARNING: Data tersimpan lokal, akan sinkron saat online", level: 1);
    }
  }

  /// 3. UPDATE DATA (Dengan Proteksi Index Asli)
  Future<void> updateLog(int uiIndex, String title, String desc, String category, {bool? isPublic}) async {
    // Ambil log dari UI list berdasarkan index yang diklik
    final logToUpdate = logsNotifier.value[uiIndex];
    
    final updatedLog = LogModel(
      id: logToUpdate.id,
      title: title,
      description: desc,
      date: DateTime.now().toString(), // Update waktu edit
      authorId: logToUpdate.authorId,
      teamId: logToUpdate.teamId,
      isPublic: isPublic ?? logToUpdate.isPublic,
      category: category, 
    );

    // ACTION 1: Cari index ASLI di dalam Hive berdasarkan ID log
    // Ini krusial karena index di UI list bisa berbeda dengan index di Hive secara keseluruhan.
    final hiveIndex = _myBox.values.toList().indexWhere((log) => log.id == updatedLog.id);
    
    if (hiveIndex != -1) {
      await _myBox.putAt(hiveIndex, updatedLog);
    }
    
    // Update UI
    final localLogs = _myBox.values.where((log) => log.teamId == updatedLog.teamId).toList();
    logsNotifier.value = localLogs.where((log) => 
      log.authorId == updatedLog.authorId || log.isPublic == true
    ).toList();

    // ACTION 2: Update Cloud
    try {
      await MongoService().updateLog(updatedLog);
    } catch (e) {
      await LogHelper.writeLog("WARNING: Update tersimpan lokal", level: 1);
    }
  }

  /// 4. REMOVE DATA (Dengan Proteksi Index Asli)
  Future<void> removeLog(int uiIndex) async {
    // Ambil log dari UI list yang ingin dihapus
    final logToRemove = logsNotifier.value[uiIndex];
    final currentTeamId = logToRemove.teamId;
    final currentAuthorId = logToRemove.authorId;
    
    // ACTION 1: Hapus dari Hive menggunakan ID log (bukan index UI)
    final hiveIndex = _myBox.values.toList().indexWhere((log) => log.id == logToRemove.id);
    if (hiveIndex != -1) {
      await _myBox.deleteAt(hiveIndex);
    }

    // Update UI
    final localLogs = _myBox.values.where((log) => log.teamId == currentTeamId).toList();
    logsNotifier.value = localLogs.where((log) => 
      log.authorId == currentAuthorId || log.isPublic == true
    ).toList();

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
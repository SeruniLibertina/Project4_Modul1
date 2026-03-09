import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../features/logbook/models/log_model.dart';
import '../helpers/log_helper.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  Db? _db;
  DbCollection? _collection;
  final String _source = "MongoService";

  factory MongoService() {
    return _instance;
  }

  MongoService._internal();

  Future<void> connect() async {
    if (_db != null && _db!.state == State.OPEN) return;

    try {
      String mongoUrl = dotenv.env['MONGO_URI'] ?? '';
      String collectionName = dotenv.env['COLLECTION_NAME'] ?? 'logs';

      if (mongoUrl.isEmpty) {
        throw Exception("MONGO_URI tidak ditemukan di file .env");
      }

      _db = await Db.create(mongoUrl);
      await _db!.open();
      _collection = _db!.collection(collectionName);
      
      await LogHelper.writeLog("Koneksi MongoDB Berhasil", source: _source, level: 2);
    } catch (e) {
      await LogHelper.writeLog("Koneksi MongoDB Gagal: $e", source: _source, level: 1);
      rethrow;
    }
  }

  Future<DbCollection> _getSafeCollection() async {
    if (_db == null || _db!.state != State.OPEN || _collection == null) {
      await connect();
    }
    return _collection!;
  }

  /// READ: Mengambil data dari Cloud berdasarkan teamId
  Future<List<LogModel>> getLogs(String teamId) async {
    try {
      final collection = await _getSafeCollection();
      await LogHelper.writeLog("INFO: Fetching data for Team: $teamId", source: _source, level: 3);

      final List<Map<String, dynamic>> data = await collection
          .find(where.eq('teamId', teamId)) // Filter hanya log kelompok ini
          .toList();
      
      return data.map((json) => LogModel.fromMap(json)).toList();
    } catch (e) {
      await LogHelper.writeLog("ERROR: Fetch Failed - $e", source: _source, level: 1);
      return [];
    }
  }

  /// CREATE: Menambah log ke Cloud
  Future<void> insertLog(LogModel log) async {
    try {
      final collection = await _getSafeCollection();
      await collection.insert(log.toMap());
    } catch (e) {
      await LogHelper.writeLog("ERROR: Insert Failed - $e", source: _source, level: 1);
      rethrow;
    }
  }

  /// UPDATE: Mengedit log di Cloud
  Future<void> updateLog(LogModel log) async {
    if (log.id == null) return;
    try {
      final collection = await _getSafeCollection();
      await collection.updateOne(
        where.id(ObjectId.fromHexString(log.id!)),
        modify
            .set('title', log.title)
            .set('description', log.description)
            .set('date', log.date)
            .set('isPublic', log.isPublic),
      );
    } catch (e) {
      await LogHelper.writeLog("ERROR: Update Failed - $e", source: _source, level: 1);
      rethrow;
    }
  }

  /// DELETE: Menghapus log di Cloud
  Future<void> deleteLog(String id) async {
    try {
      final collection = await _getSafeCollection();
      await collection.remove(where.id(ObjectId.fromHexString(id)));
    } catch (e) {
      await LogHelper.writeLog("ERROR: Delete Failed - $e", source: _source, level: 1);
      rethrow;
    }
  }
}
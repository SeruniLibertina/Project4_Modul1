import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  final ObjectId? id; // Wajib ada untuk penanda unik di MongoDB
  final String title;
  final String date;
  final String description;
  final String category;

  LogModel({
    this.id, // Tambahkan di constructor
    required this.title,
    required this.date,
    required this.description,
    this.category = 'Umum',
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      id: map['_id'] as ObjectId?, // Ambil _id dari Cloud (BSON)
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Umum',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(), // Buat ObjectId otomatis jika mengirim data baru
      'title': title,
      'date': date,
      'description': description,
      'category': category,
    };
  }
}
class LogModel {
  final String title;
  final String date;
  final String description;

  LogModel({
    required this.title,
    required this.date,
    required this.description,
  });

  // Task 4 (HOTS): Mengubah data dari format JSON (Map) menjadi Objek LogModel
  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
    );
  }

  // Task 4 (HOTS): Mengubah Objek LogModel menjadi format JSON (Map) untuk disimpan
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'description': description,
    };
  }
}
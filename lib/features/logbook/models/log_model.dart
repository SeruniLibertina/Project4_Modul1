class LogModel {
  final String title;
  final String date;
  final String description;
  final String category; // Tambahan properti kategori

  LogModel({
    required this.title,
    required this.date,
    required this.description,
    this.category = 'Umum', // Nilai default kategori
  });

  factory LogModel.fromMap(Map<String, dynamic> map) {
    return LogModel(
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Umum', // Ambil data kategori dari map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'description': description,
      'category': category, // Masukkan kategori ke format JSON
    };
  }
}
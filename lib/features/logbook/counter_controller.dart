import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _value = 0; // nilai counter
  int _step = 1; // jumlah kenaikan/penurunan
  final List<String> _history = [];

  int get value => _value;
  int get step => _step;
  List<String> get history => _history;

  // ================= INCREMENT =================
  void increment() {
    _value += _step;
    _addHistory("Tambah $_step → $_value");
  }

  // ================= DECREMENT =================
  void decrement() {
    _value -= _step;
    _addHistory("Kurang $_step → $_value");
  }

  // ================= SET STEP =================
  void setStep(int newStep) {
    _step = newStep;
  }

  // ================= SET VALUE (UNTUK LOAD DATA) =================
  void setValue(int newValue) {
    _value = newValue;
  }

  // ================= RESET =================
  void reset() {
    _value = 0;
    _history.clear();
  }

  // ================= HISTORY LIMIT 5 =================
  void _addHistory(String text) {
    _history.add(text);

    // Membatasi maksimal 5 riwayat terakhir
    if (_history.length > 5) {
      _history.removeAt(0);
    }
  }

  // =====================================================
  // ================= SHARED PREFERENCES =================
  // =====================================================

  // SAVE angka terakhir
  Future<void> saveLastValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_counter', _value);
  }

  // LOAD angka terakhir
  Future<void> loadLastValue() async {
    final prefs = await SharedPreferences.getInstance();
    _value = prefs.getInt('last_counter') ?? 0;
  }
}

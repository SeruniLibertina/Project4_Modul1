class CounterController {
  int _value = 0; // nilai counter
  int _step = 1; // jumlah kenaikan/penurunan
  final List<String> _history = [];

  int get value => _value;
  int get step => _step;
  List<String> get history => _history;

  void increment() {
    _value += _step;
    _addHistory("Tambah $_step → $_value");
  }

  void decrement() {
    _value -= _step;
    _addHistory("Kurang $_step → $_value");
  }

  void setStep(int newStep) {
    _step = newStep;
  }

  void reset() {
    _value = 0;
    _history.clear();
  }

  // Method private untuk mengatur penambahan history
  void _addHistory(String text) {
    _history.add(text);

    // Membatasi maksimal 5 riwayat terakhir
    if (_history.length > 5) {
      _history.removeAt(0);
    }
  }
}

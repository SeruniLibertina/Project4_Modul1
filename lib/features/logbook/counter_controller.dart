import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterController with ChangeNotifier {
  int _count = 0;
  int _step = 1; 
  List<String> _history = [];

  int get count => _count;
  int get step => _step;
  List<String> get history => _history;

  CounterController() {
    _loadData();
  }

  void setStep(String value) {
    int? parsedValue = int.tryParse(value);
    if (parsedValue != null && parsedValue > 0) {
      _step = parsedValue;
    } else {
      _step = 1;
    }
    notifyListeners();
  }

  void increment() {
    _count += _step;
    _addHistory("Tambah $_step");
    _saveData();
    notifyListeners();
  }

  void decrement() {
    if (_count - _step >= 0) {
      _count -= _step;
      _addHistory("Kurang $_step");
    } else {
      _count = 0;
      _addHistory("Reset ke 0");
    }
    _saveData();
    notifyListeners();
  }

  void _addHistory(String activity) {
    String time = "${DateTime.now().hour}:${DateTime.now().minute}";
    _history.insert(0, "$activity pada $time");
    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter_value', _count);
    await prefs.setStringList('history_list', _history);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _count = prefs.getInt('counter_value') ?? 0;
    _history = prefs.getStringList('history_list') ?? [];
    notifyListeners();
  }
}
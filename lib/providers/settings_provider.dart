import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isSoundEnabled = true;
  double _volume = 0.8;
  // String _difficulty = 'Средняя';
  // bool _isTimerEnabled = false;

  bool get isDarkMode => _isDarkMode;
  bool get isSoundEnabled => _isSoundEnabled;
  double get volume => _volume;
  // String get difficulty => _difficulty;
  // bool get isTimerEnabled => _isTimerEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    _isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
    _volume = prefs.getDouble('volume') ?? 0.8;
    // _difficulty = prefs.getString('difficulty') ?? 'Средняя';
    // _isTimerEnabled = prefs.getBool('timer_enabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
    // Здесь также можно применить тему глобально через другой провайдер
  }

  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _isSoundEnabled);
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', value);
    notifyListeners();
  }

  // Future<void> setDifficulty(String value) async {
  //   _difficulty = value;
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('difficulty', value);
  //   notifyListeners();
  // }

  // Future<void> toggleTimer() async {
  //   _isTimerEnabled = !_isTimerEnabled;
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('timer_enabled', _isTimerEnabled);
  //   notifyListeners();
  // }

  
}
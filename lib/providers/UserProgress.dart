import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserProgress extends ChangeNotifier{
  int _totalPoints = 0;
  int get totalPoints => _totalPoints;
  bool isInitialized = false;

  Future<void> loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _totalPoints = prefs.getInt('total_points') ?? 0;
    isInitialized = true;
    notifyListeners();
  }

  Future<void> addPoints(int points) async {
    _totalPoints += points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_points', _totalPoints);
    notifyListeners();
  }
  // userprogress.dart
  Future<void> resetPoints() async {
    _totalPoints = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_points', 0); // или prefs.remove('total_points')
    notifyListeners();
  }
  Future<int> takeGuestPoints() async {
    final points = _totalPoints;
    await resetPoints(); 
    return points;
  }
}
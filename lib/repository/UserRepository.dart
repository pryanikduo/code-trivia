import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:code_trivia/models/User.dart';

class UserRepository {
  static Future<List<User>> loadUserData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/users.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<User> users = jsonList
        .map((item) => User.fromJson(item as Map<String, dynamic>))
        .toList();
      return users;
    } catch(e) {
      print('Ошибка загрузки пользователей: $e');
      return List<User>.empty();
    }
  }
}
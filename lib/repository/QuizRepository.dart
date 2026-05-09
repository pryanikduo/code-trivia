import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/Question.dart';
import '../models/Answer.dart';
import '../models/Category.dart';

class QuizRepository {
  static Future<List<Question>> loadAllQuestion() async {
    try {
      // 1. Читаем строку из JSON-файла
      final jsonString = await rootBundle.loadString('assets/data/question.json');

      // 2. Декодируем строку в массив (List<dynamic>) 
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // 3. Преобразуем каждый элемент в объект модели
      final List<Question> questions = jsonList
        .map((item) => Question.fromJson(item as Map<String, dynamic>))
        .toList();
      return questions;
    } catch(e) {
      print('Ошибка загрузки вопросов: $e');
      return [];
    }
  }

  static Future<List<Answer>> loadAnswers() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/question.dart');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<Answer> answers = jsonList
        .map((item) => Answer.fromJson(item as Map<String, dynamic>))
        .toList();
      return answers;
    } catch(e) {
      print('Ошибка, не удалось загрузить ответы: $e');
      return [];
    }
  }

  static Future<List<Category>> loadCategories() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/question.dart');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<Category> categories = jsonList
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
      return categories;
    } catch(e) {
      print('Ошибка загрузки категорий: $e');
      return [];
    }
  }
}
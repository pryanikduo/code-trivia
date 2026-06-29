import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/Question.dart';
import '../models/Answer.dart';
import '../models/Category.dart';

class QuizRepository {
  static Future<QuizData> loadQuizData() async {
    try {
      // 1. Читаем строку из JSON-файла
      final jsonString = await rootBundle.loadString('assets/data/question.json');

      // 2. Декодируем строку в массив (List<dynamic>) 
      final Map<String, dynamic> root = jsonDecode(jsonString);
      
      // 3. Извлекаем три списка
      final List<dynamic> categoriesJson = root['categories'] as List<dynamic>;
      final List<dynamic> questionJson = root['questions'] as List<dynamic>;
      final List<dynamic> answersJson = root['answers'] as List<dynamic>;

      // 4. Преобразуем каждый элемент в объект модели
      final List<Category> categories = categoriesJson
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();

      final List<Question> questions = questionJson
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();

      final List<Answer> answers = answersJson
        .map((e) => Answer.fromJson(e as Map<String, dynamic>))
        .toList();

      // 5. Устаналиваем связи
      final Map<String, Category> categoryMap = {
        for(var cat in categories) cat.id: cat
      };
      final Map<String, List<Answer>> answersByQuestionId = {};
      for (var answer in answers) {
        answersByQuestionId.putIfAbsent(answer.questionId, () => []).add(answer);
      }

      for (var question in questions) {
        question.category = categoryMap[question.categoryId];
        question.answers = answersByQuestionId[question.id] ?? [];
      }

      return QuizData(
        categories: categories,
        questions: questions,
        answers: answers,
      );
    } catch(e) {
      print('Ошибка загрузки вопросов: $e');
      return QuizData.empty();
    }
  }
}

class QuizData {
  final List<Category> categories;
  final List<Question> questions;
  final List<Answer> answers;

  QuizData({
    required this.categories,
    required this.questions,
    required this.answers,
  });

  QuizData.empty()
      : categories = [],
        questions = [],
        answers = [];
}
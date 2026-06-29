import '../models/Question.dart';
import '../models/Category.dart';
import 'package:code_trivia/core/supabase.dart';

class QuizRepository {
  static Future<List<Category>> loadCategories() async {
    try {
      final response = await supabase
        .from('categories')
        .select('*')
        .order('name', ascending: true);
      return response
        .map<Category>((json) => Category.fromJson(json))
        .toList();
    } catch (e) {
      print('Ошибка загрузки категорий: $e');
      return [];
    }
  }

  static Future<List<Question>> loadQuestions({
    required String categoryId,
    required String difficulty,
    int limit = 10,
  }) async {
    try {
      final difficultyId = _getDifficultyId(difficulty);

      final response = await supabase
        .from('questions')
        .select('*, difficulty_levels!inner(points_multiplier)')
        .eq('category_id', categoryId)
        .eq('difficulty_id', difficultyId)
        .limit(limit * 2);

      

      var questions = response.map<Question>((json) {
        final diffData = json['difficulty_levels'] as Map<String, dynamic>?;
        return Question.fromJson({
          ...json,
          'points_multiplier': diffData?['points_multiplier'] ?? 1,
        });
      }).toList();
      questions.shuffle();
      return questions.take(limit).toList();
    } catch (e) {
      print('Ошибка загрузки вопросов: $e');
      return [];
    }
  }
  static Future<List<Question>> loadDailyQuiz({int limit = 5}) async {
  try {
    final response = await supabase
        .from('questions')
        .select('*, difficulty_levels!inner(points_multiplier)')
        .limit(20*2);

    final allQuestions = response.map<Question>((json) {
      final diffData = json['difficulty_levels'] as Map<String, dynamic>?;
      return Question.fromJson({
        ...json,
        'points_multiplier': diffData?['points_multiplier'] ?? 1,
      });
    }).toList();

    allQuestions.shuffle();
    return allQuestions.take(limit).toList();
  } catch (e) {
    print('Ошибка загрузки ежедневного квиза: $e');
    return [];
  }
}
  static int _getDifficultyId(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 1;
      case 'medium':
        return 2;
      case 'hard':
        return 3;
      default:
       return 1;
    }
  }
}

class QuizData {
  final List<Category> categories;

  QuizData({required this.categories});

  QuizData.empty() : categories = [];
}
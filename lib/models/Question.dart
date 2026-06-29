import 'Answer.dart';
import 'Category.dart';

class Question{
  String id;
  String categoryId;
  String questionText;
  String explanation;
  int points;
  String difficulty;

  Category? category;
  List<Answer> answers = [];

  Question({
    required this.id,
    required this.categoryId,
    required this.questionText, 
    required this.explanation, 
    required this.points,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json){
    return Question(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      questionText: json['question_text'] as String, 
      explanation: json['explanation'] as String, 
      points: json['points'] as int,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'question_text': questionText,
    'explanation': explanation,
    'points': points,
    'difficulty': difficulty,
  };
}
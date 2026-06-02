class Question {
  final int id;
  final String categoryId;
  final int difficultyId;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final int pointsMultiplier;

  Question({
    required this.id,
    required this.categoryId,
    required this.difficultyId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.pointsMultiplier = 1,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int? ?? 0,
      categoryId: json['category_id']?.toString() ?? '',
      difficultyId: json['difficulty_id'] as int? ?? 1,
      questionText: json['text']?.toString() ?? '',
      options: (json['options'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      correctOptionIndex: json['correct_option'] as int? ?? 0,
      explanation: json['explanation']?.toString() ?? '',
      pointsMultiplier: json['points_multiplier'] as int? ?? 1,   
    );
  }
}
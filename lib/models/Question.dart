class Question{
  String questionText;
  String explanation;
  int points;

  Question({
    required this.questionText, 
    required this.explanation, 
    required this.points
  });

  factory Question.fromJson(Map<String, dynamic> json){
    return Question(
      questionText: json['question_text'] as String, 
      explanation: json['explanation'] as String, 
      points: json['points'] as int
    );
  }

  Map<String, dynamic> toJson() => {
    'question_text': questionText,
    'explanation': explanation,
    'points': points,
  };
}
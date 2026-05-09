class Answer {
  String id;
  String questionId;
  String answerText;
  bool isCorrect;

  Answer({
    required this.id, 
    required this.questionId, 
    required this.answerText, 
    required this.isCorrect
  });

  // Создаем Answer из JSON 
  factory Answer.fromJson(Map<String, dynamic> json){
    return Answer(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      answerText: json['answer_text'] as String,
      isCorrect: json['is_correct'] as bool
    );
  }

  // Преобразуем Answer обратно в JSON, если нужно отправить на сервер
  Map<String, dynamic> toJson() => {
    'id': id,
    'question_id': questionId,
    'answer_text': answerText,
    'is_correct': isCorrect
  };
}
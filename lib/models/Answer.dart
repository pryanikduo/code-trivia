class Answer {
  String answerText;
  bool? isCorrect;

  Answer({required this.answerText, this.isCorrect});

  // Создаем Answer из JSON 
  factory Answer.fromJson(Map<String, dynamic> json){
    return Answer(
      answerText: json['answerText'] as String,
      isCorrect: json['is_correct'] as bool
    );
  }

  // Преобразуем Answer обратно в JSON, если нужно отправить на сервер
  Map<String, dynamic> toJson() => {
    'answer_text': answerText,
    'is_correct': isCorrect
  };
}
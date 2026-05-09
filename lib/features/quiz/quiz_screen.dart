import 'package:code_trivia/providers/UserProgress.dart';
import 'package:flutter/material.dart';
import 'package:code_trivia/models/Question.dart';
import 'package:code_trivia/models/Answer.dart';
// import 'package:code_trivia/repository/QuizRepository.dart';
import 'package:provider/provider.dart';
import 'package:code_trivia/features/result/result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  const QuizScreen({super.key, required this.questions});

  @override
 State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  String? _selectedAnswerId;
  bool _isAnswered = false;
  int _earnedPoints = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Очистка (вызывается при уничтожении)
    super.dispose();
  }

  void _onAnswerSelected(Answer answer) {
    setState(() {
      _selectedAnswerId = answer.id;
      _isAnswered = true;
      if(answer.isCorrect){
        _earnedPoints += widget.questions[_currentIndex].points;
      }
    });
  }

  void _nextQuestion() {
    if(_currentIndex + 1 < widget.questions.length){
      setState(() {
        _currentIndex++;
        _selectedAnswerId = null;
        _isAnswered = false;
      });
    } else {
      context.read<UserProgress>().addPoints(_earnedPoints);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            earnedPoints: _earnedPoints,
            totalQuestions: widget.questions.length,
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,   
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Предупреждение'),
                  content: Text('Вы точно хотите прекратить прохождение квиза?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                          color: Color.fromRGBO(240, 232, 213, 1.0),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Да',
                        style: TextStyle(
                          color: Color.fromRGBO(240, 232, 213, 1.0),
                        ),
                      ),
                    ),
                  ],
                );
              }
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(240, 232, 213, 1.0),
            size: 28,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Квиз',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(240, 232, 213, 1.0),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.questions.length,
              backgroundColor: const Color.fromRGBO(240, 232, 213, 1.0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color.fromRGBO(171, 253, 195, 1.0)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Card(
              color: const Color.fromRGBO(240, 232, 213, 1.0),
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Вопрос ${_currentIndex + 1}/${widget.questions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(33, 40, 68, 1.0),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      currentQuestion.questionText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(33, 40, 68, 1.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentQuestion.answers.length,
                        itemBuilder: (context, index) {
                          final answer = currentQuestion.answers[index];
                          // Определяем цвет фона для варианта ответа
                          Color? tileColor;
                          if (_isAnswered) {
                            if (answer.isCorrect) {
                              tileColor = Colors.green.shade100;
                            } else if (answer.id == _selectedAnswerId) {
                              tileColor = Colors.red.shade100;
                            }
                          }
                          return ListTile(
                            tileColor: tileColor,
                            title: Text(
                              answer.answerText,
                              style: const TextStyle(
                                color: Color.fromRGBO(33, 40, 68, 1.0),
                              ),
                            ),
                            leading: Radio<String>(
                              value: answer.id,
                              groupValue: _selectedAnswerId,
                              onChanged: _isAnswered ? null : (value) => _onAnswerSelected(answer),
                            ),
                            onTap: _isAnswered ? null : () => _onAnswerSelected(answer),
                          );
                        },
                      ),
                    ),
                    // Показываем объяснение, если ответ выбран
                    if (_isAnswered)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          currentQuestion.explanation,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Color.fromRGBO(33, 40, 68, 0.9),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: _isAnswered ? _nextQuestion : null,
                        child: Text(
                          _currentIndex + 1 == widget.questions.length ? 'Завершить' : 'Далее',
                          style: const TextStyle(
                            color: Color.fromRGBO(33, 40, 68, 1.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

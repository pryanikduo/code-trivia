import 'package:flutter/material.dart';
import 'package:code_trivia/models/Question.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:code_trivia/core/supabase.dart';
import 'package:code_trivia/features/result/result_screen.dart';
import 'package:provider/provider.dart';
import 'package:code_trivia/providers/UserProgress.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  const QuizScreen({super.key, required this.questions});

  @override
 State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _isAnswered = false;
  int _earnedPoints = 0;

  int _maxPossiblePoints = 0;

  final List<int?> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _userAnswers.length = widget.questions.length;
    _maxPossiblePoints = widget.questions.fold(0, (sum, q) => sum + 10 * q.pointsMultiplier);
  }

  @override
  void dispose() {
    // Очистка (вызывается при уничтожении)
    super.dispose();
  }

  void _onAnswerSelected(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedIndex = index;
      _isAnswered = true;

      final currentQuestion = widget.questions[_currentIndex];
      final isCorrect = index == currentQuestion.correctOptionIndex;

      if (isCorrect) {
        final pointsForThisQuestion = 10 * currentQuestion.pointsMultiplier; // ← Вот так!
        _earnedPoints += pointsForThisQuestion;
      }

      _userAnswers[_currentIndex] = index;
    });
  }

  void _nextQuestion() {
    if(_currentIndex + 1 < widget.questions.length){
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _isAnswered = false;
      });
    } else {
      _finishQuiz();
    }
  }
  
  // ВРЕМЕННО (наверное), если что заменить на код из вк
  Future<void> _finishQuiz() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      context.read<UserProgress>().addPoints(_earnedPoints);
      _navigateToResults();
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // 1. Сохраняем историю ответов
      final List<Map<String, dynamic>> answersToSave = [];

      for (int i = 0; i < widget.questions.length; i++) {
        final question = widget.questions[i];
        final selectedIndex = _userAnswers[i];
        final isCorrect = selectedIndex == question.correctOptionIndex;
        final pointsEarned = isCorrect ? (10 * question.pointsMultiplier) : 0;

        answersToSave.add({
          'user_id': user.id,
          'question_id': question.id,
          'is_correct': isCorrect,
          'points_earned': pointsEarned,
        });
      }

      if (answersToSave.isNotEmpty) {
        await supabase.from('user_answers').insert(answersToSave);
      }

      // 2. Получаем текущий total_score
      final profileData = await supabase
          .from('profiles')
          .select('total_score')
          .eq('id', user.id)
          .single();

      final currentTotalScore = profileData['total_score'] as int? ?? 0;
      final newTotalScore = currentTotalScore + _earnedPoints;

      // 3. Обновляем профиль
      await supabase
          .from('profiles')
          .update({
            'total_score': newTotalScore,
            'last_quiz_date': DateTime.now().toIso8601String().split('T')[0],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      if (mounted) Navigator.pop(context); // закрываем лоадер

      _navigateToResults();
    } catch (e) {
      print('Ошибка сохранения результатов: $e');
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Результат сохранён локально, но не в базу')),
      );

      _navigateToResults();
    }
  }

  void _navigateToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          earnedPoints: _earnedPoints,
          totalQuestions: widget.questions.length, // можно оставить для статистики
          maxPoints: _maxPossiblePoints,           // новый параметр
        ),
      ),
    );
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
                        itemCount: currentQuestion.options.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedIndex == index;
                          final isCorrect = _isAnswered && index == currentQuestion.correctOptionIndex;
                          final isWrong = _isAnswered && isSelected && !isCorrect;
                          return ListTile(
                            title: Text(
                              currentQuestion.options[index],
                              style: TextStyle(
                                color: Color.fromRGBO(33, 40, 68, 1.0),
                                fontSize: 16,
                              ),
                            ),
                            leading: Radio<int>(
                              fillColor: MaterialStateProperty.resolveWith((states) {
                                return Color.fromRGBO(33, 40, 68, 1.0); // цвет по умолчанию
                              }),
                              value: index,
                              groupValue: _selectedIndex,
                              onChanged: _isAnswered ? null : (val) => _onAnswerSelected(val!),
                            ),
                            tileColor: isCorrect ? Colors.green.shade100 : isWrong ? Colors.red.shade100 : null,
                            onTap: _isAnswered ? null : () => _onAnswerSelected(index),
                          );
                        },
                      ),
                    ),
                    if (_isAnswered && currentQuestion.explanation.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Пояснение:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQuestion.explanation,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: Color.fromRGBO(33, 40, 68, 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 56),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isAnswered ? _nextQuestion : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(33, 40, 68, 1.0),   
                          foregroundColor: const Color.fromRGBO(240, 232, 213, 1.0), 
                          disabledBackgroundColor: Colors.grey.shade400,            
                          disabledForegroundColor: Colors.grey.shade600,            
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _currentIndex + 1 == widget.questions.length 
                              ? 'Завершить квиз' 
                              : 'Далее',
                          // Убираем явный color из стиля, чтобы использовался foregroundColor
                          style: const TextStyle(fontSize: 16),
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

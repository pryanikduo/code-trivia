import 'package:flutter/material.dart';
import 'package:code_trivia/features/home/home_screen.dart';

class ResultsScreen extends StatelessWidget {
  final int earnedPoints;
  final int totalQuestions;

  const ResultsScreen({super.key, required this.earnedPoints, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    // процент правильных ответов (если каждый вопрос даёт 1 очко)
    final percent = (earnedPoints / totalQuestions * 100).round();
    String message;
    if (percent == 100) message = 'Идеально!';
    else if (percent >= 70) message = 'Отлично!';
    else if (percent >= 50) message = 'Неплохо.';
    else message = 'Попробуй ещё раз.';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Результаты',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(240, 232, 213, 1.0),
          ),
        ),
        automaticallyImplyLeading: false, // убираем кнопку назад
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Твой результат: $earnedPoints очков',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'На главную',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromRGBO(33, 40, 68, 1.0),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
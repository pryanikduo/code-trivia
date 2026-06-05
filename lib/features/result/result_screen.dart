import 'package:flutter/material.dart';
import 'package:code_trivia/features/home/home_screen.dart';

class ResultsScreen extends StatefulWidget {
  final int earnedPoints;
  final int totalQuestions;   // количество вопросов (может быть не нужно)
  final int maxPoints;        // максимально возможное количество очков

  const ResultsScreen({
    super.key,
    required this.earnedPoints,
    required this.totalQuestions,
    required this.maxPoints,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  String get _message {
    final percent = (widget.earnedPoints / widget.totalQuestions * 100).round();
    if (percent == 100) return '🎉 Идеально! 🎉';
    if (percent >= 70) return '🏆 Отлично! 🏆';
    if (percent >= 50) return '👍 Неплохо.';
    return '💪 Попробуй ещё раз.';
  }

  Color get _messageColor {
    final percent = widget.earnedPoints / widget.totalQuestions;
    if (percent >= 0.7) return Colors.green.shade700;
    if (percent >= 0.5) return Colors.orange.shade600;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final double percent = (widget.earnedPoints / widget.maxPoints).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(33, 40, 68, 1.0),
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
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Color.fromRGBO(240, 232, 213, 1.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: percent),
                        duration: const Duration(milliseconds: 1000),
                        builder: (context, value, _) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: value,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _messageColor,
                                ),
                              ),
                              Text(
                                '${(value * 100).round()}%',
                                style: const TextStyle(
                                  color: Color.fromRGBO(33, 40, 68, 1.0),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _message,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _messageColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Твой результат: ${widget.earnedPoints} из ${widget.maxPoints} очков',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color.fromRGBO(33, 40, 68, 1.0),
                      ),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(33, 40, 68, 1.0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'На главную',
                        style: TextStyle(
                          color: Color.fromRGBO(240, 232, 213, 1.0),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
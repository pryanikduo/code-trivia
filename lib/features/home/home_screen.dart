import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'CodeTrivia',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(240, 232, 213, 1.0),
          ),
        ),
      ),
      body: Stack(
        children: [
          // СКРОЛЛЯЩИЙСЯ КОНТЕНТ (с отступом снизу, чтобы не перекрывать кнопку)
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Отступ для кнопки
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Приветствие
                  const Text(
                    'Привет, пряник!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(240, 232, 213, 1.0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Готов(а) прокачать свои навыки сегодня?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(240, 232, 213, 0.8),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Статистика
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(240, 232, 213, 1.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(value: '7', label: 'дней'),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[400],
                        ),
                        _StatItem(value: '1000', label: 'очков'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Категории',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(240, 232, 213, 1.0),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Сетка категорий
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0, // Квадратные карточки
                    ),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final categories = ['Python', 'SQL', 'Базы данных', 'JS', 'HTML'];
                      return _CategoryCard(title: categories[index]);
                    },
                  ),
                  
                  const SizedBox(height: 40), // Дополнительное место внизу
                ],
              ),
            ),
          ),
          
          // КНОПКА ПОВЕРХ (плавает без фона)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _goQuiz(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(240, 232, 213, 1.0),
                    foregroundColor: const Color.fromRGBO(33, 40, 68, 1.0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 4, // Небольшая тень для кнопки
                  ),
                  child: const Text(
                    'Начать ежедневный квиз',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goQuiz(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Загрузка викторины...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

// Компонент статистики
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(33, 40, 68, 1.0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Color.fromRGBO(33, 40, 68, 1.0),
          ),
        ),
      ],
    );
  }
}

// Компонент карточки категории
class _CategoryCard extends StatelessWidget {
  final String title;

  const _CategoryCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(107, 152, 191, 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.code,
              size: 32,
              color: Color.fromRGBO(33, 40, 68, 1.0),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(33, 40, 68, 1.0),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
import 'package:code_trivia/repository/QuizRepository.dart';
import 'package:flutter/material.dart';
import 'package:code_trivia/features/home/drawer_menu.dart';
import 'package:provider/provider.dart';
import 'package:code_trivia/providers/UserProgress.dart';
import 'package:code_trivia/features/quiz/quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  QuizData? _quizData;
  bool _isLoading = true;

  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await QuizRepository.loadQuizData();
    if(mounted){
      setState(() {
        _quizData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProgress = context.watch<UserProgress>();
    if (!userProgress.isInitialized || _isLoading) return CircularProgressIndicator();
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
        actions:[
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              }, 
              icon: const Icon(
                Icons.menu,
                color: Color.fromRGBO(240, 232, 213, 1.0),
                size: 28,
              ),
            ),
          ),
        ] 
      ),
      endDrawer: const AppDrawer(),
      body: Stack(
        children: [
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(value: '7', label: 'дней', imgPath: 'assets/images/fire (2).png'),
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.grey[400],
                        ),
                        _StatItem(
                          value: userProgress.totalPoints.toString(), 
                          label: 'очков', 
                          secondImgPath: 'assets/images/cup (2).png'
                        ),
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
                    itemCount: _quizData!.categories.length,
                    itemBuilder: (context, index) {
                      // final categories = [{'title': 'Python', 'image': 'assets/images/python (2).png'}, 
                      // {'title': 'SQL', 'image': 'assets/images/sql (2).png'}, 
                      // {'title': 'JavaScript', 'image': 'assets/images/javascript (2).png'}, 
                      // {'title': 'HTML', 'image': 'assets/images/html (2).png'}];
                      final category = _quizData!.categories[index];
                      return _CategoryCard(
                        title: category.name,
                        imagePath: category.image,
                        onTap: () => _onCategoryTap(context, category.id),
                      );
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
                      borderRadius: BorderRadius.circular(12),
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

  void _goQuiz(BuildContext context) async {
    showDialog(
      context: context, 
      builder: (BuildContext context) {return CircularProgressIndicator();}
    );
    final quizData = await QuizRepository.loadQuizData();
    Navigator.pop(context);
    final questions = quizData.questions.toList()..shuffle();
    final selected = questions.take(5).toList();
    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(questions: selected)));
  }

  void _onCategoryTap (BuildContext context, String categoryId){
    showDialog(
      context: context,
      builder: (dialogContext) {          // dialogContext — контекст диалога, не главного экрана
        return AlertDialog(
          title: Text('Выберите сложность'),
          content: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              ListTile(
                title: Text('Лёгкая'),
                onTap: () {
                  // У нас есть доступ к categoryId из внешней области
                  _startQuiz(context, categoryId, 'easy');
                  Navigator.pop(dialogContext); // закрыть диалог
                },
              ),
              ListTile(
                title: Text('Средняя'),
                onTap: () {
                  _startQuiz(context, categoryId, 'medium');
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                title: Text('Сложная'),
                onTap: () {
                  _startQuiz(context, categoryId, 'hard');
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startQuiz(BuildContext context, String categoryId, String difficulty) async {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context) {return CircularProgressIndicator();}
    );
    final quizData = await QuizRepository.loadQuizData();
    Navigator.pop(context);
    final filteredQuestions = quizData.questions.where((q) =>
      q.categoryId == categoryId && q.difficulty == difficulty).toList();
    if(filteredQuestions.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Нет вопросов для выбранной сложности')),
      );
      return;
    }
    final shuffled = filteredQuestions.toList()..shuffle();
    final selected = shuffled.take(5).toList();
    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(questions: selected)));
  }
}

// Компонент статистики
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final String? imgPath;
  final String? secondImgPath;

  const _StatItem({required this.value, required this.label, this.imgPath, this.secondImgPath});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if(imgPath != null)
          Image.asset(
            imgPath!,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        const SizedBox(width: 20),
        Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
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
        ),
        const SizedBox(width: 20),
        if(secondImgPath != null)
          Image.asset(
            secondImgPath!,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
      ],
    );
  }
}

// Компонент карточки категории
class _CategoryCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const _CategoryCard({required this.title, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(107, 152, 191, 1.0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.contain
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
      ),
    );
  }
}


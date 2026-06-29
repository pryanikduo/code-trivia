import 'dart:async';
import 'package:code_trivia/repository/QuizRepository.dart';
import 'package:code_trivia/models/Category.dart';
import 'package:flutter/material.dart';
import 'package:code_trivia/features/home/drawer_menu.dart';
import 'package:code_trivia/features/quiz/quiz_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:code_trivia/core/supabase.dart';
import 'package:provider/provider.dart';
import 'package:code_trivia/providers/UserProgress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;

  int _totalScore = 0;
  int _streak = 0;
  bool _isLoadingProfile = false;

  String? _previousUserId;

  late final StreamSubscription<AuthState> _authSubscription;

  void initState() {
    super.initState();
    _loadInitialData();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn) {
        // Пользователь только что вошёл или зарегистрировался
        await _transferGuestPointsToUser(event.session?.user);
      }
    });
  }

  Future<void> _transferGuestPointsToUser(User? user) async {
    if (user == null) return;

    // Получаем провайдер UserProgress
    final userProgress = context.read<UserProgress>();
    final guestPoints = userProgress.totalPoints;

    if (guestPoints == 0) return; // нечего переносить

    try {
      // Показываем индикатор загрузки (опционально)
      // Загружаем текущий total_score пользователя
      final profileData = await supabase
          .from('profiles')
          .select('total_score')
          .eq('id', user.id)
          .maybeSingle(); // используем maybeSingle, чтобы не было ошибки, если профиля нет

      final currentScore = profileData?['total_score'] as int? ?? 0;
      final newScore = currentScore + guestPoints;

      // Обновляем профиль
      await supabase.from('profiles').upsert({
        'id': user.id,
        'total_score': newScore,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Сбрасываем локальные очки гостя
      await userProgress.resetPoints();

      // Обновляем состояние в HomeScreen (чтобы сразу показать новые очки)
      if (mounted) {
        setState(() {
          _totalScore = newScore;
          // серию оставляем как есть (она уже загрузится из профиля при следующей загрузке)
        });
        // Можно также принудительно перезагрузить профиль, чтобы обновить streak и т.д.
        _loadUserProfile(user.id);
      }

      // Показать уведомление об успешном переносе
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ваши очки гостя ($guestPoints) добавлены к аккаунту!')),
        );
      }
    } catch (e) {
      print('Ошибка переноса очков: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось перенести очки. Обратитесь в поддержку.')),
        );
      }
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final categories = await QuizRepository.loadCategories();
      if(mounted){
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Ошибка загрузки данных: $e');
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final data = await supabase
        .from('profiles')
        .select('total_score, streak')
        .eq('id', userId)
        .single();
      if(mounted) {
        setState(() {
          _totalScore = data['total_score'] ?? 0;
          _streak = data['streak'] ?? 0;
        });
      }
    } catch (e) {
      print('Ошибка загрузки профиля: $e');
    } finally {
      if(mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
      body: StreamBuilder<AuthState> (
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final isLoggedIn = snapshot.data?.session != null ||
                supabase.auth.currentSession != null;
          final user = supabase.auth.currentUser;
          final currentUserId = user?.id;
          
          final guestPoints = context.watch<UserProgress>().totalPoints;

          final displayedPoints = isLoggedIn ? _totalScore : guestPoints;
          final displayedStreak = isLoggedIn ? _streak : 0;

          if (_previousUserId != currentUserId) {
            _previousUserId = currentUserId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _totalScore = 0;
                  _streak = 0;
                  _isLoadingProfile = false;
                });
                if (isLoggedIn && user != null) {
                  setState(() => _isLoadingProfile = true);
                  _loadUserProfile(user.id);
                }
              }
            });
          }
          else if (isLoggedIn && user != null && _totalScore == 0 && !_isLoadingProfile) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _isLoadingProfile = true);
                _loadUserProfile(user.id);
              }
            });
          }
          final String displayName = isLoggedIn
            ? (user?.userMetadata?['username'] as String? ??
              user?.email?.split('@').first ?? 'Пользователь')
            : 'Гость';


          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100), // Отступ для кнопки
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Приветствие
                      Text(
                        'Привет, $displayName!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(240, 232, 213, 1.0),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLoggedIn
                            ? 'Продолжай в том же духе!'
                            : 'Войдите, чтобы сохранять прогресс и статистику',
                        style: const TextStyle(
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
                            _StatItem(
                              value: displayedStreak.toString(), 
                              label: 'дней', 
                              imgPath: 'assets/images/fire (2).png'
                            ),
                            Container(
                              width: 2,
                              height: 40,
                              color: Colors.grey[400],
                            ),
                            _StatItem(
                              value: displayedPoints.toString(), 
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
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return _CategoryCard(
                            title: category.name,
                            imagePath: getCategoryImagePath(category.name),
                            onTap: () => _onCategoryTap(context, category.id),
                          );
                        },
                      ),
                      const SizedBox(height: 40), 
                    ],
                  ),
                ),
              ),
              
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goDailyQuiz(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(240, 232, 213, 1.0),
                        foregroundColor: const Color.fromRGBO(33, 40, 68, 1.0),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4, 
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
          );
        },
      ),
    );
  }

  void _goDailyQuiz(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final questions = await QuizRepository.loadDailyQuiz(limit: 5);

      if(questions.isEmpty){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось загрузить вопросы')),
        );
        return;
      }
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(questions: questions)));
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  void _onCategoryTap (BuildContext context, String categoryId){
    showDialog(
      context: context,
      builder: (dialogContext) {          
        return AlertDialog(
          title: Text('Выберите сложность'),
          content: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              ListTile(
                title: Text('Лёгкая'),
                onTap: () {
                  _startQuiz(context, categoryId, 'easy');
                  Navigator.pop(dialogContext); 
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
    try {
      final questions = await QuizRepository.loadQuestions(
        categoryId: categoryId,
        difficulty: difficulty,
      );
      if(questions.isEmpty){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет вопросов для выбранной сложности')),
        );
        return;
      }
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(questions: questions)));
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки вопросов: $e')),
      );
    }
  }
  String getCategoryImagePath(String categoryName) {
    switch(categoryName) {
      case 'SQL':
        return 'assets/images/sql (2).png';
      case 'HTML':
        return 'assets/images/html (2).png';
      case 'JavaScript':
        return 'assets/images/javascript (2).png';
      case 'Python':
        return 'assets/images/python (2).png';
      default:
        return 'assets/images/default.png';
    }
  }
}

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

  const _CategoryCard({required this.title, 
  required this.imagePath, 
  required this.onTap});

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


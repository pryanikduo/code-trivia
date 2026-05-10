import 'package:code_trivia/providers/UserProgress.dart';
import 'package:code_trivia/providers/settings_provider.dart';  // ← добавить импорт
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/welcome/welcome_screen.dart';

Future<void> main() async {                                   // ← сделать async
  WidgetsFlutterBinding.ensureInitialized();                  // ← добавить (для асинхронности)

  // Загружаем данные провайдеров до запуска приложения
  final userProgress = UserProgress();
  await userProgress.loadPoints();

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    MultiProvider(                                            // ← заменить ChangeNotifierProvider на MultiProvider
      providers: [
        ChangeNotifierProvider(create: (_) => userProgress),
        ChangeNotifierProvider(create: (_) => settingsProvider),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeTrivia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
      builder: (context, child) {
        return Container(
          color: AppTheme.darkTheme.colorScheme.surface,
          child: child,
        );
      },
    );
  }
}
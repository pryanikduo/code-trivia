import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_trivia/providers/settings_provider.dart';
// import 'package:code_trivia/providers/UserProgress.dart';
import 'package:code_trivia/features/home/home_screen.dart';
import 'package:code_trivia/core/supabase.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
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
          'Настройки',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(240, 232, 213, 1.0),
          ),
        ),
      ),
      body: ListView(
        children: [
          // ===== Внешний вид =====
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Внешний вид', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Тёмная тема'),
            subtitle: const Text('Изменить цветовую схему приложения'),
            value: settings.isDarkMode,
            onChanged: (_) => settings.toggleDarkMode(),
          ),
          const Divider(),

          // ===== Звук =====
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Звук', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Звуки игры'),
            subtitle: const Text('Клик по кнопкам, правильные/неправильные ответы'),
            value: settings.isSoundEnabled,
            onChanged: (_) => settings.toggleSound(),
          ),
          if (settings.isSoundEnabled)
            ListTile(
              title: const Text('Громкость'),
              subtitle: Slider(
                value: settings.volume,
                min: 0,
                max: 1,
                divisions: 10,
                onChanged: (value) => settings.setVolume(value),
              ),
            ),
          const Divider(),

          // ===== Игра =====
          // const Padding(
          //   padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          //   child: Text('Игра', style: TextStyle(fontWeight: FontWeight.bold)),
          // ),
          // ListTile(
          //   title: const Text('Сложность по умолчанию'),
          //   subtitle: Text(settings.difficulty),
          //   trailing: PopupMenuButton<String>(
          //     initialValue: settings.difficulty,
          //     onSelected: settings.setDifficulty,
          //     itemBuilder: (context) => [
          //       const PopupMenuItem(value: 'Легкая', child: Text('Легкая')),
          //       const PopupMenuItem(value: 'Средняя', child: Text('Средняя')),
          //       const PopupMenuItem(value: 'Сложная', child: Text('Сложная')),
          //     ],
          //   ),
          // ),
          // SwitchListTile(
          //   title: const Text('Таймер на вопрос'),
          //   subtitle: const Text('Ограничить время ответа 30 секундами'),
          //   value: settings.isTimerEnabled,
          //   onChanged: (_) => settings.toggleTimer(),
          // ),
          // const Divider(),

          // ===== Данные =====
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Данные', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Сбросить прогресс', style: TextStyle(color: Colors.red)),
            onTap: () => _showResetDialog(context),
          ),
          const Divider(),

          // ===== О приложении =====
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('О приложении', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const ListTile(
            title: Text('Версия'),
            trailing: Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Политика конфиденциальности'),
            onTap: () => _openPrivacyPolicy(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сброс доступен только авторизованным пользователям')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сброс данных'),
        content: const Text('Все очки и достижения будут удалены без возможности восстановления. Продолжить?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () async {
              await supabase
                .from('user_answers')
                .delete()
                .eq('user_id', user.id);
              await supabase
                .from('profiles')
                .update({
                  'total_score': 0,
                  'streak': 0,
                  'last_quiz_date': null,
                })
                .eq('id', user.id);
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Прогресс сброшен')),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Сбросить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

    void _openPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Политика конфиденциальности'),
        content: const SingleChildScrollView(
          child: Text(
            'Ваше приватность важна для нас. Это приложение не собирает и не передаёт личные данные третьим лицам.\n\n'
            '📌 Что мы храним:\n'
            '• Ваш прогресс (очки, пройденные квизы) — только на вашем устройстве.\n'
            '• Настройки приложения (тема, звук) — локально на устройстве.\n'
            '• Если вы используете вход по email — мы храним только хеш пароля, сам пароль не сохраняется.\n\n'
            '📌 Мы не используем:\n'
            '• Аналитику сторонних сервисов.\n'
            '• Отслеживание местоположения.\n'
            '• Доступ к контактам, камере, микрофону.\n\n'
            '📌 Передача данных:\n'
            'Приложение не отправляет ваши данные в интернет (все операции выполняются локально).\n\n'
            'Если у вас есть вопросы, свяжитесь с нами: privacy@codetrivia.com (учебный адрес).',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
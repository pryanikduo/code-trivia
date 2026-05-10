import 'package:code_trivia/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromRGBO(33, 40, 68, 1.0), // Тёмный фон
      child: Column(
        children: [
          // Шапка меню (Header)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(107, 152, 191, 1.0),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Color.fromRGBO(33, 40, 68, 1.0),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Пряник',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(33, 40, 68, 1.0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'пряник@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(33, 40, 68, 0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Пункты меню
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.person,
                  title: 'Профиль',
                  onTap: () => _navigateToProfile(context),
                ),
                _DrawerItem(
                  icon: Icons.home,
                  title: 'Главная',
                  onTap: () => _navigateToHome(context),
                ),
                _DrawerItem(
                  icon: Icons.leaderboard,
                  title: 'Лидерборд',
                  onTap: () => _navigateToLeaderboard(context),
                ),
                _DrawerItem(
                  icon: Icons.settings,
                  title: 'Настройки',
                  onTap: () => _navigateToSettings(context),
                ),
                const Divider(color: Colors.grey),
                _DrawerItem(
                  icon: Icons.logout,
                  title: 'Выйти',
                  onTap: () => _showLogoutDialog(context),
                  color: Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToHome(BuildContext context) {
    Navigator.pop(context); // Закрываем меню
    // Показываем SnackBar (потом замените на реальную навигацию)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Главная'), duration: Duration(seconds: 1)),
    );
  }
  
  void _navigateToLeaderboard(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Лидерборд'), duration: Duration(seconds: 1)),
    );
  }
  
  void _navigateToSettings(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
      (route) => false,
    );
  }
  
  void _navigateToProfile(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Профиль'), duration: Duration(seconds: 1)),
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрываем диалог
              Navigator.pop(context); // Закрываем меню
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Выход из аккаунта')),
              );
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Компонент пункта меню
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(color: color ?? Colors.white, fontSize: 16),
      ),
      onTap: onTap,
      hoverColor: const Color.fromRGBO(107, 152, 191, 0.2),
      splashColor: const Color.fromRGBO(107, 152, 191, 0.3),
    );
  }
}
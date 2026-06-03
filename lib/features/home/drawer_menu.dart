import 'package:code_trivia/features/settings/settings_screen.dart';
import 'package:code_trivia/core/supabase.dart';
import 'package:flutter/material.dart';
import 'package:code_trivia/features/authentification/auth_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadAvatar(); 
  }

  Future<void> _loadAvatar() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _avatarUrl = null);
      return;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      setState(() {
        _avatarUrl = response?['avatar_url'] as String?;
      });
    } catch (e) {
      print('Ошибка загрузки аватарки: $e');
    }
  }

  Future<void> _uploadAvatar() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final file = File(image.path);
    final filePath = '${user.id}/avatar.jpg';

    try {
      await supabase.storage.from('avatars').upload(
        filePath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final imageUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      await supabase
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', user.id);

      setState(() {
        _avatarUrl = imageUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Аватар обновлён')),
        );
      }
    } catch (e) {
      print('Ошибка загрузки: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromRGBO(33, 40, 68, 1.0),
      child: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final isLoggedIn = snapshot.data?.session != null ||
              supabase.auth.currentSession != null;
          final user = supabase.auth.currentUser;

          final String displayName = isLoggedIn
              ? (user?.userMetadata?['username'] as String? ??
                  user?.email?.split('@').first ??
                  'Пользователь')
              : 'Гость';
          final String subtitle = isLoggedIn
              ? (user?.email ?? '')
              : 'Войдите в аккаунт';

          if (!isLoggedIn && _avatarUrl != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _avatarUrl = null);
            });
          }
          if (isLoggedIn && user != null && _avatarUrl == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _loadAvatar();
            });
          }

          return Column(
            children: [
              // Шапка меню (без изменений)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(107, 152, 191, 1.0),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: _avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _avatarUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color.fromRGBO(33, 40, 68, 1.0),
                                )
                              : null,
                        ),
                        if (isLoggedIn)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _uploadAvatar,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(blurRadius: 4, color: Colors.black26)
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Icon(Icons.edit, size: 20, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(33, 40, 68, 1.0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(33, 40, 68, 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
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
                    if (isLoggedIn) ...[
                      _DrawerItem(
                        icon: Icons.person,
                        title: 'Профиль',
                        onTap: () => _navigateToProfile(context),
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
                    ] else ...[
                      const Divider(color: Colors.grey),
                      _DrawerItem(
                        icon: Icons.login,
                        title: 'Войти',
                        onTap: () => _navigateToLogin(context),
                        color: Colors.greenAccent,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pop(context);
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

  void _navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final scaffoldContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              Navigator.pop(scaffoldContext);
              try {
                await supabase.auth.signOut();
                if (scaffoldContext.mounted) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Вы вышли из аккаунта')),
                  );
                }
              } catch (e) {
                if (scaffoldContext.mounted) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(content: Text('Ошибка выхода: $e')),
                  );
                }
              }
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
import 'package:flutter/material.dart';
import 'package:code_trivia/features/home/home_screen.dart';
import 'package:code_trivia/features/authentification/registration_screen.dart';
import 'package:code_trivia/core/supabase_auth.dart';
import 'package:sign_in_button/sign_in_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
    setState(() => isLoading = true);
    final error = await SupabaseAuth.signIn(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    if (mounted) setState(() => isLoading = false);

    if (error == null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error!)),
      );
    }
  }

  Future<void> _googleLogin() async {
    setState(() => isLoading = true);
    final error = await SupabaseAuth.signInWithGoogle();
    if (mounted) setState(() => isLoading = false);

    if (error == null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (mounted) {
      print("Ошибка входа через Google: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Вход',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(240, 232, 213, 1.0),
          ),
        ),
      ),
      body: SingleChildScrollView(  // <-- оборачиваем в ScrollView
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Авторизация',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(240, 232, 213, 1.0),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                floatingLabelStyle: TextStyle(color: Color.fromRGBO(171, 253, 195, 1.0)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(240, 232, 213, 1.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(171, 253, 195, 1.0)),
                ),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                floatingLabelStyle: TextStyle(color: Color.fromRGBO(171, 253, 195, 1.0)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(240, 232, 213, 1.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(171, 253, 195, 1.0)),
                ),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Войти',
                      style: TextStyle(color: Color.fromRGBO(33, 40, 68, 1.0)),
                    ),
            ),
            const SizedBox(height: 16),
            SignInButton(
              Buttons.google,
              onPressed: () {
                if (!isLoading) {
                  _googleLogin();
                }
              },
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              text: "Войти через Google",
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Нет аккаунта? Зарегистрироваться',
                style: TextStyle(color: Color.fromRGBO(240, 232, 213, 1.0)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
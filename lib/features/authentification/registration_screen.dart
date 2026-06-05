import 'package:code_trivia/core/supabase.dart';
import 'package:code_trivia/core/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:code_trivia/features/authentification/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:code_trivia/features/home/home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _isAgreed = false;

  Future<void> _register() async {

    if(_usernameController.text.trim().isEmpty ||
      _emailController.text.trim().isEmpty ||
      _passwordController.text.isEmpty ||
      _confirmController.text.isEmpty) {
      _showSnackBar('Пожалуйста, заполните все поля');
      return;
    } 
    if(_passwordController.text != _confirmController.text) {
      _showSnackBar('Пароли не совпадают');
      return;
    }
    if(_passwordController.text.length < 6) {
      _showSnackBar('Пароль должен содержать минимум 6 символов');
      return;
    } 
    setState(() => _isLoading = true);

    final error = await SupabaseAuth.signUp(
      email: _emailController.text.trim(), 
      password: _passwordController.text,
      username: _usernameController.text.trim(),
    );

    if (error != null) {
      setState(() => _isLoading = false);
      if (mounted) _showSnackBar(error, isErrors: true);
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    final userId = session?.user.id;

    if (userId == null) {
      setState(() => _isLoading = false);
      if (mounted) _showSnackBar('Ошибка: не удалось получить ID пользователя', isErrors: true);
      return;
    }

    try {
      await supabase
        .from('profiles')
        .update({'username': _usernameController.text.trim()})
        .eq('id', userId);
    } catch (e) {
      setState(() => _isLoading = false);
      if(mounted) _showSnackBar('Ошибка сохранения профиля: $e', isErrors: true);
      return;
    }

    setState(() => _isLoading = false);

    if(mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _showSnackBar(String message, {bool isErrors = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isErrors ? Colors.red : null,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
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
          'Регистрация',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(240, 232, 213, 1.0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Создать аккаунт',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Имя пользователя',
                  floatingLabelStyle: TextStyle(color: Color.fromRGBO(171, 253, 195, 1.0),),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(240, 232, 213, 1.0)),
                  ), 
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(171, 253, 195, 1.0)),
                  ),
                  prefixIcon: Icon(Icons.person,), 
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  floatingLabelStyle: TextStyle(color: Color.fromRGBO(171, 253, 195, 1.0),),
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
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  floatingLabelStyle: TextStyle(color: Color.fromRGBO(171, 253, 195, 1.0),),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(240, 232, 213, 1.0)),
                  ), 
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(171, 253, 195, 1.0)),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: 'Повторите пароль',
                  floatingLabelStyle: TextStyle(color: Color.fromRGBO(171, 253, 195, 1.0),),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(240, 232, 213, 1.0)),
                  ), 
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(171, 253, 195, 1.0)),
                  ),
                  prefixIcon: Icon(Icons.lock_outline), 
                ),
              ),
              const SizedBox(height: 16,),
              Row(children: [
                Checkbox(
                  value: _isAgreed, 
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isAgreed = newValue ?? false;
                    });
                  }
                ),
                const Text(
                  'Я согласен с правилами и условиями',
                  style: TextStyle(
                    color: Color.fromRGBO(240, 232, 213, 1.0),
                  ),
                ),
              ],),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: (_isLoading || !_isAgreed) ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Зарегистрироваться',
                        style: TextStyle(
                          color: Color.fromRGBO(33, 40, 68, 1.0),
                          fontSize: 16,
                        ),
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Уже есть аккаунт?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Войти',
                      style: TextStyle(
                        color: Color.fromRGBO(240, 232, 213, 1.0),
                      )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

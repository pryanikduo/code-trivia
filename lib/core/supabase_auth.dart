import 'package:code_trivia/core/supabase.dart';

class SupabaseAuth {
  static Future<String?> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final response = await supabase.auth.signUp (
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
      );
      if(response.user == null) return 'Ошибка регистрации';
      return null;
    } catch(e) {
      return e.toString();
    }
  }

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password
      );
      return response.session != null ? null : 'Неверные данные';
    } catch (e) {
      return e.toString();
    }
  }
}
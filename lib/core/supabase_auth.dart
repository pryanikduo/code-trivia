import 'package:code_trivia/core/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  static Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: '903877400297-h6nn2vs6q0s2thhbbgqurq2tnscghhmk.apps.googleusercontent.com',
      );
      print('Google sign in started');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return 'Вход через Google отменён';
      print('Google user: $googleUser');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('idToken: ${googleAuth.idToken}');
      print('accessToken: ${googleAuth.accessToken}');
      if (googleAuth.idToken == null) {
        print('idToken is null, accessToken: ${googleAuth.accessToken}');
        return 'Не удалось получить idToken от Google';
      }

      final AuthResponse res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (res.user == null) {
        return 'Ошибка: не удалось создать сессию в Supabase';
      }

      // Обновляем username в profiles (если нужно)
      final userId = res.user!.id;
      final userName = googleUser.displayName ?? '';
      await supabase.from('profiles').upsert({
        'id': userId,
        'username': userName,
      });

      return null; // успех
    } catch (e) {
      return 'Ошибка при входе через Google: $e';
    }
  }
}
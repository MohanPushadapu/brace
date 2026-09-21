import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static bool get isConfigured {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> signIn(String email, String password) async {
    if (!isConfigured) return;
    await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signUp(String email, String password, String role) async {
    if (!isConfigured) return;
    await Supabase.instance.client.auth.signUp(email: email, password: password, data: {'role': role});
  }

  static Future<void> signInWithGoogle() async {
    if (!isConfigured) return;
    await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google);
  }

  static Future<void> signOut() async {
    if (isConfigured) await Supabase.instance.client.auth.signOut();
  }
}
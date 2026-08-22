import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static String? get currentUserId => currentUser?.id;

  static String get currentUserLabel =>
      currentUser?.email?.split('@').first ?? 'Usuario';

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    return response.session != null;
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

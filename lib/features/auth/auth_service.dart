import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/profile.dart';
import '../profile/profile_repository.dart';

class AuthService {
  AuthService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static SupabaseClient get supabase => _client;

  static User? get currentUser => _client.auth.currentUser;

  static String? get currentUserId => currentUser?.id;

  static String get currentUserLabel =>
      currentUser?.email?.split('@').first ?? 'Usuario';

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  static Future<void> _ensureProfile() async {
    final user = currentUser;

    if (user == null) {
      return;
    }

    final repository = ProfileRepository(_client);
    final profile = await repository.getMyProfile(user.id);

    if (profile == null) {
      await repository.createProfile(
        Profile(
          id: user.id,
          username: user.email?.split('@').first,
          displayName: user.email?.split('@').first,
        ),
      );
    }
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);

    await _ensureProfile();
  }

  static Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.session != null) {
      await _ensureProfile();
    }

    return response.session != null;
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authUserIdProvider = StreamProvider<String?>((ref) async* {
  yield AuthService.currentUserId;

  await for (final authState in AuthService.authStateChanges) {
    yield authState.session?.user.id;
  }
});

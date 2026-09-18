import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../profile/repositories/supabase_profile_repository.dart';

class AuthService {
  final SupabaseClient _client;
  AuthService(this._client);

  static SupabaseClient get supabase => Supabase.instance.client;
  static User? get currentUser => Supabase.instance.client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static String get currentUserLabel =>
      currentUser?.email?.split('@').first ?? 'Usuario';
  static Stream<AuthState> get authStateChanges =>
      Supabase.instance.client.auth.onAuthStateChange;

  Future<void> _ensureProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final repository = SupabaseProfileRepository(_client);
    try {
      await repository.getProfile(user.id);
    } catch (_) {
      final username = user.email?.split('@').first ?? 'user';
      await _client.from('profiles').insert({
        'id': user.id,
        'username': username,
        'display_name': username,
        'email': user.email ?? '',
        'avatar_url': '',
        'bio': '',
        'average_rating': 0.0,
        'total_ratings': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    await _ensureProfile();
  }

  Future<bool> signUp({required String email, required String password}) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.session != null) {
      await _ensureProfile();
    }
    return response.session != null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authServiceProvider = Provider.autoDispose<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

final authUserIdProvider = StreamProvider.autoDispose<String?>((ref) async* {
  final client = ref.watch(supabaseClientProvider);
  yield client.auth.currentUser?.id;
  await for (final authState in client.auth.onAuthStateChange) {
    yield authState.session?.user.id;
  }
});

final currentUserProvider = Provider.autoDispose<User?>((ref) {
  ref.watch(authUserIdProvider);
  final client = ref.watch(supabaseClientProvider);
  return client.auth.currentUser;
});

final authStateProvider = StreamProvider.autoDispose<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

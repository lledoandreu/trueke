import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) async* {
  final initialSession = Supabase.instance.client.auth.currentSession;
  if (initialSession != null) {
    yield AuthState(AuthChangeEvent.initialSession, initialSession);
  }
  yield* Supabase.instance.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? Supabase.instance.client.auth.currentUser;
});

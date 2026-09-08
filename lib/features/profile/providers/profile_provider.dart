import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/profile.dart';
import '../../auth/auth_service.dart';
import '../profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

final profileProvider = FutureProvider<Profile?>((ref) async {
  final userId = ref.watch(authUserIdProvider).value;

  if (userId == null) {
    return null;
  }

  return ref.read(profileRepositoryProvider).getMyProfile(userId);
});

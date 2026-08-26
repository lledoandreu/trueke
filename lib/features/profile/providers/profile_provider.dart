import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../profile_repository.dart';
import '../../../models/profile.dart';
import '../../auth/auth_service.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

final profileProvider = FutureProvider<Profile?>((ref) async {
  final userId = AuthService.currentUserId;

  if (userId == null) {
    return null;
  }

  final profile = await ref
      .read(profileRepositoryProvider)
      .getMyProfile(userId);

  return profile;
});

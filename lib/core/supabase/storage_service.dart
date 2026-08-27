import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  Future<String> uploadAvatar({
    required File file,
    required String userId,
  }) async {
    final extension = file.path.split('.').last;

    final path = '$userId/avatar.$extension';

    await _client.storage
        .from('avatars')
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    return _client.storage.from('avatars').getPublicUrl(path);
  }
}

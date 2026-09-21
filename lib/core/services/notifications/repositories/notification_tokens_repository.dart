import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class NotificationTokensRepository {
  Future<void> saveToken({required String userId, required String token});
  Future<void> deleteToken({required String token});
}

class SupabaseNotificationTokensRepository
    implements NotificationTokensRepository {
  SupabaseNotificationTokensRepository(this._client);

  final SupabaseClient _client;
  static const _tableName = 'user_push_tokens';

  @override
  Future<void> saveToken({
    required String userId,
    required String token,
  }) async {
    final deviceType = Platform.isAndroid
        ? 'android'
        : (Platform.isIOS ? 'ios' : 'web');

    await _client.from(_tableName).upsert({
      'user_id': userId,
      'token': token,
      'device_type': deviceType,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'token');
  }

  @override
  Future<void> deleteToken({required String token}) async {
    await _client.from(_tableName).delete().eq('token', token);
  }
}

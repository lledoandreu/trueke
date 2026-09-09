import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_history_model.dart';
import '../models/notification_model.dart';

class TransactionRepository {
  final SupabaseClient _client;

  TransactionRepository(this._client);

  // --- HISTORIAL DE TRANSACCIONES ---
  Future<List<TransactionHistory>> getTransactionHistory(String userId) async {
    final response = await _client
        .from('transaction_history')
        .select()
        .or('owner_id.eq.$userId,trader_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (json) => TransactionHistory.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> addTransaction(TransactionHistory transaction) async {
    await _client.from('transaction_history').insert(transaction.toJson());
  }

  // --- NOTIFICACIONES ---
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    await _client.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': false,
    });
  }
}

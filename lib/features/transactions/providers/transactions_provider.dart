import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../features/auth/auth_service.dart';
import '../models/notification_model.dart';
import '../models/transaction_history_model.dart';
import '../repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TransactionRepository(client);
});

final transactionHistoryProvider =
    FutureProvider.autoDispose<List<TransactionHistory>>((ref) async {
      final repository = ref.watch(transactionRepositoryProvider);
      final userId = AuthService.currentUser?.id;
      if (userId == null) {
        return [];
      }
      return repository.getTransactionHistory(userId);
    });

final notificationsProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
      final repository = ref.watch(transactionRepositoryProvider);
      final userId = AuthService.currentUser?.id;
      if (userId == null) {
        return [];
      }
      return repository.getNotifications(userId);
    });

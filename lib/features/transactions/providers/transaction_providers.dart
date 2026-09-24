import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/transaction.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(Supabase.instance.client);
});

final userTransactionsProvider =
    AsyncNotifierProvider<UserTransactionsNotifier, List<ProductTransaction>>(
      () {
        return UserTransactionsNotifier();
      },
    );

class UserTransactionsNotifier extends AsyncNotifier<List<ProductTransaction>> {
  @override
  Future<List<ProductTransaction>> build() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];
    return ref.read(transactionRepositoryProvider).getUserTransactions(user.id);
  }

  Future<void> createOffer(ProductTransaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(transactionRepositoryProvider)
          .createTransaction(transaction);
      final user = Supabase.instance.client.auth.currentUser;
      return ref
          .read(transactionRepositoryProvider)
          .getUserTransactions(user?.id ?? '');
    });
  }

  Future<void> changeStatus(String transactionId, String newStatus) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(transactionRepositoryProvider)
          .updateTransactionStatus(transactionId, newStatus);
      final user = Supabase.instance.client.auth.currentUser;
      return ref
          .read(transactionRepositoryProvider)
          .getUserTransactions(user?.id ?? '');
    });
  }
}

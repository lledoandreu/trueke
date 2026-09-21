import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/search/providers/search_repository_provider.dart';
import 'package:trueke/features/transactions/models/trade_transaction.dart';
import 'package:trueke/features/transactions/repositories/transactions_repository.dart';
import 'package:trueke/features/transactions/repositories/supabase_transactions_repository.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseTransactionsRepository(client);
});

class UserTransactionsNotifier extends AsyncNotifier<List<TradeTransaction>> {
  final String userId;

  UserTransactionsNotifier(this.userId);

  @override
  Future<List<TradeTransaction>> build() async {
    final repository = ref.watch(transactionsRepositoryProvider);
    return repository.getUserTransactions(userId);
  }

  Future<void> changeStatus(String transactionId, String newStatus) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionsRepositoryProvider);
      await repository.updateTransactionStatus(transactionId, newStatus);
      return repository.getUserTransactions(userId);
    });
  }

  Future<void> proposeTrade(TradeTransaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionsRepositoryProvider);
      await repository.createTransaction(transaction);
      return repository.getUserTransactions(userId);
    });
  }
}

final userTransactionsProvider = AsyncNotifierProvider.autoDispose
    .family<UserTransactionsNotifier, List<TradeTransaction>, String>(
      UserTransactionsNotifier.new,
    );

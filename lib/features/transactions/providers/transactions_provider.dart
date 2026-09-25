import 'package:trueke/features/chat/providers/chat_providers.dart';
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
    // Buscar la transacción en el estado actual antes de mutarlo para tener los detalles
    final currentTransactions = state.value ?? [];
    final transaction = currentTransactions.firstWhere(
      (t) => t.id == transactionId,
      orElse: () => TradeTransaction(
        id: '',
        senderId: '',
        receiverId: '',
        offeredProductId: '',
        requestedProductId: '',
        status: 'pending',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionsRepositoryProvider);
      await repository.updateTransactionStatus(transactionId, newStatus);

      // Si se localizó la transacción y tiene un producto válido, enviar mensaje de sistema
      if (transaction.id.isNotEmpty) {
        try {
          final chatRepo = ref.read(chatRepositoryProvider);
          final chatRoom = await chatRepo.getOrCreateChatRoom(
            productId: transaction.requestedProductId,
            buyerId: transaction.senderId,
            sellerId: transaction.receiverId,
          );

          await chatRepo.sendMessage(
            roomId: chatRoom.id,
            senderId: transaction.senderId,
            message:
                'El estado del trueque ha cambiado a: ${newStatus.toUpperCase()}',
            isSystem: true,
          );
        } catch (_) {
          // Loggear o ignorar errores de chat de forma segura para no romper el flujo principal
        }
      }

      return repository.getUserTransactions(userId);
    });
  }

  Future<void> proposeTrade(TradeTransaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionsRepositoryProvider);
      await repository.createTransaction(transaction);

      try {
        final chatRepo = ref.read(chatRepositoryProvider);
        final chatRoom = await chatRepo.getOrCreateChatRoom(
          productId: transaction.requestedProductId,
          buyerId: transaction.senderId,
          sellerId: transaction.receiverId,
        );

        await chatRepo.sendMessage(
          roomId: chatRoom.id,
          senderId: transaction.senderId,
          message: 'Se ha enviado una nueva propuesta de trueque.',
          isSystem: true,
        );
      } catch (_) {
        // Manejo silencioso de error en el chat
      }

      return repository.getUserTransactions(userId);
    });
  }
}

final userTransactionsProvider = AsyncNotifierProvider.autoDispose
    .family<UserTransactionsNotifier, List<TradeTransaction>, String>(
      UserTransactionsNotifier.new,
    );

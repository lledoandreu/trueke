import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/transactions/providers/transactions_provider.dart';
import 'package:trueke/features/transactions/models/trade_transaction.dart';
import 'package:trueke/features/escrow/presentation/widgets/escrow_status_widget.dart';

class UserTransactionsScreen extends ConsumerWidget {
  final String userId;

  const UserTransactionsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(userTransactionsProvider(userId));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Intercambios'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Enviados', icon: Icon(Icons.outbox)),
              Tab(text: 'Recibidos', icon: Icon(Icons.move_to_inbox)),
            ],
          ),
        ),
        body: transactionsAsync.when(
          data: (transactions) {
            final sent = transactions
                .where((t) => t.senderId == userId)
                .toList();
            final received = transactions
                .where((t) => t.receiverId == userId)
                .toList();

            return TabBarView(
              children: [
                _TransactionsList(
                  transactions: sent,
                  isSender: true,
                  userId: userId,
                ),
                _TransactionsList(
                  transactions: received,
                  isSender: false,
                  userId: userId,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Error: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionsList extends ConsumerWidget {
  final List<TradeTransaction> transactions;
  final bool isSender;
  final String userId;

  const _TransactionsList({
    required this.transactions,
    required this.isSender,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'No hay propuestas en esta categoría',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ExpansionTile(
            title: Text('Trueke: ${tx.id.substring(0, 8)}...'),
            subtitle: Text('Estado: ${tx.status.toUpperCase()}'),
            trailing: !isSender && tx.status == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => ref
                            .read(userTransactionsProvider(userId).notifier)
                            .changeStatus(tx.id, 'accepted'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => ref
                            .read(userTransactionsProvider(userId).notifier)
                            .changeStatus(tx.id, 'rejected'),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tx.status == 'accepted'
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tx.status,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
            children: [
              if (tx.status == 'accepted')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: EscrowStatusWidget(
                    tradeOfferId: tx.id,
                    currentUserId: userId,
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'La pasarela de pago seguro y tracking logístico se activarán una vez aceptado el intercambio.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

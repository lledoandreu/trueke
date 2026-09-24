import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/transaction.dart';
import '../../providers/transaction_providers.dart';

class UserTransactionsScreen extends ConsumerWidget {
  const UserTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(userTransactionsProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Intercambios'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Enviados (Mis Ofertas)'),
              Tab(text: 'Recibidos (Propuestas)'),
            ],
          ),
        ),
        body: transactionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (transactions) {
            final sentOffers = transactions
                .where((t) => t.buyerId == currentUserId)
                .toList();
            final receivedOffers = transactions
                .where((t) => t.sellerId == currentUserId)
                .toList();

            return TabBarView(
              children: [
                _OffersList(offers: sentOffers, isReceived: false),
                _OffersList(offers: receivedOffers, isReceived: true),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OffersList extends ConsumerWidget {
  final List<ProductTransaction> offers;
  final bool isReceived;

  const _OffersList({required this.offers, required this.isReceived});

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.accepted:
        return Colors.blue;
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pendiente';
      case TransactionStatus.accepted:
        return 'Aceptado';
      case TransactionStatus.completed:
        return 'Completado';
      case TransactionStatus.cancelled:
        return 'Cancelado';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (offers.isEmpty) {
      return const Center(child: Text('No hay ofertas en esta categoría.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        offer.productTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        _getStatusLabel(offer.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: _getStatusColor(offer.status),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isReceived
                      ? 'De: ${offer.buyerName}'
                      : 'Vendedor: ${offer.sellerName}',
                ),
                if (offer.price != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Compensación económica: ${offer.price!.toStringAsFixed(2)} €',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
                if (isReceived &&
                    offer.status == TransactionStatus.pending) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          ref
                              .read(userTransactionsProvider.notifier)
                              .changeStatus(
                                offer.id,
                                TransactionStatus.cancelled.name,
                              );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Rechazar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(userTransactionsProvider.notifier)
                              .changeStatus(
                                offer.id,
                                TransactionStatus.accepted.name,
                              );
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                ],
                if (offer.status == TransactionStatus.accepted) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(userTransactionsProvider.notifier)
                              .changeStatus(
                                offer.id,
                                TransactionStatus.completed.name,
                              );
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Finalizar Trato'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/trade_offer.dart';
import '../chat/chat_detail_page.dart';
import '../chat/providers/chat_provider.dart';
import 'providers/trade_offers_provider.dart';

class TradeOffersPage extends ConsumerWidget {
  const TradeOffersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(tradeOffersProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis propuestas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Recibidas'),
              Tab(text: 'Enviadas'),
            ],
          ),
        ),
        body: offersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Error cargando propuestas: $error')),
          data: (offers) {
            final incoming = offers.where((offer) => offer.isIncoming).toList();
            final outgoing = offers
                .where((offer) => !offer.isIncoming)
                .toList();

            return TabBarView(
              children: [
                _OffersList(
                  offers: incoming,
                  emptyLabel: 'No te han enviado propuestas.',
                ),
                _OffersList(
                  offers: outgoing,
                  emptyLabel: 'Aún no has enviado propuestas.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OffersList extends StatelessWidget {
  const _OffersList({required this.offers, required this.emptyLabel});

  final List<TradeOffer> offers;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(emptyLabel, textAlign: TextAlign.center),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _OfferTile(offer: offers[index]),
    );
  }
}

class _OfferTile extends ConsumerWidget {
  const _OfferTile({required this.offer});

  final TradeOffer offer;

  String get _statusLabel {
    return switch (offer.status) {
      TradeOfferStatus.sent => offer.isIncoming ? 'Pendiente' : 'Enviada',
      TradeOfferStatus.accepted => 'Aceptada',
      TradeOfferStatus.declined => 'Rechazada',
    };
  }

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    TradeOfferStatus status,
  ) async {
    try {
      await ref
          .read(tradeOffersProvider.notifier)
          .respondToOffer(offer: offer, status: status);

      ref.invalidate(chatProvider);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == TradeOfferStatus.accepted
                ? 'Propuesta aceptada.'
                : 'Propuesta rechazada.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la propuesta. $error')),
      );
    }
  }

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    final conversationId = offer.conversationId;
    if (conversationId == null) {
      return;
    }

    await ref.read(chatProvider.future);

    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatDetailPage(conversationId: conversationId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offered = offer.offeredProductTitle;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
              title: Text(offer.productTitle),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    offer.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (offered != null && offered.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      offer.isIncoming
                          ? 'Te ofrecen: $offered'
                          : 'Ofreces: $offered',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
              trailing: Chip(label: Text(_statusLabel)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => _openChat(context, ref),
                    child: const Text('Abrir chat'),
                  ),
                  const Spacer(),
                  if (offer.isIncoming && offer.isPending) ...[
                    TextButton(
                      onPressed: () =>
                          _respond(context, ref, TradeOfferStatus.declined),
                      child: const Text('Rechazar'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () =>
                          _respond(context, ref, TradeOfferStatus.accepted),
                      child: const Text('Aceptar'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

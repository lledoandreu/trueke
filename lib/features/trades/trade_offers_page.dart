import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/trade_offer.dart';
import 'providers/trade_offers_provider.dart';

class TradeOffersPage extends ConsumerWidget {
  const TradeOffersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(tradeOffersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis propuestas')),
      body: offersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error cargando propuestas: $error')),
        data: (offers) => offers.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Aún no has enviado propuestas de intercambio.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: offers.length,
                separatorBuilder: (_, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _OfferTile(offer: offers[index]),
              ),
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer});

  final TradeOffer offer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
        title: Text(offer.productTitle),
        subtitle: Text(
          offer.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Chip(label: Text('Enviada')),
      ),
    );
  }
}

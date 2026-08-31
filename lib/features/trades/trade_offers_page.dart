import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/trade_offer.dart';
import 'providers/trade_offers_provider.dart';

class TradeOffersPage extends ConsumerWidget {
  const TradeOffersPage({super.key});

  Future<void> _respond(
    BuildContext context,
    WidgetRef ref,
    TradeOffer offer,
    TradeOfferStatus status,
  ) async {
    try {
      await ref
          .read(tradeOffersProvider.notifier)
          .respondToOffer(offer: offer, status: status);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == TradeOfferStatus.accepted
                ? 'Oferta aceptada.'
                : 'Oferta rechazada.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se ha podido actualizar la oferta. $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(tradeOffersProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mis Intercambios',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Recibidas', icon: Icon(Icons.download_rounded)),
              Tab(text: 'Enviadas', icon: Icon(Icons.upload_rounded)),
            ],
          ),
        ),
        body: offersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No se han podido cargar las propuestas.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      ref.invalidate(tradeOffersProvider);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          data: (offers) => TabBarView(
            children: [
              _OffersList(
                offers: offers.where((offer) => offer.isIncoming).toList(),
                onRespond: (offer, status) =>
                    _respond(context, ref, offer, status),
              ),
              _OffersList(
                offers: offers.where((offer) => !offer.isIncoming).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OffersList extends StatelessWidget {
  const _OffersList({required this.offers, this.onRespond});

  final List<TradeOffer> offers;
  final Future<void> Function(TradeOffer offer, TradeOfferStatus status)?
  onRespond;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return const Center(child: Text('No hay propuestas de intercambio.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final offer = offers[index];

        return _OfferCard(offer: offer, onRespond: onRespond);
      },
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, this.onRespond});

  final TradeOffer offer;
  final Future<void> Function(TradeOffer offer, TradeOfferStatus status)?
  onRespond;

  Color _statusColor() {
    switch (offer.status) {
      case TradeOfferStatus.sent:
        return Colors.orange;
      case TradeOfferStatus.accepted:
        return Colors.green;
      case TradeOfferStatus.rejected:
        return Colors.red;
    }
  }

  String _statusText() {
    switch (offer.status) {
      case TradeOfferStatus.sent:
        return 'Pendiente';
      case TradeOfferStatus.accepted:
        return 'Aceptado';
      case TradeOfferStatus.rejected:
        return 'Rechazado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canRespond = offer.isIncoming && offer.isPending && onRespond != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Oferta #${offer.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText(),
                    style: TextStyle(
                      color: _statusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              offer.productTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(offer.message),
            if (offer.offeredProductTitle != null) ...[
              const SizedBox(height: 12),
              Text(
                'Ofrece: ${offer.offeredProductTitle}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
            if (canRespond) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        onRespond!(offer, TradeOfferStatus.rejected),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text(
                      'Rechazar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () =>
                        onRespond!(offer, TradeOfferStatus.accepted),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Aceptar'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

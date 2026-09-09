import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/models/trade_offer.dart';
import 'package:trueke/features/trades/providers/trade_offers_provider.dart';
import '../../app/routes/app_routes.dart';

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

      if (!context.mounted) return;

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
      if (!context.mounted) return;

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
          data: (List<TradeOffer> offers) => TabBarView(
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
    final isAccepted = offer.status == TradeOfferStatus.accepted;
    final otherUserId = offer.isIncoming ? offer.fromUserId : offer.toUserId;

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
                    'Oferta #${offer.id.length > 8 ? offer.id.substring(0, 8) : offer.id}',
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
                    color: _statusColor().withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText(),
                    style: TextStyle(
                      color: _statusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Producto: ${offer.productTitle}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (offer.offeredProductTitle != null) ...[
              const SizedBox(height: 4),
              Text(
                'A cambio de: ${offer.offeredProductTitle}',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(offer.message, style: const TextStyle(color: Colors.black87)),
            if (canRespond) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        onRespond!(offer, TradeOfferStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Rechazar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () =>
                        onRespond!(offer, TradeOfferStatus.accepted),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            ],
            if (isAccepted && otherUserId != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.writeReview,
                        arguments: otherUserId,
                      );
                    },
                    icon: const Icon(
                      Icons.star_rate_rounded,
                      color: Colors.amber,
                    ),
                    label: const Text('Valorar trueque'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                    ),
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

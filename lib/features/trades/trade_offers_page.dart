import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trade_offer.dart';
import 'providers/trade_provider.dart';

class TradeOffersPage extends ConsumerWidget {
  const TradeOffersPage({super.key});

  void _handleStatusUpdate(BuildContext context, WidgetRef ref, String offerId, String newStatus) async {
    final success = await ref.read(tradeRepositoryProvider).updateOfferStatus(offerId, newStatus);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oferta ${newStatus == 'accepted' ? 'aceptada' : 'rechazada'} con éxito')),
        );
        // Refrescamos los proveedores de forma automática para actualizar la pantalla
        ref.invalidate(incomingOffersProvider);
        ref.invalidate(outgoingOffersProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el estado de la oferta')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingAsync = ref.watch(incomingOffersProvider);
    final outgoingAsync = ref.watch(outgoingOffersProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Intercambios', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Recibidas', icon: Icon(Icons.download_rounded)),
              Tab(text: 'Enviadas', icon: Icon(Icons.upload_rounded)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña 1: Ofertas Recibidas
            incomingAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (offers) => _OffersList(offers: offers, isIncoming: true, onAction: (id, status) => _handleStatusUpdate(context, ref, id, status)),
            ),
            // Pestaña 2: Ofertas Enviadas
            outgoingAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (offers) => _OffersList(offers: offers, isIncoming: false, onAction: null),
            ),
          ],
        ),
      ),
    );
  }
}

class _OffersList extends StatelessWidget {
  final List<TradeOffer> offers;
  final bool isIncoming;
  final void Function(String id, String status)? onAction;

  const _OffersList({required this.offers, required this.isIncoming, this.onAction});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted': return 'Aceptado';
      case 'rejected': return 'Rechazado';
      default: return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return const Center(child: Text('No hay propuestas de intercambio en esta sección.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final offer = offers[index];
        final isPending = offer.status == 'pending';

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    Text('Oferta # ${offer.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(offer.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(offer.status),
                        style: TextStyle(color: _getStatusColor(offer.status), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text('Detalle del Trueke:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('ID del Producto Ofrecido: ${offer.offeredProductId}'),
                const SizedBox(height: 4),
                if (offer.notes != null && offer.notes!.isNotEmpty)
                  Text('Nota: "${offer.notes}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
                if (isIncoming && isPending && onAction != null) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => onAction!(offer.id, 'rejected'),
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('Rechazar', style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => onAction!(offer.id, 'accepted'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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
      },
    );
  }
}

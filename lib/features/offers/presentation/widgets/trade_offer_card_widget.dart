import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trueke/features/offers/models/trade_offer.dart';
import 'package:trueke/features/offers/providers/trade_offer_provider.dart';

class TradeOfferCard extends ConsumerWidget {
  final TradeOffer offer;
  final String currentUserId;

  const TradeOfferCard({
    super.key,
    required this.offer,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSender = offer.senderId == currentUserId;
    final isPending = offer.status == TradeOfferStatus.pending;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isSender ? 'Propuesta Enviada' : 'Propuesta Recibida',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSender ? Colors.blue : Colors.orange,
                  ),
                ),
                _buildStatusChip(offer.status),
              ],
            ),
            const Divider(height: 24),
            Text('Producto Ofrecido ID: ${offer.senderProductId}'),
            const SizedBox(height: 4),
            Text('A cambio de ID: ${offer.receiverProductId}'),
            if (offer.additionalCash > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Compensación Económica: +${offer.additionalCash.toStringAsFixed(2)}€',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
            if (isPending && !isSender) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showConfirmationDialog(
                      context,
                      ref,
                      '¿Rechazar esta propuesta?',
                      TradeOfferStatus.declined,
                    ),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Rechazar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _showConfirmationDialog(
                      context,
                      ref,
                      '¿Aceptar este intercambio directo?',
                      TradeOfferStatus.accepted,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Aceptar Trueke'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(TradeOfferStatus status) {
    Color color;
    String label;
    switch (status) {
      case TradeOfferStatus.pending:
        color = Colors.amber;
        label = 'Pendiente';
        break;
      case TradeOfferStatus.accepted:
        color = Colors.green;
        label = 'Aceptado';
        break;
      case TradeOfferStatus.declined:
        color = Colors.red;
        label = 'Rechazado';
        break;
      case TradeOfferStatus.canceled:
        color = Colors.grey;
        label = 'Cancelado';
        break;
    }
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    TradeOfferStatus targetStatus,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text(
          'Esta acción modificará el estado del trueque de forma irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(userTradeOffersProvider.notifier)
                  .resolveOffer(offer.id, targetStatus);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: targetStatus == TradeOfferStatus.accepted
                  ? Colors.green
                  : Colors.red,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

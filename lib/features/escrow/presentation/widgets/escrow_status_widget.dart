import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/escrow_transaction.dart';
import '../../providers/escrow_notifier.dart';
import '../../providers/escrow_state.dart';

class EscrowStatusWidget extends ConsumerStatefulWidget {
  final String tradeOfferId;
  final String currentUserId;

  const EscrowStatusWidget({
    super.key,
    required this.tradeOfferId,
    required this.currentUserId,
  });

  @override
  ConsumerState<EscrowStatusWidget> createState() => _EscrowStatusWidgetState();
}

class _EscrowStatusWidgetState extends ConsumerState<EscrowStatusWidget> {
  final _formKey = GlobalKey<FormState>();
  final _trackingController = TextEditingController();
  final _carrierController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(escrowNotifierProvider(widget.tradeOfferId).notifier)
          .fetchEscrowByTradeOfferId();
    });
  }

  @override
  void dispose() {
    _trackingController.dispose();
    _carrierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final escrowState = ref.watch(escrowNotifierProvider(widget.tradeOfferId));

    if (escrowState is EscrowInitial || escrowState is EscrowLoading) {
      return const Card(
        margin: EdgeInsets.all(12),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (escrowState is EscrowError) {
      return Card(
        margin: const EdgeInsets.all(12),
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  escrowState.message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (escrowState is EscrowLoaded) {
      final tx = escrowState.transaction;
      final isSeller = widget.currentUserId == tx.sellerId;

      return Card(
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(tx),
              const Divider(height: 24),
              _buildStatusTimeline(tx.status),
              const Divider(height: 24),
              _buildTrackingDetails(tx),
              if (isSeller && tx.status == EscrowStatus.heldInEscrow) ...[
                const SizedBox(height: 16),
                _buildLogisticsForm(tx.id),
              ],
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildHeader(EscrowTransaction tx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Garantía Anti-Fraude (Stripe Escrow)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Ref: ${tx.id.substring(0, 8).toUpperCase()}...',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${tx.amount.toStringAsFixed(2)} ${tx.currency.toUpperCase()}',
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(EscrowStatus currentStatus) {
    final stages = [
      {'status': EscrowStatus.pendingDeposit, 'label': 'Depósito'},
      {'status': EscrowStatus.heldInEscrow, 'label': 'Custodia'},
      {'status': EscrowStatus.shipped, 'label': 'Enviado'},
      {'status': EscrowStatus.delivered, 'label': 'Entregado'},
    ];

    int currentIndex = stages.indexWhere((s) => s['status'] == currentStatus);
    if (currentStatus == EscrowStatus.released) currentIndex = 3;
    if (currentStatus == EscrowStatus.refunded) currentIndex = 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stages.length, (index) {
        final isCompleted = index <= currentIndex;
        final color = isCompleted ? Colors.green : Colors.grey.shade300;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stages[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCompleted
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCompleted ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
              if (index < stages.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentIndex
                        ? Colors.green
                        : Colors.grey.shade300,
                    margin: const EdgeInsets.only(bottom: 16),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTrackingDetails(EscrowTransaction tx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información de Envío',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        if (tx.trackingNumber != null) ...[
          _buildInfoRow(
            Icons.local_shipping,
            'Transportista:',
            tx.carrier ?? 'N/A',
          ),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.tag, 'Localizador:', tx.trackingNumber!),
        ] else ...[
          Row(
            children: [
              Icon(
                Icons.pending_actions,
                color: Colors.amber.shade700,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Esperando que el vendedor deposite el paquete y añada el tracking logístico.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLogisticsForm(String escrowId) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Panel de Envío (Vendedor)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _carrierController,
                  decoration: const InputDecoration(
                    labelText: 'Courier (Ej: Correos)',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _trackingController,
                  decoration: const InputDecoration(
                    labelText: 'Número Tracking',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ref
                      .read(
                        escrowNotifierProvider(widget.tradeOfferId).notifier,
                      )
                      .addTrackingLogistics(
                        escrowId: escrowId,
                        trackingNumber: _trackingController.text.trim(),
                        carrier: _carrierController.text.trim(),
                      );
                }
              },
              icon: const Icon(Icons.send_and_archive, size: 16),
              label: const Text(
                'Confirmar Envío y Bloquear Fondos',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

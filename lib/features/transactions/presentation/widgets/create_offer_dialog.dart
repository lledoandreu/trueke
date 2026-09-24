import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/product.dart';
import '../../../../models/transaction.dart';
import '../../providers/transaction_providers.dart';

class CreateOfferDialog extends ConsumerStatefulWidget {
  final Product product;

  const CreateOfferDialog({super.key, required this.product});

  @override
  ConsumerState<CreateOfferDialog> createState() => _CreateOfferDialogState();
}

class _CreateOfferDialogState extends ConsumerState<CreateOfferDialog> {
  final _priceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    final proposedPrice = double.tryParse(_priceController.text);

    final transaction = ProductTransaction(
      id: '',
      productId: widget.product.id,
      productTitle: widget.product.title,
      sellerId: widget.product.ownerId ?? '',
      sellerName: widget.product.owner,
      buyerId: currentUser.id,
      buyerName: currentUser.email?.split('@').first ?? 'Comprador',
      price: proposedPrice,
      status: TransactionStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(userTransactionsProvider.notifier).createOffer(transaction);

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Proponer Trueke'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Quieres proponer un intercambio por ${widget.product.title}?',
            ),
            const SizedBox(height: 16),
            if (widget.product.tradeType == TradeType.tradeAndMoney ||
                widget.product.tradeType == TradeType.sale)
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Compensación económica (€)',
                  border: OutlineInputBorder(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitOffer,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar Oferta'),
        ),
      ],
    );
  }
}

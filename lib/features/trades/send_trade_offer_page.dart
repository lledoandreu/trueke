import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../chat/providers/chat_provider.dart';
import 'providers/trade_offers_provider.dart';

class SendTradeOfferPage extends ConsumerStatefulWidget {
  const SendTradeOfferPage({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  ConsumerState<SendTradeOfferPage> createState() =>
      _SendTradeOfferPageState();
}

class _SendTradeOfferPageState
    extends ConsumerState<SendTradeOfferPage> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController(
      text:
          'Hola ${widget.product.owner}, me interesa tu artículo. ¿Hablamos de un posible intercambio?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    await ref.read(tradeOffersProvider.notifier).sendOffer(
          productId: widget.product.id,
          productTitle: widget.product.title,
          message: message,
        );

    await ref.read(chatProvider.notifier).startConversation(
          productId: widget.product.id,
          productTitle: widget.product.title,
          owner: widget.product.owner,
          message: message,
        );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Propuesta enviada.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proponer intercambio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Propuesta para ${widget.product.owner}',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _messageController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _send,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Enviar propuesta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

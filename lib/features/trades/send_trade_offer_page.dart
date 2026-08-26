import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../auth/auth_service.dart';
import '../chat/providers/chat_provider.dart';
import 'providers/trade_offers_provider.dart';

class SendTradeOfferPage extends ConsumerStatefulWidget {
  const SendTradeOfferPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<SendTradeOfferPage> createState() => _SendTradeOfferPageState();
}

class _SendTradeOfferPageState extends ConsumerState<SendTradeOfferPage> {
  late final TextEditingController _messageController;
  bool _isSending = false;

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

    if (message.isEmpty || _isSending) {
      return;
    }

    final currentUserId = AuthService.currentUserId;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicia sesión para enviar una propuesta.'),
        ),
      );
      return;
    }

    if (widget.product.ownerId == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes proponer un intercambio sobre tu anuncio.'),
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await ref
          .read(tradeOffersProvider.notifier)
          .sendOffer(product: widget.product, message: message);

      ref.invalidate(chatProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Propuesta enviada.')));

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se ha podido enviar la propuesta. $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proponer intercambio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Propuesta para ${widget.product.owner}'),
            const SizedBox(height: 24),
            TextField(
              controller: _messageController,
              minLines: 4,
              maxLines: 6,
              enabled: !_isSending,
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
                onPressed: _isSending ? null : _send,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_isSending ? 'Enviando...' : 'Enviar propuesta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

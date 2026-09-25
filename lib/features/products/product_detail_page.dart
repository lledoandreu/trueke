import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../presentation/providers/favorite_provider.dart';
import '../../models/product.dart';
import '../auth/auth_service.dart';
import 'package:trueke/features/chat/presentation/pages/chat_screen.dart';
import 'package:trueke/features/chat/providers/chat_providers.dart';
import 'package:trueke/features/transactions/presentation/widgets/create_offer_dialog.dart';
import 'widgets/product_description.dart';
import 'widgets/product_gallery.dart';
import 'widgets/product_info.dart';
import 'widgets/seller_card.dart';
import 'widgets/trade_info.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  bool _isStartingChat = false;

  bool get _isOwner => widget.product.ownerId == AuthService.currentUserId;

  Future<void> _handleStartChat() async {
    if (_isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes chatear contigo mismo.')),
      );
      return;
    }

    final currentUserId = AuthService.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para poder chatear.')),
      );
      return;
    }

    setState(() => _isStartingChat = true);

    try {
      final chatRepo = ref.read(chatRepositoryProvider);

      // Consumimos el nuevo repositorio inmutable (singular)
      final chatRoomEntity = await chatRepo.getOrCreateChatRoom(
        productId: widget.product.id,
        sellerId: widget.product.ownerId ?? '',
        buyerId: currentUserId,
      );

      // Enviamos el mensaje inicial usando las firmas nuevas del repositorio
      await chatRepo.sendMessage(
        roomId: chatRoomEntity.id,
        senderId: currentUserId,
        message: '¡Hola! Me interesa tu artículo "${widget.product.title}".',
      );

      if (!mounted) return;

      // Navegamos a la nueva interfaz limpia
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatScreen(roomId: chatRoomEntity.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al iniciar chat: $e')));
    } finally {
      if (mounted) {
        setState(() => _isStartingChat = false);
      }
    }
  }

  void _handleTradeOffer() {
    if (_isOwner) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Este anuncio es tuyo.')));
      return;
    }

    showDialog<bool>(
      context: context,
      builder: (context) => CreateOfferDialog(product: widget.product),
    ).then((success) {
      if (success == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Oferta de trueke enviada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUserId;
    final favoriteIdsAsync = userId != null
        ? ref.watch(favoriteIdsProvider(userId))
        : const AsyncValue<List<String>>.data([]);
    final isFav = favoriteIdsAsync.value?.contains(widget.product.id) ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ProductGallery(product: widget.product),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductInfo(product: widget.product),
                  const Divider(height: 40),
                  ProductDescription(product: widget.product),
                  if (widget.product.wanted.isNotEmpty) ...[
                    const Divider(height: 40),
                    TradeInfo(product: widget.product),
                  ],
                  const Divider(height: 40),
                  SellerCard(product: widget.product),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inicia sesión para guardar favoritos.'),
              ),
            );
            return;
          }

          await ref
              .read(favoriteNotifierProvider.notifier)
              .toggle(userId, widget.product.id, isFav);
        },
        child: favoriteIdsAsync.when(
          data: (_) => Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? AppColors.primary : Colors.grey,
          ),
          loading: () => const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (_, _) => const Icon(Icons.error_outline, color: Colors.red),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isStartingChat ? null : _handleStartChat,
                  icon: _isStartingChat
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chatear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _handleTradeOffer,
                  icon: const Icon(Icons.swap_horizontal_circle_outlined),
                  label: const Text('Ofertar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

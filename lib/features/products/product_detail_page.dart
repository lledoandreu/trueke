import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/favorites_provider.dart';
import '../../models/product.dart';
import '../auth/auth_service.dart';
import 'package:trueke/features/chat/chat_detail_page.dart';
import '../chat/providers/chat_provider.dart';
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

    setState(() => _isStartingChat = true);

    try {
      final conversationId = await ref
          .read(chatProvider.notifier)
          .startConversation(
            product: widget.product,
            message:
                '¡Hola! Me interesa tu artículo "${widget.product.title}".',
          );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChatDetailPage(conversationId: conversationId),
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

    Navigator.pushNamed(
      context,
      AppRoutes.sendTradeOffer,
      arguments: widget.product,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFav = ref
        .watch(favoritesProvider.notifier)
        .isFavorite(widget.product);

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
        onPressed: () =>
            ref.read(favoritesProvider.notifier).toggleFavorite(widget.product),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Colors.red : Colors.grey,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isStartingChat ? null : _handleStartChat,
                  icon: _isStartingChat
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _handleTradeOffer,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Ofertar Trueque'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  String _tradeLabel() {
    switch (product.tradeType) {
      case TradeType.trade:
        return 'Trueque';
      case TradeType.sale:
        return 'Venta';
      case TradeType.tradeAndMoney:
        return 'Trueque + dinero';
    }
  }

  IconData _tradeIcon() {
    switch (product.tradeType) {
      case TradeType.trade:
        return Icons.swap_horiz;
      case TradeType.sale:
        return Icons.euro;
      case TradeType.tradeAndMoney:
        return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: product.imageUrl.isNotEmpty
                  ? Image.asset(product.imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFFE5E7EB),
                      child: Icon(
                        Icons.image_outlined,
                        size: 72,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title, style: AppTextStyles.title),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(_tradeIcon(), size: 18),
                    const SizedBox(width: 6),
                    Text(_tradeLabel()),
                  ],
                ),

                const SizedBox(height: 8),

                if (product.price != null)
                  Text(
                    '${product.price!.toStringAsFixed(0)} €',
                    style: AppTextStyles.body,
                  ),

                const SizedBox(height: 8),

                Text(product.condition, style: AppTextStyles.body),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text(product.location),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18),
                    const SizedBox(width: 4),
                    Text(product.owner),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

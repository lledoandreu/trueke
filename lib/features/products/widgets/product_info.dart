import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/product.dart';

class ProductInfo extends StatelessWidget {
  final Product product;

  const ProductInfo({super.key, required this.product});

  String get tradeLabel {
    switch (product.tradeType) {
      case TradeType.trade:
        return 'TRUEQUE';
      case TradeType.sale:
        return 'VENTA';
      case TradeType.tradeAndMoney:
        return 'TRUEQUE + €';
    }
  }

  Color get tradeColor {
    switch (product.tradeType) {
      case TradeType.trade:
        return Colors.green;
      case TradeType.sale:
        return Colors.blue;
      case TradeType.tradeAndMoney:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: tradeColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            tradeLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          product.title,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        if (product.price != null)
          Text(
            '${product.price!.toStringAsFixed(0)} €',
            style: const TextStyle(
              fontSize: 38,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

        const SizedBox(height: 18),

        Row(
          children: [
            const Icon(Icons.verified_outlined),
            const SizedBox(width: 8),
            Text(product.condition),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            const Icon(Icons.location_on_outlined),
            const SizedBox(width: 8),
            Text(product.location),
          ],
        ),
      ],
    );
  }
}

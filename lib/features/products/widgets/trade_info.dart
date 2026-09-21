import 'package:flutter/material.dart';

import '../../../models/product.dart';

class TradeInfo extends StatelessWidget {
  final Product product;

  const TradeInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Busca a cambio',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 0,
          color: const Color(0xFFF5F7FA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              product.wanted,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/product.dart';

class SellerCard extends StatelessWidget {
  final Product product;

  const SellerCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vendedor',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 0,
          color: const Color(0xFFF8F9FA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFD9F8E5),
              child: Icon(Icons.person, color: AppColors.primary),
            ),
            title: Text(
              product.owner,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: const Text('Miembro verificado\n⭐ 4.9 · 58 valoraciones'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

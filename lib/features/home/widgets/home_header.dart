import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/shell_index_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../trades/trade_offers_page.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Text('Trueke', style: AppTextStyles.heading1)),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TradeOffersPage()),
              );
            },
            icon: const Icon(Icons.notifications_none),
            color: AppColors.textPrimary,
            tooltip: 'Propuestas',
          ),
          IconButton(
            onPressed: () {
              ref.read(shellIndexProvider.notifier).state = 4;
            },
            icon: const Icon(Icons.person_outline),
            color: AppColors.textPrimary,
            tooltip: 'Perfil',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Text('Trueke', style: AppTextStyles.heading1)),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
            color: AppColors.textPrimary,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

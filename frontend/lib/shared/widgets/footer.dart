import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class Footer extends StatelessWidget {
  const Footer({super.key, this.label  = 'Laith — made with love'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.4,
        child: Column(
          children: [
            Container(
              height: 1,
              width: 96,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primaryDim,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: AppTextStyles.micro.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

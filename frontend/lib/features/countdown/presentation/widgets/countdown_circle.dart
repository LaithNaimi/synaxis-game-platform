import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class CountdownCircle extends StatelessWidget {
  const CountdownCircle({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 3),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primaryGlow,
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          value > 0 ? '$value' : 'GO',
          style: AppTextStyles.heroDisplay.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}

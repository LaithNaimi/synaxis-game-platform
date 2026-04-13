import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class SynaxisTextField extends StatelessWidget {
  const SynaxisTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.icon,
    this.maxLength,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? icon;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelUppercase.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        TextFormField(
          controller: controller,
          maxLength: maxLength,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: icon != null
                ? Icon(icon, color: AppColors.onSurfaceVariant, size: 20)
                : null,
          ),
        ),
      ],
    );
  }
}

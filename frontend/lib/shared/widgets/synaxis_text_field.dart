import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Dark-themed text input field matching Cyanide Pulse design.
///
/// Features dark fill, no visible border at rest, cyan glow on focus,
/// optional suffix icon, and uppercase label.
class SynaxisTextField extends StatelessWidget {
  const SynaxisTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.suffixIcon,
    this.errorText,
    this.obscureText = false,
    this.maxLength,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? suffixIcon;
  final String? errorText;
  final bool obscureText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Uppercase tactical label
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelUppercase.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Input field
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          enabled: enabled,
          style: AppTextStyles.body.copyWith(
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '', // hide max-length counter
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.onSurfaceVariant, size: 20)
                : null,
            errorText: errorText,
            errorStyle: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}

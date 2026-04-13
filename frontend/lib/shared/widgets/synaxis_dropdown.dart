import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Dark-themed dropdown matching Cyanide Pulse design.
///
/// Styled to match the dark input fields with uppercase label.
class SynaxisDropdown<T> extends StatelessWidget {
  const SynaxisDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.icon,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final IconData? icon;

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

        // Dropdown
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              dropdownColor: AppColors.surfaceContainerHigh,
              icon: Icon(
                icon ?? Icons.keyboard_arrow_down,
                color: AppColors.onSurfaceVariant,
              ),
              style: AppTextStyles.body.copyWith(color: AppColors.onSurface),
            ),
          ),
        ),
      ],
    );
  }
}

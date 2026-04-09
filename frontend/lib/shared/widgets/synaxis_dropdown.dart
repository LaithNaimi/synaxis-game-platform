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
    this.hint,
    this.suffixIcon,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final IconData? suffixIcon;

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
                suffixIcon ?? Icons.keyboard_arrow_down,
                color: AppColors.onSurfaceVariant,
              ),
              hint: hint != null
                  ? Text(
                      hint!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    )
                  : null,
              style: AppTextStyles.body.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

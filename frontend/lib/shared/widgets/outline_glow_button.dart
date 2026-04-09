import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Secondary CTA button — outlined, translucent fill, cyan border.
///
/// Used for "Join Room" on Home screen and secondary actions.
class OutlineGlowButton extends StatelessWidget {
  const OutlineGlowButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  bool get _isDisabled => onPressed == null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final opacity = _isDisabled ? 0.4 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        width: isExpanded ? double.infinity : null,
        constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppRadius.full),
            splashColor: AppColors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 14,
              ),
              child: Row(
                mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading) ...[
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (icon != null && !isLoading) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(icon, color: AppColors.primary, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

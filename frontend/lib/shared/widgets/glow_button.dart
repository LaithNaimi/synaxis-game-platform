import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Primary CTA button — cyan gradient fill, pill shape, ambient glow.
///
/// Supports loading and disabled states per DDS §5 Global Components.
class GlowButton extends StatelessWidget {
  const GlowButton({
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

  /// If true, button stretches to fill available width.
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
          gradient: _isDisabled
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryContainer,
                  ],
                ),
          color: _isDisabled ? AppColors.surfaceContainerHigh : null,
          boxShadow: _isDisabled
              ? null
              : const [
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 30,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppRadius.full),
            splashColor: AppColors.primary.withValues(alpha: 0.2),
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
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (icon != null && !isLoading) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(icon, color: AppColors.onPrimary, size: 20),
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

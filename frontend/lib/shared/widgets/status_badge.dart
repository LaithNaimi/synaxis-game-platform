import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

enum StatusBadgeVariant {
  /// Cyan primary (e.g. HOST, CONNECTED, MATCH MVP).
  primary,

  /// Green success (e.g. SOLVED).
  success,

  /// Red/pink error (e.g. Slow Ping).
  error,

  /// Amber warning (e.g. SUDDEN DEATH).
  warning,

  /// Muted neutral.
  neutral,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.primary,
    this.showDot = false,
    this.icon,
  });

  final String label;
  final StatusBadgeVariant variant;

  final bool showDot;
  final IconData? icon;

  Color get _color {
    switch (variant) {
      case StatusBadgeVariant.primary:
        return AppColors.primary;
      case StatusBadgeVariant.success:
        return AppColors.success;
      case StatusBadgeVariant.error:
        return AppColors.error;
      case StatusBadgeVariant.warning:
        return AppColors.warning;
      case StatusBadgeVariant.neutral:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          if (icon != null) ...[
            Icon(icon, color: _color, size: 12),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label.toUpperCase(),
            style: AppTextStyles.micro.copyWith(
              color: _color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

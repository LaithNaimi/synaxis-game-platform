import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Frosted-glass container with backdrop blur and subtle cyan border.
///
/// Used for form panels (Create Room, Join Room) and settings cards.
class GlassmorphicPanel extends StatelessWidget {
  const GlassmorphicPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lg;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppGlow.panelBlur,
          sigmaY: AppGlow.panelBlur,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppColors.panelBorder,
            ),
          ),
          padding: padding ??
              const EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}

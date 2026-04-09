import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Pill-shaped floating app bar matching Cyanide Pulse design.
///
/// Features:
/// - Rounded-full shape with backdrop blur
/// - SYNAXIS branding in uppercase tracked Space Grotesk
/// - Back arrow on left, optional trailing widget (e.g. timer icon) on right
/// - Ambient glow shadow
class SynaxisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SynaxisAppBar({
    super.key,
    this.title = 'SYNAXIS',
    this.showBackButton = true,
    this.onBack,
    this.trailing,
    this.centerContent,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? trailing;

  /// Optional widget displayed between title and trailing (e.g. "CONNECTED" status).
  final Widget? centerContent;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppGlow.appBarBackdropBlur,
              sigmaY: AppGlow.appBarBackdropBlur,
            ),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0x990E4D58), // cyan-950/60
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2626C6DA), // rgba(38,198,218,0.15)
                    blurRadius: AppGlow.appBarBlur,
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  // Back button
                  if (showBackButton)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      onPressed: onBack ?? () => Navigator.maybePop(context),
                      splashRadius: 20,
                    ),
                  if (showBackButton) const SizedBox(width: AppSpacing.xs),

                  // Title
                  Text(
                    title.toUpperCase(),
                    style: AppTextStyles.appBarTitle.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                  // Center content
                  if (centerContent != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    centerContent!,
                  ],

                  const Spacer(),

                  // Trailing
                  if (trailing != null)
                    trailing!
                  else
                    IconButton(
                      icon: const Icon(
                        Icons.timer_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      onPressed: () {}, // placeholder
                      splashRadius: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

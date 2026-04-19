import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/router/route_names.dart';

class SynaxisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SynaxisAppBar({
    super.key,
    this.title = 'SYNAXIS',
    this.showBackButton = true,
    this.onBack,
    this.trailing,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Widget? trailing;

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
        child: _buildGlassyContainer(
          child: Row(
            children: [
              if (showBackButton) _buildBackButton(context),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.appBarTitle.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              trailing ?? _buildDefaultTrailing(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassyContainer({required Widget child}) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGlow,
            AppColors.primaryContainer.withValues(alpha: 0.3),
            AppColors.primaryGlow,
          ],
        ),
      ),
      child: child,
    );
  }

  Widget _buildBackButton(BuildContext context) => IconButton(
    icon: const Icon(
      Icons.arrow_back,
      color: AppColors.primary,
      size: AppSpacing.lg,
    ),
    onPressed: onBack ?? () => context.go(RouteNames.home),
  );

  Widget _buildDefaultTrailing() => IconButton(
    icon: const Icon(Icons.timer_outlined, color: AppColors.primary),
    onPressed: () {},
  );
}

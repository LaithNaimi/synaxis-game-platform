import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glow_button.dart';
import '../../../../shared/widgets/outline_glow_button.dart';
import '../../../../shared/widgets/footer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            _buildEtherealBadge(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'SYNAXIS',
              style: AppTextStyles.heroDisplay.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTagline(),
            const SizedBox(height: AppSpacing.xxl),
            GlowButton(
              label: 'Create Room',
              onPressed: () => context.go(RouteNames.createRoom),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlineGlowButton(
              label: 'Join Room',
              onPressed: () => context.go(RouteNames.joinRoom),
            ),
            const SizedBox(height: AppSpacing.md),
            const Footer(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildEtherealBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),

        gradient: LinearGradient(
          colors: [
            AppColors.primaryGlow,
            AppColors.primaryContainer.withValues(alpha: 0.2),
            AppColors.primaryGlow,
          ],
        ),
      ),
      child: Text(
        'THE ETHEREAL HEARTH',
        style: AppTextStyles.labelUppercase.copyWith(
          color: AppColors.primary,
          fontSize: 12,
        ),
      ),
    );
  }

  // ── Tagline ──────────────────────────────────────────────────────
  Widget _buildTagline() {
    return Text(
      'Connect in the quiet corners of the galaxy A soft-futuristic social space designed for meaningful play and shared serenity.',
      textAlign: TextAlign.center,
      style: AppTextStyles.body.copyWith(fontSize: 17, height: 1.6),
    );
  }
}

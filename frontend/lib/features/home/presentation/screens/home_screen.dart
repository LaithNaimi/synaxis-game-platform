import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glow_button.dart';
import '../../../../shared/widgets/nebula_background.dart';
import '../../../../shared/widgets/outline_glow_button.dart';
import '../../../../shared/widgets/synaxis_app_bar.dart';

/// Landing screen — pure navigation, zero network calls (DDS §27.1).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: SynaxisAppBar(
        showBackButton: false,
        trailing: IconButton(
          icon: const Icon(
            Icons.timer_outlined,
            color: AppColors.primary,
            size: 22,
          ),
          onPressed: () {},
          splashRadius: 20,
        ),
      ),
      body: NebulaBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.maxContentWidth,
              ),
              child: Column(
                children: [
                  // Space for app bar
                  SizedBox(
                    height: MediaQuery.of(context).padding.top +
                        AppSpacing.xxl +
                        AppSpacing.lg,
                  ),

                  // ── "THE ETHEREAL HEARTH" badge ────────
                  _buildEtherealBadge(),

                  const SizedBox(height: AppSpacing.lg),

                  // ── SYNAXIS hero title with glow ───────
                  _buildHeroTitle(),

                  const SizedBox(height: AppSpacing.md),

                  // ── Tagline paragraph ──────────────────
                  _buildTagline(),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Create Room CTA ────────────────────
                  GlowButton(
                    label: 'Create Room',
                    onPressed: () => context.go(RouteNames.createRoom),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── Join Room CTA ──────────────────────
                  OutlineGlowButton(
                    label: 'Join Room',
                    onPressed: () => context.go(RouteNames.joinRoom),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Ethereal Hearth badge ────────────────────────────────────────
  // Gradient-border pill chip: outer container is the gradient,
  // inner container is the solid fill, creating a border effect.
  Widget _buildEtherealBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
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

  // ── SYNAXIS hero title ───────────────────────────────────────────
  // Large Space Grotesk text with soft cyan text-shadow glow.
  Widget _buildHeroTitle() {
    return Text(
      'SYNAXIS',
      textAlign: TextAlign.center,
      style: AppTextStyles.heroDisplay.copyWith(
        color: AppColors.onSurface,
        shadows: const [
          Shadow(color: AppColors.primaryGlow, blurRadius: 15),
          Shadow(color: AppColors.primaryGlow, blurRadius: 40),
        ],
      ),
    );
  }

  // ── Tagline ──────────────────────────────────────────────────────
  Widget _buildTagline() {
    return Text(
      'Connect in the quiet corners of the galaxy. '
      'A soft-futuristic social space designed for '
      'meaningful play and shared serenity.',
      textAlign: TextAlign.center,
      style: AppTextStyles.body.copyWith(
        color: AppColors.onSurfaceVariant,
        fontSize: 17,
        height: 1.6,
      ),
    );
  }
}

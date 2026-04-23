import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class ScoreHealthBar extends StatelessWidget {
  const ScoreHealthBar({
    super.key,
    required this.score,
    required this.scoreDelta,
    required this.health,
    required this.healthDelta,
    required this.penaltyScoreDelta,
  });

  final int score;
  final int scoreDelta;
  final int health;
  final int healthDelta;
  final int penaltyScoreDelta;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScoreSection(),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _buildIntegritySection()),
      ],
    );
  }

  Widget _buildScoreSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceContainerHigh,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'YOUR SCORE',
              style: AppTextStyles.micro.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            Row(
              children: [
                Text(
                  _formatScore(score),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                if (scoreDelta != 0) ...[
                  const SizedBox(width: AppSpacing.xs),
                  _DeltaBadge(value: scoreDelta, positive: scoreDelta > 0),
                ],
                if (penaltyScoreDelta != 0) ...[
                  const SizedBox(width: AppSpacing.xs),
                  _DeltaBadge(value: penaltyScoreDelta, positive: false),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntegritySection() {
    final healthFraction = (health / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'INTEGRITY',
              style: AppTextStyles.micro.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 10,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: healthFraction,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$health%',
              style: AppTextStyles.label.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.shield_rounded,
              color: AppColors.primary.withValues(alpha: 0.7),
              size: 18,
            ),
            if (healthDelta != 0) ...[
              const SizedBox(width: AppSpacing.xs),
              _DeltaBadge(value: healthDelta, positive: healthDelta > 0),
            ],
          ],
        ),
      ],
    );
  }

  String _formatScore(int value) {
    if (value >= 1000) {
      final thousands = value ~/ 1000;
      final remainder = value % 1000;
      return '$thousands,${remainder.toString().padLeft(3, '0')}';
    }
    return '$value';
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.value, required this.positive});

  final int value;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Text(
      positive ? '+$value' : '$value',
      style: AppTextStyles.caption.copyWith(
        color: positive ? AppColors.success : AppColors.error,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

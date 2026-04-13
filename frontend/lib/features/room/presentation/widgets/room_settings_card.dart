import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glassmorphic_panel.dart';

/// Read-only settings summary shown in the lobby.
class RoomSettingsCard extends StatelessWidget {
  const RoomSettingsCard({
    super.key,
    required this.cefrLevel,
    required this.totalRounds,
    required this.roundDuration,
    required this.maxPlayers,
  });

  final String cefrLevel;
  final int totalRounds;
  final int roundDuration;
  final int maxPlayers;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.settings_outlined,
                color: AppColors.primary,
                size: AppSpacing.lg,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Room Settings',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          _buildRow('Difficulty (CEFR)', cefrLevel),
          _buildRow('Total Rounds', '$totalRounds Rounds'),
          _buildRow('Round Duration', '$roundDuration Seconds'),
          _buildRow('Max Players', '$maxPlayers Slots'),

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              value,
              style: AppTextStyles.label.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/status_badge.dart';

/// A single player row for the lobby player list.
///
/// Shows avatar (with online dot), display name, optional HOST badge,
/// a status line, and an optional ping-warning badge.
class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.name,
    required this.avatarIndex,
    this.isHost = false,
    this.status,
    this.isOnline = true,
    this.pingWarning,
  });

  final String name;

  /// Maps to asset `av{avatarIndex}.png`. Falls back to a generic icon.
  final int avatarIndex;

  final bool isHost;

  /// e.g. "Ready to lead", "Synchronizing…"
  final String? status;

  final bool isOnline;

  /// e.g. "Slow Ping (240ms)" — shown as an amber warning badge.
  final String? pingWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(
          left: BorderSide(
            color: isHost ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildInfo()),
          if (pingWarning != null) ...[
            const SizedBox(width: AppSpacing.sm),
            StatusBadge(
              label: pingWarning!,
              variant: StatusBadgeVariant.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceContainerHigh,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surfaceContainerLow,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                name,
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isHost) ...[
              const SizedBox(width: AppSpacing.sm),
              const StatusBadge(
                label: 'HOST',
                icon: Icons.star,
                variant: StatusBadgeVariant.primary,
              ),
            ],
          ],
        ),
        if (status != null) ...[
          const SizedBox(height: 2),
          Text(
            status!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

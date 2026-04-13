import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glassmorphic_panel.dart';

class LiveFeedEntry {
  const LiveFeedEntry({required this.text, this.sender, this.isSystem = false});

  final String? sender;

  final String text;

  final bool isSystem;
}

class LiveFeedCard extends StatelessWidget {
  const LiveFeedCard({super.key, required this.messages});

  final List<LiveFeedEntry> messages;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'LIVE FEED',
                style: AppTextStyles.labelUppercase.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
                size: AppSpacing.md,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          ...messages.map(_buildEntry),
        ],
      ),
    );
  }

  Widget _buildEntry(LiveFeedEntry entry) {
    if (entry.isSystem) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(
          '~ ${entry.text} ~',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${entry.sender}: ',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: entry.text,
              style: AppTextStyles.caption.copyWith(color: AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

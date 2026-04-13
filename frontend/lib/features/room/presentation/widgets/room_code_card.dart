import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glassmorphic_panel.dart';

class RoomCodeCard extends StatelessWidget {
  const RoomCodeCard({super.key, required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicPanel(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ROOM CODE', style: AppTextStyles.labelUppercase),
              const SizedBox(height: AppSpacing.xs),
              Text(
                roomCode,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.onSurface,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: AppColors.primary),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: roomCode));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Room code copied to clipboard'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

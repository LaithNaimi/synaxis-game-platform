import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Full-screen semi-transparent loading overlay for Cyanide Pulse theme.
///
/// Blocks interaction during API calls (DDS §5 Global Components).
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.7),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

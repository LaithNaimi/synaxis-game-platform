import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Application [ThemeData] — expanded in FE-001.2.
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      useMaterial3: true,
    );
  }
}

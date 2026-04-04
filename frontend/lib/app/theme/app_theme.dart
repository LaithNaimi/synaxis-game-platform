import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Application [ThemeData] for light MVP (DDS §8).
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      outline: AppColors.outline,
      surfaceTint: Colors.transparent,
    );

    final textTheme = AppTextStyles.textTheme(
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: AppRadius.elevationLow,
        titleTextStyle: AppTextStyles.textTitle.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        space: AppSpacing.md,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.onSurface,
        contentTextStyle: AppTextStyles.textBody.copyWith(
          color: AppColors.surface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppRadius.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: const EdgeInsets.all(AppSpacing.sm),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSpacing.minTapTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}

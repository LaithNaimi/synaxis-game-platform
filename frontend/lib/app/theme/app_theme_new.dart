

/*
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Cyanide Pulse dark theme for Synaxis.
class AppTheme {
  AppTheme._(); // منع إنشاء نسخة من الكلاس

  static ThemeData dark() {
    // 1. تعريف نظام الألوان الأساسي
    final colorScheme = _buildColorScheme();

    // 2. تعريف نظام النصوص
    final textTheme = AppTextStyles.textTheme(
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      fontFamily: AppTextStyles.fontBody,
      
      // تعيين الأنماط الفرعية باستخدام دوال مساعدة لتقليل الزحام
      appBarTheme: _buildAppBarTheme(),
      dividerTheme: _buildDividerTheme(),
      snackBarTheme: _buildSnackBarTheme(),
      cardTheme: _buildCardTheme(),
      filledButtonTheme: _buildFilledButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      dropdownMenuTheme: _buildDropdownMenuTheme(),
      iconTheme: const IconThemeData(color: AppColors.primary, size: 24),
      bottomSheetTheme: _buildBottomSheetTheme(),
      dialogTheme: _buildDialogTheme(),
    );
  }

  // ─── الدوال المساعدة (Helper Methods) لتبسيط الكود ───

  static ColorScheme _buildColorScheme() {
    return const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surfaceContainer,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: Colors.transparent,
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTextStyles.appBarTitle.copyWith(color: AppColors.primary),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme() {
    // دالة داخلية صغيرة لمنع تكرار كود الحواف (Borders)
    OutlineInputBorder buildBorder({Color? color}) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: color == null ? BorderSide.none : BorderSide(color: color),
        );

    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerHigh,
      hintStyle: AppTextStyles.body.copyWith(
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      labelStyle: AppTextStyles.labelUppercase.copyWith(color: AppColors.primary),
      border: buildBorder(),
      enabledBorder: buildBorder(),
      focusedBorder: buildBorder(color: AppColors.primary.withValues(alpha: 0.4)),
      errorBorder: buildBorder(color: AppColors.error),
      contentPadding: const EdgeInsets.all(AppSpacing.md),
    );
  }

  static FilledButtonThemeData _buildFilledButtonTheme() {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(0, AppSpacing.minTapTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        shape: const StadiumBorder(),
        textStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }

  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      color: AppColors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.panelBorder),
      ),
      margin: const EdgeInsets.all(AppSpacing.sm),
    );
  }

  // ... (يمكنك إكمال بقية الـ Themes بنفس الطريقة المنظمة)
  
  static DividerThemeData _buildDividerTheme() => const DividerThemeData(
        color: AppColors.outlineVariant,
        space: AppSpacing.md,
        thickness: 1,
      );

  static SnackBarThemeData _buildSnackBarTheme() => SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHighest,
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      );

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() => OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, AppSpacing.minTapTarget),
          shape: const StadiumBorder(),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
      );

  static BottomSheetThemeData _buildBottomSheetTheme() => const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      );

  static DialogThemeData _buildDialogTheme() => DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      );

  static DropdownMenuThemeData _buildDropdownMenuTheme() => DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
        ),
      );
}

🧐 ما الذي تغير ولماذا هذا أفضل؟
تقليل "التعشيش" (Flattening): بدلاً من أن يكون تابع dark() عبارة عن 150 سطر من الأقواس المتداخلة، أصبح الآن عبارة عن "قائمة مهام" واضحة تقرأها في ثوانٍ.

مبدأ المسؤولية الواحدة (Single Responsibility): كل دالة مساعدة (مثل _buildCardTheme) مسؤولة فقط عن جزء صغير. إذا أردت تعديل شكل الكروت، تذهب مباشرة لتلك الدالة بدلاً من البحث وسط مئات الأسطر.

سهولة الصيانة: لاحظ دالة buildBorder داخل _buildInputDecorationTheme. لقد قمنا بكتابة منطق الـ Border مرة واحدة واستخدمناه 4 مرات. لو أردت تغيير borderRadius للحقول مستقبلاً، ستغيره في سطر واحد فقط.

النظافة (Cleanliness): الكود أصبح يتحدث عن نفسه. التابع dark() الآن يخبرك "ماذا" يفعل (يبني ثيم مظلم)، والدوال المساعدة تخبرك "كيف" تفعل ذلك بالتفصيل.
 */


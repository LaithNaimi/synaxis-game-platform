import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/home_screen_theme.dart';

/// Shared sci-fi [InputDecoration] for forms on [SynaxisSciFiBackground].
InputDecoration synaxisSciFiInputDecoration(
  HomeScreenTheme home, {
  String? label,
  String? hint,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    floatingLabelBehavior: label == null || label.isEmpty
        ? FloatingLabelBehavior.never
        : FloatingLabelBehavior.auto,
    labelStyle: TextStyle(
      color: home.onPrimaryText.withValues(alpha: 0.92),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    ),
    hintStyle: TextStyle(color: home.accentCyan.withValues(alpha: 0.45)),
    filled: true,
    fillColor: home.backgroundDeepNavy.withValues(alpha: 0.42),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: home.accentCyan.withValues(alpha: 0.9)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: home.accentCyan.withValues(alpha: 0.85)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: home.accentCyan, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.redAccent.shade100),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.redAccent.shade200, width: 1.2),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm + 2,
    ),
  );
}

import 'package:flutter/material.dart';

/// Semantic color tokens (DDS §8.2). Use via [Theme.of(context).colorScheme] when possible,
/// or these constants only inside theme / design-system code — not raw hex in feature widgets.
abstract final class AppColors {
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color outline = Color(0xFFE0E0E0);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF9A825);
}

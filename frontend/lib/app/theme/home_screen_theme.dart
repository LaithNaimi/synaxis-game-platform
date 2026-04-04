import 'package:flutter/material.dart';

/// Dark sci-fi palette for the entry [HomeScreen] (reference layout).
/// Registered on [ThemeData.extensions] — read via
/// `Theme.of(context).extension<HomeScreenTheme>()`.
@immutable
class HomeScreenTheme extends ThemeExtension<HomeScreenTheme> {
  const HomeScreenTheme({
    required this.backgroundDeepNavy,
    required this.accentCyan,
    required this.primaryButtonTeal,
    required this.titleGlowColor,
    required this.onPrimaryText,
  });

  /// Base fill behind the wireframe PNG (~ DDS reference).
  final Color backgroundDeepNavy;

  /// Cyan/teal for borders, glows, and accents.
  final Color accentCyan;

  /// Filled primary CTA background.
  final Color primaryButtonTeal;

  /// Outer glow for the SYNAXIS wordmark.
  final Color titleGlowColor;

  /// Button labels on filled primary.
  final Color onPrimaryText;

  static const HomeScreenTheme synaxis = HomeScreenTheme(
    backgroundDeepNavy: Color(0xFF0A1622),
    accentCyan: Color(0xFF26A69A),
    primaryButtonTeal: Color(0xFF26A69A),
    titleGlowColor: Color(0xFF26A69A),
    onPrimaryText: Color(0xFFFFFFFF),
  );

  @override
  HomeScreenTheme copyWith({
    Color? backgroundDeepNavy,
    Color? accentCyan,
    Color? primaryButtonTeal,
    Color? titleGlowColor,
    Color? onPrimaryText,
  }) {
    return HomeScreenTheme(
      backgroundDeepNavy: backgroundDeepNavy ?? this.backgroundDeepNavy,
      accentCyan: accentCyan ?? this.accentCyan,
      primaryButtonTeal: primaryButtonTeal ?? this.primaryButtonTeal,
      titleGlowColor: titleGlowColor ?? this.titleGlowColor,
      onPrimaryText: onPrimaryText ?? this.onPrimaryText,
    );
  }

  @override
  HomeScreenTheme lerp(ThemeExtension<HomeScreenTheme>? other, double t) {
    if (other is! HomeScreenTheme) return this;
    return HomeScreenTheme(
      backgroundDeepNavy: Color.lerp(
        backgroundDeepNavy,
        other.backgroundDeepNavy,
        t,
      )!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      primaryButtonTeal: Color.lerp(
        primaryButtonTeal,
        other.primaryButtonTeal,
        t,
      )!,
      titleGlowColor: Color.lerp(titleGlowColor, other.titleGlowColor, t)!,
      onPrimaryText: Color.lerp(onPrimaryText, other.onPrimaryText, t)!,
    );
  }
}

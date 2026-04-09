import 'package:flutter/material.dart';

/// Cyanide Pulse design system color tokens.
///
/// Derived from the "Deep Space" palette in DESIGN.md and HTML mockup references.
/// Use via [AppColors.xxx] in theme wiring; never hardcode hex in feature widgets.
abstract final class AppColors {
  // ── Core Surfaces (Deep Space foundation) ──────────────────────────
  static const Color background = Color(0xFF0B0E14);
  static const Color surfaceDim = Color(0xFF0B0E14);
  static const Color surfaceContainerLowest = Color(0xFF000000);
  static const Color surfaceContainerLow = Color(0xFF10131A);
  static const Color surfaceContainer = Color(0xFF161A21);
  static const Color surfaceContainerHigh = Color(0xFF1C2028);
  static const Color surfaceContainerHighest = Color(0xFF22262F);
  static const Color surfaceBright = Color(0xFF282C36);

  // ── Primary system (Bioluminescent Cyan) ───────────────────────────
  static const Color primary = Color(0xFF58E7FB);
  static const Color primaryDim = Color(0xFF45D8ED);
  static const Color primaryContainer = Color(0xFF1CC2D6);
  static const Color onPrimary = Color(0xFF00515B);
  static const Color onPrimaryContainer = Color(0xFF00363D);

  // ── Secondary system ───────────────────────────────────────────────
  static const Color secondary = Color(0xFF96A5FF);
  static const Color secondaryContainer = Color(0xFF2F3F92);
  static const Color onSecondary = Color(0xFF0F2176);
  static const Color onSecondaryContainer = Color(0xFFC7CDFF);

  // ── Tertiary (lighter cyan) ────────────────────────────────────────
  static const Color tertiary = Color(0xFFCCF9FF);
  static const Color tertiaryContainer = Color(0xFF93F1FD);
  static const Color onTertiary = Color(0xFF00646D);
  static const Color onTertiaryContainer = Color(0xFF005B63);

  // ── Text / on-surface content ──────────────────────────────────────
  static const Color onBackground = Color(0xFFECEDF6);
  static const Color onSurface = Color(0xFFECEDF6);
  static const Color onSurfaceVariant = Color(0xFFA9ABB3);

  // ── Status ─────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF716C);
  static const Color errorDim = Color(0xFFD7383B);
  static const Color errorContainer = Color(0xFF9F0519);
  static const Color onError = Color(0xFF490006);
  static const Color onErrorContainer = Color(0xFFFFA8A3);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);

  // ── Utilities ──────────────────────────────────────────────────────
  static const Color outline = Color(0xFF73757D);
  static const Color outlineVariant = Color(0xFF45484F);
  static const Color surfaceTint = Color(0xFF58E7FB);
  static const Color inverseSurface = Color(0xFFF9F9FF);
  static const Color inverseOnSurface = Color(0xFF52555C);
  static const Color inversePrimary = Color(0xFF006975);

  // ── Glow / effect helpers ──────────────────────────────────────────
  /// Primary glow for drop shadows and ambient effects.
  static const Color primaryGlow = Color(0x3358E7FB); // ~20% opacity
  /// Stronger glow for active/hover states.
  static const Color primaryGlowStrong = Color(0x6658E7FB); // ~40% opacity
  /// Subtle cyan for grid overlay lines.
  static const Color gridLine = Color(0x0858E7FB); // ~3% opacity
  /// Card/panel border at low opacity.
  static const Color panelBorder = Color(0x1A58E7FB); // ~10% opacity
}
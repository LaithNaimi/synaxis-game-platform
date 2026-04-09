/// Spacing, touch targets, corner radii, and glow constants for Cyanide Pulse.
abstract final class AppSpacing {
  // ── Spacing scale ────────────────────────────────────────────────
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Default horizontal screen padding.
  static const double screenPadding = md;

  /// Min tap target per Material guideline (48dp).
  static const double minTapTarget = 48;

  /// Max content width on web / wide screens (DDS §8.6).
  static const double maxContentWidth = 560;

  /// Wider max for leaderboard lists.
  static const double maxContentWidthWide = 720;
}

/// Corner radii for the Cyanide Pulse pill/rounded aesthetic.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// Pill shape for buttons and app bar.
  static const double full = 9999;

  // ── Elevation (light-emission model, not Material shadows) ─────
  static const double elevationLow = 0;
  static const double elevationModal = 0;
}

/// Glow and blur constants for consistent ambient effects.
abstract final class AppGlow {
  /// Primary button glow shadow spread.
  static const double buttonSpread = 30;
  static const double buttonBlur = 30;

  /// App bar ambient glow.
  static const double appBarSpread = 20;
  static const double appBarBlur = 20;

  /// Backdrop blur for glassmorphic panels.
  static const double panelBlur = 20;

  /// Backdrop blur for app bar.
  static const double appBarBackdropBlur = 24;
}

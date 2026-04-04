/// Spacing, min touch targets (DDS §8.3), and corner radii (DDS §8.5).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Material guideline for primary actions / letter keys (DDS §8.3).
  static const double minTapTarget = 48;
}

/// Corner radii & elevation scale (DDS §8.5).
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  static const double elevationLow = 1;
  static const double elevationModal = 8;
}

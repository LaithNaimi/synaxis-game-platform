import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale (DDS §8.4). Base styles without color — color comes from [TextTheme] / [ColorScheme].
///
/// DDS names: [textDisplay], [textTitle], [textBody], [textLabel], [textCaption].
/// Short names ([display], …) are aliases for use inside theme wiring.
abstract final class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static const TextStyle textDisplay = display;
  static const TextStyle textTitle = title;
  static const TextStyle textBody = body;
  static const TextStyle textLabel = label;
  static const TextStyle textCaption = caption;

  /// Maps DDS tokens to Material 3 [TextTheme] with explicit [onSurface] / [onSurfaceVariant].
  static TextTheme textTheme({
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    return TextTheme(
      displayLarge: textDisplay.copyWith(color: onSurface),
      titleLarge: textTitle.copyWith(color: onSurface),
      bodyLarge: textBody.copyWith(color: onSurface),
      labelLarge: textLabel.copyWith(color: onSurface),
      bodySmall: textCaption.copyWith(color: onSurfaceVariant),
    );
  }
}

/// Orbitron + cyan stacked glow for "SYNAXIS" (home) and screen headers ("CREATE ROOM", etc.).
abstract final class SynaxisNeonTitleStyles {
  static const List<Shadow> glowShadows = [
    Shadow(color: Color(0xFF00FFFF), blurRadius: 4.0),
    Shadow(color: Color(0xFF00FFFF), blurRadius: 12.0),
  ];

  /// Game name on [HomeScreen] — e.g. "SYNAXIS".
  static TextStyle gameName({double letterSpacing = 4}) => GoogleFonts.orbitron(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    letterSpacing: letterSpacing,
    color: Colors.white,
    shadows: glowShadows,
  );

  /// Feature screen title — e.g. "CREATE ROOM".
  static TextStyle screenTitle({double letterSpacing = 3}) =>
      GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: letterSpacing,
        color: Colors.white,
        shadows: glowShadows,
      );
}

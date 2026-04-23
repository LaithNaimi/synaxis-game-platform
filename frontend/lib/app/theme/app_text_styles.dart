import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for Cyanide Pulse design system.
///
/// Headlines: **Space Grotesk** (geometric, tactical).
/// Body / labels: **Plus Jakarta Sans** (humanist, readable).
/// Arabic blocks: **Noto Sans Arabic** via explicit `fontFamily` override on Learning screen.
abstract final class AppTextStyles {
  // ── Font family getters via google_fonts ────────────────────────────
  static String get fontHeadline => GoogleFonts.spaceGrotesk().fontFamily!;
  static String get fontBody => GoogleFonts.plusJakartaSans().fontFamily!;
  static String get fontArabic => GoogleFonts.notoSansArabic().fontFamily!;

  // ── Hero / display (Space Grotesk) ─────────────────────────────────
  /// Countdown number, hero masked word.
  static TextStyle get display => GoogleFonts.spaceGrotesk(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.5,
      );

  /// Massive hero text (SYNAXIS title, countdown digits).
  static TextStyle get heroDisplay => GoogleFonts.spaceGrotesk(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        height: 1.0,
        letterSpacing: -1.5,
      );

  // ── Headings (Space Grotesk) ───────────────────────────────────────
  /// Screen titles (e.g. "Set the Hearth", "The Lobby").
  static TextStyle get title => GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      );

  /// Section headings within screens.
  static TextStyle get titleMedium => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  // ── Body (Plus Jakarta Sans) ───────────────────────────────────────
  /// Standard body text.
  static TextStyle get body => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  /// Bold body variant.
  static TextStyle get bodyBold => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ── Labels (Plus Jakarta Sans) ─────────────────────────────────────
  /// Button labels, input labels.
  static TextStyle get label => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  /// Uppercase tactical labels with letter spacing (e.g. "ROOM CODE", "PLAYER NAME").
  static TextStyle get labelUppercase => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 2.5,
      );

  // ── Caption / micro data ───────────────────────────────────────────
  /// Hints, metadata, secondary info.
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
      );

  /// Micro tactical readouts (ping, session ID).
  static TextStyle get micro => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 1.0,
      );

  // ── App bar title (Space Grotesk, uppercase tracked) ───────────────
  static TextStyle get appBarTitle => GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 3.0,
      );

  // ── Legacy aliases (used in app_theme.dart TextTheme mapping) ──────
  static TextStyle get textDisplay => display;
  static TextStyle get textTitle => title;
  static TextStyle get textBody => body;
  static TextStyle get textLabel => label;
  static TextStyle get textCaption => caption;

  /// Build a [TextTheme] for [ThemeData].
  static TextTheme textTheme({
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    return TextTheme(
      displayLarge: heroDisplay.copyWith(color: onSurface),
      displayMedium: display.copyWith(color: onSurface),
      headlineLarge: title.copyWith(color: onSurface),
      headlineMedium: titleMedium.copyWith(color: onSurface),
      titleLarge: titleMedium.copyWith(color: onSurface),
      titleMedium: label.copyWith(color: onSurface),
      bodyLarge: body.copyWith(color: onSurface),
      bodyMedium: body.copyWith(color: onSurfaceVariant),
      bodySmall: caption.copyWith(color: onSurfaceVariant),
      labelLarge: label.copyWith(color: onSurface),
      labelMedium: labelUppercase.copyWith(color: onSurfaceVariant),
      labelSmall: micro.copyWith(color: onSurfaceVariant),
    );
  }
}

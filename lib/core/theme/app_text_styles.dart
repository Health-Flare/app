import 'package:flutter/material.dart';

/// HealthFlare Design System — Typography v1.0
///
/// Font Families:
/// - Display/Headings: Fraunces — warm, optical serif
/// - Body/UI: DM Sans — clean humanist sans-serif
/// - Mono/Data: DM Mono — for timestamps, data values, codes
///
/// Fonts are bundled as assets (assets/fonts/). Exposed as a [TextTheme]
/// ready to drop into [ThemeData].
abstract final class AppTextStyles {
  // ---------------------------------------------------------------------------
  // Font family constants
  // ---------------------------------------------------------------------------

  static const String _fraunces = 'Fraunces';
  static const String _dmSans = 'DMSans';
  static const String _dmMono = 'DMMono';

  // ---------------------------------------------------------------------------
  // Line Heights
  // ---------------------------------------------------------------------------

  static const double _displayLineHeight = 1.2;
  static const double _bodyLineHeight = 1.6;
  static const double _labelLineHeight = 1.4;

  // ---------------------------------------------------------------------------
  // Display Styles (Fraunces)
  // ---------------------------------------------------------------------------

  /// display-xl: 40px, weight 600 — Marketing hero headlines.
  static const TextStyle displayXl = TextStyle(
    fontFamily: _fraunces,
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: _displayLineHeight,
  );

  /// display-lg: 32px, weight 600 — App section headers.
  static const TextStyle displayLg = TextStyle(
    fontFamily: _fraunces,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: _displayLineHeight,
  );

  /// display-md: 24px, weight 500 — Card titles, modal headers.
  static const TextStyle displayMd = TextStyle(
    fontFamily: _fraunces,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: _displayLineHeight,
  );

  // ---------------------------------------------------------------------------
  // Heading Styles (DM Sans)
  // ---------------------------------------------------------------------------

  /// heading-sm: 18px, weight 600 — Sub-section headers.
  static const TextStyle headingSm = TextStyle(
    fontFamily: _dmSans,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: _labelLineHeight,
  );

  // ---------------------------------------------------------------------------
  // Body Styles (DM Sans)
  // ---------------------------------------------------------------------------

  /// body-lg: 16px, weight 400 — Primary body copy.
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _dmSans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: _bodyLineHeight,
  );

  /// body-md: 14px, weight 400 — Secondary body, descriptions.
  static const TextStyle bodyMd = TextStyle(
    fontFamily: _dmSans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: _bodyLineHeight,
  );

  // ---------------------------------------------------------------------------
  // Label Styles (DM Sans)
  // ---------------------------------------------------------------------------

  /// label: 13px, weight 500 — Form labels, UI labels.
  static const TextStyle label = TextStyle(
    fontFamily: _dmSans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: _labelLineHeight,
  );

  /// caption: 12px, weight 400 — Timestamps, footnotes.
  static const TextStyle caption = TextStyle(
    fontFamily: _dmSans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: _labelLineHeight,
  );

  // ---------------------------------------------------------------------------
  // Data Styles (DM Mono)
  // ---------------------------------------------------------------------------

  /// data: 14px, weight 400 — Log values, stats, codes.
  static const TextStyle data = TextStyle(
    fontFamily: _dmMono,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: _bodyLineHeight,
  );

  // ---------------------------------------------------------------------------
  // Button Styles (DM Sans)
  // ---------------------------------------------------------------------------

  /// Button text: 15px, weight 500.
  static const TextStyle button = TextStyle(
    fontFamily: _dmSans,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: _labelLineHeight,
  );

  // ---------------------------------------------------------------------------
  // TextTheme for ThemeData
  // ---------------------------------------------------------------------------

  /// Full [TextTheme] mapping design system tokens to Material roles.
  static const TextTheme textTheme = TextTheme(
    // Display — using Fraunces
    displayLarge: displayXl,
    displayMedium: displayLg,
    displaySmall: displayMd,
    // Headline — using Fraunces for larger, DM Sans for smaller
    headlineLarge: displayLg,
    headlineMedium: displayMd,
    headlineSmall: headingSm,
    // Title — DM Sans
    titleLarge: headingSm,
    titleMedium: TextStyle(
      fontFamily: _dmSans,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: _labelLineHeight,
    ),
    titleSmall: TextStyle(
      fontFamily: _dmSans,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: _labelLineHeight,
    ),
    // Body — DM Sans
    bodyLarge: bodyLg,
    bodyMedium: bodyMd,
    bodySmall: caption,
    // Label — DM Sans
    labelLarge: button,
    labelMedium: label,
    labelSmall: caption,
  );
}

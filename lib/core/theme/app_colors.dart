import 'package:flutter/material.dart';

/// Health Flare — design token colour palette.
///
/// These are the raw colour values. Use [AppTheme] to access them via
/// [ThemeData] and [ColorScheme] in widgets — reach directly into this
/// class only when you genuinely need a colour that has no semantic slot.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// Primary teal — used for CTAs, active nav items, key accents.
  static const Color teal = Color(0xFF2A9D8F);
  static const Color tealLight = Color(0xFF52C5B6);
  static const Color tealDark = Color(0xFF1A7A6E);

  /// Warm amber — used for highlights, warnings, first-log prompt cards.
  static const Color amber = Color(0xFFE9C46A);
  static const Color amberDark = Color(0xFFD4A017);

  /// Coral — used sparingly for reaction flags, destructive actions.
  static const Color coral = Color(0xFFE76F51);
  static const Color coralLight = Color(0xFFFF9B85);

  // ---------------------------------------------------------------------------
  // Neutrals
  // ---------------------------------------------------------------------------

  static const Color grey50 = Color(0xFFF8F9FA);
  static const Color grey100 = Color(0xFFF1F3F5);
  static const Color grey200 = Color(0xFFE9ECEF);
  static const Color grey300 = Color(0xFFDEE2E6);
  static const Color grey400 = Color(0xFFADB5BD);
  static const Color grey500 = Color(0xFF6C757D);
  static const Color grey600 = Color(0xFF495057);
  static const Color grey700 = Color(0xFF343A40);
  static const Color grey800 = Color(0xFF212529);
  static const Color grey900 = Color(0xFF121416);

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF2A9D8F); // teal
  static const Color warning = Color(0xFFE9C46A); // amber
  static const Color error = Color(0xFFE76F51);   // coral
  static const Color info = Color(0xFF457B9D);

  // ---------------------------------------------------------------------------
  // Surface
  // ---------------------------------------------------------------------------

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color background = Color(0xFFF8F9FA);

  // ---------------------------------------------------------------------------
  // Dark mode equivalents
  // ---------------------------------------------------------------------------

  static const Color surfaceDark = Color(0xFF1A1D1E);
  static const Color surfaceVariantDark = Color(0xFF252A2B);
  static const Color backgroundDark = Color(0xFF121416);
}

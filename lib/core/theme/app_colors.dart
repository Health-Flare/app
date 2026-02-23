import 'package:flutter/material.dart';

/// HealthFlare Design System — Colour Palette v1.0
///
/// These are the raw colour values. Use [AppTheme] to access them via
/// [ThemeData] and [ColorScheme] in widgets — reach directly into this
/// class only when you genuinely need a colour that has no semantic slot.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Primary Palette
  // ---------------------------------------------------------------------------

  /// Primary CTA buttons, key highlights, active states.
  static const Color flareAmber = Color(0xFFF5A623);

  /// Secondary accents, alert indicators, energy.
  static const Color dawnCoral = Color(0xFFF07560);

  /// Links, informational states, calm counterpoint.
  static const Color morningSky = Color(0xFF6BB8D4);

  /// App background, cards, surface base.
  static const Color softCloud = Color(0xFFF4F1EC);

  /// Primary text, headings.
  static const Color deepDusk = Color(0xFF2C2825);

  // ---------------------------------------------------------------------------
  // Extended Palette
  // ---------------------------------------------------------------------------

  /// Card tints, notification backgrounds, subtle fills.
  static const Color sunrisePeach = Color(0xFFFDE8D8);

  /// Info banners, highlight backgrounds.
  static const Color paleSky = Color(0xFFDFF0F7);

  /// Success states, stable/good readings.
  static const Color sageMist = Color(0xFFB8CCBF);

  /// Dividers, borders, secondary surfaces.
  static const Color warmLinen = Color(0xFFEDE8DF);

  /// Page backgrounds, modals.
  static const Color ashWhite = Color(0xFFFAFAF8);

  // ---------------------------------------------------------------------------
  // Semantic Colours
  // ---------------------------------------------------------------------------

  /// Success / Stable.
  static const Color success = sageMist;

  /// Warning / Mild concern.
  static const Color warning = flareAmber;

  /// Alert / Active flare.
  static const Color alert = dawnCoral;

  /// Info.
  static const Color info = morningSky;

  /// Destructive / Delete.
  static const Color destructive = Color(0xFFC94F3A);

  // ---------------------------------------------------------------------------
  // Severity Scale (Symptom Logging)
  // ---------------------------------------------------------------------------

  /// Level 1 — Clear.
  static const Color severityClear = Color(0xFFB8CCBF);

  /// Level 2 — Mild.
  static const Color severityMild = Color(0xFFF5E6A3);

  /// Level 3 — Moderate.
  static const Color severityModerate = Color(0xFFF5A623);

  /// Level 4 — Significant.
  static const Color severitySignificant = Color(0xFFF07560);

  /// Level 5 — Severe.
  static const Color severitySevere = Color(0xFFC94F3A);

  /// Severity scale as a list (index 0 = Clear, index 4 = Severe).
  static const List<Color> severityScale = [
    severityClear,
    severityMild,
    severityModerate,
    severitySignificant,
    severitySevere,
  ];

  // ---------------------------------------------------------------------------
  // Semantic Surface & Text Aliases
  // ---------------------------------------------------------------------------
  // Use these for direct access when not using Theme.of(context).colorScheme.
  // For themed widgets, prefer ColorScheme slots via the theme.

  /// Primary app background (Soft Cloud).
  static const Color background = softCloud;

  /// Primary surface for cards, sheets, modals (White).
  static const Color surface = Color(0xFFFFFFFF);

  /// Secondary/variant surface (Soft Cloud).
  static const Color surfaceVariant = softCloud;

  /// Tertiary surface for inputs, subtle fills (Ash White).
  static const Color surfaceTertiary = ashWhite;

  /// Primary text colour (Deep Dusk).
  static const Color text = deepDusk;

  /// Subtle/secondary text (Deep Dusk at ~70%).
  static const Color textSubtle = Color(0xFF6B6560);

  /// Muted text for captions, placeholders (Deep Dusk at ~50%).
  static const Color textMuted = Color(0xFF9E9790);

  /// Primary action colour (Flare Amber).
  static const Color primaryAction = flareAmber;

  /// Secondary action colour (Dawn Coral).
  static const Color secondaryAction = dawnCoral;

  /// Link colour (Morning Sky).
  static const Color link = morningSky;

  /// Border/divider colour (Warm Linen).
  static const Color border = warmLinen;

  /// Highlight/tint for cards, notifications (Sunrise Peach).
  static const Color highlight = sunrisePeach;

  // ---------------------------------------------------------------------------
  // Button Colours
  // ---------------------------------------------------------------------------

  /// Disabled button background.
  static const Color disabledBackground = warmLinen;

  /// Disabled button text.
  static const Color disabledText = textMuted;

  // ---------------------------------------------------------------------------
  // Dark Mode (v2 scope — placeholders)
  // ---------------------------------------------------------------------------

  /// Dark mode background.
  static const Color darkBackground = Color(0xFF1E1C1A);

  /// Dark mode surface.
  static const Color darkSurface = Color(0xFF252220);
}

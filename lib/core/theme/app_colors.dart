import 'package:flutter/material.dart';

/// HealthFlare Design System: Colour Palette v2.0
///
/// Two separate systems, deliberately non-overlapping — see
/// Health-Flare/brand's `brand-guidelines.md` (v2.1) for the source of
/// truth and the reasoning behind the split:
///
/// - **Identity** (this section's first half): nav, buttons, headers, text,
///   backgrounds. Pulled straight from the brand guidelines' 9-colour
///   palette. Never use these for severity/status signalling.
/// - **Functional / status** (second half): severity scale, destructive
///   actions, info. A second palette scoped to functional UI only, exempt
///   from "no clinical blues" / "always one colour" because it isn't doing
///   a branding job. Never use these for nav/CTAs/headers/the mark.
///
/// These are the raw colour values. Use [AppTheme] to access them via
/// [ThemeData] and [ColorScheme] in widgets: reach directly into this
/// class only when you genuinely need a colour that has no semantic slot.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Identity Palette (brand-guidelines.md v2.0)
  // ---------------------------------------------------------------------------

  /// Primary CTA buttons, key highlights, active states. (Sunrise)
  static const Color sunrise = Color(0xFFE0694E);

  /// Links, Health Flare text accent, hover states. (Ember)
  ///
  /// Not a UI "pop" colour — it's a 4.8:1-contrast text/link colour, more
  /// restrained than the old dawnCoral. If something needs a second bold
  /// accent (not text), that's a functional-palette job, not this.
  static const Color ember = Color(0xFFB4502F);

  /// Primary text, headings, dark ground. (Ink)
  static const Color ink = Color(0xFF221C18);

  /// Secondary/muted text. (Slate) Also used as the neutral "info" colour —
  /// see brand-guidelines.md v2.1: info gave up its hue (was Morning Sky
  /// blue) rather than get a brand-safe substitute.
  static const Color slate = Color(0xFF6B5E54);

  /// App background, light ground. (Dawn)
  static const Color dawn = Color(0xFFFBF7F2);

  /// Card tints, dividers, subtle fills, the neutral "info" surface. (Sand)
  static const Color sand = Color(0xFFF3E9DD);

  /// Light tint of [sunrise] over [dawn], for primary/secondary containers
  /// and highlight fills. Not a named brand colour — a derived tint, since
  /// the guidelines don't define tint variants.
  static const Color sunriseTint = Color(0xFFF6DDD4);

  // ---------------------------------------------------------------------------
  // Functional / Status Palette (brand-guidelines.md v2.1 addendum)
  // ---------------------------------------------------------------------------

  /// Severity: clear / calm.
  static const Color flareClear = Color(0xFFBFCBAE);

  /// Severity: mild.
  static const Color flareMild = Color(0xFFF0D28A);

  /// Severity: moderate.
  ///
  /// Deliberately NOT [sunrise] or brand Amber: a "moderate symptom" chip
  /// must never look like the primary CTA colour.
  static const Color flareModerate = Color(0xFFE8A94A);

  /// Severity: significant.
  static const Color flareSignificant = Color(0xFFD1683F);

  /// Severity: severe.
  static const Color flareSevere = Color(0xFFA8402C);

  /// Severity scale as a list (index 0 = Clear, index 4 = Severe).
  static const List<Color> severityScale = [
    flareClear,
    flareMild,
    flareModerate,
    flareSignificant,
    flareSevere,
  ];

  /// Delete / irreversible actions ONLY.
  ///
  /// Deliberately darker and more desaturated than [flareSevere] — a delete
  /// confirmation should never visually echo a severity flag.
  static const Color destructiveColor = Color(0xFF7A2E24);

  // ---------------------------------------------------------------------------
  // Semantic Colours
  // ---------------------------------------------------------------------------

  /// Success / Stable.
  static const Color success = flareClear;

  /// Warning / Mild concern.
  static const Color warning = flareModerate;

  /// Alert / Active flare.
  static const Color alert = flareSignificant;

  /// Info. No dedicated hue — neutral surface/text, see [slate]/[sand].
  static const Color info = slate;

  /// Destructive / Delete.
  static const Color destructive = destructiveColor;

  // ---------------------------------------------------------------------------
  // Semantic Surface & Text Aliases
  // ---------------------------------------------------------------------------
  // Use these for direct access when not using Theme.of(context).colorScheme.
  // For themed widgets, prefer ColorScheme slots via the theme.

  /// Primary app background (Dawn).
  static const Color background = dawn;

  /// Primary surface for cards, sheets, modals (White).
  static const Color surface = Color(0xFFFFFFFF);

  /// Secondary/variant surface (Dawn).
  static const Color surfaceVariant = dawn;

  /// Tertiary surface for inputs, subtle fills.
  ///
  /// Same value as [dawn] — the guidelines define one light ground, not a
  /// second near-white tier. Kept as a distinct token in case inputs need
  /// to diverge from the scaffold background later.
  static const Color surfaceTertiary = dawn;

  /// Primary text colour (Ink).
  static const Color text = ink;

  /// Subtle/secondary text (Slate).
  ///
  /// Contrast on white: ~6.0:1 | on Dawn/Sand: ~5.3:1. Safe for body and
  /// caption text on any light surface.
  static const Color textSubtle = slate;

  /// Muted text for captions, placeholders (Ink at ~50%).
  ///
  /// NOT WCAG AA compliant for readable text. Restricted to: disabled
  /// button labels (exempt from contrast requirements). Never use for
  /// visible, actionable, or informational text.
  static const Color textMuted = Color(0xFF9E958E);

  /// Primary action colour (Sunrise).
  static const Color primaryAction = sunrise;

  /// Secondary action colour (Ember).
  static const Color secondaryAction = ember;

  /// Link colour. No dedicated hue — see [slate].
  static const Color link = slate;

  /// Border/divider colour (Sand).
  static const Color border = sand;

  /// Highlight/tint for cards, notifications (Sunrise tint).
  static const Color highlight = sunriseTint;

  // ---------------------------------------------------------------------------
  // Button Colours
  // ---------------------------------------------------------------------------

  /// Disabled button background.
  static const Color disabledBackground = sand;

  /// Disabled button text.
  static const Color disabledText = textMuted;

  // ---------------------------------------------------------------------------
  // Profile Tag Palette (brand-guidelines.md v2.2 addendum)
  // ---------------------------------------------------------------------------
  // Distinguishes multiple profiles/avatars from each other. No semantic
  // meaning — never reuse identity or functional colours for this job, and
  // never reuse these for identity/functional either. Replaces a v1 palette
  // that used teal/blue/purple/green, exactly the hues the brand system is
  // built around avoiding.

  static const List<Color> profileTagPalette = [
    Color(0xFF762D33), // brick
    Color(0xFF76322D), // clay
    Color(0xFF763D2D), // rust
    Color(0xFF76492D), // cedar
    Color(0xFF76542D), // walnut
    Color(0xFF76602D), // ochre
    Color(0xFF766B2D), // honey
    Color(0xFF76762D), // olive
  ];

  // ---------------------------------------------------------------------------
  // Dark Mode (v2 scope: placeholders, not yet contrast-audited)
  // ---------------------------------------------------------------------------

  /// Dark mode background.
  static const Color darkBackground = Color(0xFF1E1C1A);

  /// Dark mode surface.
  static const Color darkSurface = Color(0xFF252220);
}

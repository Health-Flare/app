import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// HealthFlare Design System — Theme v1.0
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark, // v2 scope
/// )
/// ```
abstract final class AppTheme {
  // ---------------------------------------------------------------------------
  // Spacing Tokens
  // ---------------------------------------------------------------------------

  /// Base unit: 4px.
  static const double spaceUnit = 4;

  static const double space1 = 4; // Micro gaps, icon padding
  static const double space2 = 8; // Tight component spacing
  static const double space3 = 12; // List item gaps
  static const double space4 = 16; // Standard component padding
  static const double space5 = 20; // Card inner padding
  static const double space6 = 24; // Section gaps, form spacing
  static const double space8 = 32; // Large section breaks
  static const double space10 = 40; // Page section separation
  static const double space12 = 48; // Hero/marketing breathing room

  // ---------------------------------------------------------------------------
  // Border Radius Tokens
  // ---------------------------------------------------------------------------

  static const double radiusSm = 6; // Tags, chips, badges
  static const double radiusMd = 12; // Buttons, inputs, small cards
  static const double radiusLg = 18; // Cards, modals, sheets
  static const double radiusXl = 28; // Large feature cards, hero elements
  static const double radiusFull = 9999; // Pills, toggles, avatar circles

  static const BorderRadius borderRadiusSm =
      BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd =
      BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg =
      BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl =
      BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusFull =
      BorderRadius.all(Radius.circular(radiusFull));

  // ---------------------------------------------------------------------------
  // Shadow Tokens (warm-toned)
  // ---------------------------------------------------------------------------

  /// Subtle card lift.
  static const BoxShadow shadowSm = BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 3,
    color: Color(0x142C2825), // rgba(44,40,37,0.08)
  );

  /// Standard cards, buttons.
  static const BoxShadow shadowMd = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 12,
    color: Color(0x1A2C2825), // rgba(44,40,37,0.10)
  );

  /// Modals, bottom sheets.
  static const BoxShadow shadowLg = BoxShadow(
    offset: Offset(0, 8),
    blurRadius: 24,
    color: Color(0x1F2C2825), // rgba(44,40,37,0.12)
  );

  /// Focus ring (amber).
  static BoxShadow get shadowFocus => BoxShadow(
        offset: Offset.zero,
        blurRadius: 0,
        spreadRadius: 3,
        color: AppColors.flareAmber.withAlpha(89), // ~35% opacity
      );

  // ---------------------------------------------------------------------------
  // Animation Durations
  // ---------------------------------------------------------------------------

  static const Duration durationMicro = Duration(milliseconds: 150);
  static const Duration durationStandard = Duration(milliseconds: 250);
  static const Duration durationPage = Duration(milliseconds: 320);
  static const Duration durationOnboarding = Duration(milliseconds: 400);
  static const Duration durationShimmer = Duration(milliseconds: 1500);

  // ---------------------------------------------------------------------------
  // Animation Curves
  // ---------------------------------------------------------------------------

  static const Curve curveStandard = Curves.easeOutCubic;
  static const Curve curveSpring = Curves.easeOutBack;

  // ---------------------------------------------------------------------------
  // Light Theme
  // ---------------------------------------------------------------------------

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _lightColorScheme,
        textTheme: AppTextStyles.textTheme,
        scaffoldBackgroundColor: AppColors.softCloud,
        appBarTheme: _appBarTheme(_lightColorScheme),
        cardTheme: _cardTheme,
        inputDecorationTheme: _inputDecorationTheme(_lightColorScheme),
        elevatedButtonTheme: _elevatedButtonTheme(_lightColorScheme),
        outlinedButtonTheme: _outlinedButtonTheme(_lightColorScheme),
        textButtonTheme: _textButtonTheme(_lightColorScheme),
        navigationBarTheme: _navigationBarTheme(_lightColorScheme),
        dividerTheme: const DividerThemeData(
          color: AppColors.warmLinen,
          space: 1,
          thickness: 1,
        ),
        chipTheme: _chipTheme(_lightColorScheme),
      );

  // ---------------------------------------------------------------------------
  // Dark Theme (v2 scope — placeholder)
  // ---------------------------------------------------------------------------

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: _darkColorScheme,
        textTheme: AppTextStyles.textTheme,
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: _appBarTheme(_darkColorScheme),
        cardTheme: _cardTheme,
        inputDecorationTheme: _inputDecorationTheme(_darkColorScheme),
        elevatedButtonTheme: _elevatedButtonTheme(_darkColorScheme),
        outlinedButtonTheme: _outlinedButtonTheme(_darkColorScheme),
        textButtonTheme: _textButtonTheme(_darkColorScheme),
        navigationBarTheme: _navigationBarTheme(_darkColorScheme),
        dividerTheme: DividerThemeData(
          color: AppColors.deepDusk.withAlpha(128),
          space: 1,
          thickness: 1,
        ),
        chipTheme: _chipTheme(_darkColorScheme),
      );

  // ---------------------------------------------------------------------------
  // Colour Schemes
  // ---------------------------------------------------------------------------

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    // Primary: Flare Amber
    primary: AppColors.flareAmber,
    onPrimary: AppColors.deepDusk,
    primaryContainer: AppColors.sunrisePeach,
    onPrimaryContainer: AppColors.deepDusk,
    // Secondary: Dawn Coral
    secondary: AppColors.dawnCoral,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.sunrisePeach,
    onSecondaryContainer: AppColors.deepDusk,
    // Tertiary: Morning Sky
    tertiary: AppColors.morningSky,
    onTertiary: AppColors.deepDusk,
    tertiaryContainer: AppColors.paleSky,
    onTertiaryContainer: AppColors.deepDusk,
    // Error/Destructive
    error: AppColors.destructive,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF6B2214),
    // Surface
    surface: Colors.white,
    onSurface: AppColors.deepDusk,
    surfaceContainerHighest: AppColors.softCloud,
    onSurfaceVariant: Color(0xFF6B6560), // Deep Dusk at ~70%
    // Outline
    outline: AppColors.warmLinen,
    outlineVariant: AppColors.warmLinen,
    // Shadow
    shadow: AppColors.deepDusk,
    scrim: AppColors.deepDusk,
    // Inverse
    inverseSurface: AppColors.deepDusk,
    onInverseSurface: AppColors.softCloud,
    inversePrimary: AppColors.flareAmber,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    // Primary: Flare Amber (unchanged for dark)
    primary: AppColors.flareAmber,
    onPrimary: AppColors.deepDusk,
    primaryContainer: Color(0xFF5C4210),
    onPrimaryContainer: AppColors.sunrisePeach,
    // Secondary: Dawn Coral
    secondary: AppColors.dawnCoral,
    onSecondary: AppColors.deepDusk,
    secondaryContainer: Color(0xFF5C2E28),
    onSecondaryContainer: AppColors.sunrisePeach,
    // Tertiary: Morning Sky
    tertiary: AppColors.morningSky,
    onTertiary: AppColors.deepDusk,
    tertiaryContainer: Color(0xFF1E4A5C),
    onTertiaryContainer: AppColors.paleSky,
    // Error/Destructive
    error: Color(0xFFFF8A80),
    onError: AppColors.deepDusk,
    errorContainer: Color(0xFF5C2214),
    onErrorContainer: Color(0xFFFFDAD6),
    // Surface
    surface: AppColors.darkSurface,
    onSurface: AppColors.softCloud,
    surfaceContainerHighest: AppColors.darkBackground,
    onSurfaceVariant: Color(0xFFB0AAA5),
    // Outline
    outline: Color(0xFF4A4543),
    outlineVariant: Color(0xFF3A3533),
    // Shadow
    shadow: Colors.black,
    scrim: Colors.black,
    // Inverse
    inverseSurface: AppColors.softCloud,
    onInverseSurface: AppColors.deepDusk,
    inversePrimary: AppColors.flareAmber,
  );

  // ---------------------------------------------------------------------------
  // Component Themes
  // ---------------------------------------------------------------------------

  static AppBarTheme _appBarTheme(ColorScheme cs) => AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headingSm.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
        ),
      );

  static const CardThemeData _cardTheme = CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: borderRadiusLg,
    ),
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
  );

  static InputDecorationTheme _inputDecorationTheme(ColorScheme cs) =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.ashWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space4,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: BorderSide(color: AppColors.warmLinen, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: BorderSide(color: AppColors.warmLinen, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: BorderSide(color: AppColors.flareAmber, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadiusMd,
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        labelStyle: AppTextStyles.caption.copyWith(
          color: cs.onSurface.withAlpha(179), // 70% opacity
        ),
        floatingLabelStyle: TextStyle(color: AppColors.flareAmber),
        hintStyle: AppTextStyles.bodyMd.copyWith(
          color: cs.onSurfaceVariant.withAlpha(153),
        ),
        errorStyle: TextStyle(color: cs.error),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme cs) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.flareAmber,
          foregroundColor: AppColors.deepDusk,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.disabledText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: borderRadiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme cs) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepDusk,
          backgroundColor: AppColors.sunrisePeach,
          side: BorderSide(color: AppColors.warmLinen),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: borderRadiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      );

  static TextButtonThemeData _textButtonTheme(ColorScheme cs) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepDusk,
          padding: const EdgeInsets.symmetric(horizontal: space2, vertical: space1),
          minimumSize: const Size(44, 44),
          textStyle: AppTextStyles.button,
        ),
      );

  static NavigationBarThemeData _navigationBarTheme(ColorScheme cs) =>
      NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: AppColors.flareAmber.withAlpha(30),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.flareAmber, size: 24);
          }
          return IconThemeData(color: cs.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = AppTextStyles.caption;
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(
              color: AppColors.flareAmber,
              fontWeight: FontWeight.w700,
            );
          }
          return base.copyWith(color: cs.onSurfaceVariant);
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      );

  static ChipThemeData _chipTheme(ColorScheme cs) => ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: AppColors.flareAmber.withAlpha(30),
        labelStyle: AppTextStyles.label,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(
          borderRadius: borderRadiusSm,
        ),
        padding: const EdgeInsets.symmetric(horizontal: space3, vertical: radiusSm),
      );
}

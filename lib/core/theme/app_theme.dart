import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Health Flare — [ThemeData] factory.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
/// )
/// ```
abstract final class AppTheme {
  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _lightColorScheme,
        textTheme: AppTextStyles.textTheme,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: _appBarTheme(_lightColorScheme),
        cardTheme: _cardTheme,
        inputDecorationTheme: _inputDecorationTheme(_lightColorScheme),
        elevatedButtonTheme: _elevatedButtonTheme(_lightColorScheme),
        outlinedButtonTheme: _outlinedButtonTheme(_lightColorScheme),
        textButtonTheme: _textButtonTheme(_lightColorScheme),
        navigationBarTheme: _navigationBarTheme(_lightColorScheme),
        dividerTheme: const DividerThemeData(
          color: AppColors.grey200,
          space: 1,
          thickness: 1,
        ),
        chipTheme: _chipTheme(_lightColorScheme),
      );

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: _darkColorScheme,
        textTheme: AppTextStyles.textTheme,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: _appBarTheme(_darkColorScheme),
        cardTheme: _cardTheme,
        inputDecorationTheme: _inputDecorationTheme(_darkColorScheme),
        elevatedButtonTheme: _elevatedButtonTheme(_darkColorScheme),
        outlinedButtonTheme: _outlinedButtonTheme(_darkColorScheme),
        textButtonTheme: _textButtonTheme(_darkColorScheme),
        navigationBarTheme: _navigationBarTheme(_darkColorScheme),
        dividerTheme: DividerThemeData(
          color: AppColors.grey700,
          space: 1,
          thickness: 1,
        ),
        chipTheme: _chipTheme(_darkColorScheme),
      );

  // ---------------------------------------------------------------------------
  // Colour schemes
  // ---------------------------------------------------------------------------

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.teal,
    onPrimary: Colors.white,
    primaryContainer: AppColors.tealLight,
    onPrimaryContainer: AppColors.tealDark,
    secondary: AppColors.amber,
    onSecondary: AppColors.grey800,
    secondaryContainer: Color(0xFFFFF3CD),
    onSecondaryContainer: AppColors.amberDark,
    tertiary: AppColors.coral,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.coralLight,
    onTertiaryContainer: Color(0xFF6B2214),
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF6B2214),
    surface: AppColors.surface,
    onSurface: AppColors.grey800,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.grey600,
    outline: AppColors.grey300,
    outlineVariant: AppColors.grey200,
    shadow: AppColors.grey900,
    scrim: AppColors.grey900,
    inverseSurface: AppColors.grey800,
    onInverseSurface: AppColors.grey50,
    inversePrimary: AppColors.tealLight,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.tealLight,
    onPrimary: AppColors.tealDark,
    primaryContainer: AppColors.tealDark,
    onPrimaryContainer: AppColors.tealLight,
    secondary: AppColors.amber,
    onSecondary: AppColors.grey800,
    secondaryContainer: AppColors.amberDark,
    onSecondaryContainer: AppColors.amber,
    tertiary: AppColors.coralLight,
    onTertiary: AppColors.grey800,
    tertiaryContainer: AppColors.coral,
    onTertiaryContainer: Colors.white,
    error: AppColors.coralLight,
    onError: AppColors.grey900,
    errorContainer: AppColors.coral,
    onErrorContainer: Colors.white,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.grey100,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.grey400,
    outline: AppColors.grey600,
    outlineVariant: AppColors.grey700,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.grey100,
    onInverseSurface: AppColors.grey800,
    inversePrimary: AppColors.teal,
  );

  // ---------------------------------------------------------------------------
  // Shared component themes
  // ---------------------------------------------------------------------------

  static AppBarTheme _appBarTheme(ColorScheme cs) => AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.textTheme.titleLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
        ),
      );

  static const CardThemeData _cardTheme = CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
  );

  static InputDecorationTheme _inputDecorationTheme(ColorScheme cs) =>
      InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: cs.primary),
        hintStyle: TextStyle(
          color: cs.onSurfaceVariant.withAlpha(153),
        ),
        errorStyle: TextStyle(color: cs.error),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme cs) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.onSurface.withAlpha(30),
          disabledForegroundColor: cs.onSurface.withAlpha(97),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.textTheme.labelLarge,
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme cs) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.textTheme.labelLarge,
        ),
      );

  static TextButtonThemeData _textButtonTheme(ColorScheme cs) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(44, 44),
          textStyle: AppTextStyles.textTheme.labelLarge,
        ),
      );

  static NavigationBarThemeData _navigationBarTheme(ColorScheme cs) =>
      NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withAlpha(30),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: cs.primary, size: 24);
          }
          return IconThemeData(color: cs.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = AppTextStyles.textTheme.labelSmall!;
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(
              color: cs.primary,
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
        selectedColor: cs.primary.withAlpha(30),
        labelStyle: AppTextStyles.textTheme.labelMedium,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      );
}

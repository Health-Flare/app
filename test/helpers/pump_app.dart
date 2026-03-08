import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/theme/app_theme.dart';

/// Helper functions for widget testing.
///
/// Instead of an extension (which has limitations with super calls),
/// these are standalone helper functions.
class TestPump {
  TestPump._();

  /// Pumps a widget wrapped in the necessary providers and theme.
  static Future<void> pumpApp(
    WidgetTester tester,
    Widget widget, {
    Isar? isar,
    List<Override>? overrides,
  }) async {
    final allOverrides = <Override>[
      if (isar != null) isarProvider.overrideWithValue(isar),
      ...?overrides,
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: allOverrides,
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: widget,
        ),
      ),
    );
  }

  /// Pumps a widget wrapped in a Scaffold for proper Material context.
  static Future<void> pumpInScaffold(
    WidgetTester tester,
    Widget widget, {
    Isar? isar,
    List<Override>? overrides,
  }) async {
    await pumpApp(
      tester,
      Scaffold(body: widget),
      isar: isar,
      overrides: overrides,
    );
  }

  /// Taps a widget and settles.
  static Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Enters text and settles.
  static Future<void> enterTextAndSettle(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Scrolls until finder is visible.
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder, {
    double delta = 100,
    int maxScrolls = 50,
  }) async {
    int scrollCount = 0;
    while (!tester.any(finder) && scrollCount < maxScrolls) {
      await tester.drag(find.byType(Scrollable).first, Offset(0, -delta));
      await tester.pump();
      scrollCount++;
    }
    await tester.pumpAndSettle();
  }
}

/// Common finders for Health Flare widgets.
class AppFinders {
  AppFinders._();

  /// Finds an elevated button by its text.
  static Finder elevatedButton(String text) =>
      find.widgetWithText(ElevatedButton, text);

  /// Finds a text button by its text.
  static Finder textButton(String text) =>
      find.widgetWithText(TextButton, text);

  /// Finds an outlined button by its text.
  static Finder outlinedButton(String text) =>
      find.widgetWithText(OutlinedButton, text);

  /// Finds a text field by its label or hint.
  static Finder textField(String labelOrHint) => find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            (widget.decoration?.labelText == labelOrHint ||
                widget.decoration?.hintText == labelOrHint),
      );

  /// Finds a snackbar with specific text.
  static Finder snackBar(String text) =>
      find.widgetWithText(SnackBar, text);

  /// Finds a list tile by its title.
  static Finder listTile(String title) =>
      find.widgetWithText(ListTile, title);

  /// Finds a chip by its label.
  static Finder chip(String label) =>
      find.widgetWithText(Chip, label);

  /// Finds a filter chip by its label.
  static Finder filterChip(String label) =>
      find.widgetWithText(FilterChip, label);
}

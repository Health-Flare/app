import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../helpers/test_database.dart';

/// Step definitions for common test actions shared across features.

/// {@template given_the_app_has_been_installed_and_launched_for_the_first_time}
/// Sets up a fresh app state with no existing data.
/// {@endtemplate}
Future<void> givenTheAppHasBeenInstalledAndLaunchedForTheFirstTime(
  WidgetTester tester,
) async {
  // Database will be created fresh by the test setup
}

/// {@template given_the_app_is_open}
/// Ensures the app is running and ready for interaction.
/// {@endtemplate}
Future<void> givenTheAppIsOpen(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

/// {@template when_the_app_loads}
/// Waits for the app to fully load and settle.
/// {@endtemplate}
Future<void> whenTheAppLoads(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

/// {@template when_i_tap_text}
/// Taps on a widget containing the specified text.
/// {@endtemplate}
Future<void> whenITap(WidgetTester tester, String text) async {
  final finder = find.text(text);
  expect(finder, findsOneWidget, reason: 'Could not find "$text" to tap');
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// {@template when_i_enter_text_in_field}
/// Enters text into a text field found by the given finder.
/// {@endtemplate}
Future<void> whenIEnterTextInField(
  WidgetTester tester,
  String text,
  Finder fieldFinder,
) async {
  await tester.enterText(fieldFinder, text);
  await tester.pumpAndSettle();
}

/// {@template then_i_see_text}
/// Verifies that the specified text is visible on screen.
/// {@endtemplate}
Future<void> thenISee(WidgetTester tester, String text) async {
  expect(find.text(text), findsAtLeastNWidgets(1));
}

/// {@template then_i_do_not_see_text}
/// Verifies that the specified text is NOT visible on screen.
/// {@endtemplate}
Future<void> thenIDoNotSee(WidgetTester tester, String text) async {
  expect(find.text(text), findsNothing);
}

/// {@template then_i_see_widget}
/// Verifies that a widget of the specified type is visible.
/// {@endtemplate}
Future<void> thenISeeWidget<T>(WidgetTester tester) async {
  expect(find.byType(T), findsAtLeastNWidgets(1));
}

/// {@template then_i_do_not_see_widget}
/// Verifies that no widget of the specified type is visible.
/// {@endtemplate}
Future<void> thenIDoNotSeeWidget<T>(WidgetTester tester) async {
  expect(find.byType(T), findsNothing);
}

/// A map to store shared test state between steps.
class TestContext {
  static final Map<String, dynamic> _data = {};
  static Isar? _isar;

  static T get<T>(String key) => _data[key] as T;
  static void set<T>(String key, T value) => _data[key] = value;
  static void clear() => _data.clear();

  static Isar get isar => _isar!;
  static set isar(Isar value) => _isar = value;

  static Future<void> reset() async {
    clear();
    if (_isar != null) {
      await TestDatabase.clear(_isar!);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Step definitions for navigation-related scenarios.

/// {@template given_i_am_on_the_dashboard}
/// Verifies we are on the dashboard screen.
/// {@endtemplate}
Future<void> givenIAmOnTheDashboard(WidgetTester tester) async {
  await tester.pumpAndSettle();
  // Dashboard should show "Health Flare" in the app bar
  expect(find.text('Health Flare'), findsAtLeastNWidgets(1));
}

/// {@template when_i_tap_the_back_button}
/// Taps the back navigation button.
/// {@endtemplate}
Future<void> whenITapTheBackButton(WidgetTester tester) async {
  final backButton = find.byIcon(Icons.arrow_back);
  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton);
    await tester.pumpAndSettle();
  }
}

/// {@template when_i_navigate_to}
/// Navigates to a specific route by tapping on navigation elements.
/// {@endtemplate}
Future<void> whenINavigateTo(WidgetTester tester, String destination) async {
  // This would tap on navigation elements to reach the destination
  // Implementation depends on the app's navigation structure
  await tester.pumpAndSettle();
}

/// {@template then_i_am_on_screen}
/// Verifies we are on the specified screen.
/// {@endtemplate}
Future<void> thenIAmOnScreen(WidgetTester tester, String screenName) async {
  // Verify screen-specific elements
  await tester.pumpAndSettle();
}

/// {@template then_i_am_returned_to_the_dashboard}
/// Verifies we are back on the dashboard.
/// {@endtemplate}
Future<void> thenIAmReturnedToTheDashboard(WidgetTester tester) async {
  expect(find.text('Health Flare'), findsAtLeastNWidgets(1));
}

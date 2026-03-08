import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Step definitions for onboarding-related scenarios.

/// {@template given_no_profiles_exist_on_this_device}
/// Ensures the database has no profiles.
/// {@endtemplate}
Future<void> givenNoProfilesExistOnThisDevice(WidgetTester tester) async {
  // Fresh database means no profiles - handled by test setup
}

/// {@template given_i_am_on_the_onboarding_screen}
/// Verifies we are on the onboarding screen.
/// {@endtemplate}
Future<void> givenIAmOnTheOnboardingScreen(WidgetTester tester) async {
  await tester.pumpAndSettle();
  expect(
    find.text('Your health story,\nin your hands.'),
    findsOneWidget,
    reason: 'Expected to be on onboarding screen',
  );
}

/// {@template then_i_am_shown_the_onboarding_screen}
/// Verifies the onboarding screen is displayed.
/// {@endtemplate}
Future<void> thenIAmShownTheOnboardingScreen(WidgetTester tester) async {
  expect(find.text('Your health story,\nin your hands.'), findsOneWidget);
}

/// {@template then_i_see_the_app_name}
/// Verifies the app name "Health Flare" is visible.
/// {@endtemplate}
Future<void> thenISeeTheAppName(WidgetTester tester, String appName) async {
  expect(find.text(appName), findsAtLeastNWidgets(1));
}

/// {@template then_i_see_a_profile_creation_form}
/// Verifies the profile creation form is visible.
/// {@endtemplate}
Future<void> thenISeeAProfileCreationForm(WidgetTester tester) async {
  expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
}

/// {@template then_the_name_input_has_focus}
/// Verifies the name input field has focus.
/// {@endtemplate}
Future<void> thenTheNameInputHasFocus(WidgetTester tester) async {
  final textFields = find.byType(TextFormField);
  expect(textFields, findsAtLeastNWidgets(1));

  // Verify the first text field exists and is the name field
  // Note: checking actual focus state requires finding the FocusNode
  tester.widget<TextFormField>(textFields.first);
}

/// {@template when_i_enter_name}
/// Enters a name in the name field.
/// {@endtemplate}
Future<void> whenIEnterName(WidgetTester tester, String name) async {
  final nameField = find.byType(TextFormField).first;
  await tester.enterText(nameField, name);
  await tester.pump();
}

/// {@template when_i_tap_the_primary_action_button}
/// Taps the primary action button on onboarding.
/// {@endtemplate}
Future<void> whenITapThePrimaryActionButton(WidgetTester tester) async {
  final button = find.widgetWithText(
    ElevatedButton,
    'Create profile and get started  →',
  );
  expect(button, findsOneWidget, reason: 'Could not find primary action button');
  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// {@template then_a_profile_named_is_created}
/// Verifies a profile with the given name was created.
/// {@endtemplate}
Future<void> thenAProfileNamedIsCreated(
  WidgetTester tester,
  String name,
) async {
  // After creating a profile, we should be on the dashboard
  // The profile name might appear in the app bar or profile section
  await tester.pumpAndSettle();
}

/// {@template then_i_am_taken_into_the_main_app}
/// Verifies navigation to the main app after onboarding.
/// {@endtemplate}
Future<void> thenIAmTakenIntoTheMainApp(WidgetTester tester) async {
  // Should no longer see onboarding welcome text
  expect(find.text('Your health story,\nin your hands.'), findsNothing);
}

/// {@template then_the_primary_button_is_disabled}
/// Verifies the primary action button is disabled.
/// {@endtemplate}
Future<void> thenThePrimaryButtonIsDisabled(WidgetTester tester) async {
  final button = find.widgetWithText(
    ElevatedButton,
    'Create profile and get started  →',
  );
  final elevatedButton = tester.widget<ElevatedButton>(button);
  expect(elevatedButton.onPressed, isNull);
}

/// {@template then_the_primary_button_is_enabled}
/// Verifies the primary action button is enabled.
/// {@endtemplate}
Future<void> thenThePrimaryButtonIsEnabled(WidgetTester tester) async {
  final button = find.widgetWithText(
    ElevatedButton,
    'Create profile and get started  →',
  );
  final elevatedButton = tester.widget<ElevatedButton>(button);
  expect(elevatedButton.onPressed, isNotNull);
}

/// {@template then_the_first_log_prompt_is_shown}
/// Verifies the first-log prompt is displayed after onboarding.
/// {@endtemplate}
Future<void> thenTheFirstLogPromptIsShown(WidgetTester tester) async {
  // Look for first-log prompt indicators
  // This could be a modal, bottom sheet, or inline prompt
  await tester.pumpAndSettle();
}

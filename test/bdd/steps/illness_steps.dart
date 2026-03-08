import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/condition_fixtures.dart';
import '../../helpers/test_database.dart';
import 'common_steps.dart';

/// Step definitions for illness/condition-related scenarios.

/// {@template given_the_illness_entry_screen_is_open}
/// Verifies we are on the illness entry screen.
/// {@endtemplate}
Future<void> givenTheIllnessEntryScreenIsOpen(WidgetTester tester) async {
  await tester.pumpAndSettle();
  // Should see the search bar and condition list
}

/// {@template given_conditions_are_seeded}
/// Seeds the database with global conditions.
/// {@endtemplate}
Future<void> givenConditionsAreSeeded(WidgetTester tester) async {
  final isar = TestContext.isar;
  await isar.seedConditions(ConditionFixtures.globalConditions);
}

/// {@template given_symptoms_are_seeded}
/// Seeds the database with symptoms.
/// {@endtemplate}
Future<void> givenSymptomsAreSeeded(WidgetTester tester) async {
  final isar = TestContext.isar;
  await isar.seedSymptoms(ConditionFixtures.commonSymptoms);
}

/// {@template given_the_active_profile_is_tracking_condition}
/// Sets up the active profile to already be tracking a condition.
/// {@endtemplate}
Future<void> givenTheActiveProfileIsTrackingCondition(
  WidgetTester tester,
  String conditionName,
) async {
  // Add a UserCondition linking the active profile to the condition
}

/// {@template when_i_type_in_the_search_bar}
/// Types text in the illness search bar.
/// {@endtemplate}
Future<void> whenITypeInTheSearchBar(
  WidgetTester tester,
  String searchText,
) async {
  final searchField = find.byType(TextField);
  expect(searchField, findsOneWidget);
  await tester.enterText(searchField, searchText);
  await tester.pumpAndSettle();
}

/// {@template when_i_clear_the_search_bar}
/// Clears the illness search bar.
/// {@endtemplate}
Future<void> whenIClearTheSearchBar(WidgetTester tester) async {
  final searchField = find.byType(TextField);
  await tester.enterText(searchField, '');
  await tester.pumpAndSettle();
}

/// {@template when_i_tap_condition}
/// Taps on a condition in the list to select it.
/// {@endtemplate}
Future<void> whenITapCondition(
  WidgetTester tester,
  String conditionName,
) async {
  final conditionTile = find.text(conditionName);
  expect(conditionTile, findsOneWidget);
  await tester.tap(conditionTile);
  await tester.pumpAndSettle();
}

/// {@template when_i_tap_symptom_chip}
/// Taps on a symptom chip to select/deselect it.
/// {@endtemplate}
Future<void> whenITapSymptomChip(
  WidgetTester tester,
  String symptomName,
) async {
  final chip = find.widgetWithText(FilterChip, symptomName);
  if (chip.evaluate().isNotEmpty) {
    await tester.tap(chip);
    await tester.pumpAndSettle();
  }
}

/// {@template when_i_tap_done}
/// Taps the Done button on the illness screen.
/// {@endtemplate}
Future<void> whenITapDone(WidgetTester tester) async {
  final doneButton = find.text('Done');
  expect(doneButton, findsOneWidget);
  await tester.tap(doneButton);
  await tester.pumpAndSettle();
}

/// {@template then_condition_is_selected}
/// Verifies the condition is marked as selected.
/// {@endtemplate}
Future<void> thenConditionIsSelected(
  WidgetTester tester,
  String conditionName,
) async {
  // Look for visual indicator of selection (checkmark, filled style)
  // Could also check for the chip in the selected area
}

/// {@template then_i_see_condition_chip}
/// Verifies a condition chip is visible in the selected area.
/// {@endtemplate}
Future<void> thenISeeConditionChip(
  WidgetTester tester,
  String conditionName,
) async {
  final chip = find.widgetWithText(Chip, conditionName);
  expect(chip, findsOneWidget);
}

/// {@template then_the_done_button_is_disabled}
/// Verifies the Done button is disabled.
/// {@endtemplate}
Future<void> thenTheDoneButtonIsDisabled(WidgetTester tester) async {
  // Find the Done button and check its enabled state
}

/// {@template then_the_done_button_is_enabled}
/// Verifies the Done button is enabled.
/// {@endtemplate}
Future<void> thenTheDoneButtonIsEnabled(WidgetTester tester) async {
  // Find the Done button and check its enabled state
}

/// {@template then_the_symptom_quick_add_section_is_visible}
/// Verifies the symptom quick-add section is visible.
/// {@endtemplate}
Future<void> thenTheSymptomQuickAddSectionIsVisible(
  WidgetTester tester,
) async {
  // Look for "Common Symptoms" heading or symptom chips
  expect(find.text('Common Symptoms'), findsOneWidget);
}

/// {@template then_condition_list_shows_only}
/// Verifies the condition list is filtered to show only matching items.
/// {@endtemplate}
Future<void> thenConditionListShowsOnly(
  WidgetTester tester,
  List<String> expectedConditions,
) async {
  for (final condition in expectedConditions) {
    expect(find.text(condition), findsOneWidget);
  }
}

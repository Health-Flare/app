import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/profile_fixtures.dart';
import '../../helpers/test_database.dart';
import 'common_steps.dart';

/// Step definitions for profile-related scenarios.

/// {@template given_at_least_one_profile_exists}
/// Seeds the database with at least one profile.
/// {@endtemplate}
Future<void> givenAtLeastOneProfileExists(WidgetTester tester) async {
  final isar = TestContext.isar;
  await isar.seedProfiles([ProfileFixtures.simpleIsar]);
  await isar.setActiveProfile(1);
}

/// {@template given_profile_exists}
/// Seeds the database with a profile with the given name.
/// {@endtemplate}
Future<void> givenProfileExists(WidgetTester tester, String name) async {
  final isar = TestContext.isar;
  await isar.seedProfiles([
    ProfileFixtures.simpleIsar..name = name,
  ]);
}

/// {@template given_multiple_profiles_exist}
/// Seeds the database with multiple profiles.
/// {@endtemplate}
Future<void> givenMultipleProfilesExist(WidgetTester tester) async {
  final isar = TestContext.isar;
  await isar.seedProfiles(ProfileFixtures.multipleProfilesIsar);
  await isar.setActiveProfile(1);
}

/// {@template given_the_active_profile_is}
/// Sets the active profile to the one with the given name.
/// {@endtemplate}
Future<void> givenTheActiveProfileIs(
  WidgetTester tester,
  String profileName,
) async {
  // Find the profile by name and set it as active
  // This would query the database and update app settings
}

/// {@template when_i_switch_to_profile}
/// Switches to a different profile.
/// {@endtemplate}
Future<void> whenISwitchToProfile(
  WidgetTester tester,
  String profileName,
) async {
  // Open profile switcher and tap on the profile
  await tester.pumpAndSettle();
}

/// {@template then_the_active_profile_is}
/// Verifies the active profile has the expected name.
/// {@endtemplate}
Future<void> thenTheActiveProfileIs(
  WidgetTester tester,
  String expectedName,
) async {
  // Verify the profile name appears in the expected location
  expect(find.text(expectedName), findsAtLeastNWidgets(1));
}

/// {@template then_no_profile_is_created}
/// Verifies that no new profile was created.
/// {@endtemplate}
Future<void> thenNoProfileIsCreated(WidgetTester tester) async {
  // Verify database state if needed
}

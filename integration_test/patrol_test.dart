import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:patrol/patrol.dart';

import 'package:health_flare/main.dart';
import 'package:health_flare/core/providers/database_provider.dart';

import '../test/helpers/test_database.dart';
import '../test/fixtures/profile_fixtures.dart';

/// Patrol tests for native interactions and more complex E2E scenarios.
///
/// Patrol extends Flutter's integration testing with native automation,
/// allowing interaction with system dialogs, permissions, and more.
///
/// Run with: patrol test

void main() {
  late Isar isar;

  patrolSetUp(() async {
    isar = await TestDatabase.open();
  });

  patrolTearDown(() async {
    await TestDatabase.closeAll();
  });

  patrolTest('Complete onboarding flow', ($) async {
    // Start app
    await $.pumpWidget(
      ProviderScope(
        overrides: [isarProvider.overrideWithValue(isar)],
        child: const HealthFlareApp(),
      ),
    );

    // Wait for app to settle
    await $.pumpAndSettle();

    // Verify onboarding is shown
    expect($('Your health story,\nin your hands.'), findsOneWidget);

    // Enter name
    await $.enterText(find.byType(TextField).first, 'Sarah');
    await $.pump();

    // Tap create button
    await $('Create profile and get started  →').tap();
    await $.pumpAndSettle();

    // Should be past onboarding
    expect($('Your health story,\nin your hands.'), findsNothing);
  });

  patrolTest('Profile with existing data shows dashboard', ($) async {
    // Seed data
    await isar.seedProfiles([ProfileFixtures.simpleIsar]);
    await isar.setActiveProfile(1);

    // Start app
    await $.pumpWidget(
      ProviderScope(
        overrides: [isarProvider.overrideWithValue(isar)],
        child: const HealthFlareApp(),
      ),
    );

    await $.pumpAndSettle();

    // Should show dashboard
    expect($('Health Flare'), findsWidgets);
  });

  patrolTest('Can navigate to journal section', ($) async {
    // Seed data
    await isar.seedProfiles([ProfileFixtures.simpleIsar]);
    await isar.setActiveProfile(1);

    // Start app
    await $.pumpWidget(
      ProviderScope(
        overrides: [isarProvider.overrideWithValue(isar)],
        child: const HealthFlareApp(),
      ),
    );

    await $.pumpAndSettle();

    // Navigate to journal (actual navigation depends on UI)
    // This is a placeholder for the actual navigation flow
  });

  // Native interaction tests (requires actual device/emulator)
  patrolTest(
    'Can select avatar from photo library',
    skip: true, // Enable when testing on device
    ($) async {
      // Start app
      await $.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const HealthFlareApp(),
        ),
      );

      await $.pumpAndSettle();

      // Navigate to avatar picker
      // This would trigger native photo picker
      // await $.native.selectPhotoFromGallery();
    },
  );
}

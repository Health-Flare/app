// ignore_for_file: avoid_print
//
// Track and Care, end to end: the real app on a real database with the
// trackAndCare flag on. Walks every section and tab in
// docs/features/navigation.feature and screenshots each one. Run it with:
//
//   bash scripts/track_and_care.sh shots   # iOS simulator, screenshots
//   bash scripts/track_and_care.sh e2e     # same, no screenshots kept
//
// Full guide: docs/testing/track-and-care.md.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/database/app_database.dart';
import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/main.dart';

late IntegrationTestWidgetsFlutterBinding _binding;
bool _surfaceConverted = false;

/// Saved as `track_and_care_<name>.png` by the driver (SCREENSHOT_DIR).
Future<void> _shot(WidgetTester tester, String name) async {
  if (!_surfaceConverted) {
    await _binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }
  await tester.pump();
  await _binding.takeScreenshot('track_and_care_$name');
  print('📸  track_and_care_$name');
}

/// Real Isar reads take real time; pumpAndSettle can hang on them.
Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// One profile, onboarding and post-setup prompts done: opens on the
/// dashboard.
Future<Isar> _db() async {
  final dir = await getTemporaryDirectory();
  final isar = await Isar.open(
    appSchemas,
    directory: dir.path,
    name: 'track_and_care_e2e_${DateTime.now().microsecondsSinceEpoch}',
  );
  await MigrationRunner.run(isar);
  await isar.writeTxn(() async {
    await isar.profileIsars.put(
      ProfileIsar()
        ..id = 1
        ..name = 'Sarah'
        ..firstLogShown = true
        ..weatherOptInShown = true,
    );
    final s = (await isar.appSettings.get(1)) ?? AppSettings();
    s
      ..activeProfileId = 1
      ..lastProfileId = 1
      // No What's new card in the way.
      ..updateHighlightsOff = true;
    await isar.appSettings.put(s);
  });
  return isar;
}

/// A fresh launch: new providers, new router, nothing remembered.
Future<void> _launch(WidgetTester tester, Isar isar) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final startup = await IsarService.readStartupData(isar);
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        isarProvider.overrideWithValue(isar),
        featureFlagsProvider.overrideWithValue(
          const FeatureFlags(trackAndCare: true),
        ),
        profileListProvider.overrideWith(
          () => ProfileListNotifier()..preload(startup.profiles),
        ),
        activeProfileProvider.overrideWith(
          () => ActiveProfileNotifier()..preload(startup.activeProfileId),
        ),
      ],
      child: const HealthFlareApp(),
    ),
  );
  await _waitFor(tester, find.byType(NavigationBar));
}

Finder _bar(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Finder _tab(String label) =>
    find.descendant(of: find.byType(TabBar), matching: find.text(label));

String _selectedTab(WidgetTester tester) {
  final bar = tester.widget<TabBar>(find.byType(TabBar));
  return (bar.tabs[bar.controller!.index] as Tab).text!;
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await _settle(tester);
}

void main() {
  _binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Track and Care: every section and tab', (tester) async {
    final isar = await _db();
    await _launch(tester, isar);

    // The primary navigation has four sections.
    for (final label in ['Dashboard', 'Track', 'Care', 'Journal']) {
      expect(_bar(label), findsOneWidget, reason: label);
    }
    await _shot(tester, '01_dashboard');

    // Each section opens on its first tab; every tab is one more tap.
    const sections = {
      'Track': ['Symptoms', 'Vitals', 'Meals', 'Sleep', 'Activity'],
      'Care': ['Medications', 'Appointments', 'Conditions', 'Flares'],
      'Journal': ['Entries', 'Check-ins'],
    };
    var n = 2;
    for (final MapEntry(key: section, value: tabs) in sections.entries) {
      await _tap(tester, _bar(section));
      await _waitFor(tester, find.byType(TabBar));
      expect(_selectedTab(tester), tabs.first, reason: section);
      for (final t in tabs) {
        if (_selectedTab(tester) != t) await _tap(tester, _tab(t));
        expect(_selectedTab(tester), t);
        expect(tester.takeException(), isNull, reason: '$section > $t');
        await _shot(
          tester,
          '${n.toString().padLeft(2, '0')}_${section.toLowerCase()}_'
          '${t.toLowerCase().replaceAll('-', '')}',
        );
        n++;
      }
    }

    // The section remembers the last tab used.
    await _tap(tester, _bar('Care'));
    await _tap(tester, _tab('Appointments'));
    await _tap(tester, _bar('Dashboard'));
    await _tap(tester, _bar('Care'));
    expect(_selectedTab(tester), 'Appointments');

    // The add button follows the tab: the appointment form opens.
    await _tap(tester, find.byType(FloatingActionButton));
    await _waitFor(tester, find.textContaining('ppointment'));
    await _shot(tester, '${n++}_care_appointments_add');
    await tester.pageBack();
    await _settle(tester);

    // Reports is in the top bar.
    await _tap(tester, find.byTooltip('Reports'));
    await _waitFor(tester, find.text('Reports'));
    await _shot(tester, '${n++}_reports_from_care');
    await tester.pageBack();
    await _settle(tester);

    // Remembered tabs reset when the app is closed.
    await _launch(tester, isar);
    await _tap(tester, _bar('Care'));
    expect(_selectedTab(tester), 'Medications');

    // Section tabs stay usable with large text.
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _launch(tester, isar);
    await _tap(tester, _bar('Track'));
    await _shot(tester, '${n++}_track_large_text');
    // The tab row scrolls sideways: Activity is off to the right.
    await tester.ensureVisible(_tab('Activity'));
    await _settle(tester);
    await _tap(tester, _tab('Activity'));
    expect(_selectedTab(tester), 'Activity');
    expect(tester.takeException(), isNull);
    await _shot(tester, '${n++}_track_large_text_scrolled');

    await isar.close(deleteFromDisk: true);
  });
}

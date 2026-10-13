// ignore_for_file: avoid_print
//
// Release review for 1.10.0 (#171): walks the real app through every new
// notification and screen, in the order someone updating from 1.9.1 sees
// them, and screenshots each step in four variants (light and dark, at
// 100% and 200% text). Not the store screenshots: those are
// integration_test/screenshot_test.dart.
//
//   bash scripts/release_review.sh
//
// Shots are named `<variant>__NN_step`; tool/release_review_sheet.dart
// sorts them and builds the contact sheet. Guide: docs/testing/release-review.md.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:health_flare/core/navigation/bar_choice.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/bar_layout_store.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/database/app_database.dart';
import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/failed_upgrade.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/failed_upgrade/failed_upgrade_provider.dart';
import 'package:health_flare/features/release_guides/screens/release_guide_screen.dart';
import 'package:health_flare/features/whats_new/whats_new_provider.dart';
import 'package:health_flare/features/whats_new/whats_new_rules.dart';
import 'package:health_flare/main.dart';

late IntegrationTestWidgetsFlutterBinding _binding;
bool _surfaceConverted = false;
String _variant = 'light-100';

Future<void> _shot(WidgetTester tester, int step, String name) async {
  if (!_surfaceConverted) {
    await _binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }
  await _settle(tester);
  final shot = '${_variant}__${step.toString().padLeft(2, '0')}_$name';
  await _binding.takeScreenshot(shot);
  print('📸  $shot');
}

/// Real Isar reads take real time; pumpAndSettle can hang on them.
Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('[$_variant] timed out waiting for $finder');
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f.first);
  await _settle(tester);
  await tester.tap(f.first);
  await _settle(tester);
}

/// Scrolls the screen's main list until [f] is built and on screen.
Future<void> _scrollTo(WidgetTester tester, Finder f, {double by = 200}) =>
    tester.scrollUntilVisible(f, by, scrollable: find.byType(Scrollable).first);

/// Scrolls [f] (already built) to the top of its list, for a shot that
/// starts at a section header.
Future<void> _toTop(WidgetTester tester, Finder f) async {
  await Scrollable.ensureVisible(tester.element(f.first), alignment: 0.05);
  await _settle(tester);
}

/// A bar item. By tooltip: from 150% text the bar is icons only (#143).
Finder _bar(String label) => find.descendant(
  of: find.byType(NavigationBar),
  matching: find.byTooltip(label),
);

Finder _tab(String label) =>
    find.descendant(of: find.byType(TabBar), matching: find.text(label));

/// A guide row, side by side or stacked at large text.
Finder _row(String was) => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith('moved-$was'),
);

/// Someone updating from 1.9.1: one profile, the old bar, nothing seen.
/// [customBar] is a bar they had set up themselves.
Future<Isar> _upgradedFrom191({List<String>? customBar}) async {
  final dir = await getTemporaryDirectory();
  final isar = await Isar.open(
    appSchemas,
    directory: dir.path,
    name: 'release_review_${DateTime.now().microsecondsSinceEpoch}',
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
      ..updateHighlightsOff = false;
    await isar.appSettings.put(s);
  });
  await WhatsNewStore.write(
    isar,
    const WhatsNewRecord(lastSeenVersion: '1.9.1'),
  );
  await BarLayoutStore.write(
    isar,
    BarRecord(storedBar: customBar, seenVersion: 1),
  );
  return isar;
}

/// A fresh launch of 1.10.0 on [isar].
Future<void> _launch(
  WidgetTester tester,
  Isar isar, {
  FailedUpgrade? failure,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final startup = await IsarService.readStartupData(isar);
  final barRecord = await BarLayoutStore.read(isar);
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        isarProvider.overrideWithValue(isar),
        profileListProvider.overrideWith(
          () => ProfileListNotifier()..preload(startup.profiles),
        ),
        activeProfileProvider.overrideWith(
          () => ActiveProfileNotifier()..preload(startup.activeProfileId),
        ),
        barChoiceProvider.overrideWith(
          () => BarChoiceNotifier()..preload(barRecord),
        ),
        // pubspec.yaml still says 1.9.1 until the release is cut.
        installedVersionProvider.overrideWith((ref) async => '1.10.0'),
        failedUpgradeProvider.overrideWithValue(failure),
      ],
      child: const HealthFlareApp(),
    ),
  );
  await _waitFor(tester, find.byType(NavigationBar));
  await _settle(tester);
}

/// Steps 1 to 21: the default-bar upgrade, start to finish.
Future<void> _defaultBarWalk(WidgetTester tester) async {
  final isar = await _upgradedFrom191();
  await _launch(tester, isar);

  // 1. The guide card comes first.
  await _waitFor(tester, find.text('The bottom bar has changed'));
  await _shot(tester, 1, 'guide_card');

  // 2-6. The guide.
  await _tap(tester, find.text('Show me'));
  await _waitFor(tester, find.byType(ReleaseGuideScreen));
  await _shot(tester, 2, 'guide_four_sections');
  await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
  await _waitFor(tester, find.text('Where things moved'));
  await _shot(tester, 3, 'guide_where_things_moved');
  final pin = find.descendant(of: _row('Sleep'), matching: find.text('Pin'));
  await _tap(tester, pin);
  await tester.scrollUntilVisible(
    find.textContaining('Sleep is in your bar'),
    100,
    scrollable: find.byType(Scrollable).last,
  );
  await _shot(tester, 4, 'guide_pinned');
  await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
  await _waitFor(tester, find.text('Use the new layout'));
  await _shot(tester, 5, 'guide_keep_or_change');
  await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
  await _waitFor(tester, find.widgetWithText(FilledButton, 'Done'));
  await _shot(tester, 6, 'guide_finding_again');

  // 7. Back to the rows: Show me opens the screen, its bar item outlined.
  await _tap(tester, find.byTooltip('Back'));
  await _tap(tester, find.byTooltip('Back'));
  await _waitFor(tester, find.text('Where things moved'));
  await _tap(
    tester,
    find.descendant(of: _row('Meds'), matching: find.text('Show me')),
  );
  await _waitFor(tester, _tab('Medications'));
  await _shot(tester, 7, 'show_me_outlined');

  // 8-9. After the guide: What's new, then its Replay in Settings.
  await _tap(tester, _bar('Dashboard'));
  await _waitFor(tester, find.textContaining("What's new"));
  await _shot(tester, 8, 'whats_new_card');
  await _tap(tester, find.byTooltip('Settings'));
  await _scrollTo(tester, find.text("What's new"));
  await _tap(tester, find.text("What's new"));
  await _waitFor(tester, find.text('Replay guide'));
  await _shot(tester, 9, 'whats_new_replay_guide');
  await tester.pageBack();
  await _settle(tester);
  await tester.pageBack();
  await _settle(tester);

  // 10-13. The sections, and the pinned Sleep.
  await _tap(tester, _bar('Track'));
  await _waitFor(tester, find.byType(TabBar));
  await _shot(tester, 10, 'track');
  await _tap(tester, _bar('Care'));
  await _shot(tester, 11, 'care');
  await _tap(tester, _bar('Journal'));
  await _shot(tester, 12, 'journal');
  await _tap(tester, _bar('Sleep'));
  await _shot(tester, 13, 'pinned_sleep');

  // 14-16. Settings > Your layout.
  await _tap(tester, _bar('Dashboard'));
  await _tap(tester, find.byTooltip('Settings'));
  await _scrollTo(tester, find.text('Features in use'));
  await _toTop(tester, find.text('Your layout'));
  await _shot(tester, 14, 'settings_your_layout');
  await _tap(tester, find.text('Features in use'));
  await _waitFor(tester, find.textContaining('These switches apply to Sarah'));
  await _tap(tester, find.text('Meals'));
  await _waitFor(tester, find.textContaining('Meals is off for Sarah'));
  await _shot(tester, 15, 'features_in_use_meals_off');
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
      .hideCurrentSnackBar();
  await tester.pageBack();
  await _settle(tester);
  await _scrollTo(tester, find.text('Bottom bar'));
  await _tap(tester, find.text('Bottom bar'));
  await _waitFor(tester, find.text('In the bar'));
  await _shot(tester, 16, 'bottom_bar');

  // 17. Sleep pinned makes five: the bar is full and says so.
  await _scrollTo(tester, find.textContaining('The bar holds five items'));
  await _shot(tester, 17, 'bottom_bar_full');
  await _scrollTo(tester, find.text('Like before'), by: -200);
  await _tap(tester, find.text('Like before'));
  await _shot(tester, 18, 'bottom_bar_like_before');
  await tester.pageBack();
  await _settle(tester);
  await tester.pageBack();
  await _settle(tester);

  // The editor's Undo snackbar outlives it: clear it so it can't sit over
  // the Quick Log button.
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger).first)
      .hideCurrentSnackBar();
  await _settle(tester);

  // 19. Like before has five items with More: the rest are there.
  await _tap(tester, _bar('More'));
  await _shot(tester, 19, 'more');

  // 20. Quick Log with Meals off.
  await _tap(tester, _bar('Dashboard'));
  await _tap(tester, find.byType(FloatingActionButton));
  await tester.enterText(
    find.byType(TextField),
    'Toast and eggs for breakfast',
  );
  await _waitFor(tester, find.textContaining('Meals is turned off'));
  await _shot(tester, 20, 'quick_log_meals_off');

  await isar.close(deleteFromDisk: true);
}

/// Steps 21-22: someone who had set up their own bar.
Future<void> _customBarWalk(WidgetTester tester) async {
  final isar = await _upgradedFrom191(
    customBar: [
      'dashboard',
      'track.symptoms',
      'care.medications',
      'track.sleep',
      'journal.entries',
    ],
  );
  await _launch(tester, isar);
  await _waitFor(tester, find.textContaining('Yours has been kept'));
  await _shot(tester, 21, 'custom_bar_card');
  await _tap(tester, find.text('Show me'));
  await _waitFor(tester, find.byType(ReleaseGuideScreen));
  await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
  await _tap(tester, find.widgetWithText(FilledButton, 'Next'));
  await _waitFor(tester, find.text('Keep my bar'));
  await _shot(tester, 22, 'custom_bar_keep_or_change');
  await isar.close(deleteFromDisk: true);
}

/// Steps 23-24: an upgrade that stopped retrying (#112).
Future<void> _failedUpgradeWalk(WidgetTester tester) async {
  final isar = await _upgradedFrom191();
  // Seen everything else, so only the #112 card is on the dashboard.
  await WhatsNewStore.write(
    isar,
    const WhatsNewRecord(lastSeenVersion: '1.10.0'),
  );
  await BarLayoutStore.write(isar, const BarRecord(seenVersion: 2));
  final copy = File(
    '${(await getTemporaryDirectory()).path}/'
    'healthflare_pre_v16_20261102T101200Z.isar',
  )..writeAsStringSync('review');
  await _launch(
    tester,
    isar,
    failure: FailedUpgrade(
      appVersion: '1.10.0+14',
      fromVersion: 16,
      reachedVersion: 17,
      failedStep: 18,
      targetVersion: MigrationRunner.targetVersion,
      attempts: FailedUpgrade.maxAttempts,
      error: 'StateError: Bad state: review, nothing failed',
      snapshotPath: copy.path,
      snapshotTakenAt: DateTime.utc(2026, 11, 2, 10, 12),
    ),
  );
  await _waitFor(tester, find.text("This update didn't finish"));
  await _shot(tester, 23, 'failed_upgrade_card');
  await _tap(tester, find.text('Details'));
  await _waitFor(tester, find.text("Update didn't finish"));
  await _scrollTo(tester, find.text("Update didn't finish"));
  await _shot(tester, 24, 'failed_upgrade_settings');
  copy.deleteSync();
  await isar.close(deleteFromDisk: true);
}

void main() {
  _binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const variants = {
    'light-100': (Brightness.light, 1.0),
    'dark-100': (Brightness.dark, 1.0),
    'light-200': (Brightness.light, 2.0),
    'dark-200': (Brightness.dark, 2.0),
  };
  const only = String.fromEnvironment('REVIEW_VARIANT');

  for (final MapEntry(key: name, value: (brightness, scale))
      in variants.entries) {
    if (only.isNotEmpty && only != name) continue;
    testWidgets('1.10.0 review: $name', (tester) async {
      _variant = name;
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      await _defaultBarWalk(tester);
      await _customBarWalk(tester);
      await _failedUpgradeWalk(tester);
    });
  }
}

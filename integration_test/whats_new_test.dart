// ignore_for_file: avoid_print
//
// What's new, end to end: the real app on a real database, with relaunches.
// Every state in docs/features/whats-new.feature that you can see gets a
// screenshot. Run it with:
//
//   bash scripts/whats_new.sh shots            # iOS simulator, screenshots
//   bash scripts/whats_new.sh e2e              # same, no screenshots needed
//
// Full guide: docs/testing/whats-new.md.
//
// Uses the fixture releases (version 99.x) from whats_new_preview.dart, so
// it never depends on what's in the real releases.json.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/database/app_database.dart';
import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/whats_new/debug/whats_new_preview.dart';
import 'package:health_flare/features/whats_new/screens/whats_new_screen.dart';
import 'package:health_flare/features/whats_new/whats_new_provider.dart';
import 'package:health_flare/features/whats_new/whats_new_rules.dart';
import 'package:health_flare/features/whats_new/widgets/whats_new_card.dart';
import 'package:health_flare/main.dart';

// Strings the user sees. If the UI copy changes, change it here once.
const _cardOne = "What's new in 99.2";
const _cardMulti = "What's new since your last update";
const _seeWhatsNew = "See what's new";
const _switchLabel = 'Show update highlights';

late IntegrationTestWidgetsFlutterBinding _binding;
bool _surfaceConverted = false;

/// Saved as `whats_new_<name>.png` by the driver (SCREENSHOT_DIR).
Future<void> _shot(WidgetTester tester, String name) async {
  if (!_surfaceConverted) {
    await _binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }
  await tester.pump();
  await _binding.takeScreenshot('whats_new_$name');
  print('📸  whats_new_$name');
}

/// Pumps until [finder] matches or [timeout] passes. Real Isar reads take
/// real time, so fixed pumps aren't enough and pumpAndSettle can hang.
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

/// Lets the dashboard settle, then checks [finder] is still absent.
Future<void> _expectStaysAbsent(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsNothing);
}

/// A database like an existing user's: one profile, onboarding and the
/// post-setup prompts done, so the app opens straight on the dashboard.
Future<Isar> _existingUserDb({bool withProfile = true}) async {
  final dir = await getTemporaryDirectory();
  final isar = await Isar.open(
    appSchemas,
    directory: dir.path,
    name: 'whats_new_e2e_${DateTime.now().microsecondsSinceEpoch}',
  );
  await MigrationRunner.run(isar);
  if (withProfile) await _addProfile(isar);
  return isar;
}

Future<void> _addProfile(Isar isar) => isar.writeTxn(() async {
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
    ..lastProfileId = 1;
  await isar.appSettings.put(s);
});

/// One app launch, the same steps as main(): optionally apply the
/// scenario, settle What's new, read startup data, run the app. A new
/// ProviderScope key makes it a fresh launch (new providers, new router).
Future<void> _launch(
  WidgetTester tester,
  Isar isar,
  WhatsNewScenario scenario, {
  bool applyScenario = true,
}) async {
  // Close the previous launch first so its providers stop watching Isar.
  await tester.pumpWidget(const SizedBox.shrink());
  if (applyScenario) await applyPreviewScenario(isar, scenario);
  await WhatsNewStore.settle(
    isar,
    releases: previewReleases,
    installed: scenario.installed!,
  );
  final startup = await IsarService.readStartupData(isar);
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
        ...previewOverrides(scenario),
      ],
      child: const HealthFlareApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

/// Saves are async: wait for [test] to hold on the stored record rather
/// than reading once straight after a tap or swipe.
Future<void> _waitForStored(
  Isar isar,
  bool Function(WhatsNewRecord r) test,
  String what,
) async {
  final end = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(end)) {
    if (test(await WhatsNewStore.read(isar))) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  throw TestFailure(
    'Never saved: $what. Stored: ${await WhatsNewStore.read(isar)}',
  );
}

Future<void> _waitForShownCount(Isar isar, int count) => _waitForStored(
  isar,
  (r) => r.cardShownCount >= count,
  'card shown $count times',
);

Future<void> _close(WidgetTester tester, Isar isar) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 200));
  await isar.close(deleteFromDisk: true);
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Settings').first);
  await _waitFor(tester, find.text('Settings'));
  await tester.scrollUntilVisible(
    find.text(_switchLabel),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  _binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => _surfaceConverted = false);
  tearDown(() {
    _binding.platformDispatcher.clearAllTestValues();
  });

  group("What's new", () {
    testWidgets('A fresh install sees no release card', (tester) async {
      final isar = await _existingUserDb(withProfile: false);
      // First launch, before onboarding: no profiles yet.
      await WhatsNewStore.settle(
        isar,
        releases: previewReleases,
        installed: '99.2.0',
      );
      // Onboarding creates the profile.
      await _addProfile(isar);
      await _launch(tester, isar, WhatsNewScenario.card, applyScenario: false);
      await _waitFor(tester, find.text('Sarah'));
      await _expectStaysAbsent(tester, find.byType(Dismissible));
      expect(find.text(_seeWhatsNew), findsNothing);
      await _shot(tester, '00_fresh_install_no_card');
      await _close(tester, isar);
    });

    testWidgets('An update with highlights shows one quiet card', (
      tester,
    ) async {
      final isar = await _existingUserDb();
      await _launch(tester, isar, WhatsNewScenario.card);
      await _waitFor(tester, find.text(_cardOne));
      expect(find.text(_seeWhatsNew), findsOneWidget);
      expect(find.byTooltip('Dismiss'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      await _shot(tester, '01_card');
      await _close(tester, isar);
    });

    testWidgets('the card in dark mode', (tester) async {
      _binding.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      final isar = await _existingUserDb();
      await _launch(tester, isar, WhatsNewScenario.card);
      await _waitFor(tester, find.text(_cardOne));
      await _shot(tester, '02_card_dark');
      await _close(tester, isar);
    });

    testWidgets('Updating past several versions shows one card', (
      tester,
    ) async {
      final isar = await _existingUserDb();
      await _launch(tester, isar, WhatsNewScenario.multi);
      await _waitFor(tester, find.text(_cardMulti));
      expect(find.byType(WhatsNewCard), findsOneWidget);
      await _shot(tester, '03_card_multi');
      await _close(tester, isar);
    });

    testWidgets('the card at 200% text', (tester) async {
      _binding.platformDispatcher.textScaleFactorTestValue = 2.0;
      final isar = await _existingUserDb();
      await _launch(tester, isar, WhatsNewScenario.card);
      await _waitFor(tester, find.text(_cardOne));
      expect(tester.takeException(), isNull);
      await _shot(tester, '04_card_200_percent_text');
      await _close(tester, isar);
    });

    testWidgets('Dismissing is final for that release, across a relaunch', (
      tester,
    ) async {
      final isar = await _existingUserDb();
      await WhatsNewStore.write(isar, const WhatsNewRecord());
      await _launch(tester, isar, WhatsNewScenario.upgrade);
      await _waitFor(tester, find.text(_cardOne));

      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(_cardOne), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);

      await _launch(tester, isar, WhatsNewScenario.upgrade);
      await _waitFor(tester, find.text('Sarah'));
      await _expectStaysAbsent(tester, find.text(_cardOne));
      await _shot(tester, '05_after_dismiss_and_relaunch');
      await _close(tester, isar);
    });

    testWidgets('Swiping the card away dismisses it', (tester) async {
      final isar = await _existingUserDb();
      await WhatsNewStore.write(isar, const WhatsNewRecord());
      await _launch(tester, isar, WhatsNewScenario.upgrade);
      await _waitFor(tester, find.text(_cardOne));
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.text(_cardOne), findsNothing);
      await _waitForStored(
        isar,
        (r) => r.lastSeenVersion == '99.2.0',
        'dismissed by swipe',
      );
      await _close(tester, isar);
    });

    testWidgets('An ignored card goes away on its own after 5 opens', (
      tester,
    ) async {
      final isar = await _existingUserDb();
      await WhatsNewStore.write(isar, const WhatsNewRecord());
      for (var open = 1; open <= kReleaseCardMaxOpens; open++) {
        await _launch(tester, isar, WhatsNewScenario.upgrade);
        await _waitFor(tester, find.text(_cardOne));
        await _waitForShownCount(isar, open);
        print('   open $open: card shown');
      }
      await _launch(tester, isar, WhatsNewScenario.upgrade);
      await _waitFor(tester, find.text('Sarah'));
      await _expectStaysAbsent(tester, find.text(_cardOne));
      print('   open ${kReleaseCardMaxOpens + 1}: no card');
      await _close(tester, isar);
    });

    testWidgets('The card holds off during an active flare', (tester) async {
      final isar = await _existingUserDb();
      await isar.writeTxn(
        () => isar.flareIsars.put(
          FlareIsar()
            ..profileId = 1
            ..startedAt = DateTime.now().subtract(const Duration(days: 1))
            ..createdAt = DateTime.now(),
        ),
      );
      await _launch(tester, isar, WhatsNewScenario.card);
      await _waitFor(tester, find.text('Sarah'));
      await _expectStaysAbsent(tester, find.text(_cardOne));
      await _shot(tester, '06_flare_no_card');
      await _close(tester, isar);
    });

    testWidgets('A bug-fix-only update shows nothing, and is in history', (
      tester,
    ) async {
      final isar = await _existingUserDb();
      await _launch(tester, isar, WhatsNewScenario.fixonly);
      await _waitFor(tester, find.text('Sarah'));
      await _expectStaysAbsent(tester, find.text(_seeWhatsNew));

      await _openSettings(tester);
      await tester.tap(find.text("What's new").first);
      await _waitFor(tester, find.text('Version 99.3.0'));
      await _shot(tester, '07_history_fix_only_release');
      await _close(tester, isar);
    });

    testWidgets('"See what\'s new" opens history and counts as seen', (
      tester,
    ) async {
      final isar = await _existingUserDb();
      await _launch(tester, isar, WhatsNewScenario.card);
      await _waitFor(tester, find.text(_seeWhatsNew));
      await tester.tap(find.text(_seeWhatsNew));
      await _waitFor(tester, find.byType(WhatsNewScreen));
      await _waitFor(tester, find.text('Version 99.2.0'));
      expect(find.text('Version 99.3.0'), findsNothing); // not installed
      await _shot(tester, '08_history');

      await tester.tap(find.text('All changes').first);
      await tester.pump(const Duration(milliseconds: 500));
      await _shot(tester, '09_history_all_changes');

      await tester.pageBack();
      await tester.pump(const Duration(milliseconds: 500));
      await _expectStaysAbsent(tester, find.text(_cardOne));
      await _waitForStored(
        isar,
        (r) => r.lastSeenVersion == '99.2.0',
        'seen after opening What\'s new',
      );
      await _close(tester, isar);
    });

    testWidgets('Highlights can be turned off, and it sticks', (tester) async {
      final isar = await _existingUserDb();
      await WhatsNewStore.write(isar, const WhatsNewRecord());
      await _launch(tester, isar, WhatsNewScenario.upgrade);
      await _waitFor(tester, find.text(_cardOne));

      await _openSettings(tester);
      await _shot(tester, '10_settings_highlights_on');

      await tester.tap(find.text(_switchLabel));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.textContaining("You won't get a card"), findsOneWidget);
      await _shot(tester, '11_settings_highlights_off');

      await _launch(tester, isar, WhatsNewScenario.upgrade);
      await _waitFor(tester, find.text('Sarah'));
      await _expectStaysAbsent(tester, find.text(_cardOne));
      expect((await WhatsNewStore.read(isar)).highlightsOff, isTrue);
      await _close(tester, isar);
    });
  });
}

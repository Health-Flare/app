// The guide's stored state (#145): schema v22, AppSettings. Real Isar.
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/bar_choice.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/bar_layout_store.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_schemas.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/features/release_guides/debug/guide_preview.dart';
import 'package:health_flare/features/release_guides/guide_rules.dart';
import 'package:health_flare/features/release_guides/release_guide_provider.dart';

void main() {
  setUpAll(() async => Isar.initializeIsarCore(download: true));

  late Directory dir;
  late Isar isar;

  Future<Isar> open() =>
      Isar.open(appSchemas, directory: dir.path, name: 'guide_store');

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('hf_guide_store_');
    isar = await open();
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close();
    dir.deleteSync(recursive: true);
  });

  test(
    'schema v22 adds the guide fields; existing rows read as nothing yet',
    () async {
      await isar.writeTxn(
        () => isar.appSettings.put(AppSettings()..schemaVersion = 21),
      );
      await MigrationRunner.run(isar);
      final s = (await isar.appSettings.get(1))!;
      expect(s.schemaVersion, 22);
      expect(await GuideStore.read(isar), const GuideRecord());
    },
  );

  test('put off and resume step survive a restart', () async {
    await MigrationRunner.run(isar);
    final r = GuideRecord(putOffOn: DateTime(2026, 11, 2), resumeStep: 1);
    await GuideStore.write(isar, r);
    await isar.close();
    isar = await open();
    expect(await GuideStore.read(isar), r);
  });

  test(
    'scripts/track_and_care.sh guide: starts as if updated from 1.9.1',
    () async {
      await MigrationRunner.run(isar);
      await BarLayoutStore.write(
        isar,
        const BarRecord(
          storedBar: ['dashboard', 'track', 'care'],
          seenVersion: 2,
        ),
      );
      await GuideStore.write(isar, const GuideRecord(resumeStep: 3));
      await applyGuidePreview(isar);
      expect(await BarLayoutStore.read(isar), const BarRecord());
      expect(await GuideStore.read(isar), const GuideRecord());
      expect(await isar.profileIsars.count(), 1);
      expect((await isar.appSettings.get(1))!.updateHighlightsOff, isFalse);
      // A launch after it still sees an update, so the card shows.
      expect(
        pendingBarChange(
          await BarLayoutStore.settle(isar, current: 2),
          current: 2,
        ),
        isNotNull,
      );
    },
  );

  group('the notifier', () {
    late ProviderContainer c;
    var now = DateTime(2026, 11, 2, 9);

    ProviderContainer container({BarRecord bar = const BarRecord()}) {
      final c = ProviderContainer(
        overrides: [
          isarProvider.overrideWithValue(isar),
          featureFlagsProvider.overrideWithValue(
            const FeatureFlags(trackAndCare: true),
          ),
          barChoiceProvider.overrideWith(
            () => BarChoiceNotifier()..preload(bar),
          ),
          guideClockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    setUp(() async {
      await MigrationRunner.run(isar);
      now = DateTime(2026, 11, 2, 9);
      // Updated from 1.9.1: nothing recorded about the bar.
      c = container();
    });

    test('Someone on the default bar is shown what changed', () {
      final s = c.read(releaseGuideProvider);
      expect(s.guide?.id, 'track-and-care');
      expect(s.change!.customized, isFalse);
      expect(s.change!.before, defaultBarVersions[1]);
      expect(c.read(guideCardModeProvider), GuideCardMode.notNow);
    });

    test('Not now: hidden this session, and the day is stored', () async {
      await c.read(releaseGuideProvider.notifier).putOff();
      expect(c.read(guideCardModeProvider), GuideCardMode.hidden);
      expect((await GuideStore.read(isar)).putOffOn, DateTime(2026, 11, 2));
    });

    test('Skipping or finishing the guide counts as seen: the bar version '
        'is recorded, nothing else changes', () async {
      await c.read(releaseGuideProvider.notifier).saveStep(1);
      await c.read(releaseGuideProvider.notifier).markSeen();
      expect(c.read(guideCardModeProvider), GuideCardMode.hidden);
      expect(await BarLayoutStore.read(isar), const BarRecord(seenVersion: 2));
      expect((await GuideStore.read(isar)).resumeStep, isNull);
    });

    test('Leaving the app mid-guide resumes it next time, not seen', () async {
      await c.read(releaseGuideProvider.notifier).saveStep(1);
      expect((await GuideStore.read(isar)).resumeStep, 1);
      expect((await BarLayoutStore.read(isar)).seenVersion, isNull);
    });

    test('Turning off highlights turns off guide cards too', () async {
      await isar.writeTxn(() async {
        final s = (await isar.appSettings.get(1))!..updateHighlightsOff = true;
        await isar.appSettings.put(s);
      });
      final c2 = container();
      expect(c2.read(guideCardModeProvider), GuideCardMode.hidden);
    });

    test('a fresh install on the new bar: no guide', () {
      final c2 = container(bar: const BarRecord(seenVersion: 2));
      expect(c2.read(releaseGuideProvider).change, isNull);
      expect(c2.read(guideCardModeProvider), GuideCardMode.hidden);
    });

    test('flag off: no guide', () {
      final c2 = ProviderContainer(
        overrides: [
          isarProvider.overrideWithValue(isar),
          featureFlagsProvider.overrideWithValue(const FeatureFlags()),
        ],
      );
      addTearDown(c2.dispose);
      expect(c2.read(guideCardModeProvider), GuideCardMode.hidden);
    });
  });
}

// What's new state on AppSettings (#139), against real Isar.
// Spec: docs/features/whats-new.feature ("Offline and storage").
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/models/activity_entry_isar.dart';
import 'package:health_flare/data/models/appointment_isar.dart';
import 'package:health_flare/data/models/condition_isar.dart';
import 'package:health_flare/data/models/daily_checkin_isar.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/data/models/elimination_entry_isar.dart';
import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/data/models/fluid_intake_isar.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/medication_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/models/sleep_entry_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/data/models/symptom_isar.dart';
import 'package:health_flare/data/models/user_condition_isar.dart';
import 'package:health_flare/data/models/user_symptom_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';
import 'package:health_flare/features/whats_new/models/release_note.dart';
import 'package:health_flare/features/whats_new/whats_new_provider.dart';
import 'package:health_flare/features/whats_new/whats_new_rules.dart';

const _schemas = [
  ProfileIsarSchema,
  JournalEntryIsarSchema,
  AppSettingsSchema,
  ConditionIsarSchema,
  UserConditionIsarSchema,
  SymptomIsarSchema,
  UserSymptomIsarSchema,
  SleepEntryIsarSchema,
  SymptomEntryIsarSchema,
  VitalEntryIsarSchema,
  MedicationIsarSchema,
  DoseLogIsarSchema,
  MealEntryIsarSchema,
  FlareIsarSchema,
  DailyCheckinIsarSchema,
  AppointmentIsarSchema,
  ActivityEntryIsarSchema,
  FluidIntakeIsarSchema,
  EliminationEntryIsarSchema,
];

const _h = [ReleaseHighlight(title: 'New thing', body: 'It does a thing.')];
final _releases = [
  const ReleaseNote(version: '1.10.0', highlights: _h),
  const ReleaseNote(version: '1.9.1'),
];

Future<Isar> _open() => Isar.open(
  _schemas,
  directory: '',
  name: 'whats_new_${DateTime.now().microsecondsSinceEpoch}',
);

Future<void> _addProfile(Isar isar) => isar.writeTxn(
  () => isar.profileIsars.put(
    ProfileIsar()
      ..id = 1
      ..name = 'Sarah',
  ),
);

void main() {
  late Isar isar;

  setUpAll(() async => Isar.initializeIsarCore(download: true));
  setUp(() async => isar = await _open());
  tearDown(() async => isar.close(deleteFromDisk: true));

  test('an existing v19 database opens with highlights on and nothing '
      'recorded yet', () async {
    await isar.writeTxn(
      () => isar.appSettings.put(AppSettings()..schemaVersion = 19),
    );
    await MigrationRunner.run(isar);

    final s = (await isar.appSettings.get(1))!;
    expect(s.schemaVersion, 20);
    expect(await WhatsNewStore.read(isar), const WhatsNewRecord());
  });

  test('round trip', () async {
    const r = WhatsNewRecord(
      lastSeenVersion: '1.9.1',
      highlightsOff: true,
      cardVersion: '1.10.0',
      cardShownCount: 3,
    );
    await WhatsNewStore.write(isar, r);
    expect(await WhatsNewStore.read(isar), r);
  });

  test('writing keeps the rest of AppSettings', () async {
    await isar.writeTxn(
      () => isar.appSettings.put(
        AppSettings()
          ..activeProfileId = 4
          ..schemaVersion = 20
          ..lastProfileId = 9,
      ),
    );
    await WhatsNewStore.write(
      isar,
      const WhatsNewRecord(lastSeenVersion: '1.10.0'),
    );
    final s = (await isar.appSettings.get(1))!;
    expect(s.activeProfileId, 4);
    expect(s.schemaVersion, 20);
    expect(s.lastProfileId, 9);
  });

  test('A fresh install sees no release card: settle runs before any '
      'profile exists', () async {
    final r = await WhatsNewStore.settle(
      isar,
      releases: _releases,
      installed: '1.10.0',
    );
    expect(r.lastSeenVersion, '1.10.0');
    expect(await WhatsNewStore.read(isar), r);
  });

  test('an existing user updating to the first What\'s new release gets '
      'its card', () async {
    await _addProfile(isar);
    final r = await WhatsNewStore.settle(
      isar,
      releases: _releases,
      installed: '1.10.0',
    );
    expect(r.lastSeenVersion, '1.9.1');
    expect(r.cardVersion, '1.10.0');
  });

  group('WhatsNewNotifier', () {
    late ProviderContainer c;

    setUp(() async {
      await _addProfile(isar);
      await WhatsNewStore.write(
        isar,
        const WhatsNewRecord(lastSeenVersion: '1.9.1', cardVersion: '1.10.0'),
      );
      c = ProviderContainer(
        overrides: [
          isarProvider.overrideWithValue(isar),
          releaseNotesProvider.overrideWith((ref) async => _releases),
          installedVersionProvider.overrideWith((ref) async => '1.10.0'),
        ],
      );
    });
    tearDown(() => c.dispose());

    test('shows the pending card and the history', () async {
      final s = await c.read(whatsNewProvider.future);
      expect([for (final r in s.card) r.version], ['1.10.0']);
      expect([for (final r in s.history) r.version], ['1.10.0', '1.9.1']);
    });

    test(
      'Dismissing is final for that release, and survives a restart',
      () async {
        await c.read(whatsNewProvider.future);
        await c.read(whatsNewProvider.notifier).dismiss();
        expect(c.read(whatsNewProvider).value!.card, isEmpty);

        final again = ProviderContainer(
          overrides: [
            isarProvider.overrideWithValue(isar),
            releaseNotesProvider.overrideWith((ref) async => _releases),
            installedVersionProvider.overrideWith((ref) async => '1.10.0'),
          ],
        );
        addTearDown(again.dispose);
        expect((await again.read(whatsNewProvider.future)).card, isEmpty);
      },
    );

    test('counts a shown card once per launch', () async {
      await c.read(whatsNewProvider.future);
      final n = c.read(whatsNewProvider.notifier);
      await n.noteCardShown();
      await n.noteCardShown();
      expect((await WhatsNewStore.read(isar)).cardShownCount, 1);
    });

    test('Highlights can be turned off, and history still works', () async {
      await c.read(whatsNewProvider.future);
      await c.read(whatsNewProvider.notifier).setHighlightsOn(false);
      final s = c.read(whatsNewProvider).value!;
      expect(s.highlightsOn, isFalse);
      expect(s.card, isEmpty);
      expect(s.history, hasLength(2));
      expect((await WhatsNewStore.read(isar)).highlightsOff, isTrue);
    });

    test(
      "Turning highlights back on doesn't bring back missed cards",
      () async {
        await c.read(whatsNewProvider.future);
        final n = c.read(whatsNewProvider.notifier);
        await n.setHighlightsOn(false);
        await n.setHighlightsOn(true);
        expect(c.read(whatsNewProvider).value!.card, isEmpty);
        expect(c.read(whatsNewProvider).value!.highlightsOn, isTrue);
      },
    );
  });

  test('Release content is bundled: the asset is listed in pubspec and '
      'parses', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final notes = await loadBundledReleaseNotes();
    expect(notes, isNotEmpty);
    for (final n in notes) {
      expect(n.highlights.length, lessThanOrEqualTo(4), reason: n.version);
    }
  });
}

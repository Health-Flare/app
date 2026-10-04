import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/database/profile_ids.dart';
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

// Issue #117: Isar works out the next auto-increment id from the highest id
// still stored when the database opens. Deleting the newest profile and
// restarting the app handed its id to the next new profile, along with any
// rows still linked to that id.

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

Future<int> _idOf(Isar isar, String name) async =>
    (await isar.profileIsars.filter().nameEqualTo(name).findFirst())!.id;

Future<Isar> _open(String name) =>
    Isar.open(_schemas, directory: '', name: name);

/// Simulates a profile deleted by v1.9.1 and earlier: the profile row goes,
/// a tracked symptom linked to it stays behind.
Future<void> _oldStyleDelete(Isar isar, int profileId) async {
  await isar.writeTxn(() async {
    await isar.userSymptomIsars.put(
      UserSymptomIsar()
        ..profileId = profileId
        ..symptomId = 1
        ..symptomName = 'Nausea'
        ..trackedSince = DateTime(2026, 9, 1),
    );
    await isar.profileIsars.delete(profileId);
  });
}

ProviderContainer _container(Isar isar) {
  final c = ProviderContainer(
    overrides: [isarProvider.overrideWithValue(isar)],
  );
  c.listen(profileListProvider, (_, _) {});
  return c;
}

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore();
  });

  tearDown(() async {
    for (final isar
        in Isar.instanceNames.map(Isar.getInstance).whereType<Isar>()) {
      if (isar.isOpen) await isar.close(deleteFromDisk: true);
    }
  });

  group('ProfileListNotifier.add after a restart', () {
    test('does not reuse the id of the newest deleted profile', () async {
      final name = 'id_reuse_add_${DateTime.now().microsecondsSinceEpoch}';
      var isar = await _open(name);
      await MigrationRunner.run(isar);
      var c = _container(isar);
      final notifier = c.read(profileListProvider.notifier);
      for (final n in ['A', 'B', 'C', 'D']) {
        await notifier.add(name: n);
      }
      final dId = await _idOf(isar, 'D');
      c.dispose();
      await _oldStyleDelete(isar, dId);
      await isar.close();

      isar = await _open(name); // app restart
      c = _container(isar);
      addTearDown(c.dispose);
      await c.read(profileListProvider.notifier).add(name: 'E');
      final eId = await _idOf(isar, 'E');

      expect(eId, isNot(dId), reason: 'E must not get the deleted id');
      expect(
        await isar.userSymptomIsars.filter().profileIdEqualTo(eId).count(),
        0,
        reason: 'a new profile starts with no data',
      );
    });

    test('ids keep counting up across several deletes and restarts', () async {
      final name = 'id_reuse_many_${DateTime.now().microsecondsSinceEpoch}';
      final seen = <int>{};
      for (var round = 0; round < 3; round++) {
        final isar = await _open(name);
        await MigrationRunner.run(isar);
        final c = _container(isar);
        await c.read(profileListProvider.notifier).add(name: 'P$round');
        final id = await _idOf(isar, 'P$round');
        expect(seen, isNot(contains(id)));
        seen.add(id);
        c.dispose();
        await isar.writeTxn(() => isar.profileIsars.delete(id));
        await isar.close();
      }
    });
  });

  group('nextProfileId', () {
    test('never returns the id of a stored profile, even if the counter '
        'is behind', () async {
      final isar = await _open(
        'id_reuse_behind_${DateTime.now().microsecondsSinceEpoch}',
      );
      await isar.writeTxn(() async {
        await isar.appSettings.put(AppSettings()..lastProfileId = 0);
        await isar.profileIsars.put(ProfileIsar()..name = 'A');
        await isar.profileIsars.put(ProfileIsar()..name = 'B');
      });
      final storedIds = await isar.profileIsars.where().idProperty().findAll();

      final next = await isar.writeTxn(() => nextProfileId(isar));

      expect(storedIds, isNot(contains(next)));
      expect(next, greaterThan(storedIds.reduce((a, b) => a > b ? a : b)));
    });
  });

  group('MigrationRunner v18 -> v19', () {
    test('seeds the id high-water mark from the highest id in use, '
        'including ids only referenced by entries', () async {
      final isar = await _open(
        'id_reuse_mig_${DateTime.now().microsecondsSinceEpoch}',
      );
      await MigrationRunner.run(isar);
      await isar.writeTxn(() async {
        await isar.profileIsars.put(
          ProfileIsar()
            ..id = 2
            ..name = 'B',
        );
        await isar.journalEntryIsars.put(
          JournalEntryIsar()
            ..profileId = 7
            ..createdAt = DateTime(2026)
            ..snapshots = [],
        );
        final s = (await isar.appSettings.get(1))!
          ..schemaVersion = 18
          ..lastProfileId = 0;
        await isar.appSettings.put(s);
      });

      await MigrationRunner.run(isar);

      final s = (await isar.appSettings.get(1))!;
      expect(s.schemaVersion, 19);
      expect(s.lastProfileId, greaterThanOrEqualTo(7));
      await isar.writeTxn(() async {
        expect(await nextProfileId(isar), greaterThan(7));
      });
    });
  });
}

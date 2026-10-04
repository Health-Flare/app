import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/profile_deletion.dart';
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

// Regression tests: deleting a profile must remove every row that belongs
// to it, not just journal entries. The confirm dialog promises "All health
// data recorded for X will be permanently removed from this device".

const _keep = 1;
const _gone = 2;

Future<Isar> _openIsar() => Isar.open(
  [
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
  ],
  directory: '',
  name: 'profile_delete_test_${DateTime.now().microsecondsSinceEpoch}',
);

/// One row in every profile-scoped collection for [profileId].
Future<void> _seed(Isar isar, int profileId) async {
  final t = DateTime(2026, 9, 1, 9);
  await isar.writeTxn(() async {
    await isar.profileIsars.put(
      ProfileIsar()
        ..id = profileId
        ..name = 'P$profileId',
    );
    await isar.journalEntryIsars.put(
      JournalEntryIsar()
        ..profileId = profileId
        ..createdAt = t
        ..snapshots = [
          JournalSnapshotIsar()
            ..body = 'note'
            ..savedAt = t,
        ],
    );
    await isar.userConditionIsars.put(
      UserConditionIsar()
        ..profileId = profileId
        ..conditionId = 1
        ..conditionName = 'Asthma'
        ..trackedSince = t,
    );
    await isar.userSymptomIsars.put(
      UserSymptomIsar()
        ..profileId = profileId
        ..symptomId = 1
        ..symptomName = 'Fatigue'
        ..trackedSince = t,
    );
    await isar.sleepEntryIsars.put(
      SleepEntryIsar()
        ..profileId = profileId
        ..bedtime = t
        ..wakeTime = t.add(const Duration(hours: 8))
        ..isNap = false
        ..createdAt = t,
    );
    await isar.symptomEntryIsars.put(
      SymptomEntryIsar()
        ..profileId = profileId
        ..name = 'Fatigue'
        ..severity = 6
        ..loggedAt = t
        ..createdAt = t,
    );
    await isar.vitalEntryIsars.put(
      VitalEntryIsar()
        ..profileId = profileId
        ..vitalType = 'heartRate'
        ..value = 72
        ..unit = 'bpm'
        ..loggedAt = t
        ..createdAt = t,
    );
    final medId = await isar.medicationIsars.put(
      MedicationIsar()
        ..profileId = profileId
        ..name = 'Methotrexate'
        ..medicationType = 'medication'
        ..doseAmount = 10
        ..doseUnit = 'mg'
        ..frequency = 'weekly'
        ..startDate = t
        ..createdAt = t,
    );
    await isar.doseLogIsars.put(
      DoseLogIsar()
        ..profileId = profileId
        ..medicationIsarId = medId
        ..loggedAt = t
        ..createdAt = t
        ..amount = 10
        ..unit = 'mg'
        ..status = 'taken',
    );
    await isar.mealEntryIsars.put(
      MealEntryIsar()
        ..profileId = profileId
        ..description = 'Toast'
        ..hasReaction = false
        ..loggedAt = t
        ..createdAt = t,
    );
    await isar.flareIsars.put(
      FlareIsar()
        ..profileId = profileId
        ..startedAt = t
        ..createdAt = t,
    );
    await isar.dailyCheckinIsars.put(
      DailyCheckinIsar()
        ..profileId = profileId
        ..checkinDate = t
        ..createdAt = t,
    );
    await isar.appointmentIsars.put(
      AppointmentIsar()
        ..profileId = profileId
        ..title = 'Rheumatology'
        ..scheduledAt = t
        ..status = 'upcoming'
        ..createdAt = t,
    );
    await isar.activityEntryIsars.put(
      ActivityEntryIsar()
        ..profileId = profileId
        ..description = 'Walk'
        ..loggedAt = t
        ..createdAt = t,
    );
    await isar.fluidIntakeIsars.put(
      FluidIntakeIsar()
        ..profileId = profileId
        ..loggedAt = t
        ..volumeMl = 250
        ..createdAt = t,
    );
    await isar.eliminationEntryIsars.put(
      EliminationEntryIsar()
        ..profileId = profileId
        ..loggedAt = t
        ..kind = 'bowel'
        ..createdAt = t,
    );
  });
}

/// Row counts per profile-scoped collection for [profileId].
Future<Map<String, int>> _counts(Isar isar, int profileId) async => {
  'journal': await isar.journalEntryIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'userConditions': await isar.userConditionIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'userSymptoms': await isar.userSymptomIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'sleep': await isar.sleepEntryIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'symptoms': await isar.symptomEntryIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'vitals': await isar.vitalEntryIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'medications': await isar.medicationIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'doses': await isar.doseLogIsars.filter().profileIdEqualTo(profileId).count(),
  'meals': await isar.mealEntryIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'flares': await isar.flareIsars.filter().profileIdEqualTo(profileId).count(),
  'checkins': await isar.dailyCheckinIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'appointments': await isar.appointmentIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'activity': await isar.activityEntryIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'fluids': await isar.fluidIntakeIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
  'elimination': await isar.eliminationEntryIsars
      .filter()
      .profileIdEqualTo(profileId)
      .count(),
};

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  late Isar isar;
  late ProviderContainer container;

  setUp(() async {
    isar = await _openIsar();
    container = ProviderContainer(
      overrides: [isarProvider.overrideWithValue(isar)],
    );
    await _seed(isar, _keep);
    await _seed(isar, _gone);
  });

  tearDown(() async {
    container.dispose();
    await isar.close(deleteFromDisk: true);
  });

  test('seed covers every profile-scoped collection', () async {
    // Guards the test itself: if a collection gains a profileId and is not
    // seeded here, this list (and the deletion) must be updated.
    final counts = await _counts(isar, _gone);
    expect(counts.length, profileScopedCollectionCount);
    expect(counts.values, everyElement(1));
  });

  test('removing a profile deletes its rows in every collection', () async {
    await container.read(profileListProvider.notifier).remove(_gone);

    expect(await isar.profileIsars.get(_gone), isNull);
    final counts = await _counts(isar, _gone);
    expect(
      counts.entries.where((e) => e.value != 0).map((e) => e.key),
      isEmpty,
      reason: 'rows left behind for the deleted profile',
    );
  });

  test('removing a profile leaves other profiles untouched', () async {
    await container.read(profileListProvider.notifier).remove(_gone);

    expect(await isar.profileIsars.get(_keep), isNotNull);
    final counts = await _counts(isar, _keep);
    expect(counts.values, everyElement(1));
  });

  test('shared catalogue rows are not deleted', () async {
    await isar.writeTxn(() async {
      await isar.conditionIsars.put(
        ConditionIsar()
          ..name = 'My custom condition'
          ..global = false,
      );
      await isar.symptomIsars.put(
        SymptomIsar()
          ..name = 'My custom symptom'
          ..global = false,
      );
    });

    await container.read(profileListProvider.notifier).remove(_gone);

    expect(await isar.conditionIsars.count(), 1);
    expect(await isar.symptomIsars.count(), 1);
  });

  test('deleteProfileData is all or nothing', () async {
    // If anything throws inside the transaction, no rows are deleted.
    await expectLater(
      isar.writeTxn(() async {
        await deleteProfileData(isar, _gone);
        throw StateError('simulated failure');
      }),
      throwsStateError,
    );

    final counts = await _counts(isar, _gone);
    expect(counts.values, everyElement(1));
    expect(await isar.profileIsars.get(_gone), isNotNull);
  });

  group('orphan cleanup (v17 to v18 migration)', () {
    test('deletes rows whose profile no longer exists', () async {
      // Simulate a delete made by an older version: only the profile row
      // (and journal) went, every other row stayed.
      await isar.writeTxn(() async {
        await isar.journalEntryIsars
            .filter()
            .profileIdEqualTo(_gone)
            .deleteAll();
        await isar.profileIsars.delete(_gone);
      });

      late int cleared;
      await isar.writeTxn(() async {
        cleared = await deleteOrphanedProfileData(isar);
      });

      expect(cleared, 1);
      expect((await _counts(isar, _gone)).values, everyElement(0));
      expect((await _counts(isar, _keep)).values, everyElement(1));
    });

    test('does nothing when no profiles exist', () async {
      await isar.writeTxn(() async {
        await isar.profileIsars.where().deleteAll();
      });

      late int cleared;
      await isar.writeTxn(() async {
        cleared = await deleteOrphanedProfileData(isar);
      });

      expect(cleared, 0);
      expect((await _counts(isar, _gone)).values, everyElement(1));
      expect((await _counts(isar, _keep)).values, everyElement(1));
    });
  });
}

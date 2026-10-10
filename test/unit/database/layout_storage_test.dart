// Layout storage (#137): the bar and its default-layout version on
// AppSettings (per device), features turned off on each profile. Against
// real Isar. Spec: docs/features/navigation-customization.feature.
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/bar_layout_store.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
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
import 'package:health_flare/models/profile.dart';

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

String _uid() => '${DateTime.now().microsecondsSinceEpoch}';

Future<Isar> _open({String directory = '', String? name}) =>
    Isar.open(_schemas, directory: directory, name: name ?? 'layout_${_uid()}');

void main() {
  setUpAll(() async => Isar.initializeIsarCore(download: true));

  group('the bar on AppSettings', () {
    test(
      'nothing stored reads as the default bar, no version recorded',
      () async {
        final isar = await _open();
        addTearDown(() => isar.close(deleteFromDisk: true));
        await isar.writeTxn(() => isar.appSettings.put(AppSettings()..id = 1));

        expect(await BarLayoutStore.read(isar), const BarRecord());
      },
    );

    test(
      'a chosen bar and its version survive closing and reopening',
      () async {
        final dir = Directory.systemTemp.createTempSync('hf_layout_');
        addTearDown(() => dir.deleteSync(recursive: true));
        final name = 'reopen_${_uid()}';
        var isar = await _open(directory: dir.path, name: name);
        const record = BarRecord(
          storedBar: ['dashboard', 'track.sleep', 'care'],
          seenVersion: 2,
        );
        await BarLayoutStore.write(isar, record);
        await isar.close();

        isar = await _open(directory: dir.path, name: name);
        addTearDown(() => isar.close());
        expect(await BarLayoutStore.read(isar), record);
      },
    );

    test('writing leaves the other settings alone', () async {
      final isar = await _open();
      addTearDown(() => isar.close(deleteFromDisk: true));
      await isar.writeTxn(
        () => isar.appSettings.put(
          AppSettings()
            ..id = 1
            ..appLockEnabled = true
            ..lastSeenWhatsNewVersion = '1.9.1',
        ),
      );

      await BarLayoutStore.write(isar, const BarRecord(seenVersion: 1));

      final s = (await isar.appSettings.get(1))!;
      expect(s.appLockEnabled, isTrue);
      expect(s.lastSeenWhatsNewVersion, '1.9.1');
    });

    test('settle on a fresh install records the current default', () async {
      final isar = await _open();
      addTearDown(() => isar.close(deleteFromDisk: true));

      final r = await BarLayoutStore.settle(isar, current: 2);

      expect(r.seenVersion, 2);
      expect((await BarLayoutStore.read(isar)).seenVersion, 2);
    });

    test('settle after an update from 1.9.1 leaves it unrecorded, so the '
        'change is shown', () async {
      final isar = await _open();
      addTearDown(() => isar.close(deleteFromDisk: true));
      await isar.writeTxn(
        () => isar.profileIsars.put(ProfileIsar()..name = 'Sarah'),
      );

      final r = await BarLayoutStore.settle(isar, current: 2);

      expect(r.seenVersion, isNull);
      expect(pendingBarChange(r, current: 2), isNotNull);
    });
  });

  group('Features in use is per profile (stored)', () {
    test('turning off Meals for Dad is stored on Dad only', () async {
      final isar = await _open();
      addTearDown(() => isar.close(deleteFromDisk: true));
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);
      final ids = await isar.writeTxn(
        () => isar.profileIsars.putAll([
          ProfileIsar()..name = 'Sarah',
          ProfileIsar()..name = 'Dad',
        ]),
      );

      await container
          .read(profileListProvider.notifier)
          .update(
            Profile(
              id: ids[1],
              name: 'Dad',
              disabledFeatureIds: ['track.meals'],
            ),
          );

      expect(
        (await isar.profileIsars.get(ids[0]))!.disabledFeatureIds,
        isEmpty,
      );
      final dad = (await isar.profileIsars.get(ids[1]))!;
      expect(dad.disabledFeatureIds, ['track.meals']);
      expect(dad.toDomain().disabledFeatureIds, ['track.meals']);
    });

    test('turning it back on clears it', () async {
      final isar = await _open();
      addTearDown(() => isar.close(deleteFromDisk: true));
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);
      final id = await isar.writeTxn(
        () => isar.profileIsars.put(
          ProfileIsar()
            ..name = 'Dad'
            ..disabledFeatureIds = ['track.meals'],
        ),
      );

      await container
          .read(profileListProvider.notifier)
          .update(Profile(id: id, name: 'Dad'));

      expect((await isar.profileIsars.get(id))!.disabledFeatureIds, isEmpty);
    });

    test('fromDomain carries the switches', () {
      final row = ProfileIsar.fromDomain(
        Profile(id: 3, name: 'Dad', disabledFeatureIds: ['care.flares']),
      );
      expect(row.disabledFeatureIds, ['care.flares']);
    });
  });

  group('MigrationRunner v21', () {
    test('a v20 database opens on the default bar, every feature on', () async {
      final isar = await _open();
      addTearDown(() => isar.close(deleteFromDisk: true));
      await isar.writeTxn(() async {
        await isar.appSettings.put(
          AppSettings()
            ..id = 1
            ..schemaVersion = 20
            ..lastSeenWhatsNewVersion = '1.9.1',
        );
        await isar.profileIsars.put(ProfileIsar()..name = 'Sarah');
      });

      await MigrationRunner.run(isar);

      final s = (await isar.appSettings.get(1))!;
      expect(s.schemaVersion, 21);
      expect(s.bottomBarIds, isNull);
      expect(s.bottomBarLayoutVersion, isNull);
      expect(s.lastSeenWhatsNewVersion, '1.9.1');
      final p = (await isar.profileIsars.where().findAll()).single;
      expect(p.name, 'Sarah');
      expect(p.disabledFeatureIds, isEmpty);
    });
  });
}

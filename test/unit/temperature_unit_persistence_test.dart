// Issue #83: per-profile temperature unit, stored on the profile.
// Specs: docs/features/profiles.feature ("Temperature unit"),
// reports.feature, symptoms_and_vitals.feature.
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/database/migration_runner.dart';
import 'package:health_flare/data/models/daily_checkin_isar.dart';
import 'package:health_flare/data/models/activity_entry_isar.dart';
import 'package:health_flare/data/models/appointment_isar.dart';
import 'package:health_flare/data/models/condition_isar.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/data/models/elimination_entry_isar.dart';
import 'package:health_flare/data/models/fluid_intake_isar.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/medication_isar.dart';
import 'package:health_flare/data/models/symptom_isar.dart';
import 'package:health_flare/data/models/user_condition_isar.dart';
import 'package:health_flare/data/models/user_symptom_isar.dart';
import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/data/models/sleep_entry_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';
import 'package:health_flare/features/reports/models/report_data.dart';
import 'package:health_flare/features/reports/services/csv_report_service.dart';
import 'package:health_flare/features/reports/services/insights_query_service.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/vital_entry.dart';
import 'package:health_flare/models/vital_type.dart';

String _uid() => '${DateTime.now().microsecondsSinceEpoch}';

Future<Isar> _openIsar({String directory = '', String? name}) => Isar.open(
  [
    ProfileIsarSchema,
    AppSettingsSchema,
    SymptomEntryIsarSchema,
    MealEntryIsarSchema,
    DailyCheckinIsarSchema,
    SleepEntryIsarSchema,
    FlareIsarSchema,
    VitalEntryIsarSchema,
    // The rest of the app's schemas: MigrationRunner works on the whole
    // database (v18 clears orphaned rows in every profile-scoped collection).
    JournalEntryIsarSchema,
    ConditionIsarSchema,
    UserConditionIsarSchema,
    SymptomIsarSchema,
    UserSymptomIsarSchema,
    MedicationIsarSchema,
    DoseLogIsarSchema,
    AppointmentIsarSchema,
    ActivityEntryIsarSchema,
    FluidIntakeIsarSchema,
    EliminationEntryIsarSchema,
  ],
  directory: directory,
  name: name ?? 'temp_unit_${_uid()}',
);

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  group('ProfileIsar temperatureUnit', () {
    test('a new profile has no temperature unit ("As logged")', () async {
      final isar = await _openIsar();
      addTearDown(() => isar.close(deleteFromDisk: true));
      final id = await isar.writeTxn(
        () => isar.profileIsars.put(ProfileIsar()..name = 'Sarah'),
      );

      final row = await isar.profileIsars.get(id);
      expect(row!.temperatureUnit, isNull);
      expect(row.toDomain().temperatureUnit, isNull);
    });

    test('the unit is saved and read back', () async {
      final isar = await _openIsar();
      addTearDown(() => isar.close(deleteFromDisk: true));
      final id = await isar.writeTxn(
        () => isar.profileIsars.put(
          ProfileIsar()
            ..name = 'Sarah'
            ..temperatureUnit = '°F',
        ),
      );

      final row = await isar.profileIsars.get(id);
      expect(row!.temperatureUnit, '°F');
      expect(row.toDomain().temperatureUnit, '°F');
    });

    test('ProfileListNotifier.update persists the unit', () async {
      final isar = await _openIsar();
      addTearDown(() => isar.close(deleteFromDisk: true));
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);
      final id = await isar.writeTxn(
        () => isar.profileIsars.put(ProfileIsar()..name = 'Sarah'),
      );

      await container
          .read(profileListProvider.notifier)
          .update(Profile(id: id, name: 'Sarah', temperatureUnit: '°C'));

      expect((await isar.profileIsars.get(id))!.temperatureUnit, '°C');
    });

    test('a reload finishing after dispose does not throw', () async {
      // ProfileListNotifier.build() kicks off an async _reload. Disposing the
      // container before it completes used to set state on a disposed ref
      // ("Cannot use the Ref ... after it has been disposed").
      final isar = await _openIsar();
      addTearDown(() => isar.close(deleteFromDisk: true));
      await isar.writeTxn(
        () => isar.profileIsars.put(ProfileIsar()..name = 'Sarah'),
      );
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );

      container.read(profileListProvider);
      container.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    test('update back to "As logged" clears the unit', () async {
      final isar = await _openIsar();
      addTearDown(() => isar.close(deleteFromDisk: true));
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);
      final id = await isar.writeTxn(
        () => isar.profileIsars.put(
          ProfileIsar()
            ..name = 'Sarah'
            ..temperatureUnit = '°F',
        ),
      );

      await container
          .read(profileListProvider.notifier)
          .update(Profile(id: id, name: 'Sarah'));

      expect((await isar.profileIsars.get(id))!.temperatureUnit, isNull);
    });

    test('each profile keeps its own unit', () async {
      final isar = await _openIsar();
      addTearDown(() => isar.close(deleteFromDisk: true));
      final ids = await isar.writeTxn(
        () => isar.profileIsars.putAll([
          ProfileIsar()
            ..name = 'Sarah'
            ..temperatureUnit = '°C',
          ProfileIsar()
            ..name = 'Dad'
            ..temperatureUnit = '°F',
        ]),
      );

      expect((await isar.profileIsars.get(ids[0]))!.temperatureUnit, '°C');
      expect((await isar.profileIsars.get(ids[1]))!.temperatureUnit, '°F');
    });

    test('the unit survives closing and reopening the database', () async {
      final dir = Directory.systemTemp.createTempSync('hf_temp_unit_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final name = 'reopen_${_uid()}';
      var isar = await _openIsar(directory: dir.path, name: name);
      final id = await isar.writeTxn(
        () => isar.profileIsars.put(
          ProfileIsar()
            ..name = 'Sarah'
            ..temperatureUnit = '°F',
        ),
      );
      await isar.close();

      isar = await _openIsar(directory: dir.path, name: name);
      addTearDown(() => isar.close());
      expect((await isar.profileIsars.get(id))!.temperatureUnit, '°F');
    });
  });

  group('MigrationRunner', () {
    test('schema version moves past v17 for the temperature unit', () async {
      final isar = await _openIsar();
      addTearDown(() => isar.close(deleteFromDisk: true));
      await isar.writeTxn(
        () => isar.appSettings.put(
          AppSettings()
            ..id = 1
            ..schemaVersion = 16,
        ),
      );

      await MigrationRunner.run(isar);

      expect((await isar.appSettings.get(1))!.schemaVersion, 20);
    });

    test('v16 → v17 keeps existing profiles at "As logged"', () async {
      final isar = await _openIsar();
      addTearDown(() => isar.close(deleteFromDisk: true));
      await isar.writeTxn(() async {
        await isar.appSettings.put(
          AppSettings()
            ..id = 1
            ..schemaVersion = 16,
        );
        await isar.profileIsars.put(ProfileIsar()..name = 'Sarah');
      });

      await MigrationRunner.run(isar);

      final p = (await isar.profileIsars.where().findAll()).single;
      expect(p.name, 'Sarah');
      expect(p.temperatureUnit, isNull);
    });
  });

  group('InsightsQueryService with a temperature unit', () {
    Future<void> addTemp(Isar isar, double v, String unit, DateTime at) =>
        isar.writeTxn(
          () => isar.vitalEntryIsars.put(
            VitalEntryIsar()
              ..profileId = 1
              ..vitalType = VitalType.temperature.name
              ..value = v
              ..unit = unit
              ..loggedAt = at
              ..createdAt = at,
          ),
        );

    test('the profile unit wins over the most recent reading', () async {
      final isar = await _openIsar();
      addTearDown(() => isar.close(deleteFromDisk: true));
      await addTemp(isar, 37.0, '°C', DateTime(2026, 9, 10));
      await addTemp(isar, 100.4, '°F', DateTime(2026, 9, 11));

      final data = await InsightsQueryService.query(
        isar: isar,
        profileId: 1,
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 9, 30),
        temperatureUnit: '°C',
      );

      final t = data.vitalTrends.singleWhere(
        (t) => t.type == VitalType.temperature,
      );
      expect(t.unit, '°C');
      expect(t.points.first.value, closeTo(37.0, 0.01));
      expect(t.points.last.value, closeTo(38.0, 0.01));
    });

    test('the unit does not rewrite saved readings', () async {
      final isar = await _openIsar();
      addTearDown(() => isar.close(deleteFromDisk: true));
      await addTemp(isar, 100.4, '°F', DateTime(2026, 9, 11));

      await InsightsQueryService.query(
        isar: isar,
        profileId: 1,
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 9, 30),
        temperatureUnit: '°C',
      );

      final row = (await isar.vitalEntryIsars.where().findAll()).single;
      expect(row.value, 100.4);
      expect(row.unit, '°F');
    });
  });

  group('CSV export', () {
    test('keeps temperature readings as logged', () {
      final csv = CsvReportService.generate(
        ReportData(
          profileName: 'Sarah',
          start: DateTime(2026, 9, 1),
          end: DateTime(2026, 9, 30),
          symptoms: const [],
          vitals: [
            VitalEntry(
              id: 1,
              profileId: 1,
              vitalType: VitalType.temperature,
              value: 100.4,
              unit: '°F',
              loggedAt: DateTime(2026, 9, 11),
              createdAt: DateTime(2026, 9, 11),
            ),
          ],
          doseLogs: const [],
          medications: const [],
          meals: const [],
          journal: const [],
          sleep: const [],
          checkins: const [],
          appointments: const [],
          activities: const [],
        ),
      );

      expect(csv, contains('100.4 °F'));
      expect(csv, isNot(contains('38.0 °C')));
    });
  });
}

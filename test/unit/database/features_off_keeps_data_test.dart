// Data safety for Features in use (#142): turning every feature off
// deletes nothing, changes nothing, and reports still include it.
// Spec: navigation-customization.feature, "Turning a feature off keeps its
// data"; rule 5 ("never deletes, hides from reports, or changes logged
// data").
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/database/app_schemas.dart';
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
import 'package:health_flare/features/reports/models/report_config.dart';
import 'package:health_flare/features/reports/services/report_query_service.dart';

final _day = DateTime(2026, 10, 1, 8);

/// Row count of every health-data collection.
Future<Map<String, int>> _counts(Isar isar) async => {
  'activityEntryIsars': await isar.activityEntryIsars.count(),
  'appointmentIsars': await isar.appointmentIsars.count(),
  'conditionIsars': await isar.conditionIsars.count(),
  'dailyCheckinIsars': await isar.dailyCheckinIsars.count(),
  'doseLogIsars': await isar.doseLogIsars.count(),
  'eliminationEntryIsars': await isar.eliminationEntryIsars.count(),
  'flareIsars': await isar.flareIsars.count(),
  'fluidIntakeIsars': await isar.fluidIntakeIsars.count(),
  'journalEntryIsars': await isar.journalEntryIsars.count(),
  'mealEntryIsars': await isar.mealEntryIsars.count(),
  'medicationIsars': await isar.medicationIsars.count(),
  'profileIsars': await isar.profileIsars.count(),
  'sleepEntryIsars': await isar.sleepEntryIsars.count(),
  'symptomEntryIsars': await isar.symptomEntryIsars.count(),
  'symptomIsars': await isar.symptomIsars.count(),
  'userConditionIsars': await isar.userConditionIsars.count(),
  'userSymptomIsars': await isar.userSymptomIsars.count(),
  'vitalEntryIsars': await isar.vitalEntryIsars.count(),
};

void main() {
  setUpAll(() async => Isar.initializeIsarCore(download: true));

  test('turning every feature off deletes and changes nothing, and reports '
      'still include it', () async {
    final isar = await Isar.open(
      appSchemas,
      directory: '',
      name: 'features_off_${DateTime.now().microsecondsSinceEpoch}',
    );
    addTearDown(() => isar.close(deleteFromDisk: true));
    await MigrationRunner.run(isar);
    await isar.writeTxn(() async {
      await isar.profileIsars.put(
        ProfileIsar()
          ..id = 1
          ..name = 'Sarah',
      );
      await isar.mealEntryIsars.put(
        MealEntryIsar()
          ..profileId = 1
          ..description = 'Toast and eggs'
          ..hasReaction = false
          ..loggedAt = _day
          ..createdAt = _day,
      );
      await isar.sleepEntryIsars.put(
        SleepEntryIsar()
          ..profileId = 1
          ..bedtime = _day.subtract(const Duration(hours: 8))
          ..wakeTime = _day
          ..isNap = false
          ..createdAt = _day,
      );
    });
    final before = await _counts(isar);

    final container = ProviderContainer(
      overrides: [
        isarProvider.overrideWithValue(isar),
        featureFlagsProvider.overrideWithValue(
          const FeatureFlags(trackAndCare: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    final sarah = (await isar.profileIsars.get(1))!.toDomain();
    await container
        .read(profileListProvider.notifier)
        .update(
          sarah.copyWith(
            disabledFeatureIds: [
              for (final f in navFeatures)
                if (f.canTurnOff) f.id,
            ],
          ),
        );

    expect((await isar.profileIsars.get(1))!.disabledFeatureIds, hasLength(9));
    expect(await _counts(isar), before);
    final meal = (await isar.mealEntryIsars.where().findAll()).single;
    expect(meal.description, 'Toast and eggs');

    final report = await ReportQueryService.query(
      isar: isar,
      profileId: 1,
      profileName: 'Sarah',
      config: ReportConfig(
        preset: DateRangePreset.custom,
        customStart: DateTime(2026, 9, 1),
        customEnd: DateTime(2026, 10, 31),
      ),
    );
    expect(report.meals, hasLength(1));
    expect(report.sleep, hasLength(1));
  });

  group('Onboarding never asks this up front', () {
    test('a new profile starts with every feature on', () async {
      final isar = await Isar.open(
        appSchemas,
        directory: '',
        name: 'features_new_${DateTime.now().microsecondsSinceEpoch}',
      );
      addTearDown(() => isar.close(deleteFromDisk: true));
      await MigrationRunner.run(isar);
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);
      await container.read(profileListProvider.notifier).add(name: 'Sam');
      final row = (await isar.profileIsars.where().findAll()).single;
      expect(row.disabledFeatureIds, isEmpty);
    });

    test('Features in use is not part of onboarding', () {
      final onboarding = Directory('lib/features/onboarding')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final f in onboarding) {
        final src = f.readAsStringSync();
        expect(src, isNot(contains('Features in use')), reason: f.path);
        expect(src, isNot(contains('disabledFeatureIds')), reason: f.path);
      }
    });
  });
}

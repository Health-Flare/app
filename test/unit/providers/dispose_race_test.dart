import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/core/providers/elimination_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/fluid_intake_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/data/database/app_settings.dart';
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

// Issue #87: notifiers that read Isar and then set `state` threw "Cannot use
// the Ref ... after it has been disposed" when the provider was disposed
// while the read was in flight. In the app that's a logged error; in tests
// it failed whichever test owned the container, depending on timing (the
// move_to_profile / move_dose_appointment CI flakes).
//
// Each case reads the provider (starting its async load), disposes the
// container straight away, then waits for the read to land. Without the
// `ref.mounted` guard the late `state =` is an uncaught error and the test
// fails, every time.

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

class _FixedActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

/// Providers whose build() starts an Isar read that ends in `state =`.
/// Per-profile ones only read when a profile is active, so the active
/// profile is pinned to 1 for these.
final _loadingProviders = <String, ProviderListenable<Object?>>{
  'activityEntryListProvider': activityEntryListProvider,
  'appointmentListProvider': appointmentListProvider,
  'conditionCatalogProvider': conditionCatalogProvider,
  'symptomCatalogProvider': symptomCatalogProvider,
  'userConditionListProvider': userConditionListProvider,
  'userSymptomListProvider': userSymptomListProvider,
  'dailyCheckinListProvider': dailyCheckinListProvider,
  'doseLogListProvider': doseLogListProvider,
  'eliminationListProvider': eliminationListProvider,
  'flareListProvider': flareListProvider,
  'fluidIntakeListProvider': fluidIntakeListProvider,
  'journalEntryListProvider': journalEntryListProvider,
  'mealEntryListProvider': mealEntryListProvider,
  'medicationListProvider': medicationListProvider,
  'sleepEntryListProvider': sleepEntryListProvider,
  'symptomEntryListProvider': symptomEntryListProvider,
  'vitalEntryListProvider': vitalEntryListProvider,
  'firstLogPromptProvider': firstLogPromptProvider,
  'weatherOptInProvider': weatherOptInProvider,
  'profileListProvider': profileListProvider,
};

void main() {
  late Isar isar;

  setUpAll(() async {
    await Isar.initializeIsarCore();
  });

  setUp(() async {
    isar = await Isar.open(
      _schemas,
      directory: '',
      name: 'dispose_race_${DateTime.now().microsecondsSinceEpoch}',
    );
    await isar.writeTxn(() async {
      await isar.profileIsars.put(
        ProfileIsar()
          ..id = 1
          ..name = 'Sarah',
      );
      await isar.appSettings.put(AppSettings()..activeProfileId = 1);
    });
  });

  tearDown(() async => isar.close(deleteFromDisk: true));

  Future<void> disposeMidLoad(
    ProviderListenable<Object?> provider, {
    bool pinActiveProfile = true,
  }) async {
    final container = ProviderContainer(
      overrides: [
        isarProvider.overrideWithValue(isar),
        if (pinActiveProfile)
          activeProfileProvider.overrideWith(_FixedActiveProfile.new),
      ],
    );
    container.read(provider);
    container.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  group('a load finishing after the provider is disposed does not throw', () {
    for (final MapEntry(key: name, value: provider)
        in _loadingProviders.entries) {
      test(name, () => disposeMidLoad(provider));
    }

    test('activeProfileProvider (loads the saved id from the database)', () {
      return disposeMidLoad(activeProfileProvider, pinActiveProfile: false);
    });
  });
}

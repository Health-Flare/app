// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:health_flare/main.dart';
import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/providers/dashboard_provider.dart';
import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/models/activity_item.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/daily_checkin.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/sleep_entry.dart';
import 'package:health_flare/models/symptom.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/models/user_symptom.dart';
import 'package:health_flare/models/vital_entry.dart';

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

final _sarah = Profile(id: 1, name: 'Sarah Chen');

final _now = DateTime(2026, 5, 4, 9, 30);

final _medications = [
  Medication(
    id: 1,
    profileId: 1,
    name: 'Hydroxychloroquine',
    medicationType: 'medication',
    doseAmount: 200,
    doseUnit: 'mg',
    frequency: 'twice_daily',
    startDate: DateTime(2024, 6, 1),
    createdAt: DateTime(2024, 6, 1),
  ),
  Medication(
    id: 2,
    profileId: 1,
    name: 'Vitamin D',
    medicationType: 'supplement',
    doseAmount: 2000,
    doseUnit: 'IU',
    frequency: 'once_daily',
    startDate: DateTime(2025, 1, 1),
    createdAt: DateTime(2025, 1, 1),
  ),
  Medication(
    id: 3,
    profileId: 1,
    name: 'Tramadol',
    medicationType: 'medication',
    doseAmount: 50,
    doseUnit: 'mg',
    frequency: 'as_needed',
    startDate: DateTime(2024, 9, 15),
    createdAt: DateTime(2024, 9, 15),
  ),
];

final _appointments = [
  Appointment(
    id: 1,
    profileId: 1,
    title: 'Rheumatology follow-up',
    providerName: 'Dr. Patel',
    scheduledAt: DateTime(2026, 5, 12, 14, 0),
    status: AppointmentStatus.upcoming,
    createdAt: _now,
    questions: const [
      AppointmentQuestion(
        questionId: 'q1',
        question: 'Can we review my HCQ dosage?',
      ),
      AppointmentQuestion(
        questionId: 'q2',
        question: 'What should I do during a severe flare?',
      ),
    ],
  ),
  Appointment(
    id: 2,
    profileId: 1,
    title: 'GP check-in',
    providerName: 'Dr. Williams',
    scheduledAt: DateTime(2026, 4, 22, 10, 30),
    status: AppointmentStatus.completed,
    outcomeNotes: 'Blood work ordered. Continue current medications.',
    createdAt: _now,
  ),
];

final _journalEntries = [
  JournalEntry(
    id: 1,
    profileId: 1,
    createdAt: DateTime(2026, 5, 3, 20, 15),
    snapshots: [
      JournalSnapshot(
        body:
            'Rough day — fatigue hit hard after lunch. '
            'Managed a short walk but had to rest for two hours afterwards. '
            "Joint pain in knees is a 6/10 today. Tomorrow's rheumatology "
            'appointment can\'t come soon enough.',
        title: 'Rough Saturday',
        savedAt: DateTime(2026, 5, 3, 20, 15),
      ),
    ],
    mood: 3,
    energyLevel: 2,
  ),
  JournalEntry(
    id: 2,
    profileId: 1,
    createdAt: DateTime(2026, 4, 30, 18, 0),
    snapshots: [
      JournalSnapshot(
        body:
            'Feeling much better than last week. '
            'Morning stiffness was only about 20 minutes today. '
            'Went to the farmers market with mum — first outing in weeks!',
        title: 'A good day',
        savedAt: DateTime(2026, 4, 30, 18, 0),
      ),
    ],
    mood: 1,
    energyLevel: 3,
  ),
  JournalEntry(
    id: 3,
    profileId: 1,
    createdAt: DateTime(2026, 4, 25, 21, 0),
    snapshots: [
      JournalSnapshot(
        body:
            'Started tracking sleep this week. Noticing a clear correlation '
            'between poor sleep and next-day pain levels. Will mention to Dr. Patel.',
        savedAt: DateTime(2026, 4, 25, 21, 0),
      ),
    ],
  ),
];

final _meals = [
  MealEntry(
    id: 1,
    profileId: 1,
    description: 'Oat porridge with blueberries and flaxseed',
    hasReaction: false,
    loggedAt: DateTime(2026, 5, 4, 8, 0),
    createdAt: DateTime(2026, 5, 4, 8, 0),
  ),
  MealEntry(
    id: 2,
    profileId: 1,
    description: 'Gluten-free pasta with roasted vegetables',
    notes: 'Felt slightly bloated after — monitor this.',
    hasReaction: true,
    loggedAt: DateTime(2026, 5, 3, 19, 30),
    createdAt: DateTime(2026, 5, 3, 19, 30),
  ),
  MealEntry(
    id: 3,
    profileId: 1,
    description: 'Green smoothie — spinach, banana, almond milk',
    hasReaction: false,
    loggedAt: DateTime(2026, 5, 3, 8, 15),
    createdAt: DateTime(2026, 5, 3, 8, 15),
  ),
];

final _activities = [
  ActivityEntry(
    id: 1,
    profileId: 1,
    description: 'Short walk around the block',
    activityType: ActivityType.walking,
    effortLevel: 2,
    durationMinutes: 20,
    loggedAt: DateTime(2026, 5, 3, 15, 0),
    createdAt: DateTime(2026, 5, 3, 15, 0),
  ),
  ActivityEntry(
    id: 2,
    profileId: 1,
    description: 'Gentle stretching and breathing',
    activityType: ActivityType.gentleExercise,
    effortLevel: 1,
    durationMinutes: 15,
    loggedAt: DateTime(2026, 5, 2, 10, 0),
    createdAt: DateTime(2026, 5, 2, 10, 0),
  ),
  ActivityEntry(
    id: 3,
    profileId: 1,
    description: 'Rest day — very low energy',
    activityType: ActivityType.rest,
    effortLevel: 1,
    loggedAt: DateTime(2026, 5, 1, 18, 0),
    createdAt: DateTime(2026, 5, 1, 18, 0),
  ),
];

final _flares = [
  Flare(
    id: 1,
    profileId: 1,
    startedAt: DateTime(2026, 4, 20),
    endedAt: DateTime(2026, 4, 24),
    initialSeverity: 7,
    peakSeverity: 8,
    notes: 'Triggered after the cold front came through. Joint pain and fatigue.',
    createdAt: DateTime(2026, 4, 20),
  ),
  Flare(
    id: 2,
    profileId: 1,
    startedAt: DateTime(2026, 2, 10),
    endedAt: DateTime(2026, 2, 13),
    initialSeverity: 5,
    peakSeverity: 6,
    createdAt: DateTime(2026, 2, 10),
  ),
];

final _checkins = [
  DailyCheckin(
    id: 1,
    profileId: 1,
    checkinDate: DateTime(2026, 5, 3),
    wellbeing: 3,
    notes: 'Joints aching. Tired after a busy day.',
    createdAt: DateTime(2026, 5, 3, 22, 0),
  ),
  DailyCheckin(
    id: 2,
    profileId: 1,
    checkinDate: DateTime(2026, 5, 2),
    wellbeing: 4,
    createdAt: DateTime(2026, 5, 2, 21, 30),
  ),
];

// Conditions — showcases Active + In recovery grouping and diagnosis dates.
final _userConditions = [
  UserCondition(
    id: 1,
    profileId: 1,
    conditionId: 101,
    conditionName: 'Lupus (SLE)',
    trackedSince: DateTime(2022, 3, 15),
    diagnosedAt: DateTime(2022, 3, 15),
    status: ConditionStatus.active,
    statusHistory: const [],
  ),
  UserCondition(
    id: 2,
    profileId: 1,
    conditionId: 102,
    conditionName: 'Fibromyalgia',
    trackedSince: DateTime(2023, 7, 1),
    diagnosedAt: DateTime(2023, 7, 1),
    status: ConditionStatus.inRecovery,
    statusHistory: [
      ConditionStatusEvent(eventType: 'recovery', date: DateTime.utc(2026, 1, 15)),
    ],
  ),
  UserCondition(
    id: 3,
    profileId: 1,
    conditionId: 103,
    conditionName: 'Chronic Fatigue Syndrome',
    trackedSince: DateTime(2024, 5, 20),
    status: ConditionStatus.active,
    statusHistory: const [],
  ),
];

final _userSymptoms = [
  UserSymptom(
    id: 1,
    profileId: 1,
    symptomId: 201,
    symptomName: 'Fatigue',
    trackedSince: DateTime(2022, 3, 15),
  ),
  UserSymptom(
    id: 2,
    profileId: 1,
    symptomId: 202,
    symptomName: 'Joint pain',
    trackedSince: DateTime(2022, 3, 15),
  ),
  UserSymptom(
    id: 3,
    profileId: 1,
    symptomId: 203,
    symptomName: 'Brain fog',
    trackedSince: DateTime(2023, 1, 1),
  ),
];

final _symptomEntries = [
  SymptomEntry(
    id: 1,
    profileId: 1,
    userSymptomIsarId: 1,
    name: 'Fatigue',
    severity: 7,
    loggedAt: DateTime(2026, 5, 3, 14, 0),
    createdAt: DateTime(2026, 5, 3, 14, 0),
  ),
  SymptomEntry(
    id: 2,
    profileId: 1,
    userSymptomIsarId: 2,
    name: 'Joint pain',
    severity: 6,
    loggedAt: DateTime(2026, 5, 3, 14, 0),
    createdAt: DateTime(2026, 5, 3, 14, 0),
  ),
  SymptomEntry(
    id: 3,
    profileId: 1,
    userSymptomIsarId: 3,
    name: 'Brain fog',
    severity: 5,
    loggedAt: DateTime(2026, 5, 2, 10, 30),
    createdAt: DateTime(2026, 5, 2, 10, 30),
  ),
];

final _sleepEntries = [
  SleepEntry(
    id: 1,
    profileId: 1,
    bedtime: DateTime(2026, 5, 3, 23, 15),
    wakeTime: DateTime(2026, 5, 4, 7, 0),
    qualityRating: 3,
    createdAt: DateTime(2026, 5, 4, 7, 0),
  ),
  SleepEntry(
    id: 2,
    profileId: 1,
    bedtime: DateTime(2026, 5, 2, 22, 0),
    wakeTime: DateTime(2026, 5, 3, 7, 30),
    qualityRating: 4,
    createdAt: DateTime(2026, 5, 3, 7, 30),
  ),
];

final _doseLogs = [
  DoseLog(
    id: 1,
    profileId: 1,
    medicationIsarId: 1,
    loggedAt: DateTime(2026, 5, 4, 8, 0),
    createdAt: DateTime(2026, 5, 4, 8, 0),
    amount: 200,
    unit: 'mg',
    status: 'taken',
  ),
  DoseLog(
    id: 2,
    profileId: 1,
    medicationIsarId: 2,
    loggedAt: DateTime(2026, 5, 4, 8, 5),
    createdAt: DateTime(2026, 5, 4, 8, 5),
    amount: 2000,
    unit: 'IU',
    status: 'taken',
  ),
];

// ---------------------------------------------------------------------------
// Fake notifiers — override build() to skip Isar
// ---------------------------------------------------------------------------

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [_sarah];
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => _sarah.id;

  @override
  Future<void> setActive(int? id) async {}
}

class _FakeConditionCatalog extends ConditionCatalogNotifier {
  @override
  List<Condition> build() => [];
}

class _FakeSymptomCatalog extends SymptomCatalogNotifier {
  @override
  List<Symptom> build() => [];
}

class _FakeUserConditions extends UserConditionListNotifier {
  @override
  List<UserCondition> build() => _userConditions;
}

class _FakeUserSymptoms extends UserSymptomListNotifier {
  @override
  List<UserSymptom> build() => _userSymptoms;
}

class _FakeJournalList extends JournalEntryListNotifier {
  @override
  List<JournalEntry> build() => _journalEntries;
}

class _FakeSleepList extends SleepEntryListNotifier {
  @override
  List<SleepEntry> build() => _sleepEntries;
}

class _FakeFirstLogPrompt extends FirstLogPromptNotifier {
  @override
  bool build() => false;

  @override
  Future<void> markShown() async {}

  @override
  void show() {}

  @override
  Future<void> dismiss() async {}
}

class _FakeWeatherOptIn extends WeatherOptInNotifier {
  @override
  bool build() => false;

  @override
  Future<void> dismiss({required bool enabled}) async {}
}

class _FakeFlareList extends FlareListNotifier {
  @override
  List<Flare> build() => _flares;
}

class _FakeCheckinList extends DailyCheckinListNotifier {
  @override
  List<DailyCheckin> build() => _checkins;
}

class _FakeAppointmentList extends AppointmentListNotifier {
  @override
  List<Appointment> build() => _appointments;
}

class _FakeSymptomEntryList extends SymptomEntryListNotifier {
  @override
  List<SymptomEntry> build() => _symptomEntries;
}

class _FakeVitalEntryList extends VitalEntryListNotifier {
  @override
  List<VitalEntry> build() => [];
}

class _FakeDoseLogList extends DoseLogListNotifier {
  @override
  List<DoseLog> build() => _doseLogs;
}

class _FakeMealEntryList extends MealEntryListNotifier {
  @override
  List<MealEntry> build() => _meals;
}

class _FakeMedicationList extends MedicationListNotifier {
  @override
  List<Medication> build() => _medications;
}

class _FakeActivityEntryList extends ActivityEntryListNotifier {
  @override
  List<ActivityEntry> build() => _activities;
}

// Empty variants used for the onboarding screenshot.
class _EmptyProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [];
}

class _EmptyActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => null;
}

// ---------------------------------------------------------------------------
// Provider overrides helpers
// ---------------------------------------------------------------------------

List<ActivityItem> _dashboardFeed() {
  final items = <ActivityItem>[
    ..._journalEntries.map(
      (e) => JournalActivityItem(timestamp: e.createdAt, entry: e),
    ),
    ..._sleepEntries.map(
      (e) => SleepActivityItem(timestamp: e.wakeTime, entry: e),
    ),
  ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items.take(10).toList();
}

List<Override> _overrides() => [
  profileListProvider.overrideWith(_FakeProfileList.new),
  activeProfileProvider.overrideWith(_FakeActiveProfile.new),
  conditionCatalogProvider.overrideWith(_FakeConditionCatalog.new),
  symptomCatalogProvider.overrideWith(_FakeSymptomCatalog.new),
  userConditionListProvider.overrideWith(_FakeUserConditions.new),
  userSymptomListProvider.overrideWith(_FakeUserSymptoms.new),
  journalEntryListProvider.overrideWith(_FakeJournalList.new),
  sleepEntryListProvider.overrideWith(_FakeSleepList.new),
  firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
  weatherOptInProvider.overrideWith(_FakeWeatherOptIn.new),
  flareListProvider.overrideWith(_FakeFlareList.new),
  activeFlareProvider.overrideWith((ref) => null),
  dailyCheckinListProvider.overrideWith(_FakeCheckinList.new),
  todayCheckinProvider.overrideWith((ref) => null),
  appointmentListProvider.overrideWith(_FakeAppointmentList.new),
  activeProfileAppointmentsProvider.overrideWith(
    (ref) => _appointments,
  ),
  upcomingAppointmentsProvider.overrideWith(
    (ref) => _appointments.where((a) => a.isUpcoming).toList(),
  ),
  symptomEntryListProvider.overrideWith(_FakeSymptomEntryList.new),
  activeProfileSymptomEntriesProvider.overrideWith(
    (ref) => _symptomEntries,
  ),
  vitalEntryListProvider.overrideWith(_FakeVitalEntryList.new),
  activeProfileVitalEntriesProvider.overrideWith((ref) => []),
  doseLogListProvider.overrideWith(_FakeDoseLogList.new),
  activeProfileDoseLogsProvider.overrideWith((ref) => _doseLogs),
  mealEntryListProvider.overrideWith(_FakeMealEntryList.new),
  activeProfileMealEntriesProvider.overrideWith((ref) => _meals),
  medicationListProvider.overrideWith(_FakeMedicationList.new),
  activeProfileMedicationsProvider.overrideWith((ref) => _medications),
  activityEntryListProvider.overrideWith(_FakeActivityEntryList.new),
  activeProfileActivityEntriesProvider.overrideWith(
    (ref) => _activities,
  ),
  dashboardActivityProvider.overrideWith((ref) => _dashboardFeed()),
  dashboardHasActivityProvider.overrideWith((ref) => true),
];

List<Override> _onboardingOverrides() => [
  profileListProvider.overrideWith(_EmptyProfileList.new),
  activeProfileProvider.overrideWith(_EmptyActiveProfile.new),
  conditionCatalogProvider.overrideWith(_FakeConditionCatalog.new),
  symptomCatalogProvider.overrideWith(_FakeSymptomCatalog.new),
  userConditionListProvider.overrideWith(_FakeUserConditions.new),
  userSymptomListProvider.overrideWith(_FakeUserSymptoms.new),
  journalEntryListProvider.overrideWith(_FakeJournalList.new),
  sleepEntryListProvider.overrideWith(_FakeSleepList.new),
  firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
  weatherOptInProvider.overrideWith(_FakeWeatherOptIn.new),
  flareListProvider.overrideWith(_FakeFlareList.new),
  activeFlareProvider.overrideWith((ref) => null),
  dailyCheckinListProvider.overrideWith(_FakeCheckinList.new),
  todayCheckinProvider.overrideWith((ref) => null),
  appointmentListProvider.overrideWith(_FakeAppointmentList.new),
  activeProfileAppointmentsProvider.overrideWith((ref) => []),
  upcomingAppointmentsProvider.overrideWith((ref) => []),
  symptomEntryListProvider.overrideWith(_FakeSymptomEntryList.new),
  activeProfileSymptomEntriesProvider.overrideWith((ref) => []),
  vitalEntryListProvider.overrideWith(_FakeVitalEntryList.new),
  activeProfileVitalEntriesProvider.overrideWith((ref) => []),
  doseLogListProvider.overrideWith(_FakeDoseLogList.new),
  activeProfileDoseLogsProvider.overrideWith((ref) => []),
  mealEntryListProvider.overrideWith(_FakeMealEntryList.new),
  activeProfileMealEntriesProvider.overrideWith((ref) => []),
  medicationListProvider.overrideWith(_FakeMedicationList.new),
  activeProfileMedicationsProvider.overrideWith((ref) => []),
  activityEntryListProvider.overrideWith(_FakeActivityEntryList.new),
  activeProfileActivityEntriesProvider.overrideWith((ref) => []),
  dashboardActivityProvider.overrideWith((ref) => []),
  dashboardHasActivityProvider.overrideWith((ref) => false),
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps after navigation and waits for animations to settle (without
/// pumpAndSettle, which hangs on repeating animations).
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Takes a named screenshot and prints progress to the console.
Future<void> _screenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await binding.convertFlutterSurfaceToImage();
  await tester.pump();
  await binding.takeScreenshot(name);
  print('📸  $name');
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
  });

  group('screenshots', () {
    testWidgets('01_onboarding', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _onboardingOverrides(),
          child: const HealthFlareApp(),
        ),
      );
      await _settle(tester);
      await _screenshot(binding, tester, '01_onboarding');
    });

    testWidgets('02_dashboard', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const HealthFlareApp(),
        ),
      );
      await _settle(tester);
      await _screenshot(binding, tester, '02_dashboard');
    });

    // Tracking — Symptoms tab (default view when tapping Tracking in nav)
    testWidgets('03_tracking_symptoms', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const HealthFlareApp(),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('Tracking'));
      await _settle(tester);
      await _screenshot(binding, tester, '03_tracking_symptoms');
    });

    // Tracking — Illnesses tab showing Active + In recovery sections
    testWidgets('04_tracking_illnesses', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const HealthFlareApp(),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('Tracking'));
      await _settle(tester);
      await tester.tap(find.text('Illnesses'));
      await _settle(tester);
      await _screenshot(binding, tester, '04_tracking_illnesses');
    });

    // Condition detail — Fibromyalgia (in recovery, has diagnosis date + history)
    testWidgets('05_condition_detail', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const HealthFlareApp(),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('Tracking'));
      await _settle(tester);
      await tester.tap(find.text('Illnesses'));
      await _settle(tester);
      await tester.tap(find.text('Fibromyalgia'));
      await _settle(tester);
      await _screenshot(binding, tester, '05_condition_detail');
    });

    testWidgets('06_medications', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const HealthFlareApp(),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('Medications'));
      await _settle(tester);
      await _screenshot(binding, tester, '06_medications');
    });

    testWidgets('07_meals', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const HealthFlareApp(),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('Meals'));
      await _settle(tester);
      await _screenshot(binding, tester, '07_meals');
    });

    testWidgets('08_journal', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const HealthFlareApp(),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('Journal'));
      await _settle(tester);
      await _screenshot(binding, tester, '08_journal');
    });

    testWidgets('09_journal_composer', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const HealthFlareApp(),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('Journal'));
      await _settle(tester);
      await tester.tap(find.byTooltip('New journal entry'));
      await _settle(tester);
      await _screenshot(binding, tester, '09_journal_composer');
    });

    testWidgets('10_medication_form', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const HealthFlareApp(),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('Medications'));
      await _settle(tester);
      await tester.tap(find.byTooltip('Add medication'));
      await _settle(tester);
      await _screenshot(binding, tester, '10_medication_form');
    });

    testWidgets('11_meal_form', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(),
          child: const HealthFlareApp(),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('Meals'));
      await _settle(tester);
      await tester.tap(find.byTooltip('Log meal'));
      await _settle(tester);
      await _screenshot(binding, tester, '11_meal_form');
    });
  });
}

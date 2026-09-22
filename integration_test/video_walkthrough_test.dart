// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
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
import 'package:health_flare/models/weather_snapshot.dart';
import 'package:health_flare/core/providers/weather_provider.dart';

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------
//
// Deliberately duplicated from screenshot_test.dart rather than shared: this
// file drives a real-time recording (see scripts/take_video.sh /
// take_video_android.sh, which wrap it with simctl/adb screen recording), so
// it must keep working in isolation even if the screenshot suite's fixtures
// change shape for screenshot-specific reasons. Keep the two in sync by eye
// when either changes meaningfully.

final _sarah = Profile(id: 1, name: 'Sarah Chen', weatherTrackingEnabled: true);

final _fakeWeather = WeatherSnapshot(
  temperatureCelsius: 18.0,
  weatherCode: 2,
  pressureHPa: 1013.0,
  humidityPercent: 62,
  windSpeedKmh: 14.0,
  capturedAt: DateTime(2026, 5, 4, 9, 30),
);

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
            'Rough day. Fatigue hit hard after lunch. '
            'Managed a short walk but had to rest for two hours afterwards. '
            "Joint pain in knees is a 6/10 today. Tomorrow's rheumatology "
            'appointment can\'t come soon enough.',
        title: 'Rough Saturday',
        savedAt: DateTime(2026, 5, 3, 20, 15),
      ),
    ],
    mood: 3,
    energyLevel: 2,
    weatherSnapshot: WeatherSnapshot(
      temperatureCelsius: 11.0,
      weatherCode: 61,
      pressureHPa: 1008.0,
      humidityPercent: 78,
      windSpeedKmh: 22.0,
      capturedAt: DateTime(2026, 5, 3, 20, 15),
    ),
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
            'Went to the farmers market with mum, first outing in weeks!',
        title: 'A good day',
        savedAt: DateTime(2026, 4, 30, 18, 0),
      ),
    ],
    mood: 1,
    energyLevel: 3,
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
    notes: 'Felt slightly bloated after. Monitor this.',
    hasReaction: true,
    loggedAt: DateTime(2026, 5, 3, 19, 30),
    createdAt: DateTime(2026, 5, 3, 19, 30),
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
];

final _flares = [
  Flare(
    id: 1,
    profileId: 1,
    startedAt: DateTime(2026, 4, 20),
    endedAt: DateTime(2026, 4, 24),
    initialSeverity: 7,
    peakSeverity: 8,
    notes:
        'Triggered after the cold front came through. Joint pain and fatigue.',
    createdAt: DateTime(2026, 4, 20),
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
];

// Conditions: showcases Active + In recovery grouping and diagnosis dates.
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
      ConditionStatusEvent(
        eventType: 'recovery',
        date: DateTime.utc(2026, 1, 15),
      ),
    ],
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
];

// ---------------------------------------------------------------------------
// Fake notifiers: override build() to skip Isar
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

class _EmptyProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [];
}

class _EmptyActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => null;
}

// ---------------------------------------------------------------------------
// Provider overrides
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
  activeProfileAppointmentsProvider.overrideWith((ref) => _appointments),
  upcomingAppointmentsProvider.overrideWith(
    (ref) => _appointments.where((a) => a.isUpcoming).toList(),
  ),
  symptomEntryListProvider.overrideWith(_FakeSymptomEntryList.new),
  activeProfileSymptomEntriesProvider.overrideWith((ref) => _symptomEntries),
  vitalEntryListProvider.overrideWith(_FakeVitalEntryList.new),
  activeProfileVitalEntriesProvider.overrideWith((ref) => []),
  doseLogListProvider.overrideWith(_FakeDoseLogList.new),
  activeProfileDoseLogsProvider.overrideWith((ref) => _doseLogs),
  mealEntryListProvider.overrideWith(_FakeMealEntryList.new),
  activeProfileMealEntriesProvider.overrideWith((ref) => _meals),
  medicationListProvider.overrideWith(_FakeMedicationList.new),
  activeProfileMedicationsProvider.overrideWith((ref) => _medications),
  activityEntryListProvider.overrideWith(_FakeActivityEntryList.new),
  activeProfileActivityEntriesProvider.overrideWith((ref) => _activities),
  dashboardActivityProvider.overrideWith((ref) => _dashboardFeed()),
  dashboardHasActivityProvider.overrideWith((ref) => true),
  currentWeatherProvider.overrideWith((ref) async => _fakeWeather),
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
  currentWeatherProvider.overrideWith((ref) async => null),
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Holds on the current frame for [seconds] of real wall-clock time: long
/// enough for a viewer (or the external screen recorder) to actually read
/// the screen, not just flash past it.
///
/// Each scene rebuilds the widget tree from scratch via pumpWidget rather
/// than navigating between scenes with Back buttons: this mirrors
/// screenshot_test.dart's per-screen approach and avoids depending on
/// back-navigation affordances this file hasn't verified the finders for.
/// The short rebuild flash between scenes is expected; edit clips at cut
/// points when trimming the raw capture.
Future<void> _hold(WidgetTester tester, double seconds, String label) async {
  print('🎬  $label');
  const step = Duration(milliseconds: 200);
  final ticks = (seconds * 1000 / step.inMilliseconds).round();
  for (var i = 0; i < ticks; i++) {
    await tester.pump(step);
  }
}

// ---------------------------------------------------------------------------
// Walkthrough
// ---------------------------------------------------------------------------

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
  });

  testWidgets('full_app_walkthrough', (tester) async {
    // ── Scene 1: guided onboarding ──────────────────────────────────────
    //
    // Each scene below gets its own Key on the ProviderScope. Without one,
    // Flutter reconciles same-type widgets in place across pumpWidget calls
    // instead of remounting, so overriding a NotifierProvider with a
    // different fake class has no effect on a Notifier that already built
    // once (only future/new elements pick up the new override), and the app
    // silently keeps showing whatever screen the previous scene left it on.
    // A fresh Key forces a full teardown/remount: a fresh ProviderContainer
    // per scene, so every scene's overrides actually take effect and
    // GoRouter's initialLocation is re-evaluated from scratch.
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('scene-onboarding'),
        overrides: _onboardingOverrides(),
        child: const HealthFlareApp(),
      ),
    );
    await _settle(tester);
    await _hold(tester, 2.5, 'onboarding: welcome');

    final nextButton = find.widgetWithText(FilledButton, 'Next');
    await tester.tap(nextButton);
    await _settle(tester);
    await _hold(tester, 2.5, 'onboarding: what you can track');

    await tester.tap(nextButton);
    await _settle(tester);
    await _hold(tester, 2.5, 'onboarding: your privacy');

    await tester.tap(nextButton);
    await _settle(tester);
    await _hold(tester, 2, 'onboarding: create profile');

    // ── Scene 2: dashboard, populated ───────────────────────────────────
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('scene-dashboard'),
        overrides: _overrides(),
        child: const HealthFlareApp(),
      ),
    );
    await _settle(tester);
    await _hold(tester, 3, 'dashboard');

    // ── Scene 3: tracking: symptoms ────────────────────────────────────
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('scene-tracking-symptoms'),
        overrides: _overrides(),
        child: const HealthFlareApp(),
      ),
    );
    await _settle(tester);
    await tester.tap(find.text('Tracking'));
    await _settle(tester);
    await _hold(tester, 2.5, 'tracking: symptoms');

    // ── Scene 4: tracking: illnesses → condition detail ───────────────
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('scene-tracking-illnesses'),
        overrides: _overrides(),
        child: const HealthFlareApp(),
      ),
    );
    await _settle(tester);
    await tester.tap(find.text('Tracking'));
    await _settle(tester);
    await tester.tap(find.text('Illnesses'));
    await _settle(tester);
    await _hold(tester, 2, 'tracking: illnesses');
    await tester.tap(find.text('Fibromyalgia'));
    await _settle(tester);
    await _hold(tester, 2.5, 'condition detail');

    // ── Scene 5: medications ────────────────────────────────────────────
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('scene-medications'),
        overrides: _overrides(),
        child: const HealthFlareApp(),
      ),
    );
    await _settle(tester);
    await tester.tap(find.text('Medications'));
    await _settle(tester);
    await _hold(tester, 2.5, 'medications');

    // ── Scene 6: journal: list → composer ──────────────────────────────
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('scene-journal'),
        overrides: _overrides(),
        child: const HealthFlareApp(),
      ),
    );
    await _settle(tester);
    await tester.tap(find.text('Journal'));
    await _settle(tester);
    await _hold(tester, 2, 'journal: entries');

    await tester.tap(find.byTooltip('New journal entry'));
    await _settle(tester);
    await tester.pump(); // weather postFrameCallback
    await _hold(tester, 2.5, 'journal: new entry composer');

    // ── Scene 7: symptom form with weather chip ─────────────────────────
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('scene-symptom-weather'),
        overrides: _overrides(),
        child: const HealthFlareApp(),
      ),
    );
    await _settle(tester);
    await tester.tap(find.text('Tracking'));
    await _settle(tester);
    await tester.tap(find.byTooltip('Log symptom'));
    await _settle(tester);
    await tester.pump(); // weather postFrameCallback
    await _hold(tester, 3, 'log symptom: with weather');

    print('🎬  walkthrough complete');
  });
}

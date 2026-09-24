// ignore_for_file: avoid_print

// Dedicated, self-contained screenshot suite for Quick Log: deliberately
// kept out of screenshot_test.dart (which walks the whole app) so it's fast
// enough to run on demand, e.g. to refresh docs or a PR description after a
// classifier change:
//
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/quick_log_screenshot_test.dart \
//     -d DEVICE_ID
//
// or via scripts/take_quick_log_screenshots.sh, which finds a booted/
// available simulator for you. Output: screenshots/quick_log/NAME.png.
//
// Linux has no integration_test screenshot plugin. On that embedder the
// same tests write the frame themselves when SCREENSHOT_DIR is set.
// Those desktop frames are kept beside the iOS set, under
// screenshots/quick_log/linux/, so a Linux run does not replace the
// simulator PNGs.
//
// Each test opens the sheet and types one sample text, so both the type
// chip and the primary button's "Quick Add: <Type>" / "Add to Journal"
// label (see quick_log_sheet.dart) are visible in the resulting image:
// covering every QuickLogEntryType the classifier can suggest, including
// the catalogue-matched, tracked-custom, and generic-keyword paths for
// Condition and Symptom detection (see quick_log_classifier.dart).

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
// Sample data: just enough for the dashboard + Quick Log to render and for
// each classification path to have something to match against.
// ---------------------------------------------------------------------------

// Cycle and bowel tracking are opt-in. Turn both on so those chips can
// appear in the proof shots; other types do not depend on the flags.
final _sarah = Profile(
  id: 1,
  name: 'Sarah Chen',
  cycleTrackingEnabled: true,
  bowelTrackingEnabled: true,
);

final _medications = [
  Medication(
    id: 1,
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

// A condition Sarah isn't tracking yet, so the catalogue-match screenshot
// has something new to demonstrate.
final _conditionCatalog = [
  const Condition(id: 301, name: "Sjögren's syndrome"),
];

// A tracked condition with no catalogue entry, matched only via its acronym
// ("Chronic Fatigue Syndrome" → "CFS"), and, deliberately, one whose name
// contains a parenthesis ("Lupus (SLE)") to keep exercising the acronym
// crash fix in QuickLogParser.textMentionsName on every real run of this
// suite, not just in unit tests.
final _trackedConditions = [
  UserCondition(
    id: 1,
    profileId: 1,
    conditionId: 101,
    conditionName: 'Lupus (SLE)',
    trackedSince: DateTime(2022, 3, 15),
  ),
  UserCondition(
    id: 2,
    profileId: 1,
    conditionId: 103,
    conditionName: 'Chronic Fatigue Syndrome',
    trackedSince: DateTime(2024, 5, 20),
  ),
];

// A catalogue symptom outside Quick Log's generic keyword list.
final _symptomCatalog = [const Symptom(id: 301, name: 'Photophobia')];

// A tracked custom symptom the user created once via the full form:
// recognised here on a later Quick Log mention with no keyword involved.
final _trackedSymptoms = [
  UserSymptom(
    id: 1,
    profileId: 1,
    symptomId: 203,
    symptomName: 'Brain fog',
    trackedSince: DateTime(2023, 1, 1),
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
  List<Condition> build() => _conditionCatalog;
}

class _FakeUserConditions extends UserConditionListNotifier {
  @override
  List<UserCondition> build() => _trackedConditions;
}

class _FakeSymptomCatalog extends SymptomCatalogNotifier {
  @override
  List<Symptom> build() => _symptomCatalog;
}

class _FakeUserSymptoms extends UserSymptomListNotifier {
  @override
  List<UserSymptom> build() => _trackedSymptoms;
}

class _FakeMedicationList extends MedicationListNotifier {
  @override
  List<Medication> build() => _medications;
}

class _EmptyJournalList extends JournalEntryListNotifier {
  @override
  List<JournalEntry> build() => [];
}

class _EmptySleepList extends SleepEntryListNotifier {
  @override
  List<SleepEntry> build() => [];
}

class _EmptyFlareList extends FlareListNotifier {
  @override
  List<Flare> build() => [];
}

class _EmptyCheckinList extends DailyCheckinListNotifier {
  @override
  List<DailyCheckin> build() => [];
}

class _EmptyAppointmentList extends AppointmentListNotifier {
  @override
  List<Appointment> build() => [];
}

class _EmptySymptomEntryList extends SymptomEntryListNotifier {
  @override
  List<SymptomEntry> build() => [];
}

class _EmptyVitalEntryList extends VitalEntryListNotifier {
  @override
  List<VitalEntry> build() => [];
}

class _EmptyDoseLogList extends DoseLogListNotifier {
  @override
  List<DoseLog> build() => [];
}

class _EmptyMealEntryList extends MealEntryListNotifier {
  @override
  List<MealEntry> build() => [];
}

class _EmptyActivityEntryList extends ActivityEntryListNotifier {
  @override
  List<ActivityEntry> build() => [];
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

List<Override> _overrides() => [
  profileListProvider.overrideWith(_FakeProfileList.new),
  activeProfileProvider.overrideWith(_FakeActiveProfile.new),
  conditionCatalogProvider.overrideWith(_FakeConditionCatalog.new),
  symptomCatalogProvider.overrideWith(_FakeSymptomCatalog.new),
  userConditionListProvider.overrideWith(_FakeUserConditions.new),
  userSymptomListProvider.overrideWith(_FakeUserSymptoms.new),
  medicationListProvider.overrideWith(_FakeMedicationList.new),
  activeProfileMedicationsProvider.overrideWith((ref) => _medications),
  journalEntryListProvider.overrideWith(_EmptyJournalList.new),
  sleepEntryListProvider.overrideWith(_EmptySleepList.new),
  firstLogPromptProvider.overrideWith(_FakeFirstLogPrompt.new),
  weatherOptInProvider.overrideWith(_FakeWeatherOptIn.new),
  flareListProvider.overrideWith(_EmptyFlareList.new),
  activeFlareProvider.overrideWith((ref) => null),
  dailyCheckinListProvider.overrideWith(_EmptyCheckinList.new),
  todayCheckinProvider.overrideWith((ref) => null),
  appointmentListProvider.overrideWith(_EmptyAppointmentList.new),
  activeProfileAppointmentsProvider.overrideWith((ref) => []),
  upcomingAppointmentsProvider.overrideWith((ref) => []),
  symptomEntryListProvider.overrideWith(_EmptySymptomEntryList.new),
  activeProfileSymptomEntriesProvider.overrideWith((ref) => []),
  vitalEntryListProvider.overrideWith(_EmptyVitalEntryList.new),
  activeProfileVitalEntriesProvider.overrideWith((ref) => []),
  doseLogListProvider.overrideWith(_EmptyDoseLogList.new),
  activeProfileDoseLogsProvider.overrideWith((ref) => []),
  mealEntryListProvider.overrideWith(_EmptyMealEntryList.new),
  activeProfileMealEntriesProvider.overrideWith((ref) => []),
  activityEntryListProvider.overrideWith(_EmptyActivityEntryList.new),
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

// On Android, convertFlutterSurfaceToImage() may only be called once per
// test: reset per-test via setUp below.
bool _surfaceConverted = false;

Future<void> _screenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  if (!_surfaceConverted) {
    await binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }
  await tester.pump();
  try {
    await binding.takeScreenshot(name);
  } on MissingPluginException {
    // Linux has no integration_test captureScreenshot plugin. The iOS and
    // Android driver path above is unchanged; this writes the same frame.
    await _writeDesktopPng(tester, name);
  }
  print('📸  $name');
}

/// Desktop fallback for [IntegrationTestWidgetsFlutterBinding.takeScreenshot].
Future<void> _writeDesktopPng(WidgetTester tester, String name) async {
  final element = tester.element(find.byType(HealthFlareApp));
  var renderObject = element.renderObject!;
  while (!renderObject.isRepaintBoundary) {
    final parent = renderObject.parent;
    if (parent == null) break;
    renderObject = parent;
  }
  if (renderObject.debugNeedsPaint) {
    await tester.pump();
  }
  final layer = renderObject.debugLayer! as OffsetLayer;
  final image = await layer.toImage(renderObject.paintBounds);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final dirPath =
      Platform.environment['SCREENSHOT_DIR'] ??
      '/workspace/screenshots/quick_log';
  final dir = Directory(dirPath);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final file = File('${dir.path}/$name.png');
  file.writeAsBytesSync(data!.buffer.asUint8List());
  print('saved ${file.path} (${file.lengthSync()} bytes)');
}

/// Boots the app, taps the dashboard's + button, optionally types [text],
/// then screenshots the resulting Quick Log sheet as [name].
Future<void> _shootQuickLog(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name, {
  String? text,
}) async {
  await tester.pumpWidget(
    ProviderScope(overrides: _overrides(), child: const HealthFlareApp()),
  );
  await _settle(tester);
  await tester.tap(find.byTooltip('Open quick log'));
  await _settle(tester);
  if (text != null) {
    await tester.enterText(find.byType(TextField), text);
    await _settle(tester);
  }
  await _screenshot(binding, tester, name);
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

  setUp(() => _surfaceConverted = false);

  group('quick log screenshots', () {
    testWidgets('01_default', (tester) async {
      await _shootQuickLog(binding, tester, '01_default');
    });

    testWidgets('02_meal', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '02_meal',
        text: 'Had grilled salmon with rice for dinner',
      );
    });

    testWidgets('03_symptom_keyword', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '03_symptom_keyword',
        text: 'Bad flare today, knees and wrists both swollen',
      );
    });

    testWidgets('04_vital', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '04_vital',
        text: 'Blood pressure was 128 over 84 this morning',
      );
    });

    testWidgets('05_medication', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '05_medication',
        text: 'Took tramadol for the pain',
      );
    });

    testWidgets('06_doctor_visit', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '06_doctor_visit',
        text: 'Saw Dr. Patel about my joint inflammation',
      );
    });

    testWidgets('07_sleep', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '07_sleep',
        text: 'Slept for 6 hours last night, woke up twice',
      );
    });

    // Condition catalogue match: not yet tracked (see _conditionCatalog).
    testWidgets('08_condition_catalogue', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '08_condition_catalogue',
        text: "Just found out I have Sjögren's syndrome",
      );
    });

    // Condition matched by acronym against a profile's own tracked
    // condition ("Chronic Fatigue Syndrome" → "CFS"): not in any catalogue.
    testWidgets('09_condition_tracked_acronym', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '09_condition_tracked_acronym',
        text: 'Rough CFS day today',
      );
    });

    // Generic diagnosis-status language: no catalogue/tracked name needed.
    testWidgets('10_condition_diagnosis_language', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '10_condition_diagnosis_language',
        text: 'Officially in remission as of this week',
      );
    });

    // Symptom catalogue match outside the generic keyword list.
    testWidgets('11_symptom_catalogue', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '11_symptom_catalogue',
        text: 'Photophobia again this afternoon',
      );
    });

    // Symptom matched against a profile's own previously-tracked custom
    // symptom ("Brain fog") rather than any keyword.
    testWidgets('12_symptom_tracked', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '12_symptom_tracked',
        text: 'Brain fog again, hard to focus',
      );
    });

    testWidgets('13_activity', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '13_activity',
        text: 'Walked the dog for 30 minutes, felt really hard going',
      );
    });

    testWidgets('14_flare', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '14_flare',
        text: 'Flare started today, pain 7/10',
      );
    });

    testWidgets('15_mood', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '15_mood',
        text: 'Feeling really low and anxious today',
      );
    });

    testWidgets('16_cycle', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '16_cycle',
        text: 'Period started, cramps 6/10',
      );
    });

    testWidgets('17_fluids', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '17_fluids',
        text: 'Drank two litres of water this afternoon',
      );
    });

    testWidgets('18_bowel', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '18_bowel',
        text: 'Bristol type 6 twice this morning',
      );
    });

    testWidgets('19_nap', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '19_nap',
        text: 'Had a 20 minute nap after lunch',
      );
    });

    testWidgets('20_peak_flow', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '20_peak_flow',
        text: 'Peak flow was 420 L/min this morning',
      );
    });

    testWidgets('21_missed_dose', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '21_missed_dose',
        text: 'Forgot my tramadol this morning',
      );
    });

    // Known drug with no matching medication on the profile: the chip can
    // still say Medication, but the button must say Add to Journal.
    testWidgets('22_journal_when_unmatched', (tester) async {
      await _shootQuickLog(
        binding,
        tester,
        '22_journal_when_unmatched',
        text: 'Took 400mg ibuprofen for the pain',
      );
    });
  });
}

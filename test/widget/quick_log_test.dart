import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/features/quick_log/quick_log_classifier.dart';
import 'package:health_flare/features/quick_log/widgets/quick_log_sheet.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/sleep_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';
import 'package:health_flare/models/vital_type.dart';
import 'package:health_flare/models/weather_snapshot.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Sarah')];
}

class _FakeMealList extends MealEntryListNotifier {
  @override
  List<MealEntry> build() => [];
}

class _FakeSymptomList extends SymptomEntryListNotifier {
  @override
  List<SymptomEntry> build() => [];
}

class _FakeJournalList extends JournalEntryListNotifier {
  @override
  List<JournalEntry> build() => [];

  @override
  Future<int> add({
    required int profileId,
    required DateTime createdAt,
    required JournalSnapshot firstSnapshot,
    int? mood,
    int? energyLevel,
    WeatherSnapshot? weatherSnapshot,
  }) async {
    journalCalls.add({'profileId': profileId, 'body': firstSnapshot.body});
    return 1;
  }
}

// Recorded add() calls, cleared before each structured-save test.
final journalCalls = <Map<String, Object?>>[];
final vitalCalls = <Map<String, Object?>>[];
final doseCalls = <Map<String, Object?>>[];
final sleepCalls = <Map<String, Object?>>[];

class _RecordingVitalList extends VitalEntryListNotifier {
  @override
  List<VitalEntry> build() => [];

  @override
  Future<int> add({
    required int profileId,
    required VitalType vitalType,
    required double value,
    double? value2,
    required String unit,
    required DateTime loggedAt,
    String? notes,
    int? flareIsarId,
  }) async {
    vitalCalls.add({
      'profileId': profileId,
      'vitalType': vitalType,
      'value': value,
      'value2': value2,
      'unit': unit,
      'notes': notes,
    });
    return 1;
  }
}

class _RecordingDoseList extends DoseLogListNotifier {
  @override
  List<DoseLog> build() => [];

  @override
  Future<int> add({
    required int profileId,
    required int medicationIsarId,
    required DateTime loggedAt,
    required double amount,
    required String unit,
    required String status,
    String? reason,
    String? effectiveness,
    String? notes,
    int? flareIsarId,
  }) async {
    doseCalls.add({
      'profileId': profileId,
      'medicationIsarId': medicationIsarId,
      'amount': amount,
      'unit': unit,
      'status': status,
      'notes': notes,
    });
    return 1;
  }
}

class _RecordingSleepList extends SleepEntryListNotifier {
  @override
  List<SleepEntry> build() => [];

  @override
  Future<void> add({
    required int profileId,
    required DateTime bedtime,
    required DateTime wakeTime,
    int? qualityRating,
    String? notes,
  }) async {
    sleepCalls.add({
      'profileId': profileId,
      'bedtime': bedtime,
      'wakeTime': wakeTime,
      'notes': notes,
    });
  }
}

class _FakeAppointmentList extends AppointmentListNotifier {
  @override
  List<Appointment> build() => [];
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

List<Override> _overrides({List<Medication> medications = const []}) => [
  activeProfileProvider.overrideWith(_FakeActiveProfile.new),
  profileListProvider.overrideWith(_FakeProfileList.new),
  activeProfileDataProvider.overrideWith(
    (ref) => Profile(id: 1, name: 'Sarah'),
  ),
  mealEntryListProvider.overrideWith(_FakeMealList.new),
  symptomEntryListProvider.overrideWith(_FakeSymptomList.new),
  journalEntryListProvider.overrideWith(_FakeJournalList.new),
  appointmentListProvider.overrideWith(_FakeAppointmentList.new),
  activeProfileAppointmentsProvider.overrideWith((ref) => []),
  upcomingAppointmentsProvider.overrideWith((ref) => []),
  vitalEntryListProvider.overrideWith(_RecordingVitalList.new),
  doseLogListProvider.overrideWith(_RecordingDoseList.new),
  sleepEntryListProvider.overrideWith(_RecordingSleepList.new),
  activeProfileMedicationsProvider.overrideWith((ref) => medications),
];

Widget _buildSheet({List<Medication> medications = const []}) {
  return ProviderScope(
    overrides: _overrides(medications: medications),
    child: MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => showQuickLogSheet(ctx),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(
  WidgetTester tester, {
  List<Medication> medications = const [],
}) async {
  await tester.pumpWidget(_buildSheet(medications: medications));
  await tester.pump();
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> _typeAndSave(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

Medication _medication(int id, String name) => Medication(
  id: id,
  profileId: 1,
  name: name,
  medicationType: 'medication',
  doseAmount: 400,
  doseUnit: 'mg',
  frequency: 'asNeeded',
  startDate: DateTime(2026),
  createdAt: DateTime(2026),
);

// ---------------------------------------------------------------------------
// QuickLogClassifier — unit tests
// ---------------------------------------------------------------------------

void main() {
  group('QuickLogClassifier', () {
    test('returns null for fewer than 3 words', () {
      expect(QuickLogClassifier.classify(''), isNull);
      expect(QuickLogClassifier.classify('43'), isNull);
      expect(QuickLogClassifier.classify('feeling off'), isNull);
    });

    test('classifies meal keywords', () {
      expect(
        QuickLogClassifier.classify('Had grilled salmon with rice for dinner'),
        QuickLogEntryType.meal,
      );
      expect(
        QuickLogClassifier.classify('Ate a salad for lunch today'),
        QuickLogEntryType.meal,
      );
    });

    test('classifies symptom keywords', () {
      expect(
        QuickLogClassifier.classify(
          'Bad flare today knees and wrists both swollen',
        ),
        QuickLogEntryType.symptom,
      );
      expect(
        QuickLogClassifier.classify('Wrists really swollen and painful'),
        QuickLogEntryType.symptom,
      );
    });

    test('classifies vital patterns', () {
      expect(
        QuickLogClassifier.classify('Blood pressure was 128 over 84'),
        QuickLogEntryType.vital,
      );
      expect(
        QuickLogClassifier.classify('Heart rate 72 bpm this morning'),
        QuickLogEntryType.vital,
      );
    });

    test('classifies medication keywords', () {
      expect(
        QuickLogClassifier.classify('Took naproxen after lunch today'),
        QuickLogEntryType.medication,
      );
      expect(
        QuickLogClassifier.classify('Took 400mg ibuprofen at noon'),
        QuickLogEntryType.medication,
      );
    });

    test('medication takes priority over meal when both match', () {
      // "took" triggers medication before meal keywords
      expect(
        QuickLogClassifier.classify('Took naproxen after a big dinner'),
        QuickLogEntryType.medication,
      );
    });

    test('classifies doctor visit keywords', () {
      expect(
        QuickLogClassifier.classify('Saw Dr. Chen about my joint inflammation'),
        QuickLogEntryType.doctorVisit,
      );
      expect(
        QuickLogClassifier.classify('Hospital appointment tomorrow at noon'),
        QuickLogEntryType.doctorVisit,
      );
    });

    test('falls back to journal for reflective text', () {
      expect(
        QuickLogClassifier.classify(
          'Feeling overwhelmed but had a decent morning',
        ),
        QuickLogEntryType.journal,
      );
    });

    test('falls back to journal for unknown health context', () {
      expect(
        QuickLogClassifier.classify('Just found out I have fibromyalgia'),
        QuickLogEntryType.journal,
      );
    });

    test('returns null for short ambiguous text', () {
      expect(QuickLogClassifier.classify('43'), isNull);
    });

    test('classification updates as more text is added', () {
      // Short → null
      expect(QuickLogClassifier.classify('Tired'), isNull);
      // Longer symptom context → symptom
      expect(
        QuickLogClassifier.classify('Tired after eating the pasta today'),
        QuickLogEntryType.meal,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // QuickLogSheet widget tests
  // ---------------------------------------------------------------------------

  group('QuickLogSheet', () {
    testWidgets('shows profile attribution header', (tester) async {
      await _openSheet(tester);
      expect(find.text('Logging for Sarah'), findsOneWidget);
    });

    testWidgets('shows text field and save button', (tester) async {
      await _openSheet(tester);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('save button disabled when text field is empty', (
      tester,
    ) async {
      await _openSheet(tester);
      final btn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('save button disabled for whitespace only', (tester) async {
      await _openSheet(tester);
      await tester.enterText(find.byType(TextField), '     ');
      await tester.pump();
      final btn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('save button enabled when text is present', (tester) async {
      await _openSheet(tester);
      await tester.enterText(
        find.byType(TextField),
        'Had soup for lunch today',
      );
      await tester.pump();
      final btn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('no type chip shown initially', (tester) async {
      await _openSheet(tester);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('Meal chip appears for meal text', (tester) async {
      await _openSheet(tester);
      await tester.enterText(
        find.byType(TextField),
        'Had grilled salmon with rice for dinner',
      );
      await tester.pump();
      expect(find.text('Meal'), findsOneWidget);
    });

    testWidgets('Symptom chip appears for symptom text', (tester) async {
      await _openSheet(tester);
      await tester.enterText(
        find.byType(TextField),
        'Wrists really swollen and painful today',
      );
      await tester.pump();
      expect(find.text('Symptom'), findsOneWidget);
    });

    testWidgets('Medication chip appears for medication text', (tester) async {
      await _openSheet(tester);
      await tester.enterText(
        find.byType(TextField),
        'Took 400mg ibuprofen at noon today',
      );
      await tester.pump();
      expect(find.text('Medication'), findsOneWidget);
    });

    testWidgets('Doctor Visit chip appears for doctor text', (tester) async {
      await _openSheet(tester);
      await tester.enterText(
        find.byType(TextField),
        'Saw Dr. Chen about my joint inflammation',
      );
      await tester.pump();
      expect(find.text('Doctor Visit'), findsOneWidget);
    });

    testWidgets('Add details link shown with chip', (tester) async {
      await _openSheet(tester);
      await tester.enterText(
        find.byType(TextField),
        'Had grilled salmon with rice for dinner',
      );
      await tester.pump();
      expect(find.text('Add details'), findsOneWidget);
    });

    testWidgets('no Add details link when no chip', (tester) async {
      await _openSheet(tester);
      expect(find.text('Add details'), findsNothing);
    });

    testWidgets('chip disappears when text is cleared', (tester) async {
      await _openSheet(tester);
      await tester.enterText(
        find.byType(TextField),
        'Had grilled salmon for dinner',
      );
      await tester.pump();
      expect(find.text('Meal'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('shows timestamp row', (tester) async {
      await _openSheet(tester);
      // Timestamp row shows clock icon + formatted date
      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    });

    testWidgets('empty sheet dismisses without confirmation', (tester) async {
      await _openSheet(tester);
      // Tap the X close button directly
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      // Sheet dismissed — no dialog
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Logging for Sarah'), findsNothing);
    });

    testWidgets('non-empty sheet shows discard dialog on close', (
      tester,
    ) async {
      await _openSheet(tester);
      await tester.enterText(find.byType(TextField), 'Half a thought for now');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Leave without saving?'), findsOneWidget);
      expect(find.text('Discard entry'), findsOneWidget);
      expect(find.text('Keep editing'), findsOneWidget);
    });

    testWidgets('Keep editing closes dialog and sheet stays open', (
      tester,
    ) async {
      await _openSheet(tester);
      await tester.enterText(find.byType(TextField), 'Half a thought for now');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.text('Logging for Sarah'), findsOneWidget);
    });

    testWidgets('Discard entry closes sheet without saving', (tester) async {
      await _openSheet(tester);
      await tester.enterText(find.byType(TextField), 'Half a thought for now');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard entry'));
      await tester.pumpAndSettle();
      expect(find.text('Logging for Sarah'), findsNothing);
    });
  });

  group('QuickLogSheet — structured saves', () {
    setUp(() {
      journalCalls.clear();
      vitalCalls.clear();
      doseCalls.clear();
      sleepCalls.clear();
    });

    testWidgets('Sleep chip appears for sleep text', (tester) async {
      await _openSheet(tester);
      await tester.enterText(
        find.byType(TextField),
        'Slept for 6 hours last night, woke up twice',
      );
      await tester.pump();
      expect(find.text('Sleep'), findsOneWidget);
    });

    testWidgets('blood pressure text saves a structured vital', (tester) async {
      await _openSheet(tester);
      await _typeAndSave(tester, 'Blood pressure was 128 over 84 this morning');

      expect(vitalCalls, hasLength(1));
      expect(vitalCalls.single['vitalType'], VitalType.bloodPressure);
      expect(vitalCalls.single['value'], 128);
      expect(vitalCalls.single['value2'], 84);
      expect(
        vitalCalls.single['notes'],
        'Blood pressure was 128 over 84 this morning',
      );
      expect(journalCalls, isEmpty);
    });

    testWidgets('unparseable vital text falls back to a journal entry', (
      tester,
    ) async {
      await _openSheet(tester);
      await _typeAndSave(tester, 'Reading was 500/400 somehow today');

      expect(vitalCalls, isEmpty);
      expect(journalCalls, hasLength(1));
      expect(journalCalls.single['body'], 'Reading was 500/400 somehow today');
    });

    testWidgets('known medication text logs a taken dose', (tester) async {
      await _openSheet(tester, medications: [_medication(7, 'Ibuprofen')]);
      await _typeAndSave(tester, 'Took ibuprofen after lunch');

      expect(doseCalls, hasLength(1));
      expect(doseCalls.single['medicationIsarId'], 7);
      expect(doseCalls.single['status'], 'taken');
      expect(doseCalls.single['amount'], 400);
      expect(doseCalls.single['unit'], 'mg');
      expect(doseCalls.single['notes'], 'Took ibuprofen after lunch');
      expect(journalCalls, isEmpty);
    });

    testWidgets('unknown medication text falls back to a journal entry', (
      tester,
    ) async {
      await _openSheet(tester, medications: [_medication(7, 'Ibuprofen')]);
      await _typeAndSave(tester, 'Took something for the pain');

      expect(doseCalls, isEmpty);
      expect(journalCalls, hasLength(1));
    });

    testWidgets('sleep text with a duration saves a sleep entry', (
      tester,
    ) async {
      await _openSheet(tester);
      await _typeAndSave(tester, 'Slept for 6 hours last night, woke up twice');

      expect(sleepCalls, hasLength(1));
      final bedtime = sleepCalls.single['bedtime'] as DateTime;
      final wakeTime = sleepCalls.single['wakeTime'] as DateTime;
      expect(wakeTime.difference(bedtime), const Duration(hours: 6));
      expect(
        sleepCalls.single['notes'],
        'Slept for 6 hours last night, woke up twice',
      );
      expect(journalCalls, isEmpty);
    });

    testWidgets('sleep text without a duration falls back to a journal entry', (
      tester,
    ) async {
      await _openSheet(tester);
      await _typeAndSave(tester, 'Terrible night, kept waking up');

      expect(sleepCalls, isEmpty);
      expect(journalCalls, hasLength(1));
    });
  });
}

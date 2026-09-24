import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/condition_provider.dart';
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
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/dose_log.dart';
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

final symptomSaveCalls = <Map<String, Object?>>[];

class _FakeSymptomList extends SymptomEntryListNotifier {
  _FakeSymptomList([this._data = const []]);
  final List<SymptomEntry> _data;

  @override
  List<SymptomEntry> build() => _data;

  @override
  Future<int> add({
    required int profileId,
    required String name,
    required int severity,
    required DateTime loggedAt,
    List<String> locations = const [],
    String? notes,
    int? userSymptomIsarId,
    int? userConditionIsarId,
    int? flareIsarId,
    WeatherSnapshot? weatherSnapshot,
  }) async {
    symptomSaveCalls.add({
      'profileId': profileId,
      'name': name,
      'severity': severity,
      'notes': notes,
    });
    return 1;
  }
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
    bool? isNap,
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

class _FakeConditionCatalog extends ConditionCatalogNotifier {
  _FakeConditionCatalog(this._data);
  final List<Condition> _data;

  @override
  List<Condition> build() => _data;
}

final conditionTrackCalls = <Map<String, Object?>>[];

class _RecordingUserConditionList extends UserConditionListNotifier {
  _RecordingUserConditionList(this._data);
  final List<UserCondition> _data;

  @override
  List<UserCondition> build() => _data;

  @override
  Future<void> add({
    required int conditionId,
    required String conditionName,
    DateTime? diagnosedAt,
    ConditionStatus status = ConditionStatus.active,
  }) async {
    conditionTrackCalls.add({
      'conditionId': conditionId,
      'conditionName': conditionName,
      'diagnosedAt': diagnosedAt,
      'status': status,
    });
  }

  @override
  Future<void> update(UserCondition updated) async {
    conditionUpdateCalls.add(updated);
  }
}

final conditionUpdateCalls = <UserCondition>[];

class _FakeSymptomCatalog extends SymptomCatalogNotifier {
  _FakeSymptomCatalog(this._data);
  final List<Symptom> _data;

  @override
  List<Symptom> build() => _data;
}

class _FakeUserSymptomList extends UserSymptomListNotifier {
  _FakeUserSymptomList(this._data);
  final List<UserSymptom> _data;

  @override
  List<UserSymptom> build() => _data;
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

List<Override> _overrides({
  List<Medication> medications = const [],
  List<Condition> conditionCatalog = const [],
  List<UserCondition> trackedConditions = const [],
  List<Symptom> symptomCatalog = const [],
  List<UserSymptom> trackedSymptoms = const [],
  List<SymptomEntry> loggedSymptoms = const [],
}) => [
  activeProfileProvider.overrideWith(_FakeActiveProfile.new),
  profileListProvider.overrideWith(_FakeProfileList.new),
  activeProfileDataProvider.overrideWith(
    (ref) => Profile(id: 1, name: 'Sarah'),
  ),
  mealEntryListProvider.overrideWith(_FakeMealList.new),
  symptomEntryListProvider.overrideWith(() => _FakeSymptomList(loggedSymptoms)),
  journalEntryListProvider.overrideWith(_FakeJournalList.new),
  appointmentListProvider.overrideWith(_FakeAppointmentList.new),
  activeProfileAppointmentsProvider.overrideWith((ref) => []),
  upcomingAppointmentsProvider.overrideWith((ref) => []),
  vitalEntryListProvider.overrideWith(_RecordingVitalList.new),
  doseLogListProvider.overrideWith(_RecordingDoseList.new),
  sleepEntryListProvider.overrideWith(_RecordingSleepList.new),
  activeProfileMedicationsProvider.overrideWith((ref) => medications),
  conditionCatalogProvider.overrideWith(
    () => _FakeConditionCatalog(conditionCatalog),
  ),
  userConditionListProvider.overrideWith(
    () => _RecordingUserConditionList(trackedConditions),
  ),
  symptomCatalogProvider.overrideWith(
    () => _FakeSymptomCatalog(symptomCatalog),
  ),
  userSymptomListProvider.overrideWith(
    () => _FakeUserSymptomList(trackedSymptoms),
  ),
];

Widget _buildSheet({
  List<Medication> medications = const [],
  List<Condition> conditionCatalog = const [],
  List<UserCondition> trackedConditions = const [],
  List<Symptom> symptomCatalog = const [],
  List<UserSymptom> trackedSymptoms = const [],
  List<SymptomEntry> loggedSymptoms = const [],
}) {
  return ProviderScope(
    overrides: _overrides(
      medications: medications,
      conditionCatalog: conditionCatalog,
      trackedConditions: trackedConditions,
      symptomCatalog: symptomCatalog,
      trackedSymptoms: trackedSymptoms,
      loggedSymptoms: loggedSymptoms,
    ),
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
  List<Condition> conditionCatalog = const [],
  List<UserCondition> trackedConditions = const [],
  List<Symptom> symptomCatalog = const [],
  List<UserSymptom> trackedSymptoms = const [],
  List<SymptomEntry> loggedSymptoms = const [],
}) async {
  await tester.pumpWidget(
    _buildSheet(
      medications: medications,
      conditionCatalog: conditionCatalog,
      trackedConditions: trackedConditions,
      symptomCatalog: symptomCatalog,
      trackedSymptoms: trackedSymptoms,
      loggedSymptoms: loggedSymptoms,
    ),
  );
  await tester.pump();
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> _typeAndSave(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.byType(FilledButton));
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
// QuickLogClassifier: unit tests
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

    test('classifies a height reading in centimetres', () {
      expect(
        QuickLogClassifier.classify('157cm height'),
        QuickLogEntryType.vital,
      );
    });

    test('classifies a pulse reading with no explicit bpm unit', () {
      expect(QuickLogClassifier.classify('HR 72'), QuickLogEntryType.vital);
      expect(
        QuickLogClassifier.classify('Pulse 72 today'),
        QuickLogEntryType.vital,
      );
      expect(
        QuickLogClassifier.classify('72 beats per minute'),
        QuickLogEntryType.vital,
      );
    });

    test('does not classify an unrelated slash number as a vital reading', () {
      // "ate"/"sandwich" still classify it as a meal: the point is that
      // the unbounded "3/4" no longer wins the vital check first, so the
      // chip agrees with what actually gets saved.
      expect(
        QuickLogClassifier.classify('Ate 3/4 of a sandwich for lunch'),
        QuickLogEntryType.meal,
      );
      expect(
        QuickLogClassifier.classify('Appointment on 9/17 confirmed today'),
        isNot(QuickLogEntryType.vital),
      );
    });

    test('classifies short vital readings without the word-count minimum', () {
      expect(QuickLogClassifier.classify('74kg'), QuickLogEntryType.vital);
      expect(QuickLogClassifier.classify('144cm'), QuickLogEntryType.vital);
      expect(QuickLogClassifier.classify('4\'8"'), QuickLogEntryType.vital);
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

    testWidgets('shows text field and primary button', (tester) async {
      await _openSheet(tester);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Add to Journal'), findsOneWidget);
    });

    testWidgets('primary button disabled when text field is empty', (
      tester,
    ) async {
      await _openSheet(tester);
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('primary button disabled for whitespace only', (tester) async {
      await _openSheet(tester);
      await tester.enterText(find.byType(TextField), '     ');
      await tester.pump();
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('primary button enabled when text is present', (tester) async {
      await _openSheet(tester);
      await tester.enterText(
        find.byType(TextField),
        'Had soup for lunch today',
      );
      await tester.pump();
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
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

    testWidgets('Condition chip appears for a known catalogue condition', (
      tester,
    ) async {
      await _openSheet(
        tester,
        conditionCatalog: [const Condition(id: 1, name: 'Fibromyalgia')],
      );
      await tester.enterText(
        find.byType(TextField),
        'Just found out I have fibromyalgia',
      );
      await tester.pump();
      expect(find.text('Condition'), findsOneWidget);
    });

    testWidgets(
      'Condition chip appears for a previously-tracked custom condition',
      (tester) async {
        await _openSheet(
          tester,
          trackedConditions: [
            UserCondition(
              id: 1,
              profileId: 1,
              conditionId: 9,
              conditionName: 'Myalgic encephalomyelitis',
              trackedSince: DateTime(2026),
            ),
          ],
        );
        await tester.enterText(find.byType(TextField), 'Rough ME day today');
        await tester.pump();
        expect(find.text('Condition'), findsOneWidget);
      },
    );

    testWidgets('Symptom chip appears for a catalogue symptom not in the '
        'generic keyword list', (tester) async {
      await _openSheet(
        tester,
        symptomCatalog: [const Symptom(id: 1, name: 'Photophobia')],
      );
      await tester.enterText(
        find.byType(TextField),
        'Photophobia again this afternoon',
      );
      await tester.pump();
      expect(find.text('Symptom'), findsOneWidget);
    });

    testWidgets('Symptom chip appears for a previously-created custom '
        'symptom', (tester) async {
      await _openSheet(
        tester,
        trackedSymptoms: [
          UserSymptom(
            id: 1,
            profileId: 1,
            symptomId: 4,
            symptomName: 'Brain fog',
            trackedSince: DateTime(2026),
          ),
        ],
      );
      await tester.enterText(
        find.byType(TextField),
        'Brain fog again, hard to focus',
      );
      await tester.pump();
      expect(find.text('Symptom'), findsOneWidget);
    });

    // Regression: a symptom logged only via the standalone "Log symptom"
    // full form never creates a UserSymptom record (only a SymptomEntry.name
    // string: see recentSymptomNamesProvider), so it must still be
    // recognised here through the profile's logged symptom-entry history,
    // not just the UserSymptom catalogue.
    testWidgets(
      'Symptom chip appears for a symptom only ever logged via the full '
      'entry form (no UserSymptom record)',
      (tester) async {
        await _openSheet(
          tester,
          loggedSymptoms: [
            SymptomEntry(
              id: 1,
              profileId: 1,
              name: 'Brain fog',
              severity: 4,
              loggedAt: DateTime(2026, 1, 1),
              createdAt: DateTime(2026, 1, 1),
            ),
          ],
        );
        await tester.enterText(find.byType(TextField), 'Brain Fog again');
        await tester.pump();
        expect(find.text('Symptom'), findsOneWidget);
      },
    );

    testWidgets('primary button defaults to "Add to Journal"', (tester) async {
      await _openSheet(tester);
      expect(find.text('Add to Journal'), findsOneWidget);
    });

    testWidgets('primary button names the detected quick-add type', (
      tester,
    ) async {
      await _openSheet(tester);
      await tester.enterText(
        find.byType(TextField),
        'Had grilled salmon with rice for dinner',
      );
      await tester.pump();
      expect(find.text('Quick Add: Meal'), findsOneWidget);
    });

    testWidgets('primary button relabels live as the type chip updates', (
      tester,
    ) async {
      await _openSheet(tester);
      await tester.enterText(find.byType(TextField), 'Tired');
      await tester.pump();
      expect(find.text('Add to Journal'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        'Tired after eating the pasta today',
      );
      await tester.pump();
      expect(find.text('Quick Add: Meal'), findsOneWidget);
    });

    testWidgets(
      'primary button and Add details link are never worded the same',
      (tester) async {
        await _openSheet(tester);
        await tester.enterText(
          find.byType(TextField),
          'Had grilled salmon with rice for dinner',
        );
        await tester.pump();
        expect(find.text('Quick Add: Meal'), findsOneWidget);
        expect(find.text('Add details'), findsOneWidget);
      },
    );

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
      // Sheet dismissed: no dialog
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

  group('QuickLogSheet: structured saves', () {
    setUp(() {
      journalCalls.clear();
      vitalCalls.clear();
      doseCalls.clear();
      sleepCalls.clear();
      conditionTrackCalls.clear();
      conditionUpdateCalls.clear();
      symptomSaveCalls.clear();
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

    testWidgets(
      'combined blood pressure and pulse text saves both structured vitals',
      (tester) async {
        await _openSheet(tester);
        await _typeAndSave(tester, 'BP 118/76, pulse 68bpm');

        expect(vitalCalls, hasLength(2));
        expect(vitalCalls[0]['vitalType'], VitalType.bloodPressure);
        expect(vitalCalls[0]['value'], 118);
        expect(vitalCalls[0]['value2'], 76);
        expect(vitalCalls[1]['vitalType'], VitalType.heartRate);
        expect(vitalCalls[1]['value'], 68);
        expect(journalCalls, isEmpty);
      },
    );

    testWidgets('pulse text with no bpm unit saves a structured heart rate', (
      tester,
    ) async {
      await _openSheet(tester);
      await _typeAndSave(tester, 'Pulse 72 today');

      expect(vitalCalls, hasLength(1));
      expect(vitalCalls.single['vitalType'], VitalType.heartRate);
      expect(vitalCalls.single['value'], 72);
      expect(journalCalls, isEmpty);
    });

    testWidgets('height text in centimetres saves a structured vital', (
      tester,
    ) async {
      await _openSheet(tester);
      await _typeAndSave(tester, '157cm height');

      expect(vitalCalls, hasLength(1));
      expect(vitalCalls.single['vitalType'], VitalType.height);
      expect(vitalCalls.single['value'], 157);
      expect(vitalCalls.single['unit'], 'cm');
      expect(journalCalls, isEmpty);
    });

    testWidgets('a short weight-only entry saves a structured vital', (
      tester,
    ) async {
      await _openSheet(tester);
      await _typeAndSave(tester, '74kg');

      expect(vitalCalls, hasLength(1));
      expect(vitalCalls.single['vitalType'], VitalType.weight);
      expect(vitalCalls.single['value'], 74);
      expect(vitalCalls.single['unit'], 'kg');
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

    testWidgets('pain without a named drug saves a symptom', (tester) async {
      await _openSheet(tester, medications: [_medication(7, 'Ibuprofen')]);
      await _typeAndSave(tester, 'Took something for the pain');

      expect(doseCalls, isEmpty);
      expect(journalCalls, isEmpty);
      expect(symptomSaveCalls, hasLength(1));
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

    testWidgets('sleep text with a 12-hour time range saves a sleep entry', (
      tester,
    ) async {
      await _openSheet(tester);
      await _typeAndSave(tester, 'slept 8pm to 4am');

      expect(sleepCalls, hasLength(1));
      final bedtime = sleepCalls.single['bedtime'] as DateTime;
      final wakeTime = sleepCalls.single['wakeTime'] as DateTime;
      expect(bedtime.hour, 20);
      expect(wakeTime.hour, 4);
      expect(wakeTime.difference(bedtime), const Duration(hours: 8));
      expect(sleepCalls.single['notes'], 'slept 8pm to 4am');
      expect(journalCalls, isEmpty);
    });

    testWidgets('sleep text with a 24-hour time range saves a sleep entry', (
      tester,
    ) async {
      await _openSheet(tester);
      await _typeAndSave(tester, 'slept 20:00 to 4:00');

      expect(sleepCalls, hasLength(1));
      final bedtime = sleepCalls.single['bedtime'] as DateTime;
      final wakeTime = sleepCalls.single['wakeTime'] as DateTime;
      expect(bedtime.hour, 20);
      expect(wakeTime.hour, 4);
      expect(wakeTime.difference(bedtime), const Duration(hours: 8));
      expect(journalCalls, isEmpty);
    });

    testWidgets('Condition-typed save starts tracking the matched condition', (
      tester,
    ) async {
      await _openSheet(
        tester,
        conditionCatalog: [const Condition(id: 5, name: 'Fibromyalgia')],
      );
      await _typeAndSave(tester, 'Just found out I have fibromyalgia');

      expect(conditionTrackCalls, hasLength(1));
      expect(conditionTrackCalls.single['conditionId'], 5);
      expect(conditionTrackCalls.single['conditionName'], 'Fibromyalgia');
      expect(journalCalls, isEmpty);
    });

    testWidgets(
      'Condition-typed save is a no-op for an already-tracked condition',
      (tester) async {
        await _openSheet(
          tester,
          trackedConditions: [
            UserCondition(
              id: 1,
              profileId: 1,
              conditionId: 9,
              conditionName: 'Myalgic encephalomyelitis',
              trackedSince: DateTime(2026),
            ),
          ],
        );
        await _typeAndSave(tester, 'Rough ME day today');

        // Already tracked with no status-change language in the text:
        // nothing to add or update. (Falling back to a redundant add() call
        // would rely on the real notifier's own idempotency; skipping it
        // entirely here is the more correct behaviour.)
        expect(conditionTrackCalls, isEmpty);
        expect(conditionUpdateCalls, isEmpty);
        expect(journalCalls, isEmpty);
      },
    );

    testWidgets('"Just found out" language stamps a diagnosis date on a new '
        'condition', (tester) async {
      await _openSheet(
        tester,
        conditionCatalog: [const Condition(id: 5, name: 'Fibromyalgia')],
      );
      await _typeAndSave(tester, 'Just found out I have fibromyalgia');

      expect(conditionTrackCalls, hasLength(1));
      expect(conditionTrackCalls.single['diagnosedAt'], isNotNull);
    });

    testWidgets('a bare mention of an already-known condition does not guess a '
        'diagnosis date', (tester) async {
      await _openSheet(
        tester,
        conditionCatalog: [const Condition(id: 5, name: 'Fibromyalgia')],
      );
      await _typeAndSave(tester, 'Fibromyalgia flare again today');

      expect(conditionTrackCalls, hasLength(1));
      expect(conditionTrackCalls.single['diagnosedAt'], isNull);
    });

    testWidgets(
      'remission language on a tracked condition updates its status and '
      'history',
      (tester) async {
        await _openSheet(
          tester,
          trackedConditions: [
            UserCondition(
              id: 1,
              profileId: 1,
              conditionId: 9,
              conditionName: 'Myalgic encephalomyelitis',
              trackedSince: DateTime(2026),
            ),
          ],
        );
        await _typeAndSave(tester, 'Officially in remission from my ME now');

        expect(conditionTrackCalls, isEmpty);
        expect(conditionUpdateCalls, hasLength(1));
        final updated = conditionUpdateCalls.single;
        expect(updated.status, ConditionStatus.inRecovery);
        expect(updated.statusHistory, hasLength(1));
        expect(updated.statusHistory.single.eventType, 'recovery');
      },
    );

    testWidgets('Symptom-typed save resolves to the canonical tracked name and '
        'keeps the typed text as notes', (tester) async {
      await _openSheet(
        tester,
        trackedSymptoms: [
          UserSymptom(
            id: 1,
            profileId: 1,
            symptomId: 4,
            symptomName: 'Brain fog',
            trackedSince: DateTime(2026),
          ),
        ],
      );
      await _typeAndSave(tester, 'Bad brain fog again, hard to focus');

      expect(symptomSaveCalls, hasLength(1));
      expect(symptomSaveCalls.single['name'], 'Brain fog');
      expect(
        symptomSaveCalls.single['notes'],
        'Bad brain fog again, hard to focus',
      );
    });

    testWidgets(
      'Symptom-typed save with no canonical match saves the raw text as '
      'the name, with no redundant notes',
      (tester) async {
        await _openSheet(tester);
        await _typeAndSave(tester, 'Sharp pain in my left foot');

        expect(symptomSaveCalls, hasLength(1));
        expect(symptomSaveCalls.single['name'], 'Sharp pain in my left foot');
        expect(symptomSaveCalls.single['notes'], isNull);
      },
    );

    testWidgets('Symptom-typed save parses an explicit severity scale', (
      tester,
    ) async {
      await _openSheet(tester);
      await _typeAndSave(tester, 'Joint pain 8/10 today, hard to walk');

      expect(symptomSaveCalls, hasLength(1));
      expect(symptomSaveCalls.single['severity'], 8);
    });

    testWidgets(
      'Symptom-typed save maps a qualitative severity word when no scale '
      'is given',
      (tester) async {
        await _openSheet(tester);
        await _typeAndSave(tester, 'Mild headache this afternoon');

        expect(symptomSaveCalls, hasLength(1));
        expect(symptomSaveCalls.single['severity'], 3);
      },
    );

    testWidgets('Symptom-typed save defaults severity to 5 when nothing can be '
        'parsed', (tester) async {
      await _openSheet(tester);
      await _typeAndSave(tester, 'Knees and wrists both swollen again');

      expect(symptomSaveCalls, hasLength(1));
      expect(symptomSaveCalls.single['severity'], 5);
    });
  });
}

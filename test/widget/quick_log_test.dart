import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/features/quick_log/quick_log_classifier.dart';
import 'package:health_flare/features/quick_log/widgets/quick_log_sheet.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/symptom_entry.dart';

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
}

class _FakeAppointmentList extends AppointmentListNotifier {
  @override
  List<Appointment> build() => [];
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

List<Override> _overrides() => [
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
];

Widget _buildSheet() {
  return ProviderScope(
    overrides: _overrides(),
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

Future<void> _openSheet(WidgetTester tester) async {
  await tester.pumpWidget(_buildSheet());
  await tester.pump();
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

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
}

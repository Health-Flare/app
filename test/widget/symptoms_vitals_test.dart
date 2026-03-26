import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/features/symptoms_vitals/screens/symptom_entry_form_screen.dart';
import 'package:health_flare/features/symptoms_vitals/screens/symptoms_vitals_screen.dart';
import 'package:health_flare/features/symptoms_vitals/screens/vital_entry_form_screen.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';
import 'package:health_flare/models/vital_type.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeSymptomList extends SymptomEntryListNotifier {
  _FakeSymptomList({this.entries = const []});
  final List<SymptomEntry> entries;

  @override
  List<SymptomEntry> build() => entries;
}

class _FakeVitalList extends VitalEntryListNotifier {
  _FakeVitalList({this.entries = const []});
  final List<VitalEntry> entries;

  @override
  List<VitalEntry> build() => entries;
}

class _FakeActiveProfile extends ActiveProfileNotifier {
  @override
  int? build() => 1;
}

class _FakeProfileList extends ProfileListNotifier {
  @override
  List<Profile> build() => [Profile(id: 1, name: 'Sarah')];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _sarah = Profile(id: 1, name: 'Sarah');

Widget _buildListScreen({
  List<SymptomEntry> symptoms = const [],
  List<VitalEntry> vitals = const [],
}) {
  return ProviderScope(
    overrides: [
      symptomEntryListProvider.overrideWith(
        () => _FakeSymptomList(entries: symptoms),
      ),
      vitalEntryListProvider.overrideWith(
        () => _FakeVitalList(entries: vitals),
      ),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith((ref) => _sarah),
      activeProfileSymptomEntriesProvider.overrideWith(
        (ref) =>
            ([...symptoms]..sort((a, b) => b.loggedAt.compareTo(a.loggedAt))),
      ),
      activeProfileVitalEntriesProvider.overrideWith(
        (ref) =>
            ([...vitals]..sort((a, b) => b.loggedAt.compareTo(a.loggedAt))),
      ),
    ],
    child: const MaterialApp(home: SymptomsVitalsScreen()),
  );
}

Widget _buildSymptomForm({SymptomEntry? entry}) {
  return ProviderScope(
    overrides: [
      symptomEntryListProvider.overrideWith(_FakeSymptomList.new),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith((ref) => _sarah),
    ],
    child: MaterialApp(home: SymptomEntryFormScreen(entry: entry)),
  );
}

Widget _buildVitalForm({VitalEntry? entry}) {
  return ProviderScope(
    overrides: [
      vitalEntryListProvider.overrideWith(_FakeVitalList.new),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith((ref) => _sarah),
    ],
    child: MaterialApp(home: VitalEntryFormScreen(entry: entry)),
  );
}

// ---------------------------------------------------------------------------
// SymptomsVitalsScreen — list screen
// ---------------------------------------------------------------------------

void main() {
  group('SymptomsVitalsScreen', () {
    testWidgets('shows symptom empty state when no entries', (tester) async {
      await tester.pumpWidget(_buildListScreen());
      await tester.pump();

      expect(find.text('No symptoms logged yet'), findsOneWidget);
    });

    testWidgets('switches to vitals tab and shows empty state', (tester) async {
      await tester.pumpWidget(_buildListScreen());
      await tester.pump();

      await tester.tap(find.text('Vitals'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No vitals logged yet'), findsOneWidget);
    });

    testWidgets('shows symptom entries in reverse chronological order', (
      tester,
    ) async {
      final entries = [
        SymptomEntry(
          id: 1,
          profileId: 1,
          name: 'Headache',
          severity: 7,
          loggedAt: DateTime(2026, 2, 15, 8, 0),
          createdAt: DateTime(2026, 2, 15, 8, 0),
        ),
        SymptomEntry(
          id: 2,
          profileId: 1,
          name: 'Nausea',
          severity: 3,
          loggedAt: DateTime(2026, 2, 17, 9, 30),
          createdAt: DateTime(2026, 2, 17, 9, 30),
        ),
      ];

      await tester.pumpWidget(_buildListScreen(symptoms: entries));
      await tester.pump();

      expect(find.text('Nausea'), findsOneWidget);
      expect(find.text('Headache'), findsOneWidget);

      // Nausea (more recent) should appear first — verify tile ordering
      final nauseaOffset = tester.getTopLeft(find.text('Nausea')).dy;
      final headacheOffset = tester.getTopLeft(find.text('Headache')).dy;
      expect(nauseaOffset, lessThan(headacheOffset));
    });

    testWidgets('shows vital entries on vitals tab', (tester) async {
      final vitals = [
        VitalEntry(
          id: 1,
          profileId: 1,
          vitalType: VitalType.heartRate,
          value: 72,
          unit: 'BPM',
          loggedAt: DateTime(2026, 2, 15, 8, 0),
          createdAt: DateTime(2026, 2, 15, 8, 0),
        ),
      ];

      await tester.pumpWidget(_buildListScreen(vitals: vitals));
      await tester.pump();

      await tester.tap(find.text('Vitals'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('72 BPM'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // SymptomEntryFormScreen
  // ---------------------------------------------------------------------------

  group('SymptomEntryFormScreen', () {
    testWidgets('shows "Logging for Sarah" label', (tester) async {
      await tester.pumpWidget(_buildSymptomForm());
      await tester.pump();

      expect(find.text('Logging for Sarah'), findsOneWidget);
    });

    testWidgets('renders symptom name and severity fields', (tester) async {
      await tester.pumpWidget(_buildSymptomForm());
      await tester.pump();

      expect(find.byKey(const Key('symptom_name_field')), findsOneWidget);
      expect(find.byKey(const Key('severity_selector')), findsOneWidget);
    });

    testWidgets('shows severity buttons 1–10', (tester) async {
      await tester.pumpWidget(_buildSymptomForm());
      await tester.pump();

      for (final n in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']) {
        expect(
          find.descendant(
            of: find.byKey(const Key('severity_selector')),
            matching: find.text(n),
          ),
          findsOneWidget,
          reason: 'Severity button $n not found',
        );
      }
    });

    testWidgets('shows save button', (tester) async {
      await tester.pumpWidget(_buildSymptomForm());
      await tester.pump();

      expect(find.text('Add to profile'), findsOneWidget);
    });

    testWidgets('shows validation error when name is empty', (tester) async {
      await tester.pumpWidget(_buildSymptomForm());
      await tester.pump();

      // Tap a severity
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('severity_selector')),
          matching: find.text('5'),
        ),
      );
      await tester.pump();

      // Tap save without entering a name
      await tester.tap(find.text('Add to profile'));
      await tester.pump();

      expect(find.text('Symptom name is required'), findsOneWidget);
    });

    testWidgets('shows validation error when severity not set', (tester) async {
      await tester.pumpWidget(_buildSymptomForm());
      await tester.pump();

      // Enter a name but no severity
      await tester.enterText(
        find.byKey(const Key('symptom_name_field')),
        'Headache',
      );
      await tester.pump();

      // Tap save without selecting severity
      await tester.tap(find.text('Add to profile'));
      await tester.pump();

      expect(find.text('Severity is required'), findsOneWidget);
    });

    testWidgets('accepts notes input', (tester) async {
      await tester.pumpWidget(_buildSymptomForm());
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('symptom_notes_field')),
        'Worse after eating',
      );
      await tester.pump();

      expect(find.text('Worse after eating'), findsOneWidget);
    });

    testWidgets('edit mode shows "Edit symptom" title and "Save changes"', (
      tester,
    ) async {
      final entry = SymptomEntry(
        id: 1,
        profileId: 1,
        name: 'Fatigue',
        severity: 6,
        loggedAt: DateTime(2026, 2, 15, 8, 0),
        createdAt: DateTime(2026, 2, 15, 8, 0),
      );

      await tester.pumpWidget(_buildSymptomForm(entry: entry));
      await tester.pump();

      expect(find.text('Edit symptom'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('edit mode pre-fills name field', (tester) async {
      final entry = SymptomEntry(
        id: 1,
        profileId: 1,
        name: 'Migraine',
        severity: 9,
        notes: 'Visual aura for 20 mins',
        loggedAt: DateTime(2026, 2, 15, 8, 0),
        createdAt: DateTime(2026, 2, 15, 8, 0),
      );

      await tester.pumpWidget(_buildSymptomForm(entry: entry));
      await tester.pump();

      expect(find.text('Migraine'), findsOneWidget);
      expect(find.text('Visual aura for 20 mins'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // VitalEntryFormScreen
  // ---------------------------------------------------------------------------

  group('VitalEntryFormScreen', () {
    testWidgets('shows "Logging for Sarah" label', (tester) async {
      await tester.pumpWidget(_buildVitalForm());
      await tester.pump();

      expect(find.text('Logging for Sarah'), findsOneWidget);
    });

    testWidgets('renders vital type dropdown and value field', (tester) async {
      await tester.pumpWidget(_buildVitalForm());
      await tester.pump();

      expect(find.byKey(const Key('vital_type_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('vital_value_field')), findsOneWidget);
    });

    testWidgets('shows save button', (tester) async {
      await tester.pumpWidget(_buildVitalForm());
      await tester.pump();

      expect(find.text('Add to profile'), findsOneWidget);
    });

    testWidgets('shows validation error when value is empty', (tester) async {
      await tester.pumpWidget(_buildVitalForm());
      await tester.pump();

      // Tap save without entering a value
      await tester.tap(find.text('Add to profile'));
      await tester.pump();

      expect(find.text('Enter a valid number'), findsOneWidget);
    });

    testWidgets('accepts value input', (tester) async {
      await tester.pumpWidget(_buildVitalForm());
      await tester.pump();

      await tester.enterText(find.byKey(const Key('vital_value_field')), '88');
      await tester.pump();

      // Check the text field contains the entered value
      final field = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('vital_value_field')),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.controller.text, '88');
    });

    testWidgets('blood pressure shows two value fields', (tester) async {
      final entry = VitalEntry(
        id: 1,
        profileId: 1,
        vitalType: VitalType.bloodPressure,
        value: 120,
        value2: 80,
        unit: 'mmHg',
        loggedAt: DateTime(2026, 2, 15, 8, 0),
        createdAt: DateTime(2026, 2, 15, 8, 0),
      );

      await tester.pumpWidget(_buildVitalForm(entry: entry));
      await tester.pump();

      expect(find.byKey(const Key('vital_value_field')), findsOneWidget);
      expect(find.byKey(const Key('vital_value2_field')), findsOneWidget);
    });

    testWidgets('edit mode shows "Edit vital" title and "Save changes"', (
      tester,
    ) async {
      final entry = VitalEntry(
        id: 1,
        profileId: 1,
        vitalType: VitalType.weight,
        value: 68,
        unit: 'kg',
        loggedAt: DateTime(2026, 2, 15, 8, 0),
        createdAt: DateTime(2026, 2, 15, 8, 0),
      );

      await tester.pumpWidget(_buildVitalForm(entry: entry));
      await tester.pump();

      expect(find.text('Edit vital'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('edit mode pre-fills value', (tester) async {
      final entry = VitalEntry(
        id: 1,
        profileId: 1,
        vitalType: VitalType.weight,
        value: 68,
        unit: 'kg',
        loggedAt: DateTime(2026, 2, 15, 8, 0),
        createdAt: DateTime(2026, 2, 15, 8, 0),
      );

      await tester.pumpWidget(_buildVitalForm(entry: entry));
      await tester.pump();

      expect(find.text('68'), findsOneWidget);
    });

    testWidgets('accepts notes input', (tester) async {
      await tester.pumpWidget(_buildVitalForm());
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('vital_notes_field')),
        'Taken after exercise',
      );
      await tester.pump();

      expect(find.text('Taken after exercise'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // VitalEntry.displayValue unit tests
  // ---------------------------------------------------------------------------

  group('VitalEntry.displayValue', () {
    test('formats whole number without decimals', () {
      final entry = VitalEntry(
        id: 1,
        profileId: 1,
        vitalType: VitalType.heartRate,
        value: 72,
        unit: 'BPM',
        loggedAt: DateTime(2026, 2, 15),
        createdAt: DateTime(2026, 2, 15),
      );
      expect(entry.displayValue, '72 BPM');
    });

    test('formats decimal value with decimal point', () {
      final entry = VitalEntry(
        id: 1,
        profileId: 1,
        vitalType: VitalType.temperature,
        value: 37.2,
        unit: '°C',
        loggedAt: DateTime(2026, 2, 15),
        createdAt: DateTime(2026, 2, 15),
      );
      expect(entry.displayValue, '37.2 °C');
    });

    test('formats blood pressure with slash notation', () {
      final entry = VitalEntry(
        id: 1,
        profileId: 1,
        vitalType: VitalType.bloodPressure,
        value: 120,
        value2: 80,
        unit: 'mmHg',
        loggedAt: DateTime(2026, 2, 15),
        createdAt: DateTime(2026, 2, 15),
      );
      expect(entry.displayValue, '120/80 mmHg');
    });
  });
}

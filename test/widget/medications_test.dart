import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/medications/screens/dose_log_form_screen.dart';
import 'package:health_flare/features/medications/screens/medication_form_screen.dart';
import 'package:health_flare/features/medications/screens/medications_screen.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/profile.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeMedicationList extends MedicationListNotifier {
  _FakeMedicationList({this.meds = const []});
  final List<Medication> meds;

  @override
  List<Medication> build() => meds;
}

class _FakeDoseLogList extends DoseLogListNotifier {
  _FakeDoseLogList({this.logs = const []});
  final List<DoseLog> logs;

  @override
  List<DoseLog> build() => logs;
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
// Test data
// ---------------------------------------------------------------------------

final _sarah = Profile(id: 1, name: 'Sarah');
final _now = DateTime(2026, 3, 1);

Medication _med({
  int id = 1,
  String name = 'Metformin',
  String type = 'medication',
  double dose = 500,
  String unit = 'mg',
  String frequency = 'twice_daily',
  DateTime? endDate,
}) => Medication(
  id: id,
  profileId: 1,
  name: name,
  medicationType: type,
  doseAmount: dose,
  doseUnit: unit,
  frequency: frequency,
  startDate: DateTime(2026, 1, 1),
  endDate: endDate,
  createdAt: _now,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildListScreen({
  List<Medication> meds = const [],
  List<DoseLog> logs = const [],
}) {
  return ProviderScope(
    overrides: [
      medicationListProvider.overrideWith(
        () => _FakeMedicationList(meds: meds),
      ),
      doseLogListProvider.overrideWith(() => _FakeDoseLogList(logs: logs)),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith((ref) => _sarah),
      activeProfileMedicationsProvider.overrideWith(
        (ref) =>
            meds.where((m) => m.profileId == 1).toList()
              ..sort((a, b) => a.name.compareTo(b.name)),
      ),
      activeProfileActiveMedicationsProvider.overrideWith(
        (ref) => meds
            .where((m) => m.profileId == 1 && m.isActive && !m.isSupplement)
            .toList(),
      ),
      activeProfileDiscontinuedMedicationsProvider.overrideWith(
        (ref) => meds
            .where((m) => m.profileId == 1 && !m.isActive && !m.isSupplement)
            .toList(),
      ),
      activeProfileActiveSupplementsProvider.overrideWith(
        (ref) => meds
            .where((m) => m.profileId == 1 && m.isActive && m.isSupplement)
            .toList(),
      ),
      activeProfileDiscontinuedSupplementsProvider.overrideWith(
        (ref) => meds
            .where((m) => m.profileId == 1 && !m.isActive && m.isSupplement)
            .toList(),
      ),
    ],
    child: const MaterialApp(home: MedicationsScreen()),
  );
}

Widget _buildMedicationForm({Medication? medication}) {
  return ProviderScope(
    overrides: [
      medicationListProvider.overrideWith(_FakeMedicationList.new),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith((ref) => _sarah),
    ],
    child: MaterialApp(home: MedicationFormScreen(medication: medication)),
  );
}

Widget _buildDoseForm({required Medication med, DoseLog? doseLog}) {
  return ProviderScope(
    overrides: [
      doseLogListProvider.overrideWith(_FakeDoseLogList.new),
      activeProfileProvider.overrideWith(_FakeActiveProfile.new),
      profileListProvider.overrideWith(_FakeProfileList.new),
      activeProfileDataProvider.overrideWith((ref) => _sarah),
    ],
    child: MaterialApp(
      home: DoseLogFormScreen(medication: med, doseLog: doseLog),
    ),
  );
}

// ---------------------------------------------------------------------------
// MedicationsScreen — list screen
// ---------------------------------------------------------------------------

void main() {
  group('MedicationsScreen', () {
    testWidgets('shows empty state when no medications', (tester) async {
      await tester.pumpWidget(_buildListScreen());
      await tester.pump();

      expect(find.text('No medications yet'), findsOneWidget);
      expect(
        find.text('Tap + to add a medication or supplement'),
        findsOneWidget,
      );
    });

    testWidgets('shows medication name and dose in list', (tester) async {
      final meds = [_med()];

      await tester.pumpWidget(_buildListScreen(meds: meds));
      await tester.pump();

      expect(find.text('Metformin'), findsOneWidget);
      expect(find.textContaining('500 mg'), findsOneWidget);
    });

    testWidgets('medication appears under Medications section header', (
      tester,
    ) async {
      final meds = [_med()];

      await tester.pumpWidget(_buildListScreen(meds: meds));
      await tester.pump();

      // "Medications" appears in AppBar title + section header
      expect(find.text('Medications'), findsNWidgets(2));
    });

    testWidgets('supplement appears under Supplements section header', (
      tester,
    ) async {
      final meds = [_med(id: 2, name: 'Vitamin D3', type: 'supplement')];

      await tester.pumpWidget(_buildListScreen(meds: meds));
      await tester.pump();

      expect(find.text('Supplements'), findsOneWidget);
      expect(find.text('Vitamin D3'), findsOneWidget);
    });

    testWidgets('active and supplement sections are separate', (tester) async {
      final meds = [
        _med(id: 1, name: 'Metformin'),
        _med(id: 2, name: 'Vitamin D3', type: 'supplement'),
      ];

      await tester.pumpWidget(_buildListScreen(meds: meds));
      await tester.pump();

      // "Medications" appears in AppBar title + section header
      expect(find.text('Medications'), findsNWidgets(2));
      expect(find.text('Supplements'), findsOneWidget);
      expect(find.text('Metformin'), findsOneWidget);
      expect(find.text('Vitamin D3'), findsOneWidget);
    });

    testWidgets('discontinued section shows collapsed toggle', (tester) async {
      final pastDate = DateTime(2025, 12, 31);
      final meds = [_med(id: 1, name: 'Prednisolone', endDate: pastDate)];

      await tester.pumpWidget(_buildListScreen(meds: meds));
      await tester.pump();

      expect(find.textContaining('Discontinued (1)'), findsOneWidget);
      // Prednisolone should be hidden until expanded
      expect(find.text('Prednisolone'), findsNothing);
    });

    testWidgets('discontinued section expands on tap', (tester) async {
      final pastDate = DateTime(2025, 12, 31);
      final meds = [_med(id: 1, name: 'Prednisolone', endDate: pastDate)];

      await tester.pumpWidget(_buildListScreen(meds: meds));
      await tester.pump();

      await tester.tap(find.textContaining('Discontinued (1)'));
      await tester.pump();

      expect(find.text('Prednisolone'), findsOneWidget);
    });

    testWidgets('shows FAB for adding medication', (tester) async {
      await tester.pumpWidget(_buildListScreen());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // MedicationFormScreen
  // ---------------------------------------------------------------------------

  group('MedicationFormScreen', () {
    testWidgets('shows "Logging for Sarah" attribution', (tester) async {
      await tester.pumpWidget(_buildMedicationForm());
      await tester.pump();

      expect(find.text('Logging for Sarah'), findsOneWidget);
    });

    testWidgets('shows medication type toggle', (tester) async {
      await tester.pumpWidget(_buildMedicationForm());
      await tester.pump();

      expect(find.byKey(const Key('medication_type_toggle')), findsOneWidget);
    });

    testWidgets('renders name, dose, frequency fields', (tester) async {
      await tester.pumpWidget(_buildMedicationForm());
      await tester.pump();

      expect(find.byKey(const Key('medication_name_field')), findsOneWidget);
      expect(find.byKey(const Key('dose_amount_field')), findsOneWidget);
      expect(find.byKey(const Key('frequency_dropdown')), findsOneWidget);
    });

    testWidgets('shows "Add to profile" save button', (tester) async {
      await tester.pumpWidget(_buildMedicationForm());
      await tester.pump();

      expect(find.text('Add to profile'), findsOneWidget);
    });

    testWidgets('shows validation error when name is empty', (tester) async {
      await tester.pumpWidget(_buildMedicationForm());
      await tester.pump();

      await tester.tap(find.text('Add to profile'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('shows validation error when start date not set', (
      tester,
    ) async {
      await tester.pumpWidget(_buildMedicationForm());
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('medication_name_field')),
        'Metformin',
      );
      await tester.pump();

      await tester.tap(find.text('Add to profile'));
      await tester.pump();

      expect(find.text('Start date is required'), findsOneWidget);
    });

    testWidgets('edit mode shows "Edit medication" title and "Save changes"', (
      tester,
    ) async {
      await tester.pumpWidget(_buildMedicationForm(medication: _med()));
      await tester.pump();

      expect(find.text('Edit medication'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('edit mode pre-fills medication name', (tester) async {
      await tester.pumpWidget(_buildMedicationForm(medication: _med()));
      await tester.pump();

      expect(find.text('Metformin'), findsOneWidget);
    });

    testWidgets('edit mode shows delete icon button', (tester) async {
      await tester.pumpWidget(_buildMedicationForm(medication: _med()));
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('custom frequency shows label field', (tester) async {
      await tester.pumpWidget(_buildMedicationForm());
      await tester.pump();

      // Open frequency dropdown and select Custom
      await tester.tap(find.byKey(const Key('frequency_dropdown')));
      await tester.pump();
      await tester.tap(find.text('Custom').last);
      await tester.pump();

      expect(find.byKey(const Key('frequency_label_field')), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // DoseLogFormScreen
  // ---------------------------------------------------------------------------

  group('DoseLogFormScreen', () {
    testWidgets('shows "Logging for Sarah" attribution', (tester) async {
      await tester.pumpWidget(_buildDoseForm(med: _med()));
      await tester.pump();

      expect(find.text('Logging for Sarah'), findsOneWidget);
    });

    testWidgets('shows status segmented button', (tester) async {
      await tester.pumpWidget(_buildDoseForm(med: _med()));
      await tester.pump();

      expect(find.byKey(const Key('dose_status_toggle')), findsOneWidget);
      expect(find.text('Taken'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
      expect(find.text('Missed'), findsOneWidget);
    });

    testWidgets('pre-fills amount from medication defaults', (tester) async {
      await tester.pumpWidget(_buildDoseForm(med: _med()));
      await tester.pump();

      final field = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('dose_amount_field')),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.controller.text, '500');
    });

    testWidgets('shows effectiveness options', (tester) async {
      await tester.pumpWidget(_buildDoseForm(med: _med()));
      await tester.pump();

      expect(find.text('Helped a lot'), findsOneWidget);
      expect(find.text('Helped a little'), findsOneWidget);
      expect(find.text('No effect'), findsOneWidget);
      expect(find.text('Made it worse'), findsOneWidget);
    });

    testWidgets('reason field hidden when status is Taken', (tester) async {
      await tester.pumpWidget(_buildDoseForm(med: _med()));
      await tester.pump();

      expect(find.byKey(const Key('dose_reason_field')), findsNothing);
    });

    testWidgets('reason field shown when status is Skipped', (tester) async {
      await tester.pumpWidget(_buildDoseForm(med: _med()));
      await tester.pump();

      await tester.tap(find.text('Skipped'));
      await tester.pump();

      expect(find.byKey(const Key('dose_reason_field')), findsOneWidget);
    });

    testWidgets('reason field shown when status is Missed', (tester) async {
      await tester.pumpWidget(_buildDoseForm(med: _med()));
      await tester.pump();

      await tester.tap(find.text('Missed'));
      await tester.pump();

      expect(find.byKey(const Key('dose_reason_field')), findsOneWidget);
    });

    testWidgets('shows "Log dose" save button', (tester) async {
      await tester.pumpWidget(_buildDoseForm(med: _med()));
      await tester.pump();

      expect(find.text('Log dose'), findsOneWidget);
    });

    testWidgets('edit mode shows "Edit dose" title and "Save changes"', (
      tester,
    ) async {
      final log = DoseLog(
        id: 1,
        profileId: 1,
        medicationIsarId: 1,
        loggedAt: _now,
        createdAt: _now,
        amount: 500,
        unit: 'mg',
        status: 'taken',
      );

      await tester.pumpWidget(_buildDoseForm(med: _med(), doseLog: log));
      await tester.pump();

      expect(find.text('Edit dose'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('edit mode shows delete icon button', (tester) async {
      final log = DoseLog(
        id: 1,
        profileId: 1,
        medicationIsarId: 1,
        loggedAt: _now,
        createdAt: _now,
        amount: 500,
        unit: 'mg',
        status: 'taken',
      );

      await tester.pumpWidget(_buildDoseForm(med: _med(), doseLog: log));
      await tester.pump();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Medication domain model unit tests
  // ---------------------------------------------------------------------------

  group('Medication', () {
    test('isActive returns true when endDate is null', () {
      final m = _med();
      expect(m.isActive, isTrue);
    });

    test('isActive returns false when endDate is in the past', () {
      final m = _med(endDate: DateTime(2025, 1, 1));
      expect(m.isActive, isFalse);
    });

    test('isSupplement returns true for supplement type', () {
      final m = _med(type: 'supplement');
      expect(m.isSupplement, isTrue);
    });

    test('isSupplement returns false for medication type', () {
      final m = _med();
      expect(m.isSupplement, isFalse);
    });

    test('doseDisplay formats whole number without decimals', () {
      final m = _med(dose: 500, unit: 'mg');
      expect(m.doseDisplay, '500 mg');
    });

    test('frequencyDisplay returns human label for known keys', () {
      expect(_med(frequency: 'once_daily').frequencyDisplay, 'Once daily');
      expect(_med(frequency: 'twice_daily').frequencyDisplay, 'Twice daily');
      expect(
        _med(frequency: 'three_times_daily').frequencyDisplay,
        'Three times daily',
      );
      expect(_med(frequency: 'as_needed').frequencyDisplay, 'As needed');
      expect(_med(frequency: 'weekly').frequencyDisplay, 'Weekly');
    });
  });

  // ---------------------------------------------------------------------------
  // DoseLog domain model unit tests
  // ---------------------------------------------------------------------------

  group('DoseLog', () {
    DoseLog makeDoseLog({String status = 'taken', String? effectiveness}) =>
        DoseLog(
          id: 1,
          profileId: 1,
          medicationIsarId: 1,
          loggedAt: _now,
          createdAt: _now,
          amount: 500,
          unit: 'mg',
          status: status,
          effectiveness: effectiveness,
        );

    test('statusDisplay returns human label', () {
      expect(makeDoseLog(status: 'taken').statusDisplay, 'Taken');
      expect(makeDoseLog(status: 'skipped').statusDisplay, 'Skipped');
      expect(makeDoseLog(status: 'missed').statusDisplay, 'Missed');
    });

    test('effectivenessDisplay returns human label', () {
      expect(
        makeDoseLog(effectiveness: 'helped_a_lot').effectivenessDisplay,
        'Helped a lot',
      );
      expect(
        makeDoseLog(effectiveness: 'helped_a_little').effectivenessDisplay,
        'Helped a little',
      );
      expect(
        makeDoseLog(effectiveness: 'no_effect').effectivenessDisplay,
        'No effect',
      );
      expect(
        makeDoseLog(effectiveness: 'made_it_worse').effectivenessDisplay,
        'Made it worse',
      );
    });

    test('amountDisplay formats whole number without decimals', () {
      expect(makeDoseLog().amountDisplay, '500 mg');
    });
  });
}

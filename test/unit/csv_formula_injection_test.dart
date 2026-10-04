import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/features/reports/models/report_data.dart';
import 'package:health_flare/features/reports/services/csv_report_service.dart';
import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/daily_checkin.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/symptom_entry.dart';

// Issue #108: free text typed into the app (or carried in from an imported
// backup) went into the CSV as-is. A cell starting with = + - @ tab or CR is
// run as a formula when a clinician opens the file in Excel, Sheets or
// LibreOffice. A HYPERLINK or IMPORTXML formula pointed at a server can
// send the other cells' contents there.

const _payload = '=HYPERLINK("x?d="&A2,"Click")';
final _t = DateTime(2026, 9, 10, 9);

ReportData _report({
  List<SymptomEntry> symptoms = const [],
  List<DoseLog> doseLogs = const [],
  List<Medication> medications = const [],
  List<MealEntry> meals = const [],
  List<JournalEntry> journal = const [],
  List<DailyCheckin> checkins = const [],
  List<Appointment> appointments = const [],
  List<ActivityEntry> activities = const [],
}) => ReportData(
  profileName: 'Sarah',
  start: DateTime(2026, 9, 1),
  end: DateTime(2026, 9, 30),
  symptoms: symptoms,
  vitals: const [],
  doseLogs: doseLogs,
  medications: medications,
  meals: meals,
  journal: journal,
  sleep: const [],
  checkins: checkins,
  appointments: appointments,
  activities: activities,
);

/// Every data cell of the generated CSV, parsed back the way a spreadsheet
/// would read it (quotes removed).
List<String> _cells(ReportData data) {
  final rows = Csv().decode(CsvReportService.generate(data));
  return [
    for (final row in rows.skip(1))
      for (final cell in row) '$cell',
  ];
}

/// A spreadsheet treats a cell as a formula if it starts with one of these.
bool _isFormula(String cell) => cell.isNotEmpty && '=+-@\t\r'.contains(cell[0]);

ReportData _everyFreeTextField(String text) => _report(
  symptoms: [
    SymptomEntry(
      id: 1,
      profileId: 1,
      name: text,
      severity: 5,
      notes: text,
      loggedAt: _t,
      createdAt: _t,
    ),
  ],
  medications: [
    Medication(
      id: 7,
      profileId: 1,
      name: text,
      medicationType: 'medication',
      doseAmount: 1,
      doseUnit: 'mg',
      frequency: 'daily',
      startDate: _t,
      createdAt: _t,
    ),
  ],
  doseLogs: [
    DoseLog(
      id: 2,
      profileId: 1,
      medicationIsarId: 7,
      loggedAt: _t,
      createdAt: _t,
      amount: 1,
      unit: text,
      status: 'taken',
      notes: text,
    ),
  ],
  meals: [
    MealEntry(
      id: 3,
      profileId: 1,
      description: text,
      hasReaction: false,
      notes: text,
      loggedAt: _t,
      createdAt: _t,
    ),
  ],
  journal: [
    JournalEntry(
      id: 4,
      profileId: 1,
      createdAt: _t,
      snapshots: [JournalSnapshot(body: text, title: text, savedAt: _t)],
    ),
  ],
  checkins: [
    DailyCheckin(
      id: 5,
      profileId: 1,
      checkinDate: _t,
      createdAt: _t,
      stressLevel: text,
      notes: text,
    ),
  ],
  appointments: [
    Appointment(
      id: 6,
      profileId: 1,
      title: text,
      scheduledAt: _t,
      status: AppointmentStatus.completed,
      outcomeNotes: text,
      createdAt: _t,
    ),
  ],
  activities: [
    ActivityEntry(
      id: 8,
      profileId: 1,
      description: text,
      notes: text,
      loggedAt: _t,
      createdAt: _t,
    ),
  ],
);

void main() {
  group('CSV export: spreadsheet formulas in free text (#108)', () {
    for (final lead in ['=', '+', '-', '@', '\t', '\r']) {
      final label = lead
          .replaceAll('\t', 'tab')
          .replaceAll('\r', 'carriage return');
      test('text starting with $label is never a formula in any column', () {
        final text = '${lead}1+1';
        final cells = _cells(_everyFreeTextField(text));

        final formulas = cells.where(_isFormula).toList();
        expect(formulas, isEmpty, reason: 'cells read as formulas: $formulas');
      });
    }

    test('a HYPERLINK payload in notes is kept as text, not run', () {
      final cells = _cells(
        _report(
          symptoms: [
            SymptomEntry(
              id: 1,
              profileId: 1,
              name: 'Headache',
              severity: 6,
              notes: _payload,
              loggedAt: _t,
              createdAt: _t,
            ),
          ],
        ),
      );

      expect(cells, contains("'$_payload"));
      expect(cells.where(_isFormula), isEmpty);
    });

    test('every free-text column is covered', () {
      // Cells in _everyFreeTextField that are the user's text on its own:
      // symptom name + notes, medication name + dose notes, meal
      // description + notes, check-in stress + notes, appointment title +
      // outcome, journal title + body, activity description + notes.
      // (The dose unit follows the amount, "1.0 =1+1", so it can't start a
      // formula.) If a text column is added without the guard, this fails.
      final cells = _cells(_everyFreeTextField('=1+1'));
      expect(cells.where((c) => c == "'=1+1").length, 14);
      expect(cells.where((c) => c == '=1+1'), isEmpty);
    });

    test('ordinary text is unchanged', () {
      final cells = _cells(
        _everyFreeTextField('Ate pasta, felt fine. 2-3 hours later: nausea'),
      );
      expect(
        cells.where((c) => c.startsWith("'")),
        isEmpty,
        reason: 'only cells that would be formulas get the guard',
      );
    });

    test('columns the app writes itself are not altered', () {
      final cells = _cells(_everyFreeTextField('Fine'));
      expect(cells, contains('2026-09-10 09:00'));
      expect(cells, contains('Symptom'));
    });
  });
}

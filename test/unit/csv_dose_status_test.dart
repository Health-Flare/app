// Issue #130: every dose row in the CSV looked the same whatever its
// status, so a missed or skipped dose read as taken, and the reason and
// effectiveness were dropped. The PDF already showed status.
//
// Spec (already on main): reports.feature, "CSV medications export includes
// dose log fields" (status taken/skipped/missed); medications.feature,
// "Effectiveness ratings are included in exported reports".
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/features/reports/models/report_data.dart';
import 'package:health_flare/features/reports/services/csv_report_service.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/medication.dart';

final _t = DateTime(2026, 9, 10, 9, 5);

final _metformin = Medication(
  id: 7,
  profileId: 1,
  name: 'Metformin',
  medicationType: 'medication',
  doseAmount: 500,
  doseUnit: 'mg',
  frequency: 'daily',
  startDate: _t,
  createdAt: _t,
);

DoseLog _dose({
  String status = 'taken',
  double amount = 500,
  String unit = 'mg',
  String? reason,
  String? effectiveness,
  String? notes,
}) => DoseLog(
  id: 1,
  profileId: 1,
  medicationIsarId: 7,
  loggedAt: _t,
  createdAt: _t,
  amount: amount,
  unit: unit,
  status: status,
  reason: reason,
  effectiveness: effectiveness,
  notes: notes,
);

/// The dose row as a spreadsheet reads it: Date, Type, Name, Detail, Notes.
List<String> _row(DoseLog dose) {
  final rows = Csv().decode(
    CsvReportService.generate(
      ReportData(
        profileName: 'Sarah',
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 9, 30),
        symptoms: const [],
        vitals: const [],
        doseLogs: [dose],
        medications: [_metformin],
        meals: const [],
        journal: const [],
        sleep: const [],
        checkins: const [],
        appointments: const [],
        activities: const [],
      ),
    ),
  );
  return [for (final c in rows[1]) '$c'];
}

String _detail(DoseLog d) => _row(d)[3];

void main() {
  group('Taken, skipped and missed doses are told apart', () {
    test('a taken dose says Taken', () {
      expect(_detail(_dose()), '500 mg · Taken');
    });

    test('a skipped dose says Skipped', () {
      expect(_detail(_dose(status: 'skipped')), '500 mg · Skipped');
    });

    test('a missed dose says Missed, the issue\'s example', () {
      expect(
        _row(
          _dose(
            status: 'missed',
            reason: 'Forgot',
            effectiveness: 'helped_a_little',
            notes: 'n',
          ),
        ),
        [
          '2026-09-10 09:05',
          'Medication',
          'Metformin',
          '500 mg · Missed · Forgot · Helped a little',
          'n',
        ],
      );
    });
  });

  group('reason and effectiveness', () {
    test('appear when recorded', () {
      expect(
        _detail(_dose(effectiveness: 'made_it_worse')),
        '500 mg · Taken · Made it worse',
      );
      expect(
        _detail(_dose(status: 'skipped', reason: 'Felt sick')),
        '500 mg · Skipped · Felt sick',
      );
    });

    test('are left out when not recorded, with no empty separators', () {
      expect(_detail(_dose(status: 'missed')), '500 mg · Missed');
      expect(_detail(_dose(status: 'missed', reason: '')), '500 mg · Missed');
    });
  });

  group('amount', () {
    test('a whole number has no ".0"', () {
      expect(_detail(_dose()), startsWith('500 mg'));
      expect(_detail(_dose()), isNot(contains('500.0')));
    });

    test('a fraction keeps its decimals', () {
      expect(_detail(_dose(amount: 2.5, unit: 'ml')), '2.5 ml · Taken');
    });
  });

  test('a reason that looks like a formula can\'t run in a spreadsheet', () {
    final detail = _detail(
      _dose(status: 'missed', reason: '=HYPERLINK("x?d="&A2,"Click")'),
    );
    // The cell starts with the amount, so a spreadsheet reads it as text.
    expect(detail, startsWith('500 mg · Missed · '));
    expect('=+-@\t\r'.contains(detail[0]), isFalse);
  });
}

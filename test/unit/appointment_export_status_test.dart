import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_flare/features/reports/models/report_data.dart';
import 'package:health_flare/features/reports/services/csv_report_service.dart';
import 'package:health_flare/features/reports/services/pdf_report_service.dart';
import 'package:health_flare/models/appointment.dart';

// #138: "Exports don't call a passed appointment upcoming".
// Spec: docs/features/doctor-visits.feature.

final _now = DateTime(2026, 3, 26, 11, 0);

Appointment _appt(int id, String title, DateTime at) => Appointment(
  id: id,
  profileId: 1,
  title: title,
  scheduledAt: at,
  status: AppointmentStatus.upcoming,
  createdAt: DateTime(2026, 1, 1),
);

final _passed = _appt(1, 'GP check-in', _now.subtract(const Duration(days: 2)));
final _ahead = _appt(2, 'Physio assessment', _now.add(const Duration(days: 5)));

ReportData _report() => ReportData(
  profileName: 'Sarah',
  start: DateTime(2026, 3, 1),
  end: DateTime(2026, 3, 31),
  symptoms: const [],
  vitals: const [],
  doseLogs: const [],
  medications: const [],
  meals: const [],
  journal: const [],
  sleep: const [],
  checkins: const [],
  appointments: [_passed, _ahead],
  activities: const [],
);

void main() {
  group("Exports don't call a passed appointment upcoming", () {
    test('CSV', () {
      final rows = Csv().decode(
        CsvReportService.generate(_report(), now: _now),
      );
      List<dynamic> rowFor(String title) =>
          rows.firstWhere((r) => r.contains(title));
      expect(rowFor('GP check-in'), contains('Outcome not recorded'));
      expect(rowFor('GP check-in'), isNot(contains('Upcoming')));
      expect(rowFor('Physio assessment'), contains('Upcoming'));
    });

    test('PDF', () {
      expect(
        PdfReportService.appointmentRowValue(_passed, _now),
        contains('Outcome not recorded'),
      );
      expect(
        PdfReportService.appointmentRowValue(_passed, _now),
        isNot(contains('Upcoming')),
      );
      expect(
        PdfReportService.appointmentRowValue(_ahead, _now),
        contains('Upcoming'),
      );
    });
  });
}

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/features/reports/models/report_data.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/interference.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/sleep_entry.dart';

/// Generates a flat CSV string from [ReportData].
///
/// Columns: Date, Type, Title / Name, Detail, Notes, Got in the way, Impact
///
/// The last two columns are filled for symptoms only. They are appended at
/// the end so spreadsheets built on the first five columns keep working.
/// Unrecorded interference is an empty cell, never "Not at all".
abstract final class CsvReportService {
  static final _fmt = DateFormat('yyyy-MM-dd HH:mm');
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  static String generate(ReportData data) {
    final rows = <List<dynamic>>[
      [
        'Date',
        'Type',
        'Name / Title',
        'Detail',
        'Notes',
        'Got in the way',
        'Impact',
      ],
    ];

    // Build a medication lookup map.
    final medById = {for (final m in data.medications) m.id: m};

    for (final e in data.symptoms) {
      rows.add([
        _fmt.format(e.loggedAt),
        'Symptom',
        _text(e.name),
        'Severity ${e.severity}/10',
        _text(e.notes),
        Interference.label(e.interference) ?? '',
        _text(e.impact),
      ]);
    }

    for (final e in data.vitals) {
      rows.add([
        _fmt.format(e.loggedAt),
        'Vital',
        e.vitalType.label,
        e.displayValue,
        _text(e.notes),
      ]);
    }

    for (final e in data.doseLogs) {
      final Medication? med = medById[e.medicationIsarId];
      rows.add([
        _fmt.format(e.loggedAt),
        'Medication',
        med == null ? 'Unknown' : _text(med.name),
        _text('${e.amount} ${e.unit}'),
        _text(e.notes),
      ]);
    }

    for (final e in data.meals) {
      rows.add([
        _fmt.format(e.loggedAt),
        'Meal',
        _text(e.description),
        e.hasReaction ? 'Reaction flagged' : '',
        _text(e.notes),
      ]);
    }

    for (final e in data.sleep) {
      final dur = e.wakeTime.difference(e.bedtime);
      final h = dur.inHours;
      final m = dur.inMinutes % 60;
      rows.add([
        _fmt.format(e.wakeTime),
        'Sleep',
        '${h}h ${m}m',
        [
          if (e.qualityRating != null) 'Quality ${e.qualityRating}/5',
          if (e.wokeRested != null)
            'Woke rested: ${SleepEntry.wokeRestedLabels[e.wokeRested! - 1]}',
        ].join('  ·  '),
        _text(e.notes),
      ]);
    }

    for (final e in data.checkins) {
      rows.add([
        _dateFmt.format(e.checkinDate),
        'Check-in',
        e.wellbeing == null
            ? 'Wellbeing not recorded'
            : 'Wellbeing ${e.wellbeing}/10',
        _text(e.stressLevel),
        _text(e.notes),
      ]);
    }

    for (final e in data.appointments) {
      rows.add([
        _fmt.format(e.scheduledAt),
        'Appointment',
        _text(e.title),
        _apptStatus(e.status),
        _text(e.outcomeNotes),
      ]);
    }

    for (final e in data.journal) {
      rows.add([
        _fmt.format(e.createdAt),
        'Journal',
        _text(e.title),
        _text(e.body.length > 200 ? '${e.body.substring(0, 200)}…' : e.body),
        '',
      ]);
    }

    for (final e in data.activities) {
      final parts = <String>[];
      if (e.activityType != null) parts.add(e.activityType!.label);
      if (e.effortLevel != null) parts.add('Effort ${e.effortLevel}/5');
      if (e.durationMinutes != null) parts.add('${e.durationMinutes} min');
      rows.add([
        _fmt.format(e.loggedAt),
        'Activity',
        _text(e.description),
        parts.join('  ·  '),
        _text(e.notes),
      ]);
    }

    // Pad non-symptom rows to the full width.
    for (final row in rows) {
      while (row.length < rows.first.length) {
        row.add('');
      }
    }

    // Sort data rows by date (column 0) ascending.
    final header = rows.removeAt(0);
    rows.sort((a, b) => (a[0] as String).compareTo(b[0] as String));
    rows.insert(0, header);

    return Csv().encode(rows);
  }

  /// Characters that make a spreadsheet read a cell as a formula
  /// (=, +, -, @, tab, carriage return).
  static const _formulaLeads = {'=', '+', '-', '@', '\t', '\r'};

  /// Makes user-entered text safe to open in a spreadsheet (#108).
  ///
  /// Excel, Sheets and LibreOffice run a cell that starts with a formula
  /// character, so a note like `=HYPERLINK(...)` in a symptom entry, or in a
  /// backup someone else made, would run on the clinician's computer. A
  /// leading apostrophe makes the spreadsheet show the text as typed. Only
  /// cells that would be read as formulas are changed.
  ///
  /// Every column that holds user-entered text must go through this.
  static String _text(String? value) {
    if (value == null || value.isEmpty) return '';
    return _formulaLeads.contains(value[0]) ? "'$value" : value;
  }

  static String _apptStatus(String status) => switch (status) {
    AppointmentStatus.upcoming => 'Upcoming',
    AppointmentStatus.completed => 'Completed',
    AppointmentStatus.cancelled => 'Cancelled',
    AppointmentStatus.missed => 'Missed',
    _ => status,
  };
}

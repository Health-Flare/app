import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/features/reports/models/report_data.dart';
import 'package:health_flare/models/appointment_timing.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/medication.dart';

/// Generates a flat CSV string from [ReportData].
///
/// Columns: Date, Type, Title / Name, Detail, Notes
abstract final class CsvReportService {
  static final _fmt = DateFormat('yyyy-MM-dd HH:mm');
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  /// [now] decides whether an appointment still marked Upcoming has
  /// passed (#138). Defaults to the current time.
  static String generate(ReportData data, {DateTime? now}) {
    final at = now ?? DateTime.now();
    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Name / Title', 'Detail', 'Notes'],
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
        _doseDetail(e),
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
        e.qualityRating != null ? 'Quality ${e.qualityRating}/5' : '',
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
        appointmentStatusLabel(e, at),
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

    // Sort data rows by date (column 0) ascending.
    final header = rows.removeAt(0);
    rows.sort((a, b) => (a[0] as String).compareTo(b[0] as String));
    rows.insert(0, header);

    return Csv().encode(rows);
  }

  /// "500 mg · Missed · Forgot · Helped a little": amount, status, then
  /// the reason and effectiveness when recorded (#130). A missed or
  /// skipped dose must never read as taken. The cell starts with the
  /// amount, so the reason inside it can't start a formula; it still goes
  /// through [_text] in case the order ever changes.
  static String _doseDetail(DoseLog e) {
    final reason = e.reason?.trim();
    return _text(
      [
        e.amountDisplay,
        e.statusDisplay,
        if (reason != null && reason.isNotEmpty) reason,
        if (e.effectiveness != null) e.effectivenessDisplay,
      ].join(' · '),
    );
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
}

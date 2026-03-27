import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/features/reports/models/report_data.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/medication.dart';

/// Generates a flat CSV string from [ReportData].
///
/// Columns: Date, Type, Title / Name, Detail, Notes
abstract final class CsvReportService {
  static final _fmt = DateFormat('yyyy-MM-dd HH:mm');
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  static String generate(ReportData data) {
    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Name / Title', 'Detail', 'Notes'],
    ];

    // Build a medication lookup map.
    final medById = {for (final m in data.medications) m.id: m};

    for (final e in data.symptoms) {
      rows.add([
        _fmt.format(e.loggedAt),
        'Symptom',
        e.name,
        'Severity ${e.severity}/10',
        e.notes ?? '',
      ]);
    }

    for (final e in data.vitals) {
      rows.add([
        _fmt.format(e.loggedAt),
        'Vital',
        e.vitalType.label,
        e.displayValue,
        e.notes ?? '',
      ]);
    }

    for (final e in data.doseLogs) {
      final Medication? med = medById[e.medicationIsarId];
      rows.add([
        _fmt.format(e.loggedAt),
        'Medication',
        med?.name ?? 'Unknown',
        '${e.amount} ${e.unit}',
        e.notes ?? '',
      ]);
    }

    for (final e in data.meals) {
      rows.add([
        _fmt.format(e.loggedAt),
        'Meal',
        e.description,
        e.hasReaction ? 'Reaction flagged' : '',
        e.notes ?? '',
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
        e.notes ?? '',
      ]);
    }

    for (final e in data.checkins) {
      rows.add([
        _dateFmt.format(e.checkinDate),
        'Check-in',
        'Wellbeing ${e.wellbeing}/10',
        e.stressLevel ?? '',
        e.notes ?? '',
      ]);
    }

    for (final e in data.appointments) {
      rows.add([
        _fmt.format(e.scheduledAt),
        'Appointment',
        e.title,
        _apptStatus(e.status),
        e.outcomeNotes ?? '',
      ]);
    }

    for (final e in data.journal) {
      rows.add([
        _fmt.format(e.createdAt),
        'Journal',
        e.title ?? '',
        e.body.length > 200 ? '${e.body.substring(0, 200)}…' : e.body,
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
        e.description,
        parts.join('  ·  '),
        e.notes ?? '',
      ]);
    }

    // Sort data rows by date (column 0) ascending.
    final header = rows.removeAt(0);
    rows.sort((a, b) => (a[0] as String).compareTo(b[0] as String));
    rows.insert(0, header);

    return Csv().encode(rows);
  }

  static String _apptStatus(String status) => switch (status) {
    AppointmentStatus.upcoming => 'Upcoming',
    AppointmentStatus.completed => 'Completed',
    AppointmentStatus.cancelled => 'Cancelled',
    AppointmentStatus.missed => 'Missed',
    _ => status,
  };
}

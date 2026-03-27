import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:health_flare/features/reports/models/report_data.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/medication.dart';

/// Generates a PDF [Uint8List] from [ReportData].
abstract final class PdfReportService {
  static final _fmt = DateFormat('d MMM yyyy');
  static final _timeFmt = DateFormat('HH:mm');
  static final _hdrFmt = DateFormat('d MMM yyyy, HH:mm');

  static Future<Uint8List> generate(ReportData data) async {
    final pdf = pw.Document();

    // Pre-build all content sections so we know what to include.
    final sections = <pw.Widget>[];

    _addSymptoms(sections, data);
    _addVitals(sections, data);
    _addMedications(sections, data);
    _addMeals(sections, data);
    _addSleep(sections, data);
    _addCheckins(sections, data);
    _addAppointments(sections, data);
    _addActivities(sections, data);
    _addJournal(sections, data);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader(data),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        build: (ctx) => sections.isEmpty
            ? [pw.Text('No data found for this date range.')]
            : sections,
      ),
    );

    return pdf.save();
  }

  // ── Header ────────────────────────────────────────────────────────────────

  static pw.Widget _buildHeader(ReportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Health Report — ${data.profileName}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Generated ${_hdrFmt.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          '${_fmt.format(data.start)} – ${_fmt.format(data.end)}',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
        ),
        pw.Divider(thickness: 1),
      ],
    );
  }

  // ── Section helpers ───────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
    child: pw.Text(
      title,
      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
    ),
  );

  static pw.Widget _row(String label, String value, {bool muted = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 140,
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 10,
                  color: muted ? PdfColors.grey600 : PdfColors.grey900,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
            ),
          ],
        ),
      );

  // ── Symptoms ──────────────────────────────────────────────────────────────

  static void _addSymptoms(List<pw.Widget> out, ReportData data) {
    if (data.symptoms.isEmpty) return;
    out.add(_sectionTitle('Symptoms (${data.symptoms.length})'));
    for (final e in data.symptoms) {
      final label = '${_fmt.format(e.loggedAt)} ${_timeFmt.format(e.loggedAt)}';
      final value = StringBuffer('${e.name}  ·  severity ${e.severity}/10');
      if (e.notes != null) value.write('\n${e.notes}');
      out.add(_row(label, value.toString()));
    }
  }

  // ── Vitals ────────────────────────────────────────────────────────────────

  static void _addVitals(List<pw.Widget> out, ReportData data) {
    if (data.vitals.isEmpty) return;
    out.add(_sectionTitle('Vitals (${data.vitals.length})'));
    for (final e in data.vitals) {
      final label = '${_fmt.format(e.loggedAt)} ${_timeFmt.format(e.loggedAt)}';
      final value = StringBuffer('${e.vitalType.label}  ${e.displayValue}');
      if (e.notes != null) value.write('\n${e.notes}');
      out.add(_row(label, value.toString()));
    }
  }

  // ── Medications ───────────────────────────────────────────────────────────

  static void _addMedications(List<pw.Widget> out, ReportData data) {
    if (data.doseLogs.isEmpty) return;
    final medById = {for (final m in data.medications) m.id: m};
    out.add(_sectionTitle('Medications / doses (${data.doseLogs.length})'));
    for (final e in data.doseLogs) {
      final Medication? med = medById[e.medicationIsarId];
      final label = '${_fmt.format(e.loggedAt)} ${_timeFmt.format(e.loggedAt)}';
      final value = StringBuffer(
        '${med?.name ?? 'Unknown'}  ·  ${e.amount} ${e.unit}  ·  ${e.statusDisplay}',
      );
      if (e.notes != null) value.write('\n${e.notes}');
      out.add(_row(label, value.toString()));
    }
  }

  // ── Meals ─────────────────────────────────────────────────────────────────

  static void _addMeals(List<pw.Widget> out, ReportData data) {
    if (data.meals.isEmpty) return;
    out.add(_sectionTitle('Meals (${data.meals.length})'));
    for (final e in data.meals) {
      final label = '${_fmt.format(e.loggedAt)} ${_timeFmt.format(e.loggedAt)}';
      final value = StringBuffer(e.description);
      if (e.hasReaction) value.write('  ⚠ reaction flagged');
      if (e.notes != null) value.write('\n${e.notes}');
      out.add(_row(label, value.toString()));
    }
  }

  // ── Sleep ─────────────────────────────────────────────────────────────────

  static void _addSleep(List<pw.Widget> out, ReportData data) {
    if (data.sleep.isEmpty) return;
    out.add(_sectionTitle('Sleep (${data.sleep.length})'));
    for (final e in data.sleep) {
      final dur = e.wakeTime.difference(e.bedtime);
      final h = dur.inHours;
      final m = dur.inMinutes % 60;
      final label = _fmt.format(e.wakeTime);
      final value = StringBuffer('${h}h ${m}m');
      if (e.qualityRating != null) {
        value.write('  ·  quality ${e.qualityRating}/5');
      }
      if (e.isNap) value.write('  (nap)');
      if (e.notes != null) value.write('\n${e.notes}');
      out.add(_row(label, value.toString()));
    }
  }

  // ── Check-ins ─────────────────────────────────────────────────────────────

  static void _addCheckins(List<pw.Widget> out, ReportData data) {
    if (data.checkins.isEmpty) return;
    out.add(_sectionTitle('Daily check-ins (${data.checkins.length})'));
    for (final e in data.checkins) {
      final label = _fmt.format(e.checkinDate);
      final value = StringBuffer('Wellbeing ${e.wellbeing}/10');
      if (e.stressLevel != null) value.write('  ·  stress: ${e.stressLevel}');
      if (e.cyclePhase != null) value.write('  ·  ${e.cyclePhase}');
      if (e.notes != null) value.write('\n${e.notes}');
      out.add(_row(label, value.toString()));
    }
  }

  // ── Appointments ──────────────────────────────────────────────────────────

  static void _addAppointments(List<pw.Widget> out, ReportData data) {
    if (data.appointments.isEmpty) return;
    out.add(_sectionTitle('Appointments (${data.appointments.length})'));
    for (final e in data.appointments) {
      final label =
          '${_fmt.format(e.scheduledAt)} ${_timeFmt.format(e.scheduledAt)}';
      final value = StringBuffer(e.title);
      if (e.providerName != null) value.write('  ·  ${e.providerName}');
      value.write('  ·  ${_apptStatus(e.status)}');
      if (e.outcomeNotes != null) value.write('\n${e.outcomeNotes}');
      out.add(_row(label, value.toString()));
    }
  }

  // ── Activities ────────────────────────────────────────────────────────────

  static void _addActivities(List<pw.Widget> out, ReportData data) {
    if (data.activities.isEmpty) return;
    out.add(_sectionTitle('Activities (${data.activities.length})'));
    for (final e in data.activities) {
      final label = '${_fmt.format(e.loggedAt)} ${_timeFmt.format(e.loggedAt)}';
      final value = StringBuffer(e.description);
      if (e.activityType != null) value.write('  ·  ${e.activityType!.label}');
      if (e.effortLevel != null) value.write('  ·  effort ${e.effortLevel}/5');
      if (e.durationMinutes != null) {
        value.write('  ·  ${e.durationMinutes} min');
      }
      if (e.notes != null) value.write('\n${e.notes}');
      out.add(_row(label, value.toString()));
    }
  }

  // ── Journal ───────────────────────────────────────────────────────────────

  static void _addJournal(List<pw.Widget> out, ReportData data) {
    if (data.journal.isEmpty) return;
    out.add(_sectionTitle('Journal entries (${data.journal.length})'));
    for (final e in data.journal) {
      final label =
          '${_fmt.format(e.createdAt)} ${_timeFmt.format(e.createdAt)}';
      final body = e.body.length > 400
          ? '${e.body.substring(0, 400)}…'
          : e.body;
      final value = e.title != null ? '${e.title}\n$body' : body;
      out.add(_row(label, value));
    }
  }

  static String _apptStatus(String status) => switch (status) {
    AppointmentStatus.upcoming => 'Upcoming',
    AppointmentStatus.completed => 'Completed',
    AppointmentStatus.cancelled => 'Cancelled',
    AppointmentStatus.missed => 'Missed',
    _ => status,
  };
}

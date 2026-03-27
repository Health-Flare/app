import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/daily_checkin.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/sleep_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';

/// Aggregated data collected for a report.
class ReportData {
  const ReportData({
    required this.profileName,
    required this.start,
    required this.end,
    required this.symptoms,
    required this.vitals,
    required this.doseLogs,
    required this.medications,
    required this.meals,
    required this.journal,
    required this.sleep,
    required this.checkins,
    required this.appointments,
    required this.activities,
  });

  final String profileName;
  final DateTime start;
  final DateTime end;

  final List<SymptomEntry> symptoms;
  final List<VitalEntry> vitals;
  final List<DoseLog> doseLogs;
  final List<Medication> medications;
  final List<MealEntry> meals;
  final List<JournalEntry> journal;
  final List<SleepEntry> sleep;
  final List<DailyCheckin> checkins;
  final List<Appointment> appointments;
  final List<ActivityEntry> activities;

  bool get isEmpty =>
      symptoms.isEmpty &&
      vitals.isEmpty &&
      doseLogs.isEmpty &&
      meals.isEmpty &&
      journal.isEmpty &&
      sleep.isEmpty &&
      checkins.isEmpty &&
      appointments.isEmpty &&
      activities.isEmpty;
}

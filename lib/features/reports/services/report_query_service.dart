import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/appointment_isar.dart';
import 'package:health_flare/data/models/daily_checkin_isar.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/medication_isar.dart';
import 'package:health_flare/data/models/sleep_entry_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/data/models/vital_entry_isar.dart';
import 'package:health_flare/features/reports/models/report_config.dart';
import 'package:health_flare/features/reports/models/report_data.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/daily_checkin.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/sleep_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';

/// Queries each Isar collection and returns a [ReportData] for the given
/// profile and date range.
abstract final class ReportQueryService {
  static Future<ReportData> query({
    required Isar isar,
    required int profileId,
    required String profileName,
    required ReportConfig config,
  }) async {
    final start = config.resolvedStart;
    final end = config.resolvedEnd;

    bool inRange(DateTime dt) => !dt.isBefore(start) && !dt.isAfter(end);
    bool isProfile(int id) => id == profileId;

    final symptoms = config.includeSymptoms
        ? (await isar.symptomEntryIsars.where().findAll())
              .where((r) => isProfile(r.profileId) && inRange(r.loggedAt))
              .map((r) => r.toDomain())
              .cast<SymptomEntry>()
              .toList()
        : <SymptomEntry>[];

    final vitals = config.includeVitals
        ? (await isar.vitalEntryIsars.where().findAll())
              .where((r) => isProfile(r.profileId) && inRange(r.loggedAt))
              .map((r) => r.toDomain())
              .cast<VitalEntry>()
              .toList()
        : <VitalEntry>[];

    final meals = config.includeMeals
        ? (await isar.mealEntryIsars.where().findAll())
              .where((r) => isProfile(r.profileId) && inRange(r.loggedAt))
              .map((r) => r.toDomain())
              .cast<MealEntry>()
              .toList()
        : <MealEntry>[];

    final doseLogs = config.includeMedications
        ? (await isar.doseLogIsars.where().findAll())
              .where((r) => isProfile(r.profileId) && inRange(r.loggedAt))
              .map((r) => r.toDomain())
              .cast<DoseLog>()
              .toList()
        : <DoseLog>[];

    // Fetch medications so dose logs can be labelled by name.
    final medications = config.includeMedications
        ? (await isar.medicationIsars.where().findAll())
              .where((r) => isProfile(r.profileId))
              .map((r) => r.toDomain())
              .cast<Medication>()
              .toList()
        : <Medication>[];

    final journal = config.includeJournal
        ? (await isar.journalEntryIsars.where().findAll())
              .where((r) => isProfile(r.profileId) && inRange(r.createdAt))
              .map((r) => r.toDomain())
              .cast<JournalEntry>()
              .toList()
        : <JournalEntry>[];

    final sleep = config.includeSleep
        ? (await isar.sleepEntryIsars.where().findAll())
              .where((r) => isProfile(r.profileId) && inRange(r.wakeTime))
              .map((r) => r.toDomain())
              .cast<SleepEntry>()
              .toList()
        : <SleepEntry>[];

    final checkins = config.includeCheckins
        ? (await isar.dailyCheckinIsars.where().findAll())
              .where((r) => isProfile(r.profileId) && inRange(r.checkinDate))
              .map((r) => r.toDomain())
              .cast<DailyCheckin>()
              .toList()
        : <DailyCheckin>[];

    final appointments = config.includeAppointments
        ? (await isar.appointmentIsars.where().findAll())
              .where((r) => isProfile(r.profileId) && inRange(r.scheduledAt))
              .map((r) => r.toDomain())
              .cast<Appointment>()
              .toList()
        : <Appointment>[];

    return ReportData(
      profileName: profileName,
      start: start,
      end: end,
      symptoms: symptoms,
      vitals: vitals,
      meals: meals,
      doseLogs: doseLogs,
      medications: medications,
      journal: journal,
      sleep: sleep,
      checkins: checkins,
      appointments: appointments,
    );
  }
}

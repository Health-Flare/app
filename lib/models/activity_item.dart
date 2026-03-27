import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/daily_checkin.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/sleep_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';

/// A single item in the dashboard activity feed.
///
/// Sealed so that exhaustive pattern-matching in widget switch expressions
/// covers all variants without a default branch.
sealed class ActivityItem {
  const ActivityItem({required this.timestamp});

  /// The point in time used for sorting (newest first).
  final DateTime timestamp;
}

/// A journal entry in the activity feed.
final class JournalActivityItem extends ActivityItem {
  const JournalActivityItem({required super.timestamp, required this.entry});

  final JournalEntry entry;
}

/// A sleep session in the activity feed.
final class SleepActivityItem extends ActivityItem {
  const SleepActivityItem({required super.timestamp, required this.entry});

  final SleepEntry entry;
}

/// A symptom log in the activity feed.
final class SymptomActivityItem extends ActivityItem {
  const SymptomActivityItem({required super.timestamp, required this.entry});

  final SymptomEntry entry;
}

/// A vital measurement in the activity feed.
final class VitalActivityItem extends ActivityItem {
  const VitalActivityItem({required super.timestamp, required this.entry});

  final VitalEntry entry;
}

/// A dose log in the activity feed.
final class DoseLogActivityItem extends ActivityItem {
  const DoseLogActivityItem({
    required super.timestamp,
    required this.doseLog,
    this.medication,
  });

  final DoseLog doseLog;
  final Medication? medication;
}

/// A meal entry in the activity feed.
final class MealActivityItem extends ActivityItem {
  const MealActivityItem({required super.timestamp, required this.entry});

  final MealEntry entry;
}

/// A flare event in the activity feed.
final class FlareActivityItem extends ActivityItem {
  const FlareActivityItem({required super.timestamp, required this.entry});

  final Flare entry;
}

/// A daily check-in in the activity feed.
final class CheckinActivityItem extends ActivityItem {
  const CheckinActivityItem({required super.timestamp, required this.entry});

  final DailyCheckin entry;
}

/// An appointment in the activity feed.
final class AppointmentActivityItem extends ActivityItem {
  const AppointmentActivityItem({
    required super.timestamp,
    required this.entry,
  });

  final Appointment entry;
}

/// An activity log entry in the activity feed.
final class ActivityLogActivityItem extends ActivityItem {
  const ActivityLogActivityItem({
    required super.timestamp,
    required this.entry,
  });

  final ActivityEntry entry;
}

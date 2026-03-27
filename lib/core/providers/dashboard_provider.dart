import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/models/activity_item.dart';

// ---------------------------------------------------------------------------
// Dashboard activity feed
// ---------------------------------------------------------------------------

/// The ten most-recent health events for the active profile,
/// sorted newest-first.
///
/// Merges all logged entry types into a unified feed.
final dashboardActivityProvider = Provider<List<ActivityItem>>((ref) {
  final journalEntries = ref.watch(activeProfileJournalProvider);
  final sleepEntries = ref.watch(activeSleepEntriesProvider);
  final symptomEntries = ref.watch(activeProfileSymptomEntriesProvider);
  final vitalEntries = ref.watch(activeProfileVitalEntriesProvider);
  final doseLogs = ref.watch(activeProfileDoseLogsProvider);
  final medications = ref.watch(activeProfileMedicationsProvider);
  final mealEntries = ref.watch(activeProfileMealEntriesProvider);
  final flares = ref.watch(activeProfileFlaresProvider);
  final checkins = ref.watch(activeProfileCheckinsProvider);
  final appointments = ref.watch(activeProfileAppointmentsProvider);
  final activityEntries = ref.watch(activeProfileActivityEntriesProvider);

  final medById = {for (final m in medications) m.id: m};

  final items = <ActivityItem>[
    ...journalEntries.map(
      (e) => JournalActivityItem(timestamp: e.createdAt, entry: e),
    ),
    ...sleepEntries.map(
      (e) => SleepActivityItem(timestamp: e.wakeTime, entry: e),
    ),
    ...symptomEntries.map(
      (e) => SymptomActivityItem(timestamp: e.loggedAt, entry: e),
    ),
    ...vitalEntries.map(
      (e) => VitalActivityItem(timestamp: e.loggedAt, entry: e),
    ),
    ...doseLogs.map(
      (e) => DoseLogActivityItem(
        timestamp: e.loggedAt,
        doseLog: e,
        medication: medById[e.medicationIsarId],
      ),
    ),
    ...mealEntries.map(
      (e) => MealActivityItem(timestamp: e.loggedAt, entry: e),
    ),
    ...flares.map((e) => FlareActivityItem(timestamp: e.startedAt, entry: e)),
    ...checkins.map(
      (e) => CheckinActivityItem(timestamp: e.checkinDate, entry: e),
    ),
    ...appointments.map(
      (e) => AppointmentActivityItem(timestamp: e.scheduledAt, entry: e),
    ),
    ...activityEntries.map(
      (e) => ActivityLogActivityItem(timestamp: e.loggedAt, entry: e),
    ),
  ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return items.take(10).toList();
});

/// True when [dashboardActivityProvider] contains at least one item.
final dashboardHasActivityProvider = Provider<bool>((ref) {
  return ref.watch(dashboardActivityProvider).isNotEmpty;
});

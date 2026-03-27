import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/daily_checkin_isar.dart';
import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/data/models/sleep_entry_isar.dart';
import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/features/reports/models/insight_data.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';

/// Queries Isar and computes insight data for a profile and date window.
abstract final class InsightsQueryService {
  static Future<InsightData> query({
    required Isar isar,
    required int profileId,
    required DateTime start,
    required DateTime end,
  }) async {
    final windowStart = _startOfDay(start);
    final windowEnd = _endOfDay(end);

    bool inWindow(DateTime dt) =>
        !dt.isBefore(windowStart) && !dt.isAfter(windowEnd);
    bool isProfile(int id) => id == profileId;

    // ── Load raw data ────────────────────────────────────────────────────────

    final allSymptoms = (await isar.symptomEntryIsars.where().findAll())
        .where((r) => isProfile(r.profileId) && inWindow(r.loggedAt))
        .map((r) => r.toDomain())
        .cast<SymptomEntry>()
        .toList();

    final allMeals = (await isar.mealEntryIsars.where().findAll())
        .where((r) => isProfile(r.profileId) && inWindow(r.loggedAt))
        .map((r) => r.toDomain())
        .cast<MealEntry>()
        .toList();

    final allCheckins = (await isar.dailyCheckinIsars.where().findAll())
        .where((r) => isProfile(r.profileId) && inWindow(r.checkinDate))
        .map((r) => r.toDomain())
        .toList();

    // Sleep: also fetch entries outside the window (lookback for correlation).
    final lookbackStart = windowStart.subtract(const Duration(days: 1));
    final allSleep = (await isar.sleepEntryIsars.where().findAll())
        .where(
          (r) =>
              isProfile(r.profileId) &&
              !r.wakeTime.isBefore(lookbackStart) &&
              !r.wakeTime.isAfter(windowEnd),
        )
        .map((r) => r.toDomain())
        .toList();

    // Flares: load all for profile; compute overlap with window.
    final allFlares = (await isar.flareIsars.where().findAll())
        .where((r) => isProfile(r.profileId))
        .map((r) => r.toDomain())
        .toList();

    // ── Compute symptom trends ────────────────────────────────────────────────

    final byName = <String, List<SymptomEntry>>{};
    for (final e in allSymptoms) {
      (byName[e.name] ??= []).add(e);
    }

    final symptomTrends = byName.entries.map((entry) {
      final points =
          entry.value
              .map(
                (e) => TrendPoint(
                  date: DateTime(
                    e.loggedAt.year,
                    e.loggedAt.month,
                    e.loggedAt.day,
                  ),
                  value: e.severity.toDouble(),
                ),
              )
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      return SymptomTrend(name: entry.key, points: points);
    }).toList()..sort((a, b) => b.points.length.compareTo(a.points.length));

    // ── Compute wellbeing trend ───────────────────────────────────────────────

    final wellbeingTrend =
        allCheckins
            .map(
              (c) => TrendPoint(
                date: DateTime(
                  c.checkinDate.year,
                  c.checkinDate.month,
                  c.checkinDate.day,
                ),
                value: c.wellbeing.toDouble(),
              ),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    // ── Compute flare periods overlapping the window ──────────────────────────

    final flarePeriods = <InsightFlarePeriod>[];
    for (final f in allFlares) {
      final flareEnd = f.endedAt ?? DateTime.now();
      // Only include if it overlaps the window.
      if (flareEnd.isBefore(windowStart) || f.startedAt.isAfter(windowEnd)) {
        continue;
      }
      flarePeriods.add(
        InsightFlarePeriod(
          start: f.startedAt.isBefore(windowStart) ? windowStart : f.startedAt,
          end: flareEnd.isAfter(windowEnd) ? windowEnd : flareEnd,
        ),
      );
    }

    // ── Compute food triggers ─────────────────────────────────────────────────

    final reactionMeals = allMeals.where((m) => m.hasReaction).toList();
    final foodTriggers = <FoodTrigger>[];

    for (final meal in reactionMeals) {
      final sixHoursAfter = meal.loggedAt.add(const Duration(hours: 6));
      final nearby = allSymptoms
          .where(
            (s) =>
                !s.loggedAt.isBefore(meal.loggedAt) &&
                !s.loggedAt.isAfter(sixHoursAfter),
          )
          .toList();
      foodTriggers.add(FoodTrigger(meal: meal, symptoms: nearby));
    }
    // Sort: most associated symptoms first.
    foodTriggers.sort((a, b) => b.symptoms.length.compareTo(a.symptoms.length));

    // ── Compute sleep correlation ─────────────────────────────────────────────

    // Group symptoms by calendar day for fast lookup.
    final symptomsByDay = <DateTime, List<SymptomEntry>>{};
    for (final s in allSymptoms) {
      final day = DateTime(s.loggedAt.year, s.loggedAt.month, s.loggedAt.day);
      (symptomsByDay[day] ??= []).add(s);
    }

    final poorSleepSeverities = <double>[];
    final goodSleepSeverities = <double>[];

    for (final sleep in allSleep) {
      if (sleep.isNap) continue;
      final quality = sleep.qualityRating;
      if (quality == null) continue;

      final nextDay = DateTime(
        sleep.wakeTime.year,
        sleep.wakeTime.month,
        sleep.wakeTime.day,
      ).add(const Duration(days: 1));

      final nextDaySymptoms = symptomsByDay[nextDay];
      if (nextDaySymptoms == null || nextDaySymptoms.isEmpty) continue;

      final avg =
          nextDaySymptoms.map((s) => s.severity).reduce((a, b) => a + b) /
          nextDaySymptoms.length;

      if (quality <= 2) {
        poorSleepSeverities.add(avg);
      } else if (quality >= 4) {
        goodSleepSeverities.add(avg);
      }
    }

    final sleepCorrelation = SleepCorrelation(
      poorSleepAvg: poorSleepSeverities.isNotEmpty
          ? poorSleepSeverities.reduce((a, b) => a + b) /
                poorSleepSeverities.length
          : null,
      poorSleepDays: poorSleepSeverities.isNotEmpty
          ? poorSleepSeverities.length
          : null,
      goodSleepAvg: goodSleepSeverities.isNotEmpty
          ? goodSleepSeverities.reduce((a, b) => a + b) /
                goodSleepSeverities.length
          : null,
      goodSleepDays: goodSleepSeverities.isNotEmpty
          ? goodSleepSeverities.length
          : null,
    );

    return InsightData(
      start: windowStart,
      end: windowEnd,
      symptomTrends: symptomTrends,
      wellbeingTrend: wellbeingTrend,
      flarePeriods: flarePeriods,
      foodTriggers: foodTriggers,
      sleepCorrelation: sleepCorrelation,
    );
  }
}

DateTime _startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
DateTime _endOfDay(DateTime dt) =>
    DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

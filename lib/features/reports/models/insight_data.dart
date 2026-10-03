import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_type.dart';

/// Average symptom severity for a specific weather condition.
class WeatherConditionSeverity {
  const WeatherConditionSeverity({
    required this.condition,
    required this.avgSeverity,
    required this.sampleCount,
  });

  final String condition;
  final double avgSeverity; // 1–10 average severity
  final int sampleCount;
}

/// A single (date, value) point on a trend chart.
class TrendPoint {
  const TrendPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

/// Severity trend for one named symptom.
class SymptomTrend {
  const SymptomTrend({required this.name, required this.points});

  final String name;
  final List<TrendPoint> points; // sorted ascending by date
}

/// Readings for one vital type, all expressed in [unit].
///
/// [points] carry the full logged timestamp (not truncated to the day), so
/// several readings on one day stay separate. [secondaryPoints] holds the
/// diastolic series for blood pressure and is empty for every other type.
class VitalTrend {
  const VitalTrend({
    required this.type,
    required this.unit,
    required this.points,
    this.secondaryPoints = const [],
  });

  final VitalType type;
  final String unit;
  final List<TrendPoint> points; // sorted ascending by date
  final List<TrendPoint> secondaryPoints; // sorted ascending by date
}

/// A time window during which a flare was active.
class InsightFlarePeriod {
  const InsightFlarePeriod({required this.start, required this.end});

  final DateTime start;
  final DateTime end; // uses DateTime.now() if still active
}

/// A reaction-flagged meal paired with any symptoms logged within 6 h after.
class FoodTrigger {
  const FoodTrigger({required this.meal, required this.symptoms});

  final MealEntry meal;
  final List<SymptomEntry> symptoms; // may be empty
}

/// How next-day symptom severity differs after poor vs good sleep.
///
/// [poorSleepAvg]: average severity on the day after a sleep rated 1–2.
/// [goodSleepAvg]: average severity on the day after a sleep rated 4–5.
/// Null values mean there were not enough samples to compute the average.
class SleepCorrelation {
  const SleepCorrelation({
    this.poorSleepAvg,
    this.poorSleepDays,
    this.goodSleepAvg,
    this.goodSleepDays,
  });

  final double? poorSleepAvg;
  final int? poorSleepDays;
  final double? goodSleepAvg;
  final int? goodSleepDays;

  bool get hasData => poorSleepAvg != null || goodSleepAvg != null;
}

/// All computed insight data for one profile and date window.
class InsightData {
  const InsightData({
    required this.start,
    required this.end,
    required this.symptomTrends,
    required this.wellbeingTrend,
    required this.flarePeriods,
    required this.foodTriggers,
    required this.sleepCorrelation,
    required this.weatherImpact,
    this.vitalTrends = const [],
  });

  final DateTime start;
  final DateTime end;

  /// One trend per distinct symptom name (sorted by most entries, descending).
  final List<SymptomTrend> symptomTrends;

  /// Daily wellbeing scores from check-ins (sorted ascending by date).
  final List<TrendPoint> wellbeingTrend;

  /// Flare periods that overlap the window.
  final List<InsightFlarePeriod> flarePeriods;

  /// Reaction-flagged meals within the window, paired with nearby symptoms.
  /// Sorted by number of associated symptoms descending (most suspicious first).
  final List<FoodTrigger> foodTriggers;

  final SleepCorrelation sleepCorrelation;

  /// Average symptom severity per weather condition (requires ≥2 samples per condition).
  /// Sorted by avg severity descending (most impactful conditions first).
  final List<WeatherConditionSeverity> weatherImpact;

  /// One trend per vital type with readings in the window.
  final List<VitalTrend> vitalTrends;

  bool get isEmpty =>
      symptomTrends.isEmpty &&
      wellbeingTrend.isEmpty &&
      foodTriggers.isEmpty &&
      !sleepCorrelation.hasData &&
      weatherImpact.isEmpty;
}

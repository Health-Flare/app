/// Date range presets for report generation.
enum DateRangePreset { last7days, last30days, custom }

/// Configuration chosen by the user before generating a report.
class ReportConfig {
  ReportConfig({
    this.preset = DateRangePreset.last30days,
    DateTime? customStart,
    DateTime? customEnd,
    this.includeSymptoms = true,
    this.includeVitals = true,
    this.includeMedications = true,
    this.includeMeals = true,
    this.includeJournal = true,
    this.includeSleep = true,
    this.includeCheckins = true,
    this.includeAppointments = true,
    this.includeActivities = true,
  }) : customStart =
           customStart ?? DateTime.now().subtract(const Duration(days: 30)),
       customEnd = customEnd ?? DateTime.now();

  final DateRangePreset preset;
  final DateTime customStart;
  final DateTime customEnd;

  final bool includeSymptoms;
  final bool includeVitals;
  final bool includeMedications;
  final bool includeMeals;
  final bool includeJournal;
  final bool includeSleep;
  final bool includeCheckins;
  final bool includeAppointments;
  final bool includeActivities;

  /// Returns true when at least one data type is selected.
  bool get hasDataTypes =>
      includeSymptoms ||
      includeVitals ||
      includeMedications ||
      includeMeals ||
      includeJournal ||
      includeSleep ||
      includeCheckins ||
      includeAppointments ||
      includeActivities;

  /// Resolved start date (beginning of day) based on [preset].
  DateTime get resolvedStart {
    final now = DateTime.now();
    return switch (preset) {
      DateRangePreset.last7days => _startOfDay(
        now.subtract(const Duration(days: 6)),
      ),
      DateRangePreset.last30days => _startOfDay(
        now.subtract(const Duration(days: 29)),
      ),
      DateRangePreset.custom => _startOfDay(customStart),
    };
  }

  /// Resolved end date (end of day) based on [preset].
  DateTime get resolvedEnd {
    final now = DateTime.now();
    return switch (preset) {
      DateRangePreset.last7days => _endOfDay(now),
      DateRangePreset.last30days => _endOfDay(now),
      DateRangePreset.custom => _endOfDay(customEnd),
    };
  }

  /// True when customEnd is not before customStart.
  bool get customRangeValid =>
      preset != DateRangePreset.custom || !customEnd.isBefore(customStart);

  ReportConfig copyWith({
    DateRangePreset? preset,
    DateTime? customStart,
    DateTime? customEnd,
    bool? includeSymptoms,
    bool? includeVitals,
    bool? includeMedications,
    bool? includeMeals,
    bool? includeJournal,
    bool? includeSleep,
    bool? includeCheckins,
    bool? includeAppointments,
    bool? includeActivities,
  }) => ReportConfig(
    preset: preset ?? this.preset,
    customStart: customStart ?? this.customStart,
    customEnd: customEnd ?? this.customEnd,
    includeSymptoms: includeSymptoms ?? this.includeSymptoms,
    includeVitals: includeVitals ?? this.includeVitals,
    includeMedications: includeMedications ?? this.includeMedications,
    includeMeals: includeMeals ?? this.includeMeals,
    includeJournal: includeJournal ?? this.includeJournal,
    includeSleep: includeSleep ?? this.includeSleep,
    includeCheckins: includeCheckins ?? this.includeCheckins,
    includeAppointments: includeAppointments ?? this.includeAppointments,
    includeActivities: includeActivities ?? this.includeActivities,
  );
}

DateTime _startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
DateTime _endOfDay(DateTime dt) =>
    DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

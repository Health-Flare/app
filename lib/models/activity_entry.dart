import 'package:flutter/foundation.dart';

/// Activity type options — chronic-illness appropriate, not fitness-focused.
enum ActivityType {
  walking('walking', 'Walking'),
  gentleExercise('gentle_exercise', 'Gentle exercise / yoga'),
  household('household', 'Household tasks'),
  work('work', 'Work / desk activity'),
  social('social', 'Social obligation'),
  medical('medical', 'Medical appointment'),
  rest('rest', 'Rest day'),
  other('other', 'Other');

  const ActivityType(this.value, this.label);

  /// Storage value used in Isar.
  final String value;

  /// Human-readable display label.
  final String label;

  static ActivityType? fromValue(String v) {
    for (final t in values) {
      if (t.value == v) return t;
    }
    return null;
  }
}

/// Effort scale anchor labels (1–5).
const effortLabels = {
  1: 'Very light',
  2: 'Light',
  3: 'Moderate',
  4: 'Hard',
  5: 'Maximum effort',
};

@immutable
class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.profileId,
    required this.description,
    this.activityType,
    this.effortLevel,
    this.durationMinutes,
    required this.loggedAt,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.flareIsarId,
  });

  final int id;
  final int profileId;
  final String description;

  /// Broad category. Null if user did not select one.
  final ActivityType? activityType;

  /// Perceived effort 1–5. Null = not rated.
  final int? effortLevel;

  /// Duration in minutes. Null = not recorded.
  final int? durationMinutes;

  final DateTime loggedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final int? flareIsarId;

  /// Human-readable effort label, e.g. "3 – Moderate".
  String? get effortLabel => effortLevel != null
      ? '$effortLevel – ${effortLabels[effortLevel]}'
      : null;

  ActivityEntry copyWith({
    String? description,
    ActivityType? activityType,
    int? effortLevel,
    int? durationMinutes,
    DateTime? loggedAt,
    DateTime? updatedAt,
    String? notes,
    int? flareIsarId,
    bool clearActivityType = false,
    bool clearEffortLevel = false,
    bool clearDurationMinutes = false,
    bool clearNotes = false,
  }) {
    return ActivityEntry(
      id: id,
      profileId: profileId,
      description: description ?? this.description,
      activityType: clearActivityType
          ? null
          : (activityType ?? this.activityType),
      effortLevel: clearEffortLevel ? null : (effortLevel ?? this.effortLevel),
      durationMinutes: clearDurationMinutes
          ? null
          : (durationMinutes ?? this.durationMinutes),
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: clearNotes ? null : (notes ?? this.notes),
      flareIsarId: flareIsarId ?? this.flareIsarId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ActivityEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

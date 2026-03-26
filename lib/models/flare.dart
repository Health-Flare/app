import 'package:flutter/foundation.dart';

@immutable
class Flare {
  const Flare({
    required this.id,
    required this.profileId,
    required this.startedAt,
    this.endedAt,
    this.conditionIsarIds = const [],
    this.initialSeverity,
    this.peakSeverity,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int profileId;
  final DateTime startedAt;
  final DateTime? endedAt; // null = active flare
  final List<int> conditionIsarIds; // links to UserConditionIsar.id
  final int? initialSeverity; // 1–10
  final int? peakSeverity; // 1–10 at peak or end
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// True when the flare has no end date.
  bool get isActive => endedAt == null;

  /// Duration of the flare. Uses now if still active.
  Duration get duration => (endedAt ?? DateTime.now()).difference(startedAt);

  /// Human-readable day count string, e.g. "Day 3".
  String get dayLabel {
    final days = duration.inDays + 1;
    return 'Day $days';
  }

  Flare copyWith({
    DateTime? startedAt,
    DateTime? endedAt,
    List<int>? conditionIsarIds,
    int? initialSeverity,
    int? peakSeverity,
    String? notes,
    DateTime? updatedAt,
    bool clearEndedAt = false,
    bool clearNotes = false,
    bool clearInitialSeverity = false,
    bool clearPeakSeverity = false,
  }) {
    return Flare(
      id: id,
      profileId: profileId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : (endedAt ?? this.endedAt),
      conditionIsarIds: conditionIsarIds ?? this.conditionIsarIds,
      initialSeverity: clearInitialSeverity
          ? null
          : (initialSeverity ?? this.initialSeverity),
      peakSeverity: clearPeakSeverity
          ? null
          : (peakSeverity ?? this.peakSeverity),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Flare && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

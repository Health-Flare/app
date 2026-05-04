enum ConditionStatus { active, inRecovery }

/// A single point-in-time status change recorded against a tracked condition.
class ConditionStatusEvent {
  const ConditionStatusEvent({required this.eventType, required this.date});

  /// "diagnosed" | "recovery" | "relapse"
  final String eventType;
  final DateTime date;

  @override
  bool operator ==(Object other) =>
      other is ConditionStatusEvent &&
      other.eventType == eventType &&
      other.date == date;

  @override
  int get hashCode => Object.hash(eventType, date);
}

/// Immutable domain model representing a condition tracked by a profile.
///
/// [conditionName] is denormalised from [ConditionIsar] so that display
/// doesn't require a join query.
class UserCondition {
  const UserCondition({
    required this.id,
    required this.profileId,
    required this.conditionId,
    required this.conditionName,
    required this.trackedSince,
    this.diagnosedAt,
    this.notes,
    this.status = ConditionStatus.active,
    this.statusHistory = const [],
  });

  final int id;
  final int profileId;
  final int conditionId;
  final String conditionName;
  final DateTime trackedSince;
  final DateTime? diagnosedAt;
  final String? notes;
  final ConditionStatus status;
  final List<ConditionStatusEvent> statusHistory;

  UserCondition copyWith({
    DateTime? diagnosedAt,
    String? notes,
    ConditionStatus? status,
    List<ConditionStatusEvent>? statusHistory,
  }) => UserCondition(
    id: id,
    profileId: profileId,
    conditionId: conditionId,
    conditionName: conditionName,
    trackedSince: trackedSince,
    diagnosedAt: diagnosedAt ?? this.diagnosedAt,
    notes: notes ?? this.notes,
    status: status ?? this.status,
    statusHistory: statusHistory ?? this.statusHistory,
  );

  @override
  bool operator ==(Object other) => other is UserCondition && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserCondition(id: $id, profileId: $profileId, conditionName: $conditionName, status: $status)';
}

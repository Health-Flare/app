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
  });

  final int id;
  final int profileId;
  final int conditionId;
  final String conditionName;
  final DateTime trackedSince;
  final DateTime? diagnosedAt;
  final String? notes;

  UserCondition copyWith({DateTime? diagnosedAt, String? notes}) =>
      UserCondition(
        id: id,
        profileId: profileId,
        conditionId: conditionId,
        conditionName: conditionName,
        trackedSince: trackedSince,
        diagnosedAt: diagnosedAt ?? this.diagnosedAt,
        notes: notes ?? this.notes,
      );

  @override
  bool operator ==(Object other) => other is UserCondition && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserCondition(id: $id, profileId: $profileId, conditionName: $conditionName)';
}

/// Immutable domain model representing a symptom tracked by a profile.
///
/// [symptomName] is denormalised from [SymptomIsar] so that display
/// doesn't require a join query.
class UserSymptom {
  const UserSymptom({
    required this.id,
    required this.profileId,
    required this.symptomId,
    required this.symptomName,
    required this.trackedSince,
  });

  final int id;
  final int profileId;
  final int symptomId;
  final String symptomName;
  final DateTime trackedSince;

  @override
  bool operator ==(Object other) => other is UserSymptom && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserSymptom(id: $id, profileId: $profileId, symptomName: $symptomName)';
}

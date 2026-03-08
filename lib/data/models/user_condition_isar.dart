import 'package:isar_community/isar.dart';

import 'package:health_flare/models/user_condition.dart';

part 'user_condition_isar.g.dart';

/// Isar-annotated storage representation of a profile's tracked [UserCondition].
///
/// [conditionName] is denormalised so that list views don't need a join query.
/// [diagnosedAt] is optional; when set it triggers a journal entry creation
/// (handled by the provider layer).
@collection
class UserConditionIsar {
  Id id = Isar.autoIncrement;

  /// Foreign key to the owning profile.
  @Index()
  late int profileId;

  /// Foreign key to the catalogue [ConditionIsar].
  @Index()
  late int conditionId;

  /// Denormalised display name (copied from [ConditionIsar.name] at save time).
  late String conditionName;

  /// When the user started tracking this condition.
  late DateTime trackedSince;

  /// Optional confirmed diagnosis date.
  DateTime? diagnosedAt;

  /// Optional free-text notes.
  String? notes;

  // ── Conversion ────────────────────────────────────────────────────────────

  UserCondition toDomain() => UserCondition(
    id: id,
    profileId: profileId,
    conditionId: conditionId,
    conditionName: conditionName,
    trackedSince: trackedSince,
    diagnosedAt: diagnosedAt,
    notes: notes,
  );

  static UserConditionIsar fromDomain(UserCondition u) => UserConditionIsar()
    ..id = u.id
    ..profileId = u.profileId
    ..conditionId = u.conditionId
    ..conditionName = u.conditionName
    ..trackedSince = u.trackedSince
    ..diagnosedAt = u.diagnosedAt
    ..notes = u.notes;
}

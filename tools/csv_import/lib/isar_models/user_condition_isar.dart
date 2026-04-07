import 'package:isar_community/isar.dart';

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

}

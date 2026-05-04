import 'package:isar_community/isar.dart';

import 'package:health_flare/models/user_condition.dart';

part 'user_condition_isar.g.dart';

/// A single point-in-time status change stored against a [UserConditionIsar].
/// eventType: "diagnosed" | "recovery" | "relapse"
@embedded
class ConditionStatusEventIsar {
  late String eventType;
  late DateTime date;

  ConditionStatusEvent toDomain() =>
      ConditionStatusEvent(eventType: eventType, date: date);

  static ConditionStatusEventIsar fromDomain(ConditionStatusEvent e) =>
      ConditionStatusEventIsar()
        ..eventType = e.eventType
        ..date = e.date;
}

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

  /// "active" | "inRecovery"
  String status = 'active';

  List<ConditionStatusEventIsar> statusHistory = [];

  // ── Conversion ────────────────────────────────────────────────────────────

  UserCondition toDomain() => UserCondition(
    id: id,
    profileId: profileId,
    conditionId: conditionId,
    conditionName: conditionName,
    trackedSince: trackedSince,
    diagnosedAt: diagnosedAt,
    notes: notes,
    status: status == 'inRecovery'
        ? ConditionStatus.inRecovery
        : ConditionStatus.active,
    statusHistory: statusHistory.map((e) => e.toDomain()).toList(),
  );

  static UserConditionIsar fromDomain(UserCondition u) => UserConditionIsar()
    ..id = u.id
    ..profileId = u.profileId
    ..conditionId = u.conditionId
    ..conditionName = u.conditionName
    ..trackedSince = u.trackedSince
    ..diagnosedAt = u.diagnosedAt
    ..notes = u.notes
    ..status = u.status == ConditionStatus.inRecovery ? 'inRecovery' : 'active'
    ..statusHistory = u.statusHistory
        .map(ConditionStatusEventIsar.fromDomain)
        .toList();
}

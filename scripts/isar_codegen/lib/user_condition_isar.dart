import 'package:isar_community/isar.dart';

part 'user_condition_isar.g.dart';

/// A single point-in-time status change for a tracked condition.
/// eventType: "diagnosed" | "recovery" | "relapse"
@embedded
class ConditionStatusEventIsar {
  late String eventType;
  late DateTime date;
}

@collection
class UserConditionIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  @Index()
  late int conditionId;

  late String conditionName;

  late DateTime trackedSince;

  DateTime? diagnosedAt;

  String? notes;

  /// "active" | "inRecovery"
  String status = 'active';

  List<ConditionStatusEventIsar> statusHistory = [];
}

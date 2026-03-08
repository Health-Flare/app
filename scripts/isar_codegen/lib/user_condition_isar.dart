import 'package:isar_community/isar.dart';

part 'user_condition_isar.g.dart';

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
}

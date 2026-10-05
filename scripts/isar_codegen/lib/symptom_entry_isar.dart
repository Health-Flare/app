import 'package:isar_community/isar.dart';

import 'weather_snapshot_isar.dart';

part 'symptom_entry_isar.g.dart';

@collection
class SymptomEntryIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  late String name;

  int? userSymptomIsarId;

  int? userConditionIsarId;

  late int severity;

  List<String> locations = [];

  String? notes;

  @Index()
  late DateTime loggedAt;

  late DateTime createdAt;

  int? flareIsarId;

  WeatherSnapshotIsar? weatherSnapshot;

  /// 1 (Not at all) to 5 (Very much). Null = not recorded.
  int? interference;

  /// What the symptom stopped the person doing, verbatim. Null = not recorded.
  String? impact;
}

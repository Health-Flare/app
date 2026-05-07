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

  String? notes;

  @Index()
  late DateTime loggedAt;

  late DateTime createdAt;

  int? flareIsarId;

  WeatherSnapshotIsar? weatherSnapshot;
}

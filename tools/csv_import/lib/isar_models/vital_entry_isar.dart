import 'package:isar_community/isar.dart';

part 'vital_entry_isar.g.dart';

@collection
class VitalEntryIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  late String vitalType; // VitalType.name string

  late double value;

  double? value2;

  late String unit;

  String? notes;

  @Index()
  late DateTime loggedAt;

  late DateTime createdAt;

  int? flareIsarId;

}

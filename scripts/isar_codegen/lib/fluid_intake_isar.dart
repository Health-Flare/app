import 'package:isar_community/isar.dart';

part 'fluid_intake_isar.g.dart';

@collection
class FluidIntakeIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  @Index()
  late DateTime loggedAt;

  late int volumeMl;

  String? drinkType;

  String? notes;

  late DateTime createdAt;
}

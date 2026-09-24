import 'package:isar_community/isar.dart';

import 'package:health_flare/models/fluid_intake.dart';

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

  FluidIntake toDomain() => FluidIntake(
    id: id,
    profileId: profileId,
    loggedAt: loggedAt,
    volumeMl: volumeMl,
    drinkType: drinkType,
    notes: notes,
    createdAt: createdAt,
  );
}

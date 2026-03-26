import 'package:isar_community/isar.dart';

import 'package:health_flare/models/dose_log.dart';

part 'dose_log_isar.g.dart';

@collection
class DoseLogIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  @Index()
  late int medicationIsarId; // links to MedicationIsar.id

  @Index()
  late DateTime loggedAt; // when the dose was taken/skipped/missed

  late DateTime createdAt;

  late double amount;

  late String unit;

  late String status; // "taken" | "skipped" | "missed"

  String? reason; // for skipped/missed

  String? effectiveness;
  // "helped_a_lot"|"helped_a_little"|"no_effect"|"made_it_worse"

  String? notes;

  int? flareIsarId; // nullable; back-filled when FlareIsar lands in v8

  DoseLog toDomain() => DoseLog(
    id: id,
    profileId: profileId,
    medicationIsarId: medicationIsarId,
    loggedAt: loggedAt,
    createdAt: createdAt,
    amount: amount,
    unit: unit,
    status: status,
    reason: reason,
    effectiveness: effectiveness,
    notes: notes,
    flareIsarId: flareIsarId,
  );

  static DoseLogIsar fromDomain(DoseLog d) => DoseLogIsar()
    ..id = d.id
    ..profileId = d.profileId
    ..medicationIsarId = d.medicationIsarId
    ..loggedAt = d.loggedAt
    ..createdAt = d.createdAt
    ..amount = d.amount
    ..unit = d.unit
    ..status = d.status
    ..reason = d.reason
    ..effectiveness = d.effectiveness
    ..notes = d.notes
    ..flareIsarId = d.flareIsarId;
}

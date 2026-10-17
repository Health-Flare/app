import 'package:isar_community/isar.dart';
import 'package:health_flare/models/vital_entry.dart';
import 'package:health_flare/models/vital_type.dart';

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

  /// Taken out of its flare by hand (#173).
  bool flareDetached = false;

  VitalEntry toDomain() => VitalEntry(
    id: id,
    profileId: profileId,
    vitalType: VitalType.fromString(vitalType),
    value: value,
    value2: value2,
    unit: unit,
    notes: notes,
    loggedAt: loggedAt,
    createdAt: createdAt,
    flareIsarId: flareIsarId,
    flareDetached: flareDetached,
  );

  static VitalEntryIsar fromDomain(VitalEntry e) => VitalEntryIsar()
    ..id = e.id
    ..profileId = e.profileId
    ..vitalType = e.vitalType.name
    ..value = e.value
    ..value2 = e.value2
    ..unit = e.unit
    ..notes = e.notes
    ..loggedAt = e.loggedAt
    ..createdAt = e.createdAt
    ..flareIsarId = e.flareIsarId
    ..flareDetached = e.flareDetached;
}

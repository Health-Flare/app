import 'package:isar_community/isar.dart';
import 'package:health_flare/models/symptom_entry.dart';

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

  SymptomEntry toDomain() => SymptomEntry(
    id: id,
    profileId: profileId,
    name: name,
    userSymptomIsarId: userSymptomIsarId,
    userConditionIsarId: userConditionIsarId,
    severity: severity,
    notes: notes,
    loggedAt: loggedAt,
    createdAt: createdAt,
    flareIsarId: flareIsarId,
  );

  static SymptomEntryIsar fromDomain(SymptomEntry e) => SymptomEntryIsar()
    ..id = e.id
    ..profileId = e.profileId
    ..name = e.name
    ..userSymptomIsarId = e.userSymptomIsarId
    ..userConditionIsarId = e.userConditionIsarId
    ..severity = e.severity
    ..notes = e.notes
    ..loggedAt = e.loggedAt
    ..createdAt = e.createdAt
    ..flareIsarId = e.flareIsarId;
}

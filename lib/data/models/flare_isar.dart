import 'package:isar_community/isar.dart';
import 'package:health_flare/models/flare.dart';

part 'flare_isar.g.dart';

@collection
class FlareIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  @Index()
  late DateTime startedAt;

  DateTime? endedAt; // null = active flare

  List<int> conditionIsarIds = []; // links to UserConditionIsar.id

  int? initialSeverity; // 1–10

  int? peakSeverity; // 1–10 at peak or end

  String? notes;

  late DateTime createdAt;

  DateTime? updatedAt;

  Flare toDomain() => Flare(
    id: id,
    profileId: profileId,
    startedAt: startedAt,
    endedAt: endedAt,
    conditionIsarIds: List.unmodifiable(conditionIsarIds),
    initialSeverity: initialSeverity,
    peakSeverity: peakSeverity,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static FlareIsar fromDomain(Flare f) => FlareIsar()
    ..id = f.id
    ..profileId = f.profileId
    ..startedAt = f.startedAt
    ..endedAt = f.endedAt
    ..conditionIsarIds = List.of(f.conditionIsarIds)
    ..initialSeverity = f.initialSeverity
    ..peakSeverity = f.peakSeverity
    ..notes = f.notes
    ..createdAt = f.createdAt
    ..updatedAt = f.updatedAt;
}

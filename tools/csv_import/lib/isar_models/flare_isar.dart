import 'package:isar_community/isar.dart';

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

}

import 'package:isar_community/isar.dart';

import 'package:health_flare/models/elimination_entry.dart';

part 'elimination_entry_isar.g.dart';

@collection
class EliminationEntryIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  @Index()
  late DateTime loggedAt;

  /// `bowel` or `bladder`.
  late String kind;

  int? bristolType;

  int count = 1;

  bool blood = false;

  bool urgency = false;

  String? notes;

  late DateTime createdAt;

  EliminationEntry toDomain() => EliminationEntry(
    id: id,
    profileId: profileId,
    loggedAt: loggedAt,
    kind: kind,
    bristolType: bristolType,
    count: count,
    blood: blood,
    urgency: urgency,
    notes: notes,
    createdAt: createdAt,
  );
}

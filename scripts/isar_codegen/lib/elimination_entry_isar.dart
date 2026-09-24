import 'package:isar_community/isar.dart';

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
}

import 'package:isar_community/isar.dart';

part 'journal_entry_isar.g.dart';

@embedded
class JournalSnapshotIsar {
  JournalSnapshotIsar();
  late String body;
  String? title;
  late DateTime savedAt;
}

@collection
class JournalEntryIsar {
  Id id = Isar.autoIncrement;
  @Index()
  late int profileId;
  @Index()
  late DateTime createdAt;
  late List<JournalSnapshotIsar> snapshots;
  int? mood;
  int? energyLevel;
}

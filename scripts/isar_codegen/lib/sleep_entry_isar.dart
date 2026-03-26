import 'package:isar_community/isar.dart';

part 'sleep_entry_isar.g.dart';

@collection
class SleepEntryIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  late DateTime bedtime;

  /// Indexed so we can query entries by date (wake-up day).
  @Index()
  late DateTime wakeTime;

  /// 1–5 quality rating. Null when not rated.
  int? qualityRating;

  String? notes;

  late bool isNap;

  late DateTime createdAt;
}

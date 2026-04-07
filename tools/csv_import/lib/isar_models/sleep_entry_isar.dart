import 'package:isar_community/isar.dart';

part 'sleep_entry_isar.g.dart';

/// Isar-annotated storage representation of a [SleepEntry].
///
/// Indexed on [profileId] (to load all entries for one profile) and
/// [wakeTime] (to sort by date and detect duplicate-day naps).
@collection
class SleepEntryIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  late DateTime bedtime;

  /// Indexed so we can sort and query by the day the user woke up.
  @Index()
  late DateTime wakeTime;

  /// 1–5 quality rating. Null when not rated.
  int? qualityRating;

  String? notes;

  late bool isNap;

  late DateTime createdAt;

}

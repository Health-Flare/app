import 'package:isar_community/isar.dart';

import 'package:health_flare/models/sleep_entry.dart';

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

  // ── Conversion ────────────────────────────────────────────────────────────

  SleepEntry toDomain() => SleepEntry(
    id: id,
    profileId: profileId,
    bedtime: bedtime,
    wakeTime: wakeTime,
    qualityRating: qualityRating,
    notes: notes,
    isNap: isNap,
    createdAt: createdAt,
  );

  static SleepEntryIsar fromDomain(SleepEntry e) => SleepEntryIsar()
    ..id = e.id
    ..profileId = e.profileId
    ..bedtime = e.bedtime
    ..wakeTime = e.wakeTime
    ..qualityRating = e.qualityRating
    ..notes = e.notes
    ..isNap = e.isNap
    ..createdAt = e.createdAt;
}

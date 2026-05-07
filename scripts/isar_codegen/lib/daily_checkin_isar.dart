import 'package:isar_community/isar.dart';

import 'weather_snapshot_isar.dart';

part 'daily_checkin_isar.g.dart';

@collection
class DailyCheckinIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  /// Date-only anchor for this check-in (time component ignored).
  /// Unique per profileId + checkinDate — enforced in the provider.
  @Index()
  late DateTime checkinDate;

  /// Overall wellbeing rating 1–10.
  late int wellbeing;

  /// "low" | "medium" | "high" — optional.
  String? stressLevel;

  /// "period" | "follicular" | "ovulation" | "luteal" | "not_sure" — optional.
  /// Only shown when profile.cycleTrackingEnabled == true.
  String? cyclePhase;

  String? notes;

  late DateTime createdAt;

  DateTime? updatedAt;

  WeatherSnapshotIsar? weatherSnapshot;
}

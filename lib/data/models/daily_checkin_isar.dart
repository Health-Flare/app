import 'package:isar_community/isar.dart';

import 'package:health_flare/models/daily_checkin.dart';

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

  // ── Conversion ────────────────────────────────────────────────────────────

  DailyCheckin toDomain() => DailyCheckin(
    id: id,
    profileId: profileId,
    checkinDate: checkinDate,
    wellbeing: wellbeing,
    stressLevel: stressLevel,
    cyclePhase: cyclePhase,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static DailyCheckinIsar fromDomain(DailyCheckin c) => DailyCheckinIsar()
    ..id = c.id
    ..profileId = c.profileId
    ..checkinDate = c.checkinDate
    ..wellbeing = c.wellbeing
    ..stressLevel = c.stressLevel
    ..cyclePhase = c.cyclePhase
    ..notes = c.notes
    ..createdAt = c.createdAt
    ..updatedAt = c.updatedAt;
}

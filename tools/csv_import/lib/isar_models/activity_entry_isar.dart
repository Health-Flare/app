import 'package:isar_community/isar.dart';

part 'activity_entry_isar.g.dart';

@collection
class ActivityEntryIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  late String description;

  /// Broad type: 'walking'|'gentle_exercise'|'household'|'work'|
  /// 'social'|'medical'|'rest'|'other'. Null = not specified.
  String? activityType;

  /// Perceived effort 1 (very light) – 5 (maximum). Null = not set.
  int? effortLevel;

  /// Duration in minutes. Null = not recorded.
  int? durationMinutes;

  @Index()
  late DateTime loggedAt;

  late DateTime createdAt;

  DateTime? updatedAt;

  String? notes;

  /// Set when logged during an active flare.
  int? flareIsarId;

}

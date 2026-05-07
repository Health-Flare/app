import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/weather_snapshot_isar.dart';
import 'package:health_flare/models/meal_entry.dart';

part 'meal_entry_isar.g.dart';

@collection
class MealEntryIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  late String description;

  String? notes;

  String? photoPath; // absolute path to local image file; null = no photo

  late bool hasReaction; // user-flagged reaction after this meal

  @Index()
  late DateTime loggedAt;

  late DateTime createdAt;

  DateTime? updatedAt;

  int? flareIsarId; // back-filled when FlareIsar lands in v9

  WeatherSnapshotIsar? weatherSnapshot;

  MealEntry toDomain() => MealEntry(
    id: id,
    profileId: profileId,
    description: description,
    notes: notes,
    photoPath: photoPath,
    hasReaction: hasReaction,
    loggedAt: loggedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    flareIsarId: flareIsarId,
    weatherSnapshot: weatherSnapshot?.toDomain(),
  );

  static MealEntryIsar fromDomain(MealEntry e) => MealEntryIsar()
    ..id = e.id
    ..profileId = e.profileId
    ..description = e.description
    ..notes = e.notes
    ..photoPath = e.photoPath
    ..hasReaction = e.hasReaction
    ..loggedAt = e.loggedAt
    ..createdAt = e.createdAt
    ..updatedAt = e.updatedAt
    ..flareIsarId = e.flareIsarId
    ..weatherSnapshot = e.weatherSnapshot != null
        ? WeatherSnapshotIsar.fromDomain(e.weatherSnapshot!)
        : null;
}

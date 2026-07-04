import 'package:isar_community/isar.dart';

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
}

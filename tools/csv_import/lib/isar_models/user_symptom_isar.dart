import 'package:isar_community/isar.dart';

part 'user_symptom_isar.g.dart';

/// Isar-annotated storage representation of a profile's tracked [UserSymptom].
///
/// [symptomName] is denormalised so that list views don't need a join query.
@collection
class UserSymptomIsar {
  Id id = Isar.autoIncrement;

  /// Foreign key to the owning profile.
  @Index()
  late int profileId;

  /// Foreign key to the catalogue [SymptomIsar].
  @Index()
  late int symptomId;

  /// Denormalised display name (copied from [SymptomIsar.name] at save time).
  late String symptomName;

  /// When the user started tracking this symptom.
  late DateTime trackedSince;

}

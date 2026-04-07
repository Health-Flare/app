import 'package:isar_community/isar.dart';

part 'symptom_isar.g.dart';

/// Isar-annotated storage representation of a catalogue [Symptom].
///
/// Seeded from [SeedData.symptoms] once per install (see [MigrationRunner]).
/// Users may also create custom symptoms with [global] = false.
@collection
class SymptomIsar {
  Id id = Isar.autoIncrement;

  /// Display name. Case-insensitive index supports prefix search queries.
  @Index(caseSensitive: false)
  late String name;

  /// True for seed data; false for user-created custom symptoms.
  late bool global;

}

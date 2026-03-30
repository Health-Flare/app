import 'package:isar_community/isar.dart';

part 'condition_isar.g.dart';

/// Isar-annotated storage representation of a catalogue [Condition].
///
/// Seeded from [SeedData.conditions] once per install (see [MigrationRunner]).
/// Users may also create custom conditions with [global] = false.
@collection
class ConditionIsar {
  Id id = Isar.autoIncrement;

  /// Display name. Case-insensitive index supports prefix search queries.
  @Index(caseSensitive: false)
  late String name;

  /// True for seed data; false for user-created custom conditions.
  late bool global;

}

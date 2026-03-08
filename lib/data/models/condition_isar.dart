import 'package:isar_community/isar.dart';

import 'package:health_flare/models/condition.dart';

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

  // ── Conversion ────────────────────────────────────────────────────────────

  Condition toDomain() => Condition(id: id, name: name, global: global);

  static ConditionIsar fromDomain(Condition c) => ConditionIsar()
    ..id = c.id
    ..name = c.name
    ..global = c.global;
}

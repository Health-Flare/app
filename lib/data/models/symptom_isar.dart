import 'package:isar_community/isar.dart';

import 'package:health_flare/models/symptom.dart';

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

  // ── Conversion ────────────────────────────────────────────────────────────

  Symptom toDomain() => Symptom(id: id, name: name, global: global);

  static SymptomIsar fromDomain(Symptom s) => SymptomIsar()
    ..id = s.id
    ..name = s.name
    ..global = s.global;
}

/// Immutable domain model for a symptom in the global catalogue.
///
/// [global] = true for seed data from the Flaredown catalogue.
/// [global] = false for symptoms created by the user themselves.
class Symptom {
  const Symptom({required this.id, required this.name, this.global = true});

  final int id;
  final String name;
  final bool global;

  Symptom copyWith({String? name, bool? global}) =>
      Symptom(id: id, name: name ?? this.name, global: global ?? this.global);

  @override
  bool operator ==(Object other) => other is Symptom && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Symptom(id: $id, name: $name)';
}

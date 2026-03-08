/// Immutable domain model for a condition/illness in the global catalogue.
///
/// [global] = true for seed data from the Flaredown catalogue.
/// [global] = false for conditions created by the user themselves.
class Condition {
  const Condition({required this.id, required this.name, this.global = true});

  final int id;
  final String name;
  final bool global;

  Condition copyWith({String? name, bool? global}) =>
      Condition(id: id, name: name ?? this.name, global: global ?? this.global);

  @override
  bool operator ==(Object other) => other is Condition && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Condition(id: $id, name: $name)';
}

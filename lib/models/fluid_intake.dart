import 'package:flutter/foundation.dart';

/// A fluid intake record. Volume is stored in millilitres so daily totals
/// don't depend on the unit the person typed.
@immutable
class FluidIntake {
  const FluidIntake({
    required this.id,
    required this.profileId,
    required this.loggedAt,
    required this.volumeMl,
    this.drinkType,
    this.notes,
    required this.createdAt,
  });

  final int id;
  final int profileId;
  final DateTime loggedAt;
  final int volumeMl;
  final String? drinkType;
  final String? notes;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FluidIntake && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

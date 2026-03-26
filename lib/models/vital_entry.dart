import 'package:flutter/foundation.dart';
import 'package:health_flare/models/vital_type.dart';

@immutable
class VitalEntry {
  const VitalEntry({
    required this.id,
    required this.profileId,
    required this.vitalType,
    required this.value,
    this.value2,
    required this.unit,
    this.notes,
    required this.loggedAt,
    required this.createdAt,
    this.flareIsarId,
  });

  final int id;
  final int profileId;
  final VitalType vitalType;
  final double value;
  final double? value2; // diastolic for BP
  final String unit;
  final String? notes;
  final DateTime loggedAt;
  final DateTime createdAt;
  final int? flareIsarId;

  /// Display string e.g. "72 BPM" or "120/80 mmHg"
  String get displayValue {
    if (value2 != null) {
      return '${value.toStringAsFixed(0)}/${value2!.toStringAsFixed(0)} $unit';
    }
    final formatted = value == value.truncateToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
    return '$formatted $unit';
  }

  VitalEntry copyWith({
    VitalType? vitalType,
    double? value,
    double? value2,
    String? unit,
    String? notes,
    DateTime? loggedAt,
    bool clearNotes = false,
    bool clearValue2 = false,
  }) {
    return VitalEntry(
      id: id,
      profileId: profileId,
      vitalType: vitalType ?? this.vitalType,
      value: value ?? this.value,
      value2: clearValue2 ? null : (value2 ?? this.value2),
      unit: unit ?? this.unit,
      notes: clearNotes ? null : (notes ?? this.notes),
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt,
      flareIsarId: flareIsarId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is VitalEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

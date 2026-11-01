import 'package:flutter/foundation.dart';
import 'package:health_flare/models/vital_type.dart';
import 'package:health_flare/models/vital_units.dart';

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
    this.flareDetached = false,
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

  /// Taken out of its flare by hand (#173). Which flare an entry is part
  /// of is worked out from its time ([flareFor]); this overrides it.
  final bool flareDetached;

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

  /// [displayValue] with temperature or height converted to the profile's
  /// display unit. Null shows the reading as logged. Other vital types are
  /// always shown as logged.
  String displayValueIn({String? temperatureUnit, String? heightUnit}) {
    final preferredUnit = switch (vitalType) {
      VitalType.temperature => temperatureUnit,
      VitalType.height => heightUnit,
      _ => null,
    };
    if (preferredUnit == null ||
        !vitalType.availableUnits.contains(preferredUnit) ||
        (vitalType == VitalType.temperature && preferredUnit == unit)) {
      return displayValue;
    }
    final converted = VitalUnits.convert(value, from: unit, to: preferredUnit);
    final decimals = switch ((vitalType, preferredUnit)) {
      (VitalType.height, 'cm') => 0,
      (VitalType.height, 'in') => 1,
      _ => 1,
    };
    return '${converted.toStringAsFixed(decimals)} $preferredUnit';
  }

  VitalEntry copyWith({
    VitalType? vitalType,
    double? value,
    double? value2,
    String? unit,
    String? notes,
    DateTime? loggedAt,
    bool? flareDetached,
    bool clearFlareIsarId = false,
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
      flareIsarId: clearFlareIsarId ? null : flareIsarId,
      flareDetached: flareDetached ?? this.flareDetached,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is VitalEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

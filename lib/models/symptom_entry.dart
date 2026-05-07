import 'package:flutter/foundation.dart';

import 'package:health_flare/models/weather_snapshot.dart';

@immutable
class SymptomEntry {
  const SymptomEntry({
    required this.id,
    required this.profileId,
    required this.name,
    this.userSymptomIsarId,
    this.userConditionIsarId,
    required this.severity,
    this.notes,
    required this.loggedAt,
    required this.createdAt,
    this.flareIsarId,
    this.weatherSnapshot,
  });

  final int id;
  final int profileId;
  final String name;
  final int? userSymptomIsarId;
  final int? userConditionIsarId;
  final int severity; // 1–10
  final String? notes;
  final DateTime loggedAt;
  final DateTime createdAt;
  final int? flareIsarId;
  final WeatherSnapshot? weatherSnapshot;

  SymptomEntry copyWith({
    String? name,
    int? userSymptomIsarId,
    int? userConditionIsarId,
    int? severity,
    String? notes,
    DateTime? loggedAt,
    WeatherSnapshot? weatherSnapshot,
    bool clearNotes = false,
    bool clearUserSymptomIsarId = false,
  }) {
    return SymptomEntry(
      id: id,
      profileId: profileId,
      name: name ?? this.name,
      userSymptomIsarId: clearUserSymptomIsarId
          ? null
          : (userSymptomIsarId ?? this.userSymptomIsarId),
      userConditionIsarId: userConditionIsarId ?? this.userConditionIsarId,
      severity: severity ?? this.severity,
      notes: clearNotes ? null : (notes ?? this.notes),
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt,
      flareIsarId: flareIsarId,
      weatherSnapshot: weatherSnapshot ?? this.weatherSnapshot,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SymptomEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

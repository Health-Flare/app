import 'package:flutter/foundation.dart';

import 'package:health_flare/models/weather_snapshot.dart';

@immutable
class MealEntry {
  const MealEntry({
    required this.id,
    required this.profileId,
    required this.description,
    this.notes,
    this.photoPath,
    required this.hasReaction,
    required this.loggedAt,
    required this.createdAt,
    this.updatedAt,
    this.flareIsarId,
    this.flareDetached = false,
    this.weatherSnapshot,
  });

  final int id;
  final int profileId;
  final String description;
  final String? notes;
  final String? photoPath; // absolute path to local image file; null = no photo
  final bool hasReaction;
  final DateTime loggedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? flareIsarId; // set when logged during an active flare
  /// Taken out of its flare by hand (#173). Which flare an entry is part
  /// of is worked out from its time ([flareFor]); this overrides it.
  final bool flareDetached;
  final WeatherSnapshot? weatherSnapshot;

  MealEntry copyWith({
    String? description,
    String? notes,
    String? photoPath,
    bool? hasReaction,
    DateTime? loggedAt,
    DateTime? updatedAt,
    int? flareIsarId,
    WeatherSnapshot? weatherSnapshot,
    bool? flareDetached,
    bool clearFlareIsarId = false,
    bool clearNotes = false,
    bool clearPhotoPath = false,
  }) {
    return MealEntry(
      id: id,
      profileId: profileId,
      description: description ?? this.description,
      notes: clearNotes ? null : (notes ?? this.notes),
      photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
      hasReaction: hasReaction ?? this.hasReaction,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      flareIsarId: clearFlareIsarId ? null : (flareIsarId ?? this.flareIsarId),
      flareDetached: flareDetached ?? this.flareDetached,
      weatherSnapshot: weatherSnapshot ?? this.weatherSnapshot,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MealEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

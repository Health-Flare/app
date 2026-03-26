import 'package:flutter/foundation.dart';

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

  MealEntry copyWith({
    String? description,
    String? notes,
    String? photoPath,
    bool? hasReaction,
    DateTime? loggedAt,
    DateTime? updatedAt,
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MealEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

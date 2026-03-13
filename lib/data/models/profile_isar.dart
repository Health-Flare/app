import 'package:isar_community/isar.dart';

import 'package:health_flare/models/profile.dart';

part 'profile_isar.g.dart';

/// Isar-annotated storage representation of a [Profile].
///
/// Uses mutable fields as required by Isar. Converted to/from the immutable
/// [Profile] domain class at the provider boundary — UI code never
/// interacts with this class directly.
@collection
class ProfileIsar {
  /// Auto-increment id assigned by Isar on first [put()].
  /// After [put()], this field holds the assigned id.
  Id id = Isar.autoIncrement;

  late String name;

  DateTime? dateOfBirth;

  String? avatarPath;

  /// Whether the first-log prompt has been shown for this profile.
  /// Set to true the moment the prompt is displayed — never shown again after.
  bool firstLogShown = false;

  /// Whether the user opted in to weather tracking for this profile.
  bool weatherTrackingEnabled = false;

  /// Whether the weather opt-in prompt has been shown for this profile.
  bool weatherOptInShown = false;

  // ── Conversion ────────────────────────────────────────────────────────────

  /// Convert to the immutable domain class used by the UI.
  Profile toDomain() => Profile(
    id: id,
    name: name,
    dateOfBirth: dateOfBirth,
    avatarPath: avatarPath,
    weatherTrackingEnabled: weatherTrackingEnabled,
  );

  /// Construct from a domain [Profile] for writing to Isar.
  ///
  /// Note: internal-only flags ([firstLogShown], [weatherOptInShown]) are NOT
  /// carried on the domain model. Callers that need a safe update should
  /// read the existing row from Isar and mutate it directly (read-modify-write)
  /// rather than calling this method, to avoid clobbering those flags.
  static ProfileIsar fromDomain(Profile p) => ProfileIsar()
    ..id = p.id
    ..name = p.name
    ..dateOfBirth = p.dateOfBirth
    ..avatarPath = p.avatarPath
    ..weatherTrackingEnabled = p.weatherTrackingEnabled;
}

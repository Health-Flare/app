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

  // ── Conversion ────────────────────────────────────────────────────────────

  /// Convert to the immutable domain class used by the UI.
  Profile toDomain() => Profile(
        id: id,
        name: name,
        dateOfBirth: dateOfBirth,
        avatarPath: avatarPath,
      );

  /// Construct from a domain [Profile] for writing to Isar.
  static ProfileIsar fromDomain(Profile p) => ProfileIsar()
    ..id = p.id
    ..name = p.name
    ..dateOfBirth = p.dateOfBirth
    ..avatarPath = p.avatarPath;
}

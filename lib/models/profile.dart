/// Represents a tracked person in Health Flare.
///
/// MVP: plain Dart class, held in memory via [ProfileListNotifier].
/// When the Isar data layer is added this will gain `@Collection()`,
/// `@Id()`, and generated code — the field names and types are chosen
/// to be Isar-compatible from the start so the migration is minimal.
///
/// Future intent (per requirements §2): profiles are designed to become
/// standalone accounts. The [id] field will map to the Isar document id
/// and later to a remote user id — keep it stable.
class Profile {
  Profile({
    required this.id,
    required this.name,
    this.dateOfBirth,
    this.avatarPath,
  });

  /// Stable local identifier. In the in-memory MVP this is a simple
  /// incrementing int. Isar will manage this automatically later.
  final int id;

  /// Display name — always present.
  final String name;

  /// Optional date of birth. Used in reports.
  final DateTime? dateOfBirth;

  /// Filesystem path to the chosen avatar image, or null for the default
  /// generated avatar. Set by image_picker when that layer is wired up.
  final String? avatarPath;

  /// Returns true if this profile has a real photo rather than a generated one.
  bool get hasAvatar => avatarPath != null;

  /// Produces initials from the display name (up to two characters).
  /// Used as the avatar placeholder when no photo is set.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(1, 2))
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Returns a human-readable age string if [dateOfBirth] is set.
  String? get ageLabel {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return '$age years old';
  }

  Profile copyWith({
    String? name,
    DateTime? dateOfBirth,
    String? avatarPath,
    bool clearDateOfBirth = false,
    bool clearAvatar = false,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
    );
  }

  @override
  String toString() => 'Profile(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Profile && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

/// Simple counter for generating unique in-memory ids.
/// Replaced by Isar auto-increment when the DB layer is added.
class ProfileIdGenerator {
  ProfileIdGenerator._();
  static int _next = 1;
  static int next() => _next++;
}

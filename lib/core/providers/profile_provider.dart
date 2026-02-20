import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/profile.dart';

// ---------------------------------------------------------------------------
// Profile list — all profiles on this device
// ---------------------------------------------------------------------------

/// Holds the ordered list of all profiles.
///
/// MVP: in-memory only. Replace [build] and mutating methods with Isar
/// reads/writes when the database layer is added. The public API
/// (add, update, remove, reorder) is intentionally the same shape that
/// an Isar-backed notifier would expose.
class ProfileListNotifier extends Notifier<List<Profile>> {
  @override
  List<Profile> build() => [];

  /// Add a new profile. Makes it active immediately.
  void add(Profile profile) {
    state = [...state, profile];
    ref.read(activeProfileProvider.notifier).setActive(profile.id);
  }

  /// Replace an existing profile by id, preserving list order.
  void update(Profile updated) {
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p,
    ];
  }

  /// Remove a profile by id.
  ///
  /// If the removed profile was active, switches to the first remaining
  /// profile, or clears the active id if none remain.
  void remove(int id) {
    state = state.where((p) => p.id != id).toList();

    final activeId = ref.read(activeProfileProvider);
    if (activeId == id) {
      final next = state.isNotEmpty ? state.first.id : null;
      ref.read(activeProfileProvider.notifier).setActive(next);
    }
  }

  /// Convenience: look up a profile by id, or null if not found.
  Profile? byId(int id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

final profileListProvider =
    NotifierProvider<ProfileListNotifier, List<Profile>>(
  ProfileListNotifier.new,
);

// ---------------------------------------------------------------------------
// Active profile id
// ---------------------------------------------------------------------------

/// Holds the id of the currently active profile (null = none selected yet).
class ActiveProfileNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setActive(int? id) => state = id;
}

final activeProfileProvider =
    NotifierProvider<ActiveProfileNotifier, int?>(ActiveProfileNotifier.new);

// ---------------------------------------------------------------------------
// Derived: the active Profile object
// ---------------------------------------------------------------------------

/// Combines [profileListProvider] and [activeProfileProvider] to expose
/// the full [Profile] object for the active profile.
///
/// Returns null if no profiles exist or none is selected.
final activeProfileDataProvider = Provider<Profile?>((ref) {
  final id = ref.watch(activeProfileProvider);
  if (id == null) return null;
  final profiles = ref.watch(profileListProvider);
  try {
    return profiles.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});

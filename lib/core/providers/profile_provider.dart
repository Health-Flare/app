import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/database/app_settings.dart';
import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/data/models/profile_isar.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/core/providers/database_provider.dart';

// ---------------------------------------------------------------------------
// Helpers — AppSettings access
// ---------------------------------------------------------------------------

Future<AppSettings> _getOrCreateSettings(Isar isar) async {
  return await isar.appSettings.get(1) ?? AppSettings();
}

Future<int?> _readActiveProfileId(Isar isar) async {
  final settings = await _getOrCreateSettings(isar);
  return settings.activeProfileId;
}

Future<void> _writeActiveProfileId(Isar isar, int? id) async {
  await isar.writeTxn(() async {
    final settings = await _getOrCreateSettings(isar);
    settings.activeProfileId = id;
    await isar.appSettings.put(settings);
  });
}

// ---------------------------------------------------------------------------
// Profile list — all profiles on this device
// ---------------------------------------------------------------------------

/// Holds the ordered list of all profiles.
///
/// Uses a synchronous [Notifier] (state type [List<Profile>]) so that all
/// existing UI consumers of [profileListProvider] continue to work unchanged.
/// Data is loaded asynchronously in [_init] and the [watchLazy] subscription
/// keeps the list up to date whenever Isar writes occur.
class ProfileListNotifier extends Notifier<List<Profile>> {
  List<Profile>? _preloadedState;

  /// Called from [main] before [runApp] to seed the initial state.
  void preload(List<Profile> profiles) => _preloadedState = profiles;

  @override
  List<Profile> build() {
    final isar = ref.read(isarProvider);

    final subscription = isar.profileIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);

    // If main() pre-loaded data, use it immediately (no blank-frame flash).
    // Otherwise kick off an async load (e.g. during hot restart).
    final seeded = _preloadedState;
    if (seeded != null) {
      _preloadedState = null;
      return seeded;
    }
    _reload(isar);
    return [];
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.profileIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Add a new profile. Isar assigns its id; the new profile becomes active.
  Future<void> add({
    required String name,
    DateTime? dateOfBirth,
    String? avatarPath,
  }) async {
    final isar = ref.read(isarProvider);
    final row = ProfileIsar()
      ..id = Isar.autoIncrement
      ..name = name
      ..dateOfBirth = dateOfBirth
      ..avatarPath = avatarPath;
    await isar.writeTxn(() async {
      await isar.profileIsars.put(row);
    });
    // row.id now holds the Isar-assigned id.
    await ref.read(activeProfileProvider.notifier).setActive(row.id);
  }

  /// Replace an existing profile by id.
  Future<void> update(Profile updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.profileIsars.put(ProfileIsar.fromDomain(updated));
    });
  }

  /// Remove a profile by id. Cascades to delete all its journal entries.
  ///
  /// If the removed profile was active, switches to the first remaining
  /// profile, or clears the active id if none remain.
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      // Cascade-delete all journal entries belonging to this profile.
      final entryIds = await isar.journalEntryIsars
          .where()
          .profileIdEqualTo(id)
          .idProperty()
          .findAll();
      await isar.journalEntryIsars.deleteAll(entryIds);

      await isar.profileIsars.delete(id);
    });

    final currentActive = ref.read(activeProfileProvider);
    if (currentActive == id) {
      final remaining = await isar.profileIsars.where().findAll();
      final nextId = remaining.isNotEmpty ? remaining.first.id : null;
      await ref.read(activeProfileProvider.notifier).setActive(nextId);
    }
  }

  /// Convenience: look up a profile by id from the in-memory state cache.
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
///
/// On first build, the persisted value is loaded from [AppSettings].
/// [setActive] updates state immediately then persists in the background.
class ActiveProfileNotifier extends Notifier<int?> {
  int? _preloadedState;
  bool _hasPreload = false;

  /// Called from [main] before [runApp] to seed the initial state.
  void preload(int? id) {
    _preloadedState = id;
    _hasPreload = true;
  }

  @override
  int? build() {
    // If main() pre-loaded the active profile id, use it immediately.
    if (_hasPreload) {
      _hasPreload = false;
      return _preloadedState;
    }
    // Fallback for hot restart: async load from DB.
    _loadFromDb();
    return null;
  }

  Future<void> _loadFromDb() async {
    final isar = ref.read(isarProvider);
    final id = await _readActiveProfileId(isar);
    state = id;
  }

  Future<void> setActive(int? id) async {
    state = id; // Update immediately for a responsive UI.
    final isar = ref.read(isarProvider);
    await _writeActiveProfileId(isar, id);
  }
}

final activeProfileProvider = NotifierProvider<ActiveProfileNotifier, int?>(
  ActiveProfileNotifier.new,
);

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

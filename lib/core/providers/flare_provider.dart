import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/flare_isar.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Flare list — all flares across all profiles
// ---------------------------------------------------------------------------

/// Holds all flares for all profiles.
///
/// Uses a synchronous [Notifier] with async [_init] + [watchLazy] pattern.
/// Per-profile views are derived in [activeProfileFlaresProvider] and
/// [activeFlareProvider].
class FlareListNotifier extends Notifier<List<Flare>> {
  @override
  List<Flare> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);

    final subscription = isar.flareIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);

    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.flareIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Start a new flare. Returns the Isar-assigned id.
  ///
  /// Throws a [StateError] if the profile already has an active flare.
  Future<int> add({
    required int profileId,
    required DateTime startedAt,
    List<int> conditionIsarIds = const [],
    int? initialSeverity,
    String? notes,
  }) async {
    // Enforce one active flare per profile.
    final existing = state.where((f) => f.profileId == profileId && f.isActive);
    if (existing.isNotEmpty) {
      throw StateError('Profile $profileId already has an active flare.');
    }

    final isar = ref.read(isarProvider);
    final row = FlareIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..startedAt = startedAt
      ..conditionIsarIds = List.of(conditionIsarIds)
      ..initialSeverity = initialSeverity
      ..notes = notes
      ..createdAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.flareIsars.put(row);
    });
    return row.id;
  }

  /// Update an existing flare (e.g. end it or change severity/notes).
  Future<void> update(Flare updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.flareIsars.put(FlareIsar.fromDomain(updated));
    });
  }

  /// Delete a flare. Does NOT delete entries tagged with it —
  /// their [flareIsarId] is left as-is (orphaned).
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.flareIsars.delete(id);
    });
  }

  /// Convenience: look up a flare by id from the in-memory state cache.
  Flare? byId(int id) {
    try {
      return state.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}

final flareListProvider = NotifierProvider<FlareListNotifier, List<Flare>>(
  FlareListNotifier.new,
);

// ---------------------------------------------------------------------------
// Active profile's flares — sorted reverse-chronological
// ---------------------------------------------------------------------------

final activeProfileFlaresProvider = Provider<List<Flare>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final flares = ref.watch(flareListProvider);
  return flares.where((f) => f.profileId == profileId).toList()
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
});

/// The currently active flare for the active profile, or null.
final activeFlareProvider = Provider<Flare?>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return null;
  final flares = ref.watch(flareListProvider);
  try {
    return flares.firstWhere((f) => f.profileId == profileId && f.isActive);
  } catch (_) {
    return null;
  }
});

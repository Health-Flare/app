import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/meal_entry_isar.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Meal entry list — all entries across all profiles
// ---------------------------------------------------------------------------

/// Holds all meal entries for all profiles.
///
/// Uses a synchronous [Notifier] so that all UI consumers work without
/// async concerns. Data is loaded in [_init] and [watchLazy] keeps the
/// list live whenever Isar writes occur.
///
/// Per-profile filtering is done in [activeProfileMealEntriesProvider].
class MealEntryListNotifier extends Notifier<List<MealEntry>> {
  @override
  List<MealEntry> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);

    final subscription = isar.mealEntryIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);

    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.mealEntryIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Add a new meal entry. Returns the Isar-assigned id.
  Future<int> add({
    required int profileId,
    required String description,
    String? notes,
    String? photoPath,
    required bool hasReaction,
    required DateTime loggedAt,
    int? flareIsarId,
  }) async {
    final isar = ref.read(isarProvider);
    final row = MealEntryIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..description = description
      ..notes = notes
      ..photoPath = photoPath
      ..hasReaction = hasReaction
      ..loggedAt = loggedAt
      ..createdAt = DateTime.now()
      ..flareIsarId = flareIsarId;
    await isar.writeTxn(() async {
      await isar.mealEntryIsars.put(row);
    });
    return row.id;
  }

  /// Replace an existing entry by id.
  Future<void> update(MealEntry updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.mealEntryIsars.put(MealEntryIsar.fromDomain(updated));
    });
  }

  /// Remove an entry by id.
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.mealEntryIsars.delete(id);
    });
  }

  /// Convenience: look up an entry by id from the in-memory state cache.
  MealEntry? byId(int id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

final mealEntryListProvider =
    NotifierProvider<MealEntryListNotifier, List<MealEntry>>(
      MealEntryListNotifier.new,
    );

// ---------------------------------------------------------------------------
// Active profile's meal entries
// ---------------------------------------------------------------------------

/// The meal entries for the currently active profile, in reverse
/// chronological order by loggedAt.
final activeProfileMealEntriesProvider = Provider<List<MealEntry>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final entries = ref.watch(mealEntryListProvider);
  return entries.where((e) => e.profileId == profileId).toList()
    ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
});

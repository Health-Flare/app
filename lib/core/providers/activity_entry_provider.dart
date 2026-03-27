import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/activity_entry_isar.dart';
import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Activity entry list — all entries across all profiles
// ---------------------------------------------------------------------------

/// Holds all activity entries for all profiles.
///
/// Uses a synchronous [Notifier] so that all UI consumers work without
/// async concerns. Data is loaded in [_init] and [watchLazy] keeps the
/// list live whenever Isar writes occur.
///
/// Per-profile filtering is done in [activeProfileActivityEntriesProvider].
class ActivityEntryListNotifier extends Notifier<List<ActivityEntry>> {
  @override
  List<ActivityEntry> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);

    final subscription = isar.activityEntryIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);

    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.activityEntryIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Add a new activity entry. Returns the Isar-assigned id.
  Future<int> add({
    required int profileId,
    required String description,
    ActivityType? activityType,
    int? effortLevel,
    int? durationMinutes,
    required DateTime loggedAt,
    String? notes,
    int? flareIsarId,
  }) async {
    final isar = ref.read(isarProvider);
    final now = DateTime.now();
    final row = ActivityEntryIsar()
      ..profileId = profileId
      ..description = description
      ..activityType = activityType?.value
      ..effortLevel = effortLevel
      ..durationMinutes = durationMinutes
      ..loggedAt = loggedAt
      ..createdAt = now
      ..notes = notes
      ..flareIsarId = flareIsarId;

    late int id;
    await isar.writeTxn(() async {
      id = await isar.activityEntryIsars.put(row);
    });
    return id;
  }

  /// Update an existing activity entry.
  Future<void> update(ActivityEntry entry) async {
    final isar = ref.read(isarProvider);
    final row = ActivityEntryIsar()
      ..id = entry.id
      ..profileId = entry.profileId
      ..description = entry.description
      ..activityType = entry.activityType?.value
      ..effortLevel = entry.effortLevel
      ..durationMinutes = entry.durationMinutes
      ..loggedAt = entry.loggedAt
      ..createdAt = entry.createdAt
      ..updatedAt = DateTime.now()
      ..notes = entry.notes
      ..flareIsarId = entry.flareIsarId;

    await isar.writeTxn(() async {
      await isar.activityEntryIsars.put(row);
    });
  }

  /// Delete an activity entry by id.
  Future<void> delete(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.activityEntryIsars.delete(id);
    });
  }
}

final activityEntryListProvider =
    NotifierProvider<ActivityEntryListNotifier, List<ActivityEntry>>(
      ActivityEntryListNotifier.new,
    );

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

/// All activity entries for the currently active profile,
/// sorted newest-first.
final activeProfileActivityEntriesProvider = Provider<List<ActivityEntry>>((
  ref,
) {
  final profileId = ref.watch(activeProfileProvider);
  final all = ref.watch(activityEntryListProvider);
  if (profileId == null) return [];
  return all.where((e) => e.profileId == profileId).toList()
    ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
});

/// The most recent activity entry for the active profile, or null.
final latestActivityEntryProvider = Provider<ActivityEntry?>((ref) {
  final entries = ref.watch(activeProfileActivityEntriesProvider);
  return entries.isEmpty ? null : entries.first;
});

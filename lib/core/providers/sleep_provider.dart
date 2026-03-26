import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/sleep_entry_isar.dart';
import 'package:health_flare/models/sleep_entry.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Sleep entry list — all entries across all profiles
// ---------------------------------------------------------------------------

/// Holds all sleep entries for all profiles.
///
/// Uses a synchronous [Notifier] (state type [List<SleepEntry>]) so all UI
/// consumers work without awaiting. Data is loaded asynchronously in [_init]
/// and [watchLazy] keeps it up to date after any Isar write.
///
/// Per-profile filtering is done in [activeSleepEntriesProvider].
class SleepEntryListNotifier extends Notifier<List<SleepEntry>> {
  @override
  List<SleepEntry> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);

    final subscription = isar.sleepEntryIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);

    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.sleepEntryIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Add a new sleep entry.
  ///
  /// Automatically sets [isNap] to true when a sleep entry already exists
  /// for the same calendar date (wake-up day) and profile.
  Future<void> add({
    required int profileId,
    required DateTime bedtime,
    required DateTime wakeTime,
    int? qualityRating,
    String? notes,
  }) async {
    final isar = ref.read(isarProvider);

    // Determine nap: is there already an entry on the same wake-up date?
    final wakeDate = DateTime(wakeTime.year, wakeTime.month, wakeTime.day);
    final existing = state.where((e) => e.profileId == profileId);
    final isNap = existing.any((e) => e.date == wakeDate);

    final row = SleepEntryIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..bedtime = bedtime
      ..wakeTime = wakeTime
      ..qualityRating = qualityRating
      ..notes = notes
      ..isNap = isNap
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.sleepEntryIsars.put(row);
    });
  }

  /// Replace an existing entry (used when editing).
  Future<void> update(SleepEntry updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.sleepEntryIsars.put(SleepEntryIsar.fromDomain(updated));
    });
  }

  /// Remove an entry by id.
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.sleepEntryIsars.delete(id);
    });
  }
}

final sleepEntryListProvider =
    NotifierProvider<SleepEntryListNotifier, List<SleepEntry>>(
      SleepEntryListNotifier.new,
    );

// ---------------------------------------------------------------------------
// Active profile's sleep entries
// ---------------------------------------------------------------------------

/// Sleep entries for the active profile, sorted most-recent first (by wakeTime).
final activeSleepEntriesProvider = Provider<List<SleepEntry>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final entries = ref.watch(sleepEntryListProvider);
  return entries.where((e) => e.profileId == profileId).toList()
    ..sort((a, b) => b.wakeTime.compareTo(a.wakeTime));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/symptom_entry_isar.dart';
import 'package:health_flare/data/models/weather_snapshot_isar.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/weather_snapshot.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Symptom entry list — all entries across all profiles
// ---------------------------------------------------------------------------

/// Holds all symptom entries for all profiles.
///
/// Uses a synchronous [Notifier] (state type [List<SymptomEntry>]) so that
/// all existing UI consumers continue to work unchanged. Data is loaded
/// asynchronously in [_init] and the [watchLazy] subscription keeps the
/// list up to date whenever Isar writes occur.
///
/// Per-profile filtering is done in [activeProfileSymptomEntriesProvider].
class SymptomEntryListNotifier extends Notifier<List<SymptomEntry>> {
  @override
  List<SymptomEntry> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);

    final subscription = isar.symptomEntryIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);

    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.symptomEntryIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Add a new symptom entry. Returns the Isar-assigned id.
  Future<int> add({
    required int profileId,
    required String name,
    required int severity,
    required DateTime loggedAt,
    String? notes,
    int? userSymptomIsarId,
    int? userConditionIsarId,
    int? flareIsarId,
    WeatherSnapshot? weatherSnapshot,
  }) async {
    final isar = ref.read(isarProvider);
    final row = SymptomEntryIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..name = name
      ..severity = severity
      ..loggedAt = loggedAt
      ..notes = notes
      ..userSymptomIsarId = userSymptomIsarId
      ..userConditionIsarId = userConditionIsarId
      ..flareIsarId = flareIsarId
      ..weatherSnapshot = weatherSnapshot != null
          ? WeatherSnapshotIsar.fromDomain(weatherSnapshot)
          : null
      ..createdAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.symptomEntryIsars.put(row);
    });
    return row.id;
  }

  /// Replace an existing entry by id.
  Future<void> update(SymptomEntry updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.symptomEntryIsars.put(SymptomEntryIsar.fromDomain(updated));
    });
  }

  /// Remove an entry by id.
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.symptomEntryIsars.delete(id);
    });
  }

  /// Convenience: look up an entry by id from the in-memory state cache.
  SymptomEntry? byId(int id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

final symptomEntryListProvider =
    NotifierProvider<SymptomEntryListNotifier, List<SymptomEntry>>(
      SymptomEntryListNotifier.new,
    );

// ---------------------------------------------------------------------------
// Active profile's symptom entries
// ---------------------------------------------------------------------------

/// The symptom entries for the currently active profile, in reverse
/// chronological order by loggedAt.
final activeProfileSymptomEntriesProvider = Provider<List<SymptomEntry>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final entries = ref.watch(symptomEntryListProvider);
  return entries.where((e) => e.profileId == profileId).toList()
    ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
});

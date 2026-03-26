import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/vital_entry_isar.dart';
import 'package:health_flare/models/vital_entry.dart';
import 'package:health_flare/models/vital_type.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Vital entry list — all entries across all profiles
// ---------------------------------------------------------------------------

/// Holds all vital entries for all profiles.
///
/// Uses a synchronous [Notifier] (state type [List<VitalEntry>]) so that
/// all existing UI consumers continue to work unchanged. Data is loaded
/// asynchronously in [_init] and the [watchLazy] subscription keeps the
/// list up to date whenever Isar writes occur.
///
/// Per-profile filtering is done in [activeProfileVitalEntriesProvider].
class VitalEntryListNotifier extends Notifier<List<VitalEntry>> {
  @override
  List<VitalEntry> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);

    final subscription = isar.vitalEntryIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);

    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.vitalEntryIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Add a new vital entry. Returns the Isar-assigned id.
  Future<int> add({
    required int profileId,
    required VitalType vitalType,
    required double value,
    double? value2,
    required String unit,
    required DateTime loggedAt,
    String? notes,
    int? flareIsarId,
  }) async {
    final isar = ref.read(isarProvider);
    final row = VitalEntryIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..vitalType = vitalType.name
      ..value = value
      ..value2 = value2
      ..unit = unit
      ..loggedAt = loggedAt
      ..notes = notes
      ..flareIsarId = flareIsarId
      ..createdAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.vitalEntryIsars.put(row);
    });
    return row.id;
  }

  /// Replace an existing entry by id.
  Future<void> update(VitalEntry updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.vitalEntryIsars.put(VitalEntryIsar.fromDomain(updated));
    });
  }

  /// Remove an entry by id.
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.vitalEntryIsars.delete(id);
    });
  }

  /// Convenience: look up an entry by id from the in-memory state cache.
  VitalEntry? byId(int id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

final vitalEntryListProvider =
    NotifierProvider<VitalEntryListNotifier, List<VitalEntry>>(
      VitalEntryListNotifier.new,
    );

// ---------------------------------------------------------------------------
// Active profile's vital entries
// ---------------------------------------------------------------------------

/// The vital entries for the currently active profile, in reverse
/// chronological order by loggedAt.
final activeProfileVitalEntriesProvider = Provider<List<VitalEntry>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final entries = ref.watch(vitalEntryListProvider);
  return entries.where((e) => e.profileId == profileId).toList()
    ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
});

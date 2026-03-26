import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/core/providers/database_provider.dart';

// ---------------------------------------------------------------------------
// Dose log list — all dose logs across all profiles
// ---------------------------------------------------------------------------

/// Holds all dose log entries for all profiles.
///
/// Uses a synchronous [Notifier] (state type [List<DoseLog>]) so that
/// all existing UI consumers continue to work unchanged. Data is loaded
/// asynchronously in [_init] and the [watchLazy] subscription keeps the
/// list up to date whenever Isar writes occur.
///
/// Per-medication filtering is done in [medicationDoseLogsProvider].
class DoseLogListNotifier extends Notifier<List<DoseLog>> {
  @override
  List<DoseLog> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);

    final subscription = isar.doseLogIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);

    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.doseLogIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Add a new dose log entry. Returns the Isar-assigned id.
  Future<int> add({
    required int profileId,
    required int medicationIsarId,
    required DateTime loggedAt,
    required double amount,
    required String unit,
    required String status,
    String? reason,
    String? effectiveness,
    String? notes,
  }) async {
    final isar = ref.read(isarProvider);
    final row = DoseLogIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..medicationIsarId = medicationIsarId
      ..loggedAt = loggedAt
      ..createdAt = DateTime.now()
      ..amount = amount
      ..unit = unit
      ..status = status
      ..reason = reason
      ..effectiveness = effectiveness
      ..notes = notes;
    await isar.writeTxn(() async {
      await isar.doseLogIsars.put(row);
    });
    return row.id;
  }

  /// Replace an existing dose log entry by id.
  Future<void> update(DoseLog updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.doseLogIsars.put(DoseLogIsar.fromDomain(updated));
    });
  }

  /// Remove a dose log entry by id.
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.doseLogIsars.delete(id);
    });
  }

  /// Remove all dose logs for a given medication (used on medication delete).
  Future<void> removeAllForMedication(int medicationId) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      final rows = await isar.doseLogIsars
          .filter()
          .medicationIsarIdEqualTo(medicationId)
          .findAll();
      await isar.doseLogIsars.deleteAll(rows.map((r) => r.id).toList());
    });
  }

  /// All dose logs for a given medication, from in-memory state.
  List<DoseLog> forMedication(int medicationId) =>
      state.where((d) => d.medicationIsarId == medicationId).toList()
        ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

  /// Convenience: look up a dose log by id from the in-memory state cache.
  DoseLog? byId(int id) {
    try {
      return state.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}

final doseLogListProvider =
    NotifierProvider<DoseLogListNotifier, List<DoseLog>>(
      DoseLogListNotifier.new,
    );

// ---------------------------------------------------------------------------
// Per-medication dose logs
// ---------------------------------------------------------------------------

/// Dose logs for a specific medication, reverse-chronological.
final medicationDoseLogsProvider = Provider.family<List<DoseLog>, int>((
  ref,
  medicationId,
) {
  final logs = ref.watch(doseLogListProvider);
  return logs.where((d) => d.medicationIsarId == medicationId).toList()
    ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
});

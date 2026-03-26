import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/medication_isar.dart';
import 'package:health_flare/data/models/dose_log_isar.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Medication list — all medications across all profiles
// ---------------------------------------------------------------------------

/// Holds all medications for all profiles.
///
/// Uses a synchronous [Notifier] (state type [List<Medication>]) so that
/// all existing UI consumers continue to work unchanged. Data is loaded
/// asynchronously in [_init] and the [watchLazy] subscription keeps the
/// list up to date whenever Isar writes occur.
///
/// Per-profile filtering is done in [activeProfileMedicationsProvider].
class MedicationListNotifier extends Notifier<List<Medication>> {
  @override
  List<Medication> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);

    final subscription = isar.medicationIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);

    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.medicationIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Add a new medication. Returns the Isar-assigned id.
  Future<int> add({
    required int profileId,
    required String name,
    required String medicationType,
    required double doseAmount,
    required String doseUnit,
    required String frequency,
    String? frequencyLabel,
    required DateTime startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    final isar = ref.read(isarProvider);
    final row = MedicationIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..name = name
      ..medicationType = medicationType
      ..doseAmount = doseAmount
      ..doseUnit = doseUnit
      ..frequency = frequency
      ..frequencyLabel = frequencyLabel
      ..startDate = startDate
      ..endDate = endDate
      ..notes = notes
      ..createdAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.medicationIsars.put(row);
    });
    return row.id;
  }

  /// Replace an existing medication by id.
  Future<void> update(Medication updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.medicationIsars.put(MedicationIsar.fromDomain(updated));
    });
  }

  /// Remove a medication and all its dose logs by id.
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.medicationIsars.delete(id);
      // Cascade-delete all dose logs for this medication.
      final doseLogs = await isar.doseLogIsars
          .filter()
          .medicationIsarIdEqualTo(id)
          .findAll();
      final ids = doseLogs.map((d) => d.id).toList();
      await isar.doseLogIsars.deleteAll(ids);
    });
  }

  /// Convenience: look up a medication by id from the in-memory state cache.
  Medication? byId(int id) {
    try {
      return state.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

final medicationListProvider =
    NotifierProvider<MedicationListNotifier, List<Medication>>(
      MedicationListNotifier.new,
    );

// ---------------------------------------------------------------------------
// Active profile's medications
// ---------------------------------------------------------------------------

/// All medications for the currently active profile, sorted by name.
final activeProfileMedicationsProvider = Provider<List<Medication>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final meds = ref.watch(medicationListProvider);
  return meds.where((m) => m.profileId == profileId).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
});

/// Active (non-discontinued) medications for the active profile, excl. supplements.
final activeProfileActiveMedicationsProvider = Provider<List<Medication>>((
  ref,
) {
  final meds = ref.watch(activeProfileMedicationsProvider);
  return meds.where((m) => m.isActive && !m.isSupplement).toList();
});

/// Discontinued medications for the active profile, excl. supplements.
final activeProfileDiscontinuedMedicationsProvider = Provider<List<Medication>>(
  (ref) {
    final meds = ref.watch(activeProfileMedicationsProvider);
    return meds.where((m) => !m.isActive && !m.isSupplement).toList();
  },
);

/// Active supplements for the active profile.
final activeProfileActiveSupplementsProvider = Provider<List<Medication>>((
  ref,
) {
  final meds = ref.watch(activeProfileMedicationsProvider);
  return meds.where((m) => m.isActive && m.isSupplement).toList();
});

/// Discontinued supplements for the active profile.
final activeProfileDiscontinuedSupplementsProvider = Provider<List<Medication>>(
  (ref) {
    final meds = ref.watch(activeProfileMedicationsProvider);
    return meds.where((m) => !m.isActive && m.isSupplement).toList();
  },
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/symptom.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/models/user_symptom.dart';
import 'package:health_flare/data/models/condition_isar.dart';
import 'package:health_flare/data/models/symptom_isar.dart';
import 'package:health_flare/data/models/user_condition_isar.dart';
import 'package:health_flare/data/models/user_symptom_isar.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Condition catalogue — all seeded + custom conditions
// ---------------------------------------------------------------------------

/// All conditions in the global catalogue, sorted alphabetically.
///
/// Loaded once on first access; [watchLazy] keeps the list fresh when the
/// user adds a custom condition.
class ConditionCatalogNotifier extends Notifier<List<Condition>> {
  @override
  List<Condition> build() {
    final isar = ref.read(isarProvider);

    final sub = isar.conditionIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(sub.cancel);

    _reload(isar);
    return [];
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.conditionIsars.where().sortByName().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Save a user-created custom condition.
  Future<Condition> addCustom(String name) async {
    final isar = ref.read(isarProvider);
    final row = ConditionIsar()
      ..name = name.trim()
      ..global = false;
    await isar.writeTxn(() async {
      await isar.conditionIsars.put(row);
    });
    return row.toDomain();
  }
}

final conditionCatalogProvider =
    NotifierProvider<ConditionCatalogNotifier, List<Condition>>(
      ConditionCatalogNotifier.new,
    );

// ---------------------------------------------------------------------------
// Symptom catalogue — all seeded + custom symptoms
// ---------------------------------------------------------------------------

class SymptomCatalogNotifier extends Notifier<List<Symptom>> {
  @override
  List<Symptom> build() {
    final isar = ref.read(isarProvider);

    final sub = isar.symptomIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(sub.cancel);

    _reload(isar);
    return [];
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.symptomIsars.where().sortByName().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Save a user-created custom symptom.
  Future<Symptom> addCustom(String name) async {
    final isar = ref.read(isarProvider);
    final row = SymptomIsar()
      ..name = name.trim()
      ..global = false;
    await isar.writeTxn(() async {
      await isar.symptomIsars.put(row);
    });
    return row.toDomain();
  }
}

final symptomCatalogProvider =
    NotifierProvider<SymptomCatalogNotifier, List<Symptom>>(
      SymptomCatalogNotifier.new,
    );

// ---------------------------------------------------------------------------
// User conditions — tracked conditions for the active profile
// ---------------------------------------------------------------------------

class UserConditionListNotifier extends Notifier<List<UserCondition>> {
  @override
  List<UserCondition> build() {
    final isar = ref.read(isarProvider);

    final sub = isar.userConditionIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(sub.cancel);

    _reload(isar);
    return [];
  }

  Future<void> _reload(Isar isar) async {
    final profileId = ref.read(activeProfileProvider);
    if (profileId == null) {
      state = [];
      return;
    }
    final rows = await isar.userConditionIsars
        .where()
        .profileIdEqualTo(profileId)
        .sortByConditionName()
        .findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Start tracking a condition for the active profile.
  ///
  /// No-ops silently if the condition is already tracked.
  Future<void> add({
    required int conditionId,
    required String conditionName,
    DateTime? diagnosedAt,
  }) async {
    final profileId = ref.read(activeProfileProvider);
    if (profileId == null) return;

    final isar = ref.read(isarProvider);

    // Guard: already tracked?
    final existing = await isar.userConditionIsars
        .where()
        .profileIdEqualTo(profileId)
        .filter()
        .conditionIdEqualTo(conditionId)
        .findFirst();
    if (existing != null) return;

    final row = UserConditionIsar()
      ..profileId = profileId
      ..conditionId = conditionId
      ..conditionName = conditionName
      ..trackedSince = DateTime.now()
      ..diagnosedAt = diagnosedAt;

    await isar.writeTxn(() async {
      await isar.userConditionIsars.put(row);
    });
  }

  /// Stop tracking a condition by its [UserCondition.id].
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.userConditionIsars.delete(id);
    });
  }

  /// Update the diagnosis date or notes on a tracked condition.
  Future<void> update(UserCondition updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.userConditionIsars.put(UserConditionIsar.fromDomain(updated));
    });
  }

  /// True if [conditionId] is already tracked for the active profile.
  bool isTracked(int conditionId) =>
      state.any((uc) => uc.conditionId == conditionId);
}

final userConditionListProvider =
    NotifierProvider<UserConditionListNotifier, List<UserCondition>>(
      UserConditionListNotifier.new,
    );

// ---------------------------------------------------------------------------
// User symptoms — tracked symptoms for the active profile
// ---------------------------------------------------------------------------

class UserSymptomListNotifier extends Notifier<List<UserSymptom>> {
  @override
  List<UserSymptom> build() {
    final isar = ref.read(isarProvider);

    final sub = isar.userSymptomIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(sub.cancel);

    _reload(isar);
    return [];
  }

  Future<void> _reload(Isar isar) async {
    final profileId = ref.read(activeProfileProvider);
    if (profileId == null) {
      state = [];
      return;
    }
    final rows = await isar.userSymptomIsars
        .where()
        .profileIdEqualTo(profileId)
        .sortBySymptomName()
        .findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Start tracking a symptom for the active profile.
  ///
  /// No-ops silently if the symptom is already tracked.
  Future<void> add({
    required int symptomId,
    required String symptomName,
  }) async {
    final profileId = ref.read(activeProfileProvider);
    if (profileId == null) return;

    final isar = ref.read(isarProvider);

    // Guard: already tracked?
    final existing = await isar.userSymptomIsars
        .where()
        .profileIdEqualTo(profileId)
        .filter()
        .symptomIdEqualTo(symptomId)
        .findFirst();
    if (existing != null) return;

    final row = UserSymptomIsar()
      ..profileId = profileId
      ..symptomId = symptomId
      ..symptomName = symptomName
      ..trackedSince = DateTime.now();

    await isar.writeTxn(() async {
      await isar.userSymptomIsars.put(row);
    });
  }

  /// Stop tracking a symptom by its [UserSymptom.id].
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.userSymptomIsars.delete(id);
    });
  }

  /// True if [symptomId] is already tracked for the active profile.
  bool isTracked(int symptomId) => state.any((us) => us.symptomId == symptomId);
}

final userSymptomListProvider =
    NotifierProvider<UserSymptomListNotifier, List<UserSymptom>>(
      UserSymptomListNotifier.new,
    );

// ---------------------------------------------------------------------------
// Search helpers (in-memory, starts-with ranked above contains)
// ---------------------------------------------------------------------------

/// Filters [items] by [query] with starts-with entries ranked first, then
/// contains entries — all alphabetically within each group.
///
/// Used as a pure function so it can be called from both providers and
/// build methods without extra overhead.
List<T> rankSearch<T>(List<T> items, String query, String Function(T) nameOf) {
  if (query.isEmpty) return items;
  final q = query.toLowerCase();
  final startsWith = <T>[];
  final contains = <T>[];
  for (final item in items) {
    final name = nameOf(item).toLowerCase();
    if (name.startsWith(q)) {
      startsWith.add(item);
    } else if (name.contains(q)) {
      contains.add(item);
    }
  }
  return [...startsWith, ...contains];
}

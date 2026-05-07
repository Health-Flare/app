import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/daily_checkin_isar.dart';
import 'package:health_flare/data/models/weather_snapshot_isar.dart';
import 'package:health_flare/models/daily_checkin.dart';
import 'package:health_flare/models/weather_snapshot.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// DailyCheckin list — all check-ins across all profiles
// ---------------------------------------------------------------------------

/// Holds all daily check-ins for all profiles.
///
/// Uses a synchronous [Notifier] with async [_init] + [watchLazy] pattern.
/// Per-profile and per-date views are derived in helper providers below.
class DailyCheckinListNotifier extends Notifier<List<DailyCheckin>> {
  @override
  List<DailyCheckin> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);

    final subscription = isar.dailyCheckinIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);

    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.dailyCheckinIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Save a new check-in. Enforces one per profile per calendar day.
  ///
  /// If a check-in for [checkinDate]'s calendar day already exists,
  /// throws a [StateError] — callers should open the existing entry for editing.
  Future<int> add({
    required int profileId,
    required DateTime checkinDate,
    required int wellbeing,
    String? stressLevel,
    String? cyclePhase,
    String? notes,
    WeatherSnapshot? weatherSnapshot,
  }) async {
    final dateOnly = _dateOnly(checkinDate);
    final existing = _findForDate(profileId, dateOnly);
    if (existing != null) {
      throw StateError(
        'A check-in for $profileId on $dateOnly already exists.',
      );
    }

    final isar = ref.read(isarProvider);
    final row = DailyCheckinIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..checkinDate = dateOnly
      ..wellbeing = wellbeing
      ..stressLevel = stressLevel
      ..cyclePhase = cyclePhase
      ..notes = notes
      ..createdAt = DateTime.now()
      ..weatherSnapshot = weatherSnapshot != null
          ? WeatherSnapshotIsar.fromDomain(weatherSnapshot)
          : null;
    await isar.writeTxn(() async {
      await isar.dailyCheckinIsars.put(row);
    });
    return row.id;
  }

  /// Update an existing check-in.
  Future<void> update(DailyCheckin updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.dailyCheckinIsars.put(DailyCheckinIsar.fromDomain(updated));
    });
  }

  /// Delete a check-in by id.
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.dailyCheckinIsars.delete(id);
    });
  }

  /// Returns the check-in for [profileId] on the given calendar day, or null.
  DailyCheckin? checkinForDate(int profileId, DateTime date) =>
      _findForDate(profileId, _dateOnly(date));

  DailyCheckin? _findForDate(int profileId, DateTime dateOnly) {
    try {
      return state.firstWhere(
        (c) => c.profileId == profileId && _dateOnly(c.checkinDate) == dateOnly,
      );
    } catch (_) {
      return null;
    }
  }
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

final dailyCheckinListProvider =
    NotifierProvider<DailyCheckinListNotifier, List<DailyCheckin>>(
      DailyCheckinListNotifier.new,
    );

// ---------------------------------------------------------------------------
// Active profile's check-ins — sorted reverse-chronological
// ---------------------------------------------------------------------------

final activeProfileCheckinsProvider = Provider<List<DailyCheckin>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final checkins = ref.watch(dailyCheckinListProvider);
  return checkins.where((c) => c.profileId == profileId).toList()
    ..sort((a, b) => b.checkinDate.compareTo(a.checkinDate));
});

/// Today's check-in for the active profile, or null.
final todayCheckinProvider = Provider<DailyCheckin?>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return null;
  final checkins = ref.watch(dailyCheckinListProvider);
  final today = _dateOnly(DateTime.now());
  try {
    return checkins.firstWhere(
      (c) => c.profileId == profileId && _dateOnly(c.checkinDate) == today,
    );
  } catch (_) {
    return null;
  }
});

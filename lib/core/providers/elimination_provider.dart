import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/models/elimination_entry_isar.dart';
import 'package:health_flare/models/elimination_entry.dart';

class EliminationListNotifier extends Notifier<List<EliminationEntry>> {
  @override
  List<EliminationEntry> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);
    final subscription = isar.eliminationEntryIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);
    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.eliminationEntryIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  Future<int> add({
    required int profileId,
    required DateTime loggedAt,
    required String kind,
    int? bristolType,
    int count = 1,
    bool blood = false,
    bool urgency = false,
    String? notes,
  }) async {
    final isar = ref.read(isarProvider);
    final row = EliminationEntryIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..loggedAt = loggedAt
      ..kind = kind
      ..bristolType = bristolType
      ..count = count
      ..blood = blood
      ..urgency = urgency
      ..notes = notes
      ..createdAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.eliminationEntryIsars.put(row);
    });
    return row.id;
  }
}

final eliminationListProvider =
    NotifierProvider<EliminationListNotifier, List<EliminationEntry>>(
      EliminationListNotifier.new,
    );

final activeProfileEliminationsProvider = Provider<List<EliminationEntry>>((
  ref,
) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final entries = ref.watch(eliminationListProvider);
  return entries.where((e) => e.profileId == profileId).toList()
    ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
});

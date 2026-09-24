import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/data/models/fluid_intake_isar.dart';
import 'package:health_flare/models/fluid_intake.dart';

class FluidIntakeListNotifier extends Notifier<List<FluidIntake>> {
  @override
  List<FluidIntake> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);
    final subscription = isar.fluidIntakeIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);
    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.fluidIntakeIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  Future<int> add({
    required int profileId,
    required DateTime loggedAt,
    required int volumeMl,
    String? drinkType,
    String? notes,
  }) async {
    final isar = ref.read(isarProvider);
    final row = FluidIntakeIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..loggedAt = loggedAt
      ..volumeMl = volumeMl
      ..drinkType = drinkType
      ..notes = notes
      ..createdAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.fluidIntakeIsars.put(row);
    });
    return row.id;
  }
}

final fluidIntakeListProvider =
    NotifierProvider<FluidIntakeListNotifier, List<FluidIntake>>(
      FluidIntakeListNotifier.new,
    );

final activeProfileFluidIntakesProvider = Provider<List<FluidIntake>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final entries = ref.watch(fluidIntakeListProvider);
  return entries.where((e) => e.profileId == profileId).toList()
    ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
});

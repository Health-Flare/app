import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/appointment_isar.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Appointment list — all appointments across all profiles
// ---------------------------------------------------------------------------

class AppointmentListNotifier extends Notifier<List<Appointment>> {
  @override
  List<Appointment> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);
    final subscription = isar.appointmentIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);
    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.appointmentIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Create a new appointment. Returns the Isar-assigned id.
  Future<int> add({
    required int profileId,
    required String title,
    String? providerName,
    required DateTime scheduledAt,
    String status = AppointmentStatus.upcoming,
  }) async {
    final isar = ref.read(isarProvider);
    final row = AppointmentIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..title = title
      ..providerName = providerName
      ..scheduledAt = scheduledAt
      ..status = status
      ..createdAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.appointmentIsars.put(row);
    });
    return row.id;
  }

  /// Update an existing appointment (questions, outcome, status, etc.).
  Future<void> update(Appointment updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.appointmentIsars.put(AppointmentIsar.fromDomain(updated));
    });
  }

  /// Delete an appointment by id.
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.appointmentIsars.delete(id);
    });
  }

  /// Look up by id from in-memory state.
  Appointment? byId(int id) {
    try {
      return state.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

final appointmentListProvider =
    NotifierProvider<AppointmentListNotifier, List<Appointment>>(
      AppointmentListNotifier.new,
    );

// ---------------------------------------------------------------------------
// Active profile's appointments — sorted by scheduledAt descending
// ---------------------------------------------------------------------------

final activeProfileAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final all = ref.watch(appointmentListProvider);
  return all.where((a) => a.profileId == profileId).toList()
    ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
});

/// Upcoming appointments for the active profile, sorted soonest first.
final upcomingAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final all = ref.watch(appointmentListProvider);
  final now = DateTime.now();
  return all
      .where(
        (a) =>
            a.profileId == profileId &&
            a.status == AppointmentStatus.upcoming &&
            a.scheduledAt.isAfter(now),
      )
      .toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
});

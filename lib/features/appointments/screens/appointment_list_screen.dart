import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/clock_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/core/widgets/list_empty_state.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/appointment_timing.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Shows all appointments for the active profile, grouped by upcoming / past.
class AppointmentListScreen extends ConsumerWidget {
  const AppointmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const HFAppBar(title: Text('Appointments')),
      body: const AppointmentListBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.appointmentNew),
        tooltip: 'New appointment',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment, required this.now});
  final Appointment appointment;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('EEE d MMM, HH:mm');

    return ListTile(
      leading: _StatusIcon(timing: appointmentTiming(appointment, now)),
      title: Text(
        appointment.title,
        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              if (appointment.providerName != null) appointment.providerName!,
              fmt.format(appointment.scheduledAt),
            ].join(' · '),
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          if (appointmentTiming(appointment, now) ==
              AppointmentTiming.outcomeNotRecorded)
            Text(
              'Outcome not recorded',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(
        AppRoutes.appointmentDetail(appointment.id),
        extra: appointment,
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.timing});
  final AppointmentTiming timing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (icon, color) = switch (timing) {
      AppointmentTiming.upcoming => (Icons.event_outlined, cs.primary),
      AppointmentTiming.outcomeNotRecorded => (
        Icons.event_note_outlined,
        cs.onSurfaceVariant,
      ),
      AppointmentTiming.completed => (Icons.check_circle_outline, Colors.green),
      AppointmentTiming.cancelled => (
        Icons.cancel_outlined,
        cs.onSurfaceVariant,
      ),
      AppointmentTiming.missed => (Icons.error_outline, cs.error),
    };
    return Icon(icon, color: color);
  }
}

/// Upcoming then past appointments, shared by this screen and
/// Care > Appointments (#141).
class AppointmentListBody extends ConsumerWidget {
  const AppointmentListBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(activeProfileAppointmentsProvider);
    final now = ref.watch(clockProvider)();

    // One rule for "upcoming" (#138). Anything else is past, newest first
    // (the provider already sorts by scheduled date, descending).
    final upcoming = all.where((a) => isUpcomingAt(a, now)).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final past = all.where((a) => !isUpcomingAt(a, now)).toList();

    if (all.isEmpty) {
      return ListEmptyState(
        icon: Icons.event_outlined,
        title: 'No appointments recorded yet',
        hint: 'Keep track of visits, and what was said.',
        actionLabel: 'Add appointment',
        onAction: () => context.push(AppRoutes.appointmentNew),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionHeader(title: 'Upcoming (${upcoming.length})'),
          ...upcoming.map((a) => _AppointmentTile(appointment: a, now: now)),
        ],
        if (past.isNotEmpty) ...[
          _SectionHeader(title: 'Past (${past.length})'),
          ...past.map((a) => _AppointmentTile(appointment: a, now: now)),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/clock_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/appointment.dart';
import 'package:health_flare/models/appointment_timing.dart';

/// The dashboard's appointments card (#138).
///
/// Until Track and Care (#135) gives appointments a tab, this is the way
/// into the appointments list, so it always shows something:
///
/// - no appointments: a one-line prompt to add one;
/// - nothing upcoming or needing an outcome: "No appointments coming up."
///   with "Add appointment" and "All appointments";
/// - otherwise up to [dashboardCardLimit] rows (see
///   [dashboardCardAppointments]) and "All appointments".
///
/// Spec: docs/features/doctor-visits.feature, "Dashboard appointments card".
class UpcomingAppointmentsCard extends ConsumerWidget {
  const UpcomingAppointmentsCard({super.key});

  static const prompt = 'Got an appointment coming up? Tap to add it.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(activeProfileAppointmentsProvider);
    final now = ref.watch(clockProvider)();

    if (all.isEmpty) return const _AddPrompt();

    final rows = dashboardCardAppointments(all, now);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_outlined, color: cs.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Appointments',
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No appointments coming up.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                ),
              )
            else
              for (final a in rows)
                _AppointmentRow(
                  appointment: a,
                  now: now,
                  asking: needsOutcome(a, now),
                ),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              children: [
                if (rows.isEmpty)
                  TextButton(
                    onPressed: () => context.push(AppRoutes.appointmentNew),
                    child: const Text('Add appointment'),
                  ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.appointments),
                  child: const Text('All appointments'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the active profile has never added an appointment. Not
/// dismissible: turning it off comes with Features in use (#142).
class _AddPrompt extends StatelessWidget {
  const _AddPrompt();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: cs.surfaceContainerHighest,
      child: InkWell(
        onTap: () => context.push(AppRoutes.appointmentNew),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.event_outlined, color: cs.onSurfaceVariant, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  UpcomingAppointmentsCard.prompt,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              Icon(Icons.add, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({
    required this.appointment,
    required this.now,
    required this.asking,
  });

  final Appointment appointment;
  final DateTime now;

  /// True for "How did it go?" rows: passed, no outcome yet.
  final bool asking;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM, HH:mm');
    final chip = asking ? 'How did it go?' : _inLabel(appointment, now);
    final semantics = asking
        ? '${appointment.title}, appointment ${_agoLabel(appointment, now)}, '
              'how did it go?'
        : '${appointment.title}, upcoming appointment, '
              '${DateFormat('yyyy-MM-dd').format(appointment.scheduledAt)}';

    return Semantics(
      container: true,
      label: semantics,
      button: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => context.push(
          asking
              ? AppRoutes.appointmentOutcome(appointment.id)
              : AppRoutes.appointmentDetail(appointment.id),
          extra: appointment,
        ),
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.title,
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                      ),
                      Text(
                        [
                          if (appointment.providerName != null)
                            appointment.providerName!,
                          fmt.format(appointment.scheduledAt),
                        ].join(' · '),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(chip, style: const TextStyle(fontSize: 11)),
                  backgroundColor: asking
                      ? cs.surfaceContainerHighest
                      : cs.primaryContainer,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Today", "Tomorrow" or "In N days", by calendar day.
String _inLabel(Appointment a, DateTime now) {
  final days = _calendarDays(now, a.scheduledAt);
  if (days <= 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  return 'In $days days';
}

/// "earlier today", "yesterday" or "N days ago", by calendar day.
String _agoLabel(Appointment a, DateTime now) {
  final days = _calendarDays(a.scheduledAt, now);
  if (days <= 0) return 'earlier today';
  if (days == 1) return 'yesterday';
  return '$days days ago';
}

int _calendarDays(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/appointment.dart';

/// Shows at most the next two upcoming appointments on the dashboard.
/// Returns [SizedBox.shrink] when no upcoming appointments exist.
class UpcomingAppointmentsCard extends ConsumerWidget {
  const UpcomingAppointmentsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(upcomingAppointmentsProvider);
    if (upcoming.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final shown = upcoming.take(2).toList();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_outlined, color: cs.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Upcoming',
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const Spacer(),
                if (upcoming.length > 2)
                  TextButton(
                    onPressed: () => context.push(AppRoutes.appointments),
                    child: Text('See all (${upcoming.length})'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...shown.map(
              (a) => _UpcomingRow(
                appointment: a,
                onTap: () =>
                    context.push(AppRoutes.appointmentDetail(a.id), extra: a),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.appointment, required this.onTap});

  final Appointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final diff = appointment.scheduledAt.difference(now);
    final daysLabel = _daysLabel(diff);
    final fmt = DateFormat('d MMM, HH:mm');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
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
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(daysLabel, style: const TextStyle(fontSize: 11)),
              backgroundColor: cs.primaryContainer,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  String _daysLabel(Duration diff) {
    if (diff.isNegative) return 'Today';
    final days = diff.inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    return 'In $days days';
  }
}

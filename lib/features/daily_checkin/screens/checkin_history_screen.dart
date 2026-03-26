import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/daily_checkin.dart';

/// Shows a reverse-chronological list of daily check-ins for the active profile.
class CheckInHistoryScreen extends ConsumerWidget {
  const CheckInHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkins = ref.watch(activeProfileCheckinsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Check-in history')),
      body: checkins.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'No check-ins recorded yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: checkins.length,
              separatorBuilder: (context, i) => const Divider(height: 1),
              itemBuilder: (context, i) => _CheckInTile(checkin: checkins[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.checkinNew),
        tooltip: 'Add check-in',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _CheckInTile extends StatelessWidget {
  const _CheckInTile({required this.checkin});

  final DailyCheckin checkin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('EEE, d MMM yyyy');

    return ListTile(
      leading: _WellbeingBadge(wellbeing: checkin.wellbeing),
      title: Text(
        fmt.format(checkin.checkinDate),
        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
      ),
      subtitle: _buildSubtitle(context, checkin),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          context.push(AppRoutes.checkinEdit(checkin.id), extra: checkin),
    );
  }

  Widget? _buildSubtitle(BuildContext context, DailyCheckin c) {
    final parts = <String>[];
    if (c.stressLevel != null) {
      parts.add('${_capitalize(c.stressLevel!)} stress');
    }
    if (c.cyclePhase != null) {
      parts.add(_cycleLabel(c.cyclePhase!));
    }
    if (parts.isEmpty) return null;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Text(
      parts.join(' · '),
      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _cycleLabel(String phase) => switch (phase) {
    'period' => 'Period',
    'follicular' => 'Follicular',
    'ovulation' => 'Ovulation',
    'luteal' => 'Luteal',
    'not_sure' => 'Not sure',
    _ => phase,
  };
}

class _WellbeingBadge extends StatelessWidget {
  const _WellbeingBadge({required this.wellbeing});

  final int wellbeing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: _color(wellbeing, cs),
      radius: 20,
      child: Text(
        '$wellbeing',
        style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _color(int v, ColorScheme cs) {
    if (v >= 8) return Colors.green.shade600;
    if (v >= 5) return Colors.orange.shade600;
    return cs.error;
  }
}

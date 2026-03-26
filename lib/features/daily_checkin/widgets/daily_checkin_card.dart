import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/daily_checkin.dart';

/// Dashboard card for the daily check-in.
///
/// Shows a prompt ("How is [name] doing today?") when no check-in exists
/// for today, or a summary card once a check-in has been saved.
class DailyCheckinCard extends ConsumerWidget {
  const DailyCheckinCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkin = ref.watch(todayCheckinProvider);
    final activeProfile = ref.watch(activeProfileDataProvider);

    if (activeProfile == null) return const SizedBox.shrink();

    if (checkin != null) {
      return _CheckInSummaryCard(checkin: checkin);
    }

    return _CheckInPromptCard(profileName: activeProfile.name);
  }
}

// ---------------------------------------------------------------------------
// Prompt card — shown when no check-in exists for today
// ---------------------------------------------------------------------------

class _CheckInPromptCard extends StatelessWidget {
  const _CheckInPromptCard({required this.profileName});

  final String profileName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: cs.surfaceContainerHighest,
      child: InkWell(
        onTap: () => context.push(AppRoutes.checkinNew),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.favorite_border_rounded, color: cs.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'How is $profileName doing today?',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
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

// ---------------------------------------------------------------------------
// Summary card — shown once today's check-in is saved
// ---------------------------------------------------------------------------

class _CheckInSummaryCard extends StatelessWidget {
  const _CheckInSummaryCard({required this.checkin});

  final DailyCheckin checkin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        onTap: () =>
            context.push(AppRoutes.checkinEdit(checkin.id), extra: checkin),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Wellbeing badge
              CircleAvatar(
                backgroundColor: _wellbeingColor(checkin.wellbeing, cs),
                radius: 20,
                child: Text(
                  '${checkin.wellbeing}',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s check-in',
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      _summary(checkin),
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  String _summary(DailyCheckin c) {
    final parts = <String>['${c.wellbeing}/10'];
    if (c.stressLevel != null) {
      parts.add('${_capitalize(c.stressLevel!)} stress');
    }
    return parts.join(' · ');
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  Color _wellbeingColor(int v, ColorScheme cs) {
    if (v >= 8) return Colors.green.shade600;
    if (v >= 5) return Colors.orange.shade600;
    return cs.error;
  }
}

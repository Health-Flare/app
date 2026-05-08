import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Full flare history for the active profile, reverse-chronological.
class FlareHistoryScreen extends ConsumerWidget {
  const FlareHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final flares = ref.watch(activeProfileFlaresProvider);

    return Scaffold(
      appBar: HFAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Flare history'),
            if (activeProfile != null)
              Text(
                activeProfile.name,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
      body: flares.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: flares.length,
              itemBuilder: (context, i) => _FlareTile(flare: flares[i]),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Flare tile
// ---------------------------------------------------------------------------

class _FlareTile extends StatelessWidget {
  const _FlareTile({required this.flare});

  final Flare flare;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM yyyy');

    final durationDays = flare.duration.inDays + 1;
    final durationLabel = durationDays == 1 ? '1 day' : '$durationDays days';

    return ListTile(
      key: Key('flare_tile_${flare.id}'),
      leading: CircleAvatar(
        backgroundColor: flare.isActive
            ? cs.errorContainer
            : cs.surfaceContainerHighest,
        child: Icon(
          Icons.local_fire_department_rounded,
          size: 20,
          color: flare.isActive ? cs.onErrorContainer : cs.onSurfaceVariant,
        ),
      ),
      title: Text(
        flare.isActive ? 'Active flare' : 'Flare ended',
        style: tt.bodyLarge,
      ),
      subtitle: Text(
        flare.isActive
            ? 'Started ${fmt.format(flare.startedAt)} · ${flare.dayLabel}'
            : '${fmt.format(flare.startedAt)} → ${fmt.format(flare.endedAt!)} · $durationLabel',
      ),
      trailing: flare.isActive
          ? Chip(
              label: const Text('In progress'),
              backgroundColor: cs.errorContainer,
              labelStyle: tt.labelSmall?.copyWith(color: cs.onErrorContainer),
              padding: EdgeInsets.zero,
            )
          : const Icon(Icons.chevron_right),
      onTap: () => context.push(AppRoutes.flareDetail(flare.id), extra: flare),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              size: 56,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No flares recorded',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'When a flare begins, tap "I\'m flaring" on the dashboard.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

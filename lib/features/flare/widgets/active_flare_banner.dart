import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/flare.dart';

/// Shows a tappable "I'm flaring" card when no flare is active, or a
/// persistent flare indicator when a flare is in progress.
///
/// Intended to appear at the top of the dashboard body.
class ActiveFlareBanner extends ConsumerWidget {
  const ActiveFlareBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFlare = ref.watch(activeFlareProvider);

    if (activeFlare != null) {
      return _ActiveFlareCard(flare: activeFlare);
    }

    return _StartFlareCard();
  }
}

// ---------------------------------------------------------------------------
// Active flare card — shown when a flare is in progress
// ---------------------------------------------------------------------------

class _ActiveFlareCard extends StatelessWidget {
  const _ActiveFlareCard({required this.flare});

  final Flare flare;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: cs.errorContainer,
      child: InkWell(
        onTap: () =>
            context.push(AppRoutes.flareDetail(flare.id), extra: flare),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: cs.onErrorContainer,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flare in progress',
                      style: tt.titleSmall?.copyWith(
                        color: cs.onErrorContainer,
                      ),
                    ),
                    Text(
                      flare.dayLabel,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onErrorContainer.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onErrorContainer),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Start flare card — shown when no flare is active
// ---------------------------------------------------------------------------

class _StartFlareCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final activeProfile = ref.watch(activeProfileDataProvider);
    if (activeProfile == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: cs.surfaceContainerHighest,
      child: InkWell(
        onTap: () => context.push(AppRoutes.flareNew),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                color: cs.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Is ${activeProfile.name} flaring? Tap to log a flare.',
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

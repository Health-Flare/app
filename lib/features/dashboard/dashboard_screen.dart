import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';

/// Dashboard — the home tab.
///
/// Shows the active profile name in the app bar. All data sections
/// will be scoped to the active profile once the data layer is wired up.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final title = activeProfile != null
        ? activeProfile.name
        : 'Health Flare';

    return Scaffold(
      appBar: AppBar(
        // Show profile name as the page title when a profile is active.
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Dashboard',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              title,
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
          ],
        ),
        // Profile switcher also accessible from the app bar icon
        // (the shell overlay covers this, but explicit access here gives
        // a larger tap target on the Dashboard specifically).
        actions: [
          // Reports — moved here from the bottom nav to free up that slot
          // for the Journal tab, which is accessed more frequently.
          IconButton(
            icon: const Icon(Icons.summarize_rounded),
            tooltip: 'Reports',
            onPressed: () => context.go(AppRoutes.reports),
          ),
          // Leave space for the shell overlay avatar (top-right corner).
          // Padding prevents the title from underlapping the avatar.
          const SizedBox(width: 56),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_outline_rounded,
                size: 64,
                color: cs.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Nothing logged yet.',
                style: tt.titleMedium?.copyWith(color: cs.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to record a symptom, vital, meal, '
                'or medication. The more you log, the clearer your '
                'health picture becomes.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open quick-entry bottom sheet
        },
        tooltip: 'Log entry',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

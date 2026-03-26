import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/dashboard_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/dashboard/widgets/dashboard_activity_feed.dart';
import 'package:health_flare/features/dashboard/widgets/dashboard_quick_entry_sheet.dart';
import 'package:health_flare/features/onboarding/widgets/first_log_prompt.dart';
import 'package:health_flare/features/onboarding/widgets/weather_opt_in_sheet.dart';

/// Dashboard — the home tab.
///
/// Shows the active profile name in the app bar. All data sections
/// will be scoped to the active profile once the data layer is wired up.
///
/// Also owns the first-log prompt trigger: when [firstLogPromptProvider]
/// becomes true (new profile created, not yet shown), it displays
/// [FirstLogPrompt] as a modal bottom sheet once per profile.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Check after the first frame is fully built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowPrompts());
  }

  /// Shows the weather opt-in prompt (if not yet seen), then the first-log
  /// prompt (if not yet seen), in sequence.
  ///
  /// Both prompts are marked as shown *before* being displayed so that
  /// swipe-dismiss or hot-restart cannot re-trigger them.
  Future<void> _maybeShowPrompts() async {
    if (!mounted) return;

    // Weather opt-in first
    if (ref.read(weatherOptInProvider)) {
      await showWeatherOptIn(
        context,
        onResult: (enabled) async {
          await ref
              .read(weatherOptInProvider.notifier)
              .dismiss(enabled: enabled);
          if (mounted) Navigator.of(context).pop();
        },
      );
    }

    if (!mounted) return;

    // First-log prompt second
    if (ref.read(firstLogPromptProvider)) {
      await ref.read(firstLogPromptProvider.notifier).markShown();
      if (!mounted) return;
      final profile = ref.read(activeProfileDataProvider);
      await showFirstLogPrompt(context, profileName: profile?.name ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Listen for subsequent transitions to true — handles the case where a
    // new profile is created from the profile switcher while on another tab.
    ref.listen<bool>(firstLogPromptProvider, (prev, next) {
      if (next && !(prev ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _maybeShowPrompts(),
        );
      }
    });

    final title = activeProfile != null ? activeProfile.name : 'Health Flare';

    return Scaffold(
      appBar: AppBar(
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
            Text(title, style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_rounded),
            tooltip: 'Reports',
            onPressed: () => context.go(AppRoutes.reports),
          ),
          // Leave space for the shell overlay avatar (top-right corner).
          const SizedBox(width: 56),
        ],
      ),
      body: const _DashboardBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDashboardQuickEntrySheet(context),
        tooltip: 'Log entry',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body — switches between empty state and activity feed
// ---------------------------------------------------------------------------

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasActivity = ref.watch(dashboardHasActivityProvider);
    final items = ref.watch(dashboardActivityProvider);

    if (!hasActivity) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_outline_rounded, size: 64, color: cs.primary),
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
      );
    }

    return ListView(children: [DashboardActivityFeed(items: items)]);
  }
}

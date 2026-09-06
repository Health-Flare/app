import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/dashboard_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/dashboard/widgets/dashboard_activity_feed.dart';
import 'package:health_flare/features/dashboard/widgets/dashboard_quick_entry_sheet.dart';
import 'package:health_flare/features/flare/widgets/active_flare_banner.dart';
import 'package:health_flare/features/daily_checkin/widgets/daily_checkin_card.dart';
import 'package:health_flare/features/appointments/widgets/upcoming_appointments_card.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Dashboard — the home tab.
///
/// Shows the active profile name in the app bar. All data sections
/// will be scoped to the active profile once the data layer is wired up.
///
/// Also owns the first-log trigger: when [firstLogPromptProvider] becomes
/// true (new profile created, not yet shown), it opens the same quick-log
/// sheet as the FAB — see [showDashboardQuickEntrySheet] — once per profile,
/// instead of a separate prompt UI. A brand-new user's very first log is
/// then the same low-friction sheet they'll use every day after, rather
/// than a bespoke card grid that behaves differently from daily use.
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowFirstLog());
  }

  /// Opens the quick-log sheet automatically the first time a profile lands
  /// on the dashboard, then never again for that profile.
  ///
  /// Marked as shown *before* being displayed so that swipe-dismiss or
  /// hot-restart cannot re-trigger it. The weather opt-in (if not yet seen)
  /// is handled inside [showDashboardQuickEntrySheet] itself, since asking
  /// about weather tracking makes more sense at the moment someone is about
  /// to log something than as a blocking modal before they've seen the app.
  Future<void> _maybeShowFirstLog() async {
    if (!mounted) return;
    if (!ref.read(firstLogPromptProvider)) return;

    await ref.read(firstLogPromptProvider.notifier).markShown();
    if (!mounted) return;
    await showDashboardQuickEntrySheet(context, ref);
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
          (_) => _maybeShowFirstLog(),
        );
      }
    });

    final title = activeProfile != null ? activeProfile.name : 'Health Flare';

    return Scaffold(
      appBar: HFAppBar(
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
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
          // Leave space for the shell overlay avatar (top-right corner).
        ],
      ),
      body: const _DashboardBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDashboardQuickEntrySheet(context, ref),
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
      return Column(
        children: [
          const ActiveFlareBanner(),
          const DailyCheckinCard(),
          const UpcomingAppointmentsCard(),
          Expanded(
            child: Center(
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
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      children: [
        const ActiveFlareBanner(),
        const DailyCheckinCard(),
        const UpcomingAppointmentsCard(),
        DashboardActivityFeed(items: items),
      ],
    );
  }
}

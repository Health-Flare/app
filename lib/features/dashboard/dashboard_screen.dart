import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/providers/dashboard_provider.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/dashboard/widgets/dashboard_activity_feed.dart';
import 'package:health_flare/features/quick_log/widgets/quick_log_fab.dart';
import 'package:health_flare/features/onboarding/screens/post_setup_flow_screen.dart';
import 'package:health_flare/features/flare/widgets/active_flare_banner.dart';
import 'package:health_flare/features/daily_checkin/widgets/daily_checkin_card.dart';
import 'package:health_flare/features/appointments/widgets/upcoming_appointments_card.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Dashboard: the home tab.
///
/// Shows the active profile name in the app bar. All data sections
/// will be scoped to the active profile once the data layer is wired up.
///
/// Also owns the post-setup mini-flow trigger: when the weather opt-in
/// and/or first-log prompt become due (new profile created, not yet shown),
/// it pushes [PostSetupFlowScreen] full-screen, once per profile.
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

  /// Pushes the post-setup mini-flow (weather opt-in, then first-log
  /// prompt) full-screen if either is still pending for the active profile.
  Future<void> _maybeShowPrompts() async {
    if (!mounted) return;

    final showWeather = ref.read(weatherOptInProvider);
    final showFirstLog = ref.read(firstLogPromptProvider);
    if (!showWeather && !showFirstLog) return;

    final profile = ref.read(activeProfileDataProvider);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => PostSetupFlowScreen(
          showWeatherStep: showWeather,
          showFirstLogStep: showFirstLog,
          profileName: profile?.name ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Listen for subsequent transitions to true: handles the case where a
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
        ],
      ),
      body: const _DashboardBody(),
      floatingActionButton: const QuickLogFab(),
    );
  }
}

// ---------------------------------------------------------------------------
// Body: switches between empty state and activity feed
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

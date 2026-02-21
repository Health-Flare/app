import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/journal/screens/journal_composer_screen.dart';
import '../../features/journal/screens/journal_detail_screen.dart';
import '../../features/journal/screens/journal_list_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../providers/onboarding_provider.dart';

// ---------------------------------------------------------------------------
// Route names — use these constants everywhere instead of raw strings.
// ---------------------------------------------------------------------------

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/';
  static const dashboard = '/dashboard';
  static const symptoms = '/symptoms';
  static const medications = '/medications';
  static const meals = '/meals';
  static const reports = '/reports';
  static const journal = '/journal';
  static const journalNew = '/journal/new';
  static String journalDetail(int id) => '/journal/$id';
  static String journalEdit(int id) => '/journal/$id/edit';
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

final appRouterProvider = Provider<GoRouter>((ref) {
  // Use a ValueNotifier as a listenable so the router can call refresh()
  // when onboardingProvider changes, without recreating the router instance.
  // Recreating GoRouter mid-navigation (e.g. while awaiting profile creation)
  // causes the MaterialApp.router to re-mount with a fresh initialLocation,
  // which is the regression: the screen changes before the await completes.
  final notifier = ValueNotifier<bool>(ref.read(onboardingProvider));

  ref.listen<bool>(onboardingProvider, (_, next) {
    notifier.value = next;
  });

  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation:
        ref.read(onboardingProvider) ? AppRoutes.home : AppRoutes.onboarding,
    refreshListenable: notifier,
    redirect: (context, state) {
      final onboardingDone = ref.read(onboardingProvider);

      final onOnboarding = state.matchedLocation == AppRoutes.onboarding;

      // Not done onboarding → always redirect to onboarding
      if (!onboardingDone && !onOnboarding) {
        return AppRoutes.onboarding;
      }

      // Done onboarding and trying to visit onboarding → send to home
      if (onboardingDone && onOnboarding) {
        return AppRoutes.home;
      }

      return null; // no redirect needed
    },
    routes: [
      // Onboarding — standalone, no shell
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app shell — wraps all tab destinations
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            redirect: (context, state) => AppRoutes.dashboard,
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.symptoms,
            name: 'symptoms',
            builder: (context, state) => const _PlaceholderScreen(
              title: 'Symptoms & Vitals',
            ),
          ),
          GoRoute(
            path: AppRoutes.medications,
            name: 'medications',
            builder: (context, state) => const _PlaceholderScreen(
              title: 'Medications',
            ),
          ),
          GoRoute(
            path: AppRoutes.meals,
            name: 'meals',
            builder: (context, state) => const _PlaceholderScreen(
              title: 'Meals',
            ),
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            builder: (context, state) => const _PlaceholderScreen(
              title: 'Reports',
            ),
          ),
          GoRoute(
            path: AppRoutes.journal,
            name: 'journal',
            builder: (context, state) => const JournalListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'journal-new',
                builder: (context, state) => const JournalComposerScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'journal-detail',
                builder: (context, state) => JournalDetailScreen(
                  entryId: int.parse(state.pathParameters['id']!),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'journal-edit',
                    builder: (context, state) => JournalComposerScreen(
                      entryId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Temporary placeholder for screens not yet built
// ---------------------------------------------------------------------------

class _PlaceholderScreen extends StatelessWidget {
  // ignore: unused_element
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'Coming soon',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

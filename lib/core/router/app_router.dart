import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/features/illness/screens/illness_screen.dart';
import 'package:health_flare/features/settings/screens/settings_screen.dart';
import 'package:health_flare/features/journal/screens/journal_composer_screen.dart';
import 'package:health_flare/features/journal/screens/journal_detail_screen.dart';
import 'package:health_flare/features/journal/screens/journal_list_screen.dart';
import 'package:health_flare/features/onboarding/screens/onboarding_screen.dart';
import 'package:health_flare/features/shell/app_shell.dart';
import 'package:health_flare/features/dashboard/dashboard_screen.dart';
import 'package:health_flare/features/sleep/screens/sleep_entry_screen.dart';
import 'package:health_flare/features/sleep/screens/sleep_list_screen.dart';
import 'package:health_flare/features/symptoms_vitals/screens/symptom_entry_form_screen.dart';
import 'package:health_flare/features/symptoms_vitals/screens/symptoms_vitals_screen.dart';
import 'package:health_flare/features/symptoms_vitals/screens/vital_entry_form_screen.dart';
import 'package:health_flare/features/medications/screens/medications_screen.dart';
import 'package:health_flare/features/medications/screens/medication_form_screen.dart';
import 'package:health_flare/features/medications/screens/medication_detail_screen.dart';
import 'package:health_flare/features/medications/screens/dose_log_form_screen.dart';
import 'package:health_flare/core/providers/onboarding_provider.dart';
import 'package:health_flare/models/sleep_entry.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/vital_entry.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/dose_log.dart';

// ---------------------------------------------------------------------------
// Route names — use these constants everywhere instead of raw strings.
// ---------------------------------------------------------------------------

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/';
  static const dashboard = '/dashboard';
  static const illness = '/illness';
  static const symptoms = '/symptoms';
  static const symptomsNew = '/symptoms/new-symptom';
  static String symptomsEdit(int id) => '/symptoms/$id/edit';
  static const vitalsNew = '/symptoms/new-vital';
  static String vitalsEdit(int id) => '/symptoms/$id/edit-vital';
  static const medications = '/medications';
  static const medicationsNew = '/medications/new';
  static String medicationsEdit(int id) => '/medications/$id/edit';
  static String medicationsDetail(int id) => '/medications/$id';
  static String medicationsDoseNew(int medicationId) =>
      '/medications/$medicationId/dose/new';
  static String medicationsDoseEdit(int medicationId, int doseId) =>
      '/medications/$medicationId/dose/$doseId/edit';
  static const meals = '/meals';
  static const reports = '/reports';
  static const journal = '/journal';
  static const journalNew = '/journal/new';
  static String journalDetail(int id) => '/journal/$id';
  static String journalEdit(int id) => '/journal/$id/edit';
  static const sleep = '/sleep';
  static const sleepNew = '/sleep/new';
  static String sleepEdit(int id) => '/sleep/$id/edit';
  static const settings = '/settings';
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
    initialLocation: ref.read(onboardingProvider)
        ? AppRoutes.home
        : AppRoutes.onboarding,
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

      // Settings — full-screen push, outside the shell nav bar
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
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
            path: AppRoutes.illness,
            name: 'illness',
            builder: (context, state) => const IllnessScreen(),
          ),
          GoRoute(
            path: AppRoutes.symptoms,
            name: 'symptoms',
            builder: (context, state) => const SymptomsVitalsScreen(),
            routes: [
              GoRoute(
                path: 'new-symptom',
                name: 'symptoms-new',
                builder: (context, state) => const SymptomEntryFormScreen(),
              ),
              GoRoute(
                path: ':sid/edit',
                name: 'symptoms-edit',
                builder: (context, state) =>
                    SymptomEntryFormScreen(entry: state.extra as SymptomEntry?),
              ),
              GoRoute(
                path: 'new-vital',
                name: 'vitals-new',
                builder: (context, state) => const VitalEntryFormScreen(),
              ),
              GoRoute(
                path: ':vid/edit-vital',
                name: 'vitals-edit',
                builder: (context, state) =>
                    VitalEntryFormScreen(entry: state.extra as VitalEntry?),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.medications,
            name: 'medications',
            builder: (context, state) => const MedicationsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'medications-new',
                builder: (context, state) => const MedicationFormScreen(),
              ),
              GoRoute(
                path: ':mid/edit',
                name: 'medications-edit',
                builder: (context, state) => MedicationFormScreen(
                  medication: state.extra as Medication?,
                ),
              ),
              GoRoute(
                path: ':mid',
                name: 'medications-detail',
                builder: (context, state) => MedicationDetailScreen(
                  medicationId: int.parse(state.pathParameters['mid']!),
                ),
                routes: [
                  GoRoute(
                    path: 'dose/new',
                    name: 'medications-dose-new',
                    builder: (context, state) => DoseLogFormScreen(
                      medication: state.extra as Medication,
                    ),
                  ),
                  GoRoute(
                    path: 'dose/:did/edit',
                    name: 'medications-dose-edit',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      return DoseLogFormScreen(
                        medication: extra['med'] as Medication,
                        doseLog: extra['log'] as DoseLog,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.meals,
            name: 'meals',
            builder: (context, state) => const _TabPlaceholderScreen(
              title: 'Meals',
              icon: Icons.restaurant_outlined,
              description:
                  'Record meals and flag reactions. Over time, Health Flare '
                  'will help you spot patterns between food and symptoms. '
                  'Coming in the next update.',
            ),
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: 'reports',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Reports'),
          ),
          GoRoute(
            path: AppRoutes.sleep,
            name: 'sleep',
            builder: (context, state) => const SleepListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'sleep-new',
                builder: (context, state) => const SleepEntryScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'sleep-edit',
                builder: (context, state) =>
                    SleepEntryScreen(entry: state.extra as SleepEntry?),
              ),
            ],
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
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _TabPlaceholderScreen extends StatelessWidget {
  const _TabPlaceholderScreen({
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: cs.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                title,
                style: tt.titleMedium?.copyWith(color: cs.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

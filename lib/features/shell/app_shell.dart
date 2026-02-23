import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/profile_provider.dart';
import '../../core/router/app_router.dart';
import '../profiles/widgets/profile_avatar.dart';
import '../profiles/widgets/profile_switcher_sheet.dart';

/// Persistent shell wrapping all tab destinations.
///
/// Provides:
///   • [NavigationBar] for the 5 main sections
///   • A persistent profile avatar button at the top-right, accessible
///     from every screen, that opens the [ProfileSwitcherSheet].
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    (
      route: AppRoutes.dashboard,
      label: 'Dashboard',
      icon: Icons.grid_view_rounded,
      selectedIcon: Icons.grid_view_rounded,
    ),
    (
      route: AppRoutes.symptoms,
      label: 'Symptoms',
      icon: Icons.monitor_heart_outlined,
      selectedIcon: Icons.monitor_heart_rounded,
    ),
    (
      route: AppRoutes.medications,
      label: 'Medications',
      icon: Icons.medication_outlined,
      selectedIcon: Icons.medication_rounded,
    ),
    (
      route: AppRoutes.meals,
      label: 'Meals',
      icon: Icons.restaurant_outlined,
      selectedIcon: Icons.restaurant_rounded,
    ),
    (
      route: AppRoutes.journal,
      label: 'Journal',
      icon: Icons.book_outlined,
      selectedIcon: Icons.book_rounded,
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    // Use prefix match so sub-routes (e.g. /journal/new, /journal/1/edit)
    // keep the parent tab highlighted.
    final index = _destinations.indexWhere(
      (d) => d.route == '/'
          ? location == '/'
          : location == d.route || location.startsWith('${d.route}/'),
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(activeProfileDataProvider);

    return Scaffold(
      // The individual tab screens each supply their own AppBar. The shell
      // injects the persistent profile button via an overlay so it appears
      // on every screen without each screen needing to know about it.
      body: Stack(
        children: [
          child,
          // Persistent profile indicator — top-right, always visible.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: Semantics(
              button: true,
              label: activeProfile != null
                  ? 'Switch profile. Current: ${activeProfile.name}'
                  : 'Switch profile',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => showProfileSwitcher(context),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: activeProfile != null
                        ? ProfileAvatar(
                            profile: activeProfile,
                            radius: 18,
                            showBorder: false,
                          )
                        : const _DefaultProfileButton(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) =>
            context.go(_destinations[index].route),
        destinations: _destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Fallback button when no profile exists (should not normally be visible
/// after onboarding, but guards against edge cases).
class _DefaultProfileButton extends StatelessWidget {
  const _DefaultProfileButton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 18,
      backgroundColor: cs.surfaceContainerHighest,
      child: Icon(Icons.person_outline_rounded,
          size: 20, color: cs.onSurfaceVariant),
    );
  }
}

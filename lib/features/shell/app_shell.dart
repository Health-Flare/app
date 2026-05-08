import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/router/app_router.dart';

/// Persistent shell wrapping all tab destinations.
///
/// Provides the [NavigationBar] for the main sections. Each screen is
/// responsible for its own [AppBar] via [HFAppBar], which automatically
/// includes the [ProfileIconButton] as its rightmost action.
class AppShell extends StatelessWidget {
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
      route: AppRoutes.tracking,
      label: 'Tracking',
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
    final index = _destinations.indexWhere(
      (d) => d.route == '/'
          ? location == '/'
          : location == d.route || location.startsWith('${d.route}/'),
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
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

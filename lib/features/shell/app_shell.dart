import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

/// Persistent shell wrapping all tab destinations.
/// Provides the [NavigationBar] and keeps it alive across route changes.
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
      route: AppRoutes.reports,
      label: 'Reports',
      icon: Icons.summarize_outlined,
      selectedIcon: Icons.summarize_rounded,
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _destinations.indexWhere((d) => d.route == location);
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

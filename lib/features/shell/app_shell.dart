import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/navigation/nav_registry.dart';

/// Persistent shell wrapping all tab destinations.
///
/// Provides the [NavigationBar] for the main sections. Each screen is
/// responsible for its own [AppBar] via [HFAppBar], which automatically
/// includes the [ProfileIconButton] as its rightmost action.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  /// From the navigation registry (#136). Track and Care (#141) swaps
  /// this for the layout v2 bar behind the trackAndCare flag.
  static const _destinations = legacyBar;

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

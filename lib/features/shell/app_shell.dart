import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/navigation/section_routes.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/sections/section_state.dart';

/// Persistent shell wrapping all tab destinations.
///
/// Provides the [NavigationBar] for the main sections. Each screen is
/// responsible for its own [AppBar] via [HFAppBar], which automatically
/// includes the [ProfileIconButton] as its rightmost action.
///
/// With the trackAndCare flag on (#141) the bar is Dashboard, Track, Care
/// and Journal; otherwise it's the six-item bar every release up to 1.9.1
/// had.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAndCare = ref.watch(featureFlagsProvider).trackAndCare;
    return Scaffold(
      body: child,
      bottomNavigationBar: trackAndCare
          ? _SectionBar(location: GoRouterState.of(context).uri)
          : _LegacyBar(location: GoRouterState.of(context).matchedLocation),
    );
  }
}

/// Dashboard, Track, Care, Journal. A section opens on the tab last used
/// in it this session, or its first tab.
class _SectionBar extends ConsumerWidget {
  const _SectionBar({required this.location});

  final Uri location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memo = ref.read(lastSectionProvider);
    final current = sectionIdForLocation(location);
    if (current != null) memo['bar'] = current;
    final selected = navSections.indexWhere((s) => s.id == memo['bar']);

    return NavigationBar(
      selectedIndex: selected < 0 ? 0 : selected,
      onDestinationSelected: (index) {
        final section = navSections[index];
        if (section.tabs.isEmpty) {
          context.go(AppRoutes.dashboard);
          return;
        }
        final tab =
            ref.read(lastTabProvider)[section.id] ?? section.tabs.first.id;
        context.go(tabLocation(tab));
      },
      destinations: [
        for (final s in navSections)
          NavigationDestination(
            icon: Icon(s.icon),
            selectedIcon: Icon(s.selectedIcon),
            label: s.label,
          ),
      ],
    );
  }
}

class _LegacyBar extends StatelessWidget {
  const _LegacyBar({required this.location});

  final String location;

  /// From the navigation registry (#136).
  static const _destinations = legacyBar;

  int get _currentIndex {
    final index = _destinations.indexWhere(
      (d) => d.route == '/'
          ? location == '/'
          : location == d.route || location.startsWith('${d.route}/'),
    );
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) => context.go(_destinations[index].route),
      destinations: _destinations
          .map(
            (d) => NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
          )
          .toList(),
    );
  }
}

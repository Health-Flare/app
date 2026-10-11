import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/bar_choice.dart';
import 'package:health_flare/core/navigation/effective_bar.dart';
import 'package:health_flare/core/navigation/features_in_use.dart';
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

/// The bottom bar with Track and Care on: the person's choice (#143), with
/// features in use applied. A section opens on the tab last used in it
/// this session, or its first tab that's on; a pinned screen opens itself.
class _SectionBar extends ConsumerWidget {
  const _SectionBar({required this.location});

  final Uri location;

  /// At this text size and above the bar shows icons only; each label is
  /// still read out, and shown on long press.
  static const iconsOnlyFrom = 1.5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(effectiveBarProvider);
    final memo = ref.read(lastSectionProvider);
    final current = selectedSlotId(slots, location);
    if (current != null) memo['bar'] = current;
    final selected = slots.indexWhere((s) => s.id == memo['bar']);
    final iconsOnly =
        MediaQuery.textScalerOf(context).scale(14) / 14 >= iconsOnlyFrom;

    return NavigationBar(
      selectedIndex: selected < 0 ? 0 : selected,
      labelBehavior: iconsOnly
          ? NavigationDestinationLabelBehavior.alwaysHide
          : null,
      onDestinationSelected: (index) {
        final id = slots[index].id;
        if (id == 'dashboard') {
          context.go(AppRoutes.dashboard);
        } else if (id == moreId) {
          context.go(moreLocation);
        } else if (navSections.any((s) => s.id == id)) {
          // The tab last used here, if it's still on; else the first on.
          final visible = ref.read(visibleTabsProvider(id));
          final last = ref.read(lastTabProvider)[id];
          final tab = visible.any((t) => t.id == last)
              ? last!
              : visible.first.id;
          context.go(tabLocation(tab));
        } else {
          context.go(tabLocation(id));
        }
      },
      destinations: [
        for (final s in slots)
          NavigationDestination(
            icon: Icon(s.icon),
            selectedIcon: Icon(s.selectedIcon),
            label: s.label,
            tooltip: s.label,
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

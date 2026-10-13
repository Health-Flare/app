import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/features/release_guides/widgets/bar_outline.dart';
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
/// The bar is Dashboard, Track, Care and Journal by default (#141), as the
/// person has set it up (#143).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _SectionBar(location: GoRouterState.of(context).uri),
    );
  }
}

/// The bottom bar: the person's choice (#143), with
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
            // Outlined after the release guide's "Show me" (#145).
            icon: BarOutline(id: s.id, child: Icon(s.icon)),
            selectedIcon: BarOutline(id: s.id, child: Icon(s.selectedIcon)),
            label: s.label,
            tooltip: s.label,
          ),
      ],
    );
  }
}

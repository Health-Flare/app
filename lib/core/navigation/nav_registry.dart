import 'package:flutter/material.dart';

import 'package:health_flare/core/router/app_router.dart';

/// Stable ids for sections, tabs and features (#136).
///
/// Ids are stored in user data and backups (the bottom bar, features in
/// use), so they are a public format:
///
/// - lowercase words joined by dots or hyphens: `track`, `care.medications`;
/// - never reused, never renamed. Labels can change; ids can't;
/// - an id that's retired gets an entry in [retiredNavIds] in the same PR,
///   pointing at what replaced it. `test/unit/navigation/nav_ids_test.dart`
///   fails otherwise.
///
/// Spec: docs/features/navigation-customization.feature (rule 2).

/// Something that can be turned on or off per profile in Features in use.
class NavFeature {
  const NavFeature(this.id, this.label, {this.canTurnOff = true});

  final String id;
  final String label;

  /// Symptoms and Conditions are always on.
  final bool canTurnOff;
}

/// A tab inside a section. Every list screen is exactly one tab.
class NavTab {
  const NavTab({
    required this.id,
    required this.label,
    required this.featureId,
    required this.route,
  });

  final String id;
  final String label;

  /// The feature that turns this tab on or off.
  final String featureId;

  /// Where the tab opens: the list screen's own address, so old links
  /// keep working (`section_routes.dart`, #141).
  final String route;
}

/// A destination in the primary navigation.
class NavSection {
  const NavSection({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.tabs = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final List<NavTab> tabs;
}

/// One item in a bottom bar layout: a section or a pinned tab, with the
/// label, icons and route the bar shows for it.
class NavBarItem {
  const NavBarItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  /// A section id or a tab id.
  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}

// ---------------------------------------------------------------------------
// Features
// ---------------------------------------------------------------------------

/// In Features in use order (navigation-customization.feature). Ids are
/// the tab ids, so a feature and its tab share one id.
const navFeatures = <NavFeature>[
  NavFeature('track.symptoms', 'Symptoms', canTurnOff: false),
  NavFeature('track.vitals', 'Vitals'),
  NavFeature('track.meals', 'Meals'),
  NavFeature('track.sleep', 'Sleep'),
  NavFeature('track.activity', 'Activity'),
  NavFeature('care.medications', 'Medications'),
  NavFeature('care.appointments', 'Appointments'),
  NavFeature('care.conditions', 'Conditions', canTurnOff: false),
  NavFeature('care.flares', 'Flares'),
  NavFeature('journal.entries', 'Journal'),
  NavFeature('journal.checkins', 'Check-ins'),
];

// ---------------------------------------------------------------------------
// Sections and tabs (Track and Care, layout v2)
// ---------------------------------------------------------------------------

/// The default sections and tabs, in order (navigation.feature).
const navSections = <NavSection>[
  NavSection(
    id: 'dashboard',
    label: 'Dashboard',
    icon: Icons.grid_view_rounded,
    selectedIcon: Icons.grid_view_rounded,
  ),
  NavSection(
    id: 'track',
    label: 'Track',
    icon: Icons.monitor_heart_outlined,
    selectedIcon: Icons.monitor_heart_rounded,
    tabs: [
      NavTab(
        id: 'track.symptoms',
        label: 'Symptoms',
        featureId: 'track.symptoms',
        route: AppRoutes.tracking,
      ),
      NavTab(
        id: 'track.vitals',
        label: 'Vitals',
        featureId: 'track.vitals',
        route: AppRoutes.vitals,
      ),
      NavTab(
        id: 'track.meals',
        label: 'Meals',
        featureId: 'track.meals',
        route: AppRoutes.meals,
      ),
      NavTab(
        id: 'track.sleep',
        label: 'Sleep',
        featureId: 'track.sleep',
        route: AppRoutes.sleep,
      ),
      NavTab(
        id: 'track.activity',
        label: 'Activity',
        featureId: 'track.activity',
        route: AppRoutes.activity,
      ),
    ],
  ),
  NavSection(
    id: 'care',
    label: 'Care',
    icon: Icons.medical_services_outlined,
    selectedIcon: Icons.medical_services_rounded,
    tabs: [
      NavTab(
        id: 'care.medications',
        label: 'Medications',
        featureId: 'care.medications',
        route: AppRoutes.medications,
      ),
      NavTab(
        id: 'care.appointments',
        label: 'Appointments',
        featureId: 'care.appointments',
        route: AppRoutes.appointments,
      ),
      NavTab(
        id: 'care.conditions',
        label: 'Conditions',
        featureId: 'care.conditions',
        route: AppRoutes.conditions,
      ),
      NavTab(
        id: 'care.flares',
        label: 'Flares',
        featureId: 'care.flares',
        route: AppRoutes.flareHistory,
      ),
    ],
  ),
  NavSection(
    id: 'journal',
    label: 'Journal',
    icon: Icons.book_outlined,
    selectedIcon: Icons.book_rounded,
    tabs: [
      NavTab(
        id: 'journal.entries',
        label: 'Entries',
        featureId: 'journal.entries',
        route: AppRoutes.journal,
      ),
      NavTab(
        id: 'journal.checkins',
        label: 'Check-ins',
        featureId: 'journal.checkins',
        route: AppRoutes.checkinHistory,
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// Bottom bars
// ---------------------------------------------------------------------------

/// The bar today: six destinations. Each item uses the id of what it is in
/// layout v2 (Tracking is `track`, Meds is the `care.medications` tab), so
/// the guide and the "Like before" preset can name them.
const legacyBar = <NavBarItem>[
  NavBarItem(
    id: 'dashboard',
    label: 'Dashboard',
    icon: Icons.grid_view_rounded,
    selectedIcon: Icons.grid_view_rounded,
    route: AppRoutes.dashboard,
  ),
  NavBarItem(
    id: 'track',
    label: 'Tracking',
    icon: Icons.monitor_heart_outlined,
    selectedIcon: Icons.monitor_heart_rounded,
    route: AppRoutes.tracking,
  ),
  NavBarItem(
    id: 'care.medications',
    label: 'Meds',
    icon: Icons.medication_outlined,
    selectedIcon: Icons.medication_rounded,
    route: AppRoutes.medications,
  ),
  NavBarItem(
    id: 'track.meals',
    label: 'Meals',
    icon: Icons.restaurant_outlined,
    selectedIcon: Icons.restaurant_rounded,
    route: AppRoutes.meals,
  ),
  NavBarItem(
    id: 'journal',
    label: 'Journal',
    icon: Icons.book_outlined,
    selectedIcon: Icons.book_rounded,
    route: AppRoutes.journal,
  ),
  NavBarItem(
    id: 'track.sleep',
    label: 'Sleep',
    icon: Icons.bedtime_outlined,
    selectedIcon: Icons.bedtime_rounded,
    route: AppRoutes.sleep,
  ),
];

// ---------------------------------------------------------------------------
// Retired ids
// ---------------------------------------------------------------------------

/// Retired id -> the id that replaced it. Add an entry in the same PR that
/// retires an id. Chains are followed (`a -> b -> c`).
const retiredNavIds = <String, String>{};

/// Every id in use now: features, sections and tabs.
Set<String> get knownNavIds => {
  for (final f in navFeatures) f.id,
  for (final s in navSections) ...[s.id, for (final t in s.tabs) t.id],
};

/// [id] after following [retired] replacements, or null if neither it nor
/// what replaced it is in [known]. A cycle in [retired] gives null.
String? resolveNavId(
  String id, {
  Set<String>? known,
  Map<String, String> retired = retiredNavIds,
}) {
  final ids = known ?? knownNavIds;
  final seen = <String>{};
  String? current = id;
  while (current != null && seen.add(current)) {
    if (ids.contains(current)) return current;
    current = retired[current];
  }
  return null;
}

/// [ids] resolved one by one: replacements followed, unknown ids dropped,
/// and a later duplicate removed so each id appears once, keeping the
/// order of first appearance. [ids] itself is never changed.
List<String> resolveNavIds(
  List<String> ids, {
  Set<String>? known,
  Map<String, String> retired = retiredNavIds,
}) {
  final out = <String>[];
  for (final id in ids) {
    final r = resolveNavId(id, known: known, retired: retired);
    if (r != null && !out.contains(r)) out.add(r);
  }
  return out;
}

/// The bar to show for a stored choice: [stored] resolved, or
/// [defaultBar] when nothing is stored or fewer than [minItems] items are
/// left. Never rewrites what's stored: that only happens when the person
/// changes the bar.
List<String> resolveBarIds(
  List<String>? stored, {
  required List<String> defaultBar,
  int minItems = 3,
  Set<String>? known,
  Map<String, String> retired = retiredNavIds,
}) {
  if (stored == null) return List.of(defaultBar);
  final resolved = resolveNavIds(stored, known: known, retired: retired);
  return resolved.length < minItems ? List.of(defaultBar) : resolved;
}

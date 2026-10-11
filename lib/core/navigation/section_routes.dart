import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/router/app_router.dart';

// Track and Care (#141): which tab and section a location belongs to.
// Every tab has its own location (NavTab.route), and the old list
// addresses are those locations, so old links open the right tab.
// Spec: docs/features/navigation.feature.

final _tabsById = {
  for (final s in navSections)
    for (final t in s.tabs) t.id: t,
};

final _sectionByTab = {
  for (final s in navSections)
    for (final t in s.tabs) t.id: s,
};

/// Where [tabId] opens.
String tabLocation(String tabId) => _tab(tabId).route;

NavTab _tab(String tabId) =>
    _tabsById[tabId] ?? (throw ArgumentError.value(tabId, 'tabId'));

/// The section [tabId] is in.
NavSection sectionOfTab(String tabId) =>
    _sectionByTab[tabId] ?? (throw ArgumentError.value(tabId, 'tabId'));

/// The tab a location shows or was opened from, or null if it belongs to
/// no tab (Dashboard, Reports, Settings).
String? tabIdForLocation(Uri uri) {
  final path = uri.path;

  // Tracking holds three tabs, told apart by ?tab=. Its child screens are
  // told apart by their path. Conditions belong to Care.
  if (path == AppRoutes.tracking) {
    return switch (uri.queryParameters['tab']) {
      'vitals' => 'track.vitals',
      'conditions' => 'care.conditions',
      _ => 'track.symptoms',
    };
  }
  if (path == AppRoutes.illness ||
      path.startsWith('${AppRoutes.tracking}/condition/')) {
    return 'care.conditions';
  }
  if (path.startsWith('${AppRoutes.tracking}/')) {
    return path.endsWith('new-vital') || path.endsWith('/edit-vital')
        ? 'track.vitals'
        : 'track.symptoms';
  }

  for (final tab in _tabsById.values) {
    final base = Uri.parse(tab.route).path;
    if (base == AppRoutes.tracking) continue;
    if (path == base || path.startsWith('$base/')) return tab.id;
  }
  return null;
}

/// The section to show as selected for a location, or null if it is in
/// none (Reports, Settings).
String? sectionIdForLocation(Uri uri) {
  if (uri.path == AppRoutes.home ||
      uri.path == AppRoutes.dashboard ||
      uri.path.startsWith('${AppRoutes.dashboard}/')) {
    return 'dashboard';
  }
  final tab = tabIdForLocation(uri);
  return tab == null ? null : sectionOfTab(tab).id;
}

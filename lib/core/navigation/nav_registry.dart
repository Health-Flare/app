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

  /// The list screen's route today. Track and Care (#141) moves these.
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

const navFeatures = <NavFeature>[];

// ---------------------------------------------------------------------------
// Sections and tabs (Track and Care, layout v2)
// ---------------------------------------------------------------------------

const navSections = <NavSection>[];

// ---------------------------------------------------------------------------
// Bottom bars
// ---------------------------------------------------------------------------

/// The bar today: six destinations. Each item uses the id of what it is in
/// layout v2 (Tracking is `track`, Meds is the `care.medications` tab), so
/// the guide and the "Like before" preset can name them.
const legacyBar = <NavBarItem>[];

// ---------------------------------------------------------------------------
// Retired ids
// ---------------------------------------------------------------------------

/// Retired id -> the id that replaced it. Add an entry in the same PR that
/// retires an id. Chains are followed (`a -> b -> c`).
const retiredNavIds = <String, String>{};

/// Every id in use now: features, sections and tabs.
Set<String> get knownNavIds => throw UnimplementedError();

/// [id] after following [retired] replacements, or null if neither it nor
/// what replaced it is in [known]. A cycle in [retired] gives null.
String? resolveNavId(
  String id, {
  Set<String>? known,
  Map<String, String> retired = retiredNavIds,
}) => throw UnimplementedError();

/// [ids] resolved one by one: replacements followed, unknown ids dropped,
/// and a later duplicate removed so each id appears once, keeping the
/// order of first appearance. [ids] itself is never changed.
List<String> resolveNavIds(
  List<String> ids, {
  Set<String>? known,
  Map<String, String> retired = retiredNavIds,
}) => throw UnimplementedError();

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
}) => throw UnimplementedError();

/// Keeps the [AppRoutes] import used until the registry is filled in.
const _routes = AppRoutes.dashboard;
// ignore: unused_element
String get _unusedRoute => _routes;

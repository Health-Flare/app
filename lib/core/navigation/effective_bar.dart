import 'package:flutter/material.dart';

import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/navigation/section_routes.dart';

// The bottom bar as shown (#143), worked out on every read from the stored
// choice: never written back (rule 4). Spec:
// docs/features/navigation-customization.feature ("Bottom bar").

/// More: a real screen listing what isn't in the bar.
const moreId = 'more';
const moreLocation = '/more';

const minBarItems = 3;
const maxBarItems = 5;

/// "Like before": as close to the 1.9.1 bar as five items allow. More
/// (Care, Journal) is added because those sections are left out.
const likeBeforePreset = [
  'dashboard',
  'track',
  'care.medications',
  'track.meals',
];
const likeBeforeNote = 'The old bar had six items. Sleep is now in Track.';

/// One item in the bar: a section, a pinned tab, or More.
class BarSlot {
  const BarSlot({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.moreIds = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// For More: the sections and screens it lists, in order.
  final List<String> moreIds;
}

final _sections = {for (final s in navSections) s.id: s};
final _tabs = {
  for (final s in navSections)
    for (final t in s.tabs) t.id: t,
};

/// The slot for a section or tab id, or null for an unknown id.
BarSlot? slotFor(String id) {
  final s = _sections[id];
  if (s != null) {
    return BarSlot(
      id: id,
      label: s.label,
      icon: s.icon,
      selectedIcon: s.selectedIcon,
    );
  }
  final t = _tabs[id];
  if (t != null) {
    return BarSlot(
      id: id,
      label: t.barLabel,
      icon: t.icon,
      selectedIcon: t.selectedIcon,
    );
  }
  return null;
}

/// The label for [id] in the bar and the editor.
String barLabelFor(String id) =>
    id == moreId ? 'More' : (slotFor(id)?.label ?? id);

/// The bar to show for [ids] (already resolved: barFor / resolveBarIds),
/// for what [shown] allows (features in use for the active profile).
///
/// - Dashboard is always first.
/// - A pinned screen or section that isn't shown drops out quietly.
/// - Fewer than three left: the default bar, the same rule as for ids the
///   app doesn't know.
/// - Sections left out go into More, which counts toward the five. If a
///   feature turned back on means More is needed with five already in the
///   bar, the fifth moves into More.
List<BarSlot> effectiveBar(
  List<String> ids, {
  required bool Function(String id) shown,
  List<String>? fallback,
}) {
  List<String> visible(List<String> from) => [
    'dashboard',
    for (final id in from)
      if (id != 'dashboard' && slotFor(id) != null && shown(id)) id,
  ];

  var items = visible(ids);
  if (items.length < minBarItems) {
    items = visible(fallback ?? defaultBarVersions[2]!);
  }

  final left = [
    for (final s in navSections)
      if (s.tabs.isNotEmpty && !items.contains(s.id) && shown(s.id)) s.id,
  ];
  final overflow = <String>[];
  if (left.isNotEmpty && items.length >= maxBarItems) {
    overflow.addAll(items.sublist(maxBarItems - 1));
    items = items.sublist(0, maxBarItems - 1);
  }
  final more = [...left, ...overflow];

  return [
    for (final id in items) slotFor(id)!,
    if (more.isNotEmpty)
      BarSlot(
        id: moreId,
        label: 'More',
        icon: Icons.more_horiz_rounded,
        selectedIcon: Icons.more_horiz_rounded,
        moreIds: more,
      ),
  ];
}

/// Which slot to highlight at [location], or null to keep the last one
/// (Reports). A pinned screen wins over its section: Care is not
/// highlighted while a pinned Medications is open.
String? selectedSlotId(List<BarSlot> slots, Uri location) {
  if (location.path == moreLocation) return moreId;
  final ids = [for (final s in slots) s.id];
  final tab = tabIdForLocation(location);
  if (tab != null && ids.contains(tab)) return tab;
  final section = sectionIdForLocation(location);
  if (section != null && ids.contains(section)) return section;
  final more = slots.where((s) => s.id == moreId).firstOrNull;
  if (more != null &&
      (more.moreIds.contains(section) || more.moreIds.contains(tab))) {
    return moreId;
  }
  return null;
}

/// How many slots [ids] take with every feature on, More included.
int _slotCount(List<String> ids) =>
    effectiveBar(ids, shown: (_) => true).length;

/// Whether [id] can be added: the bar, More included, stays at five.
bool canAdd(List<String> ids, String id) {
  final next = [...ids, id];
  final items = next.where((i) => slotFor(i) != null).length;
  final needsMore = navSections.any(
    (s) => s.tabs.isNotEmpty && !next.contains(s.id),
  );
  return items + (needsMore ? 1 : 0) <= maxBarItems;
}

/// Whether an item can be removed: three are the fewest.
bool canRemove(List<String> ids) => ids.length > minBarItems;

/// The line under the editor at a limit, or null between them.
String? barLimitNote(List<String> ids) {
  if (!canRemove(ids)) {
    return 'The bar needs at least three items, so none can be removed. '
        'Add one first.';
  }
  final slots = _slotCount(ids);
  if (slots < maxBarItems) return null;
  return slots > ids.length
      ? 'The bar holds five items, More included.'
      : 'The bar holds five items. Remove one to add another.';
}

/// Said after a move, for screen readers.
String moveAnnouncement(String label, int position, int of) =>
    '$label, position $position of $of';

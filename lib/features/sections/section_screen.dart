import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/navigation/features_in_use.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/navigation/section_routes.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/sections/section_state.dart';
import 'package:health_flare/features/sections/tab_content.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';
import 'package:health_flare/models/profile.dart';

/// The page for a list route when Track and Care is on: the section that
/// holds the tab the location names. No transition, so switching tabs
/// looks like switching tabs, not opening a screen.
Page<void> sectionPage(GoRouterState state) => NoTransitionPage(
  key: state.pageKey,
  child: SectionScreen(tabId: tabIdForLocation(state.uri)!),
);

/// A section (Track, Care, Journal) with its tab row, showing [tabId]
/// (#141). Spec: docs/features/navigation.feature.
///
/// Each tab has its own address, and changing tab goes there, so old links
/// and the back button work. The add button follows the tab; Reports is
/// in the top bar of every section.
class SectionScreen extends ConsumerStatefulWidget {
  const SectionScreen({super.key, required this.tabId});

  final String tabId;

  @override
  ConsumerState<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends ConsumerState<SectionScreen>
    with TickerProviderStateMixin {
  late final NavSection _section = sectionOfTab(widget.tabId);
  TabController? _controller;
  List<String> _tabIds = const [];

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// The tabs to show: those whose feature is on for the active profile,
  /// plus the open tab if its feature is off (opened directly, #142).
  List<NavTab> _tabs() {
    final visible = ref.watch(visibleTabsProvider(_section.id));
    return [
      for (final t in _section.tabs)
        if (t.id == widget.tabId || visible.contains(t)) t,
    ];
  }

  /// One controller per set of tabs; a new one when tabs come or go
  /// (a feature turned on or off, another profile).
  TabController? _controllerFor(List<NavTab> tabs) {
    final ids = [for (final t in tabs) t.id];
    final index = ids.indexOf(widget.tabId).clamp(0, ids.length - 1);
    if (ids.length < 2) {
      _retire();
      _tabIds = ids;
      return null;
    }
    if (_controller == null || !listEquals(ids, _tabIds)) {
      _retire();
      _controller = TabController(
        length: ids.length,
        initialIndex: index,
        vsync: this,
      );
      _tabIds = ids;
    } else if (_controller!.index != index) {
      // Same route, other tab (/tracking and /tracking?tab=vitals).
      _controller!.index = index;
    }
    return _controller;
  }

  /// The old controller may still be attached to this frame's TabBar.
  void _retire() {
    final old = _controller;
    _controller = null;
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabId = widget.tabId;
    ref.read(lastTabProvider)[_section.id] = tabId;
    final content = ref.watch(tabContentProvider)[tabId]!;
    final profile = ref.watch(activeProfileDataProvider);
    final tabs = _tabs();
    final controller = _controllerFor(tabs);
    final featureOn = ref.watch(featureOnProvider(tabId));
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: HFAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_section.label),
            if (profile != null)
              Text(
                profile.name,
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
          ],
        ),
        actions: [...content.actions, const ReportsIconButton()],
        // One tab left: no tab row (navigation-customization.feature).
        bottom: controller == null
            ? null
            : TabBar(
                controller: controller,
                // Scrolls sideways at large text sizes rather than cutting
                // labels off; every tab at least 48dp high.
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                onTap: (i) {
                  final next = tabs[i].id;
                  if (next != tabId) context.go(tabLocation(next));
                },
                tabs: [for (final t in tabs) Tab(height: 48, text: t.label)],
              ),
      ),
      body: Column(
        children: [
          if (!featureOn && profile != null)
            _FeatureOffLine(featureId: tabId, profile: profile),
          Expanded(
            child: PageStorage(
              bucket: ref.watch(sectionScrollBucketProvider),
              child: KeyedSubtree(
                key: PageStorageKey<String>(tabId),
                child: Builder(builder: content.body),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_$tabId',
        tooltip: content.addTooltip,
        onPressed: () {
          final target = ref.read(content.addTarget);
          context.push(target.location, extra: target.extra);
        },
        child: Icon(content.addIcon),
      ),
    );
  }
}

/// "Meals is turned off for Sarah" over a turned-off feature's list,
/// opened directly (#142). The list still shows: data is never hidden,
/// only not offered.
class _FeatureOffLine extends ConsumerWidget {
  const _FeatureOffLine({required this.featureId, required this.profile});

  final String featureId;
  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final label = navFeature(featureId).label;
    return Material(
      color: cs.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$label is turned off for ${profile.name}',
                style: TextStyle(color: cs.onSecondaryContainer),
              ),
            ),
            TextButton(
              onPressed: () => setFeatureOn(
                ref.read(profileListProvider.notifier),
                ref.read(activeProfileDataProvider) ?? profile,
                featureId,
                on: true,
              ),
              child: const Text('Turn on'),
            ),
          ],
        ),
      ),
    );
  }
}

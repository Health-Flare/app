import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/navigation/section_routes.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/sections/section_state.dart';
import 'package:health_flare/features/sections/tab_content.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

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
    with SingleTickerProviderStateMixin {
  late final NavSection _section = sectionOfTab(widget.tabId);
  late final TabController _controller = TabController(
    length: _section.tabs.length,
    initialIndex: _indexOf(widget.tabId),
    vsync: this,
  );

  int _indexOf(String tabId) =>
      _section.tabs.indexWhere((t) => t.id == tabId).clamp(0, 99);

  @override
  void didUpdateWidget(SectionScreen old) {
    super.didUpdateWidget(old);
    // Same route, other tab (/tracking and /tracking?tab=vitals).
    if (old.tabId != widget.tabId) _controller.index = _indexOf(widget.tabId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabId = widget.tabId;
    ref.read(lastTabProvider)[_section.id] = tabId;
    final content = ref.watch(tabContentProvider)[tabId]!;
    final profile = ref.watch(activeProfileDataProvider);
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
        bottom: _section.tabs.length < 2
            ? null
            : TabBar(
                controller: _controller,
                // Scrolls sideways at large text sizes rather than cutting
                // labels off; every tab at least 48dp high.
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                onTap: (i) {
                  final next = _section.tabs[i].id;
                  if (next != tabId) context.go(tabLocation(next));
                },
                tabs: [
                  for (final t in _section.tabs) Tab(height: 48, text: t.label),
                ],
              ),
      ),
      body: PageStorage(
        bucket: ref.watch(sectionScrollBucketProvider),
        child: KeyedSubtree(
          key: PageStorageKey<String>(tabId),
          child: Builder(builder: content.body),
        ),
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

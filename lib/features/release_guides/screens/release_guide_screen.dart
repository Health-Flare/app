import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/feature_flags.dart';
import 'package:health_flare/core/navigation/bar_choice.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/effective_bar.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/navigation/section_routes.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/release_guides/guide_rules.dart';
import 'package:health_flare/features/release_guides/release_guide.dart';
import 'package:health_flare/features/release_guides/release_guide_provider.dart';
import 'package:health_flare/features/release_guides/widgets/bar_drawing.dart';
import 'package:health_flare/features/release_guides/widgets/guide_card.dart';
import 'package:health_flare/features/shared/widgets/guided_step_header.dart';

/// A release guide (#145), on the same guided-flow chrome as onboarding:
/// dots, Back, Skip. Spec: docs/features/release-guides.feature.
///
/// Seen (the card won't come back) on Skip, Back on the first step, Escape,
/// a choice on "Keep it or change it", or Done. Leaving any other way (the
/// app closes, "Show me") resumes at the same step next time.
class ReleaseGuideScreen extends ConsumerStatefulWidget {
  const ReleaseGuideScreen({
    super.key,
    required this.guideId,
    this.initialStep = 0,
    this.replay = false,
  });

  final String guideId;
  final int initialStep;

  /// Opened from Settings > What's new: nothing about the guide is
  /// recorded, though a choice still changes the bar.
  final bool replay;

  @override
  ConsumerState<ReleaseGuideScreen> createState() => _ReleaseGuideScreenState();
}

class _ReleaseGuideScreenState extends ConsumerState<ReleaseGuideScreen> {
  late final ReleaseGuide _guide = releaseGuides[widget.guideId]!;

  /// Taken when the guide opens: a choice or a pin changes the bar, and
  /// the guide still shows what it was.
  late final BarChange _change;

  late final PageController _pages = PageController(
    initialPage: widget.initialStep,
  );
  late int _index = widget.initialStep;
  late GuideChoice _choice;
  bool _setUpAfter = false;
  String? _pinnedLabel;

  int get _count => _guide.steps.length;

  @override
  void initState() {
    super.initState();
    _change = ref.read(releaseGuideProvider).change ?? _replayChange();
    _choice = guideChoices(customized: _change.customized).first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(guideOpenedThisLaunchProvider.notifier).state = true;
      _saveStep(_index);
    });
  }

  /// What the guide shows when replayed: the bar before this change, or
  /// the person's own bar, beside the new default.
  BarChange _replayChange() {
    final current = currentDefaultBarVersion(ref.read(featureFlagsProvider));
    final record = ref.read(barChoiceProvider);
    final customized = record.storedBar != null;
    return BarChange(
      fromVersion: current - 1,
      toVersion: current,
      customized: customized,
      before: customized
          ? barFor(record, current: current)
          : defaultBarVersions[current - 1]!,
      newDefault: defaultBarVersions[current]!,
    );
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _saveStep(int i) {
    if (widget.replay) return;
    ref.read(releaseGuideProvider.notifier).saveStep(i);
  }

  Future<void> _markSeen() async {
    if (widget.replay) return;
    await ref.read(releaseGuideProvider.notifier).markSeen();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  Future<void> _skip() async {
    await _markSeen();
    if (mounted) _close();
  }

  void _goTo(int i) {
    if (MediaQuery.of(context).disableAnimations) {
      _pages.jumpToPage(i);
    } else {
      _pages.animateToPage(
        i,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPage(int i) {
    setState(() => _index = i);
    _saveStep(i);
    ref.read(announcerProvider)(
      context,
      'Step ${i + 1} of $_count, ${_guide.steps[i]}',
    );
  }

  Future<void> _back() async {
    if (_index == 0) return _skip();
    _goTo(_index - 1);
  }

  Future<void> _next() async {
    if (_index == 2) await _applyChoice();
    if (!mounted) return;
    _goTo(_index + 1);
  }

  Future<void> _applyChoice() async {
    final bar = ref.read(barChoiceProvider.notifier);
    switch (_choice) {
      case GuideChoice.useNew:
        if (_change.customized) await bar.useDefault();
      case GuideChoice.likeBefore:
        await bar.applyLikeBefore();
      case GuideChoice.setUpMyself:
        _setUpAfter = true;
      case GuideChoice.keepMine:
        break;
    }
    await _markSeen();
  }

  Future<void> _done() async {
    await _markSeen();
    if (!mounted) return;
    if (!_setUpAfter) return _close();
    // "Set it up myself": Settings, scrolled to Your layout.
    if (context.canPop()) {
      final router = GoRouter.of(context);
      context.pop();
      unawaited(router.push(AppRoutes.settingsLayout));
    } else {
      context.go(AppRoutes.settingsLayout);
    }
  }

  /// "Show me": the guide closes and the screen opens, its bar item
  /// outlined. Not counted as seen: the card stays until it is.
  void _showMe(GuideRow row) {
    final location = tabLocation(row.tabId);
    final slots = ref.read(effectiveBarProvider);
    ref.read(barOutlineProvider.notifier).state = selectedSlotId(
      slots,
      Uri.parse(location),
    );
    context.go(location);
  }

  Future<void> _pin(GuideRow row) async {
    final bar = ref.read(barChoiceProvider.notifier);
    final ids = bar.shownIds;
    if (ids.contains(row.tabId)) return;
    if (canAdd(ids, row.tabId)) {
      await bar.choose([...ids, row.tabId]);
      if (mounted) setState(() => _pinnedLabel = barLabelFor(row.tabId));
    } else {
      await context.push(AppRoutes.bottomBar, extra: row.tabId);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _count - 1;
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _skip},
      child: Focus(
        autofocus: true,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _back();
          },
          child: Scaffold(
            body: Column(
              children: [
                GuidedStepHeader(
                  total: _count,
                  currentIndex: _index,
                  stepTitle: _guide.steps[_index],
                  onBack: _back,
                  onSkip: last ? null : _skip,
                ),
                Expanded(
                  child: PageView(
                    controller: _pages,
                    onPageChanged: _onPage,
                    children: [
                      _Step(
                        title: _guide.steps[0],
                        children: _sectionsStep(context),
                      ),
                      _Step(
                        title: _guide.steps[1],
                        children: _movedStep(context),
                      ),
                      _Step(
                        title: _guide.steps[2],
                        children: _choiceStep(context),
                      ),
                      _Step(
                        title: _guide.steps[3],
                        children: _findAgainStep(context),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: last ? _done : _next,
                        child: Text(last ? 'Done' : 'Next'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Four sections now ──────────────────────────────────────────────────

  List<Widget> _sectionsStep(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final before = _change.customized
        ? [
            for (final id in _change.before)
              if (slotFor(id) case final s?) (s.icon, s.label),
          ]
        : [
            for (final id in _change.before)
              if (legacyBar.where((i) => i.id == id).firstOrNull
                  case final item?)
                (item.icon, item.label)
              else if (slotFor(id) case final s?)
                (s.icon, s.label),
          ];
    final after = [
      for (final id in _change.newDefault)
        if (slotFor(id) case final s?) (s.icon, s.label),
    ];
    return [
      Text(_guide.intro, style: tt.bodyLarge),
      const SizedBox(height: 16),
      BarDrawing(
        label: _change.customized ? 'Your bar' : 'The bar you had',
        items: before,
      ),
      const SizedBox(height: 12),
      BarDrawing(
        label: _change.customized ? 'The new default' : 'The new bar',
        items: after,
      ),
      const SizedBox(height: 16),
      for (final MapEntry(key: id, value: line) in _guide.sectionLines.entries)
        if (slotFor(id) case final s?)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(s.icon, color: cs.primary),
            title: Text(s.label),
            subtitle: Text(line),
          ),
    ];
  }

  // ── Where things moved ─────────────────────────────────────────────────

  List<Widget> _movedStep(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final stacked = MediaQuery.textScalerOf(context).scale(14) / 14 >= 1.5;
    ref.watch(barChoiceProvider);
    final inBar = ref.read(barChoiceProvider.notifier).shownIds;
    Widget row(GuideRow r) => _MovedRow(
      key: ValueKey('moved-${r.was}'),
      row: r,
      stacked: stacked,
      pinned: inBar.contains(r.tabId),
      onShowMe: () => _showMe(r),
      onPin: r.pinnable ? () => _pin(r) : null,
    );
    return [
      Text('Moved', style: tt.titleMedium),
      for (final r in _guide.moved) row(r),
      const SizedBox(height: 16),
      Text('Now with a place of their own', style: tt.titleMedium),
      for (final r in _guide.ownPlace) row(r),
      if (_pinnedLabel != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(
            liveRegion: true,
            child: Text(pinnedLine(_pinnedLabel!), style: tt.bodyMedium),
          ),
        ),
    ];
  }

  // ── Keep it or change it ───────────────────────────────────────────────

  List<Widget> _choiceStep(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return [
      if (_change.customized)
        Text(
          'Your bar has been kept. You can keep it, or switch to the new '
          'default.',
          style: tt.bodyLarge,
        ),
      RadioGroup<GuideChoice>(
        groupValue: _choice,
        onChanged: (c) => setState(() => _choice = c ?? _choice),
        child: Column(
          children: [
            for (final c in guideChoices(customized: _change.customized))
              RadioListTile<GuideChoice>(
                contentPadding: EdgeInsets.zero,
                value: c,
                title: Text(choiceLabel(c)),
                subtitle: switch (c) {
                  GuideChoice.likeBefore => const Text(
                    'Dashboard, Track, Medications, Meals and More',
                  ),
                  GuideChoice.setUpMyself => const Text(
                    'Opens Settings > Your layout after this guide',
                  ),
                  _ => null,
                },
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Text(
        "You can turn off features you don't use in Settings > Your layout. "
        'All of this can be changed any time.',
        style: tt.bodyMedium,
      ),
    ];
  }

  // ── Finding this again ─────────────────────────────────────────────────

  List<Widget> _findAgainStep(BuildContext context) => [
    Text(
      "This guide is in Settings > What's new, with the update that brought "
      'it. Open it any time.',
      style: Theme.of(context).textTheme.bodyLarge,
    ),
  ];
}

class _Step extends StatelessWidget {
  const _Step({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}

/// One "Was -> Now" row, with "Show me" and, for what was in the old bar,
/// "Pin". At large text it stacks instead of sitting in columns.
class _MovedRow extends StatelessWidget {
  const _MovedRow({
    super.key,
    required this.row,
    required this.stacked,
    required this.pinned,
    required this.onShowMe,
    required this.onPin,
  });

  final GuideRow row;
  final bool stacked;
  final bool pinned;
  final VoidCallback onShowMe;
  final VoidCallback? onPin;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final names = stacked
        ? Column(
            key: ValueKey('moved-${row.was}-stacked'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(row.was, style: tt.titleSmall),
              Text(row.now, style: tt.bodyMedium),
            ],
          )
        : Row(
            children: [
              Expanded(child: Text(row.was, style: tt.titleSmall)),
              ExcludeSemantics(
                child: Icon(Icons.arrow_forward, size: 16, color: cs.outline),
              ),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: Text(row.now, style: tt.bodyMedium)),
            ],
          );
    return Semantics(
      container: true,
      label: spokenRow(row),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(child: names),
            Wrap(
              spacing: 8,
              children: [
                TextButton(onPressed: onShowMe, child: const Text('Show me')),
                if (onPin != null)
                  pinned
                      ? TextButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Pinned'),
                        )
                      : OutlinedButton(
                          // The theme makes outlined buttons full width.
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(64, 48),
                          ),
                          onPressed: onPin,
                          child: const Text('Pin'),
                        ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

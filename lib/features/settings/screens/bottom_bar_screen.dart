import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/navigation/bar_choice.dart';
import 'package:health_flare/core/navigation/bar_layout.dart';
import 'package:health_flare/core/navigation/effective_bar.dart';
import 'package:health_flare/core/navigation/nav_registry.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Settings > Your layout > Bottom bar (#143). Changes apply at once, with
/// Undo. Spec: navigation-customization.feature ("Bottom bar (per device)").
class BottomBarScreen extends ConsumerStatefulWidget {
  const BottomBarScreen({super.key});

  @override
  ConsumerState<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends ConsumerState<BottomBarScreen> {
  final _inBarKey = GlobalKey();

  /// Shown after "Like before" until the next change.
  bool _likeBeforeNote = false;

  BarChoiceNotifier get _bar => ref.read(barChoiceProvider.notifier);

  Future<void> _change(List<String> ids, {String? announce}) async {
    final before = await _bar.choose(ids);
    if (!mounted) return;
    setState(() => _likeBeforeNote = false);
    if (announce != null) ref.read(announcerProvider)(context, announce);
    _offerUndo(before);
  }

  void _offerUndo(BarRecord before) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Bottom bar updated'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _bar.restore(before);
            if (mounted) setState(() => _likeBeforeNote = false);
          },
        ),
      ),
    );
  }

  Future<void> _move(List<String> ids, int from, int to) async {
    final next = List.of(ids);
    final id = next.removeAt(from);
    next.insert(to, id);
    await _change(
      next,
      announce: moveAnnouncement(barLabelFor(id), to + 1, next.length),
    );
  }

  Future<void> _useDefault() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go back to the default bar?'),
        content: const Text('Dashboard, Track, Care and Journal.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Use default'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final before = await _bar.useDefault();
    if (!mounted) return;
    setState(() => _likeBeforeNote = false);
    _offerUndo(before);
  }

  Future<void> _likeBefore() async {
    final before = await _bar.applyLikeBefore();
    if (!mounted) return;
    setState(() => _likeBeforeNote = true);
    _offerUndo(before);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(barChoiceProvider);
    final customized = ref.watch(barIsCustomizedProvider);
    final shown = ref.watch(barShownProvider);
    final profile = ref.watch(activeProfileDataProvider);
    final ids = _bar.shownIds;
    final slots = effectiveBar(ids, shown: shown);
    final more = slots.where((s) => s.id == moreId).firstOrNull;
    final note = barLimitNote(ids);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rest = ids.where((id) => id != 'dashboard').toList();

    final addable = [
      for (final s in navSections) ...[
        if (s.id != 'dashboard' && !ids.contains(s.id) && shown(s.id)) s.id,
        for (final t in s.tabs)
          if (!ids.contains(t.id) && shown(t.id)) t.id,
      ],
    ];

    return Scaffold(
      appBar: const HFAppBar(title: Text('Bottom bar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'This bar is for this device, whoever is using the app.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            _Preview(slots: slots),
            if (more != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'More: ${more.moreIds.map(barLabelFor).join(', ')}',
                  style: tt.bodyMedium,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _likeBefore,
                    child: const Text('Like before'),
                  ),
                  TextButton(
                    onPressed: customized ? _useDefault : null,
                    child: const Text('Use default'),
                  ),
                ],
              ),
            ),
            if (_likeBeforeNote)
              Card(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(likeBeforeNote),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () => Scrollable.ensureVisible(
                            _inBarKey.currentContext!,
                            duration: const Duration(milliseconds: 250),
                          ),
                          child: const Text('Change it'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            _Header('In the bar', key: _inBarKey),
            ListTile(
              key: const ValueKey('bar-row-Dashboard'),
              leading: Icon(slotFor('dashboard')!.icon),
              title: Text(
                'Dashboard',
                semanticsLabel: 'Dashboard, position 1 of ${ids.length}',
              ),
              subtitle: const Text('Always first'),
            ),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderItem: (from, to) {
                if (to != from) _move(ids, from + 1, to + 1);
              },
              children: [
                for (var i = 0; i < rest.length; i++)
                  _BarRow(
                    key: ValueKey('bar-row-${barLabelFor(rest[i])}'),
                    id: rest[i],
                    index: i,
                    position: i + 2,
                    of: ids.length,
                    hiddenFor: shown(rest[i]) ? null : profile?.name,
                    onUp: i == 0 ? null : () => _move(ids, i + 1, i),
                    onDown: i == rest.length - 1
                        ? null
                        : () => _move(ids, i + 1, i + 2),
                    onRemove: canRemove(ids)
                        ? () => _change([...ids]..remove(rest[i]))
                        : null,
                  ),
              ],
            ),
            if (note != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(
                  note,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            const _Header('Can be added'),
            for (final id in addable)
              ListTile(
                leading: Icon(slotFor(id)!.icon),
                title: Text(barLabelFor(id)),
                subtitle: _sectionOf(id) == null ? null : Text(_sectionOf(id)!),
                trailing: IconButton(
                  key: ValueKey('add-${barLabelFor(id)}'),
                  tooltip: 'Add ${barLabelFor(id)}',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: canAdd(ids, id)
                      ? () => _change([...ids, id])
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The section a tab is in, or null for a section.
String? _sectionOf(String id) {
  for (final s in navSections) {
    if (s.tabs.any((t) => t.id == id)) return s.label;
  }
  return null;
}

class _Header extends StatelessWidget {
  const _Header(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
    child: Semantics(
      header: true,
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ),
  );
}

/// What the bar will look like, not tappable.
class _Preview extends StatelessWidget {
  const _Preview({required this.slots});

  final List<BarSlot> slots;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Semantics(
      key: const ValueKey('bar-preview'),
      container: true,
      label: 'Bottom bar: ${slots.map((s) => s.label).join(', ')}',
      child: ExcludeSemantics(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              for (final s in slots)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.icon, color: cs.onSurfaceVariant),
                      const SizedBox(height: 4),
                      Text(
                        s.label,
                        style: tt.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    super.key,
    required this.id,
    required this.index,
    required this.position,
    required this.of,
    required this.hiddenFor,
    required this.onUp,
    required this.onDown,
    required this.onRemove,
  });

  final String id;
  final int index;
  final int position;
  final int of;

  /// The profile it's turned off for, if it is.
  final String? hiddenFor;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final label = barLabelFor(id);
    final section = _sectionOf(id);
    return Material(
      child: ListTile(
        contentPadding: const EdgeInsetsDirectional.only(start: 4, end: 4),
        leading: ReorderableDragStartListener(
          index: index,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(slotFor(id)!.icon),
          ),
        ),
        title: Text(label, semanticsLabel: '$label, position $position of $of'),
        subtitle: hiddenFor != null
            ? Text('Turned off for $hiddenFor, so not shown')
            : section == null
            ? null
            : Text(section),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Move $label up',
              icon: const Icon(Icons.arrow_upward_rounded),
              onPressed: onUp,
            ),
            IconButton(
              tooltip: 'Move $label down',
              icon: const Icon(Icons.arrow_downward_rounded),
              onPressed: onDown,
            ),
            IconButton(
              tooltip: 'Remove $label',
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

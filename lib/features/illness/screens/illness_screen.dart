import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/condition.dart';
import 'package:health_flare/models/symptom.dart';
import 'package:health_flare/core/providers/condition_provider.dart';

/// Screen for selecting illnesses (conditions) and quick-adding symptoms.
///
/// ## Flow
/// 1. User types in the search box — the condition list filters live (starts-with
///    ranked above contains, both groups alphabetical).
/// 2. User taps a condition row to select it — selected conditions appear as
///    removable chips above the list.
/// 3. After any condition is selected, a "Common symptoms" chip grid appears
///    below the condition list so the user can add symptoms with one tap.
/// 4. Tapping "Done" (or the back button) persists all selections and returns.
///
/// Can be pushed as a full-screen route or presented as a modal sheet via
/// [showIllnessSheet].
class IllnessScreen extends ConsumerStatefulWidget {
  const IllnessScreen({super.key});

  @override
  ConsumerState<IllnessScreen> createState() => _IllnessScreenState();
}

class _IllnessScreenState extends ConsumerState<IllnessScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  // Conditions chosen in this session (not yet in userConditionListProvider)
  final Set<int> _pendingConditionIds = {};

  // Symptoms toggled on/off in this session
  final Set<int> _pendingSymptomIds = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<Condition> _filteredConditions(
    List<Condition> all, {
    required Set<int> trackedIds,
  }) {
    // Already-tracked conditions are excluded from the selectable list.
    final available = all.where((c) => !trackedIds.contains(c.id)).toList();
    return rankSearch(available, _query, (c) => c.name);
  }

  List<Symptom> _filteredSymptoms(List<Symptom> all) {
    return rankSearch(all, _query, (s) => s.name);
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final conditionsNotifier = ref.read(userConditionListProvider.notifier);
    final symptomsNotifier = ref.read(userSymptomListProvider.notifier);

    final allConditions = ref.read(conditionCatalogProvider);
    final allSymptoms = ref.read(symptomCatalogProvider);

    for (final id in _pendingConditionIds) {
      final condition = allConditions.where((c) => c.id == id).firstOrNull;
      if (condition != null) {
        await conditionsNotifier.add(
          conditionId: condition.id,
          conditionName: condition.name,
        );
      }
    }

    for (final id in _pendingSymptomIds) {
      final symptom = allSymptoms.where((s) => s.id == id).firstOrNull;
      if (symptom != null) {
        await symptomsNotifier.add(
          symptomId: symptom.id,
          symptomName: symptom.name,
        );
      }
    }

    if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go(AppRoutes.dashboard);
      }
    }
  }

  // ── "Add custom" when search has no matches ────────────────────────────────

  Future<void> _addCustomCondition(String name) async {
    final notifier = ref.read(conditionCatalogProvider.notifier);
    final condition = await notifier.addCustom(name);
    setState(() {
      _pendingConditionIds.add(condition.id);
      _searchController.clear();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final allConditions = ref.watch(conditionCatalogProvider);
    final allSymptoms = ref.watch(symptomCatalogProvider);
    final userConditions = ref.watch(userConditionListProvider);
    final userSymptoms = ref.watch(userSymptomListProvider);

    // All condition ids that are "active" (already tracked OR pending)
    final trackedConditionIds = userConditions
        .map((uc) => uc.conditionId)
        .toSet();
    final trackedSymptomIds = userSymptoms.map((us) => us.symptomId).toSet();

    final filteredConditions = _filteredConditions(
      allConditions,
      trackedIds: trackedConditionIds,
    );
    final filteredSymptoms = _filteredSymptoms(allSymptoms);

    final showSymptomsSection =
        _pendingConditionIds.isNotEmpty || trackedConditionIds.isNotEmpty;

    final hasSelections =
        _pendingConditionIds.isNotEmpty || _pendingSymptomIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Track Illnesses')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: hasSelections && !_isSaving ? _save : null,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Add to profile'),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search illnesses…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _searchController.clear,
                        tooltip: 'Clear search',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            ),
          ),

          // ── Pending conditions chips ────────────────────────────────────
          if (_pendingConditionIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SectionLabel('Selected'),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _pendingConditionIds.map((id) {
                  final condition = allConditions
                      .where((c) => c.id == id)
                      .firstOrNull;
                  final name = condition?.name ?? '…';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      label: Text(name),
                      onDeleted: () =>
                          setState(() => _pendingConditionIds.remove(id)),
                      deleteIconColor: cs.onSecondaryContainer,
                      backgroundColor: cs.secondaryContainer,
                      labelStyle: tt.labelMedium?.copyWith(
                        color: cs.onSecondaryContainer,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Scrollable content: conditions + symptoms ───────────────────
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Conditions section header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
                    child: _SectionLabel('Conditions'),
                  ),
                ),

                // Condition rows
                if (filteredConditions.isEmpty && _query.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _AddCustomTile(
                      name: _query,
                      onTap: () => _addCustomCondition(_query),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: filteredConditions.length,
                    itemBuilder: (context, i) {
                      final condition = filteredConditions[i];
                      final isPending = _pendingConditionIds.contains(
                        condition.id,
                      );
                      return _ConditionTile(
                        condition: condition,
                        selected: isPending,
                        onTap: () => setState(() {
                          if (isPending) {
                            _pendingConditionIds.remove(condition.id);
                          } else {
                            _pendingConditionIds.add(condition.id);
                          }
                        }),
                      );
                    },
                  ),

                // Symptoms section (shown when any condition is selected)
                if (showSymptomsSection) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel('Common Symptoms'),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to add symptoms you want to track',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filteredSymptoms.map((symptom) {
                          final alreadyTracked = trackedSymptomIds.contains(
                            symptom.id,
                          );
                          final isPending = _pendingSymptomIds.contains(
                            symptom.id,
                          );
                          return _SymptomChip(
                            symptom: symptom,
                            added: alreadyTracked || isPending,
                            onTap: alreadyTracked
                                ? null // can't remove via this screen
                                : () => setState(() {
                                    if (isPending) {
                                      _pendingSymptomIds.remove(symptom.id);
                                    } else {
                                      _pendingSymptomIds.add(symptom.id);
                                    }
                                  }),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Text(
      text.toUpperCase(),
      style: tt.labelSmall?.copyWith(
        color: cs.primary,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ConditionTile extends StatelessWidget {
  const _ConditionTile({
    required this.condition,
    required this.selected,
    required this.onTap,
  });

  final Condition condition;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      title: Text(condition.name),
      trailing: selected
          ? Icon(Icons.check_circle, color: cs.primary)
          : Icon(Icons.circle_outlined, color: cs.outlineVariant),
      onTap: onTap,
      dense: true,
    );
  }
}

/// Shown when search returns no condition matches — lets the user add a
/// custom condition by name.
class _AddCustomTile extends StatelessWidget {
  const _AddCustomTile({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.add_circle_outline, color: cs.primary),
      title: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Add "'),
            TextSpan(
              text: name,
              style: TextStyle(fontWeight: FontWeight.w600, color: cs.primary),
            ),
            const TextSpan(text: '" as a custom illness'),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}

class _SymptomChip extends StatelessWidget {
  const _SymptomChip({
    required this.symptom,
    required this.added,
    required this.onTap,
  });

  final Symptom symptom;
  final bool added;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FilterChip(
      label: Text(
        symptom.name,
        style: tt.labelMedium?.copyWith(
          color: added ? cs.onSecondaryContainer : cs.onSurface,
        ),
      ),
      selected: added,
      // Use a no-op instead of null so already-tracked chips render in their
      // selected/added colour rather than the disabled (muted) state that
      // Material 3 applies when onSelected is null.
      onSelected: onTap != null ? (_) => onTap!() : (_) {},
      selectedColor: cs.secondaryContainer,
      checkmarkColor: cs.onSecondaryContainer,
      showCheckmark: added,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheet helper
// ---------------------------------------------------------------------------

/// Shows [IllnessScreen] as a tall modal bottom sheet.
///
/// Equivalent to navigating to the illness route but usable from
/// bottom-sheet contexts like [FirstLogPrompt].
Future<void> showIllnessSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        const FractionallySizedBox(heightFactor: 0.92, child: IllnessScreen()),
  );
}

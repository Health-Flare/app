import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/reports/models/insight_data.dart';
import 'package:health_flare/features/reports/services/insights_query_service.dart';
import 'package:health_flare/features/reports/widgets/food_triggers_card.dart';
import 'package:health_flare/features/reports/widgets/sleep_correlation_card.dart';
import 'package:health_flare/features/reports/widgets/trend_chart.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Pattern insights screen — shows in-app charts and correlations.
///
/// Accessible from the Reports screen. All data is read from local Isar;
/// nothing is transmitted.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _windowDays = 30;
  InsightData? _data;
  bool _loading = false;
  String? _error;

  // Which symptom is selected in the trend chart picker.
  String? _selectedSymptom;

  static final _headerFmt = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final isar = ref.read(isarProvider);
      final profile = ref.read(activeProfileDataProvider);
      if (profile == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final end = DateTime.now();
      final start = end.subtract(Duration(days: _windowDays - 1));
      final data = await InsightsQueryService.query(
        isar: isar,
        profileId: profile.id,
        start: start,
        end: end,
      );

      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
        // Default to the symptom with the most entries.
        if (_selectedSymptom == null && data.symptomTrends.isNotEmpty) {
          _selectedSymptom = data.symptomTrends.first.name;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load insights: $e';
        _loading = false;
      });
    }
  }

  void _setWindow(int days) {
    setState(() {
      _windowDays = days;
      _selectedSymptom = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final profile = ref.watch(activeProfileDataProvider);
    final profileName = profile?.name ?? 'Profile';

    return Scaffold(
      appBar: HFAppBar(title: Text('Insights — $profileName')),
      body: Column(
        children: [
          // ── Date window selector ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7 days')),
                ButtonSegment(value: 30, label: Text('30 days')),
                ButtonSegment(value: 90, label: Text('90 days')),
              ],
              selected: {_windowDays},
              onSelectionChanged: (sel) => _setWindow(sel.first),
            ),
          ),

          // ── Date range label ──────────────────────────────────────────────
          if (_data != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Text(
                '${_headerFmt.format(_data!.start)} – '
                '${_headerFmt.format(_data!.end)}',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: tt.bodySmall?.copyWith(color: cs.error),
                    ),
                  )
                : _data == null
                ? const SizedBox.shrink()
                : _data!.isEmpty
                ? _EmptyState(windowDays: _windowDays)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      if (_data!.symptomTrends.isNotEmpty)
                        _SymptomTrendSection(
                          data: _data!,
                          selected: _selectedSymptom,
                          onSymptomChanged: (name) =>
                              setState(() => _selectedSymptom = name),
                        ),
                      if (_data!.wellbeingTrend.isNotEmpty)
                        _WellbeingSection(data: _data!),
                      _FoodTriggersSection(data: _data!),
                      _SleepSection(data: _data!),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Section: Symptom trend ────────────────────────────────────────────────────

class _SymptomTrendSection extends StatelessWidget {
  const _SymptomTrendSection({
    required this.data,
    required this.selected,
    required this.onSymptomChanged,
  });

  final InsightData data;
  final String? selected;
  final ValueChanged<String> onSymptomChanged;

  @override
  Widget build(BuildContext context) {
    final selectedTrend = selected != null
        ? data.symptomTrends.firstWhere(
            (t) => t.name == selected,
            orElse: () => data.symptomTrends.first,
          )
        : data.symptomTrends.first;

    return _InsightCard(
      title: 'Symptom Trends',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.symptomTrends.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DropdownButton<String>(
                value: selectedTrend.name,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                isDense: true,
                items: data.symptomTrends
                    .map(
                      (t) =>
                          DropdownMenuItem(value: t.name, child: Text(t.name)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onSymptomChanged(v);
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                selectedTrend.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          if (data.flarePeriods.isNotEmpty) ...[
            const FlareLegendChip(),
            const SizedBox(height: 6),
          ],
          SizedBox(
            height: 180,
            child: TrendChart(
              points: selectedTrend.points,
              windowStart: data.start,
              windowEnd: data.end,
              flarePeriods: data.flarePeriods,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Severity 1–10. Gaps indicate no log that day.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section: Wellbeing trend ──────────────────────────────────────────────────

class _WellbeingSection extends StatelessWidget {
  const _WellbeingSection({required this.data});

  final InsightData data;

  @override
  Widget build(BuildContext context) {
    return _InsightCard(
      title: 'Daily Wellbeing',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.flarePeriods.isNotEmpty) ...[
            const FlareLegendChip(),
            const SizedBox(height: 6),
          ],
          SizedBox(
            height: 180,
            child: TrendChart(
              points: data.wellbeingTrend,
              windowStart: data.start,
              windowEnd: data.end,
              flarePeriods: data.flarePeriods,
              lineColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Wellbeing 1–10 from daily check-ins.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section: Food triggers ────────────────────────────────────────────────────

class _FoodTriggersSection extends StatelessWidget {
  const _FoodTriggersSection({required this.data});

  final InsightData data;

  @override
  Widget build(BuildContext context) {
    return _InsightCard(
      title: 'Food & Reactions',
      child: FoodTriggersCard(triggers: data.foodTriggers),
    );
  }
}

// ── Section: Sleep correlation ────────────────────────────────────────────────

class _SleepSection extends StatelessWidget {
  const _SleepSection({required this.data});

  final InsightData data;

  @override
  Widget build(BuildContext context) {
    return _InsightCard(
      title: 'Sleep & Symptoms',
      child: SleepCorrelationCard(correlation: data.sleepCorrelation),
    );
  }
}

// ── Shared card container ─────────────────────────────────────────────────────

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.windowDays});
  final int windowDays;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights_rounded,
              size: 56,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Not enough data yet',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Log symptoms, meals, sleep, and daily check-ins over the last '
              '$windowDays days to start seeing patterns here.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

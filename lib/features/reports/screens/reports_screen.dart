import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/report_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/reports/models/report_config.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Report configuration and generation screen.
///
/// Lets the user choose a date range, toggle data types, then export
/// as PDF or CSV via the OS share sheet.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _generating = false;
  String? _error;

  static final _dateFmt = DateFormat('d MMM yyyy');

  Future<void> _generate(ReportFormat format) async {
    setState(() {
      _generating = true;
      _error = null;
    });
    final error = await ref.read(reportGeneratorProvider).generate(format);
    if (mounted) {
      setState(() {
        _generating = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(reportConfigProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const HFAppBar(title: Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Insights shortcut ─────────────────────────────────────────
          Card(
            child: ListTile(
              leading: const Icon(Icons.insights_rounded),
              title: const Text('Pattern Insights'),
              subtitle: const Text(
                'Symptom trends, food reactions, sleep correlation',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.insights),
            ),
          ),
          const SizedBox(height: 16),

          // ── Date range ───────────────────────────────────────────────
          Text(
            'Date range',
            style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          SegmentedButton<DateRangePreset>(
            segments: const [
              ButtonSegment(
                value: DateRangePreset.last7days,
                label: Text('Last 7 days'),
              ),
              ButtonSegment(
                value: DateRangePreset.last30days,
                label: Text('Last 30 days'),
              ),
              ButtonSegment(
                value: DateRangePreset.custom,
                label: Text('Custom'),
              ),
            ],
            selected: {config.preset},
            onSelectionChanged: (sel) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(preset: sel.first)),
          ),
          if (config.preset == DateRangePreset.custom) ...[
            const SizedBox(height: 12),
            _DateRangeRow(config: config),
            if (!config.customRangeValid)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'End date must be after start date.',
                  style: tt.bodySmall?.copyWith(color: cs.error),
                ),
              ),
          ],

          const SizedBox(height: 20),

          // ── Data types ───────────────────────────────────────────────
          Text(
            'Include',
            style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          _TypeToggle(
            label: 'Symptoms',
            value: config.includeSymptoms,
            onChanged: (v) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(includeSymptoms: v)),
          ),
          _TypeToggle(
            label: 'Vitals',
            value: config.includeVitals,
            onChanged: (v) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(includeVitals: v)),
          ),
          _TypeToggle(
            label: 'Medications & doses',
            value: config.includeMedications,
            onChanged: (v) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(includeMedications: v)),
          ),
          _TypeToggle(
            label: 'Meals',
            value: config.includeMeals,
            onChanged: (v) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(includeMeals: v)),
          ),
          _TypeToggle(
            label: 'Sleep',
            value: config.includeSleep,
            onChanged: (v) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(includeSleep: v)),
          ),
          _TypeToggle(
            label: 'Daily check-ins',
            value: config.includeCheckins,
            onChanged: (v) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(includeCheckins: v)),
          ),
          _TypeToggle(
            label: 'Appointments',
            value: config.includeAppointments,
            onChanged: (v) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(includeAppointments: v)),
          ),
          _TypeToggle(
            label: 'Activities',
            value: config.includeActivities,
            onChanged: (v) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(includeActivities: v)),
          ),
          _TypeToggle(
            label: 'Journal entries',
            value: config.includeJournal,
            onChanged: (v) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(includeJournal: v)),
          ),
          if (!config.hasDataTypes)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Select at least one data type.',
                style: tt.bodySmall?.copyWith(color: cs.error),
              ),
            ),

          const SizedBox(height: 24),

          // ── Error ────────────────────────────────────────────────────
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: tt.bodySmall?.copyWith(color: cs.error),
              ),
            ),

          // ── Generate summary ─────────────────────────────────────────
          Text(
            '${_dateFmt.format(config.resolvedStart)} – ${_dateFmt.format(config.resolvedEnd)}',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // ── Action buttons ───────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _canGenerate(config)
                      ? () => _generate(ReportFormat.csv)
                      : null,
                  icon: _generating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.table_chart_outlined),
                  label: const Text('Export CSV'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _canGenerate(config)
                      ? () => _generate(ReportFormat.pdf)
                      : null,
                  icon: _generating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Export PDF'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  bool _canGenerate(ReportConfig config) =>
      !_generating && config.hasDataTypes && config.customRangeValid;
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? value),
      title: Text(label),
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class _DateRangeRow extends ConsumerWidget {
  const _DateRangeRow({required this.config});
  final ReportConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _DatePicker(
            label: 'From',
            date: config.customStart,
            onPicked: (d) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(customStart: d)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('→', style: TextStyle(color: cs.onSurfaceVariant)),
        ),
        Expanded(
          child: _DatePicker(
            label: 'To',
            date: config.customEnd,
            onPicked: (d) => ref
                .read(reportConfigProvider.notifier)
                .update(config.copyWith(customEnd: d)),
          ),
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPicked;

  static final _fmt = DateFormat('d MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) onPicked(picked);
      },
      child: Text('$label: ${_fmt.format(date)}'),
    );
  }
}

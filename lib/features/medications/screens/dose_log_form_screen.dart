import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/models/dose_log.dart';
import 'package:health_flare/models/medication.dart';

/// Full-screen form for logging or editing a dose entry.
///
/// Pass [doseLog] to open in edit mode; leave null for a new dose.
/// [medication] is always required — used to pre-fill amount/unit.
class DoseLogFormScreen extends ConsumerStatefulWidget {
  const DoseLogFormScreen({super.key, required this.medication, this.doseLog});

  final Medication medication;
  final DoseLog? doseLog;

  @override
  ConsumerState<DoseLogFormScreen> createState() => _DoseLogFormScreenState();
}

class _DoseLogFormScreenState extends ConsumerState<DoseLogFormScreen> {
  late TextEditingController _amountController;
  late TextEditingController _reasonController;
  late TextEditingController _notesController;

  late String _status; // "taken" | "skipped" | "missed"
  String? _effectiveness;
  late DateTime _loggedAt;
  bool _submitting = false;

  static const _statuses = [
    ('taken', 'Taken'),
    ('skipped', 'Skipped'),
    ('missed', 'Missed'),
  ];

  static const _effectivenessOptions = [
    ('helped_a_lot', 'Helped a lot'),
    ('helped_a_little', 'Helped a little'),
    ('no_effect', 'No effect'),
    ('made_it_worse', 'Made it worse'),
  ];

  @override
  void initState() {
    super.initState();
    final log = widget.doseLog;
    final med = widget.medication;

    if (log != null) {
      _amountController = TextEditingController(
        text: log.amount == log.amount.truncateToDouble()
            ? log.amount.toStringAsFixed(0)
            : log.amount.toString(),
      );
      _reasonController = TextEditingController(text: log.reason ?? '');
      _notesController = TextEditingController(text: log.notes ?? '');
      _status = log.status;
      _effectiveness = log.effectiveness;
      _loggedAt = log.loggedAt;
    } else {
      _amountController = TextEditingController(
        text: med.doseAmount == med.doseAmount.truncateToDouble()
            ? med.doseAmount.toStringAsFixed(0)
            : med.doseAmount.toString(),
      );
      _reasonController = TextEditingController();
      _notesController = TextEditingController();
      _status = 'taken';
      _effectiveness = null;
      _loggedAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickLoggedAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _loggedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_loggedAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _loggedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final amount =
        double.tryParse(_amountController.text.trim()) ??
        widget.medication.doseAmount;
    final reason = _reasonController.text.trim().isEmpty
        ? null
        : _reasonController.text.trim();
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    if (widget.doseLog == null) {
      final profileId = ref.read(activeProfileProvider)!;
      await ref
          .read(doseLogListProvider.notifier)
          .add(
            profileId: profileId,
            medicationIsarId: widget.medication.id,
            loggedAt: _loggedAt,
            amount: amount,
            unit: widget.medication.doseUnit,
            status: _status,
            reason: reason,
            effectiveness: _effectiveness,
            notes: notes,
          );
    } else {
      await ref
          .read(doseLogListProvider.notifier)
          .update(
            widget.doseLog!.copyWith(
              loggedAt: _loggedAt,
              amount: amount,
              status: _status,
              reason: reason,
              clearReason: reason == null,
              effectiveness: _effectiveness,
              clearEffectiveness: _effectiveness == null,
              notes: notes,
              clearNotes: notes == null,
            ),
          );
    }

    if (mounted) context.pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete dose entry?'),
        content: const Text('This dose log entry will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(doseLogListProvider.notifier).remove(widget.doseLog!.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('EEE d MMM yyyy, HH:mm');
    final activeProfile = ref.watch(activeProfileDataProvider);
    final isEdit = widget.doseLog != null;
    final showReasonField = _status == 'skipped' || _status == 'missed';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit dose' : 'Log dose — ${widget.medication.name}',
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete dose entry',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Logging for [name] ────────────────────────────────────────
            if (activeProfile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Logging for ${activeProfile.name}',
                  style: tt.labelLarge?.copyWith(color: cs.primary),
                ),
              ),

            // ── Status ────────────────────────────────────────────────────
            const _SectionLabel(label: 'Status'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              key: const Key('dose_status_toggle'),
              segments: _statuses
                  .map((s) => ButtonSegment(value: s.$1, label: Text(s.$2)))
                  .toList(),
              selected: {_status},
              onSelectionChanged: (s) => setState(() => _status = s.first),
            ),

            const SizedBox(height: 24),

            // ── Amount ────────────────────────────────────────────────────
            _SectionLabel(label: 'Amount (${widget.medication.doseUnit})'),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('dose_amount_field'),
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                suffix: Text(widget.medication.doseUnit),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Date / time ───────────────────────────────────────────────
            const _SectionLabel(label: 'Date and time'),
            const SizedBox(height: 8),
            _DateTimeField(value: fmt.format(_loggedAt), onTap: _pickLoggedAt),

            const SizedBox(height: 24),

            // ── Effectiveness (optional) ──────────────────────────────────
            const _SectionLabel(label: 'Effectiveness (optional)'),
            const SizedBox(height: 8),
            RadioGroup<String?>(
              groupValue: _effectiveness,
              onChanged: (v) => setState(() => _effectiveness = v),
              child: Column(
                children: [
                  ..._effectivenessOptions.map(
                    (opt) => RadioListTile<String?>(
                      key: Key('effectiveness_${opt.$1}'),
                      title: Text(opt.$2),
                      value: opt.$1,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  RadioListTile<String?>(
                    key: const Key('effectiveness_none'),
                    title: Text(
                      'Not rated',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    value: null,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // ── Reason (optional, shown when skipped/missed) ──────────────
            if (showReasonField) ...[
              const SizedBox(height: 8),
              const _SectionLabel(label: 'Reason (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('dose_reason_field'),
                controller: _reasonController,
                decoration: InputDecoration(
                  hintText: 'e.g. Forgot while travelling',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Notes (optional) ──────────────────────────────────────────
            const _SectionLabel(label: 'Notes (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('dose_notes_field'),
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Took with breakfast',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: !_submitting ? _save : null,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isEdit ? 'Save changes' : 'Log dose'),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small helper widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({required this.value, required this.onTap});
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

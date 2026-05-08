import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/models/vital_entry.dart';
import 'package:health_flare/models/vital_type.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Full-screen form for creating or editing a vital measurement entry.
///
/// Pass [entry] to open in edit mode; leave null for a new entry.
class VitalEntryFormScreen extends ConsumerStatefulWidget {
  const VitalEntryFormScreen({super.key, this.entry});

  final VitalEntry? entry;

  @override
  ConsumerState<VitalEntryFormScreen> createState() =>
      _VitalEntryFormScreenState();
}

class _VitalEntryFormScreenState extends ConsumerState<VitalEntryFormScreen> {
  late VitalType _vitalType;
  late TextEditingController _valueController;
  late TextEditingController _value2Controller;
  late String _unit;
  late TextEditingController _notesController;
  late DateTime _loggedAt;
  bool _submitting = false;
  bool _valueError = false;
  bool _value2Error = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      final e = widget.entry!;
      _vitalType = e.vitalType;
      _valueController = TextEditingController(
        text: e.value == e.value.truncateToDouble()
            ? e.value.toStringAsFixed(0)
            : e.value.toString(),
      );
      _value2Controller = TextEditingController(
        text: e.value2 != null
            ? (e.value2! == e.value2!.truncateToDouble()
                  ? e.value2!.toStringAsFixed(0)
                  : e.value2.toString())
            : '',
      );
      _unit = e.unit;
      _notesController = TextEditingController(text: e.notes ?? '');
      _loggedAt = e.loggedAt;
    } else {
      _vitalType = VitalType.heartRate;
      _valueController = TextEditingController();
      _value2Controller = TextEditingController();
      _unit = VitalType.heartRate.defaultUnit;
      _notesController = TextEditingController();
      _loggedAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    _value2Controller.dispose();
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
    final valueText = _valueController.text.trim();
    final value2Text = _value2Controller.text.trim();
    final needsSecondary = _vitalType.hasSecondaryValue;

    setState(() {
      _valueError = valueText.isEmpty || double.tryParse(valueText) == null;
      _value2Error =
          needsSecondary &&
          (value2Text.isEmpty || double.tryParse(value2Text) == null);
    });
    if (_valueError || _value2Error || _submitting) return;
    setState(() => _submitting = true);

    final value = double.parse(valueText);
    final value2 = needsSecondary ? double.parse(value2Text) : null;
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    if (widget.entry == null) {
      final profileId = ref.read(activeProfileProvider)!;
      await ref
          .read(vitalEntryListProvider.notifier)
          .add(
            profileId: profileId,
            vitalType: _vitalType,
            value: value,
            value2: value2,
            unit: _unit,
            loggedAt: _loggedAt,
            notes: notes,
          );
    } else {
      await ref
          .read(vitalEntryListProvider.notifier)
          .update(
            widget.entry!.copyWith(
              vitalType: _vitalType,
              value: value,
              value2: value2,
              clearValue2: value2 == null,
              unit: _unit,
              loggedAt: _loggedAt,
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
        title: const Text('Delete entry?'),
        content: const Text('This vital entry will be permanently removed.'),
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
      await ref.read(vitalEntryListProvider.notifier).remove(widget.entry!.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('EEE d MMM yyyy, HH:mm');
    final activeProfile = ref.watch(activeProfileDataProvider);
    final isEdit = widget.entry != null;

    return Scaffold(
      appBar: HFAppBar(
        title: Text(isEdit ? 'Edit vital' : 'Log vital'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete entry',
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

            // ── Vital type ────────────────────────────────────────────────
            const _SectionLabel(label: 'Vital type'),
            const SizedBox(height: 8),
            DropdownButtonFormField<VitalType>(
              key: const Key('vital_type_dropdown'),
              initialValue: _vitalType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: VitalType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (t) {
                if (t == null) return;
                setState(() {
                  _vitalType = t;
                  _unit = t.defaultUnit;
                  if (!t.hasSecondaryValue) {
                    _value2Controller.clear();
                    _value2Error = false;
                  }
                });
              },
            ),

            const SizedBox(height: 24),

            // ── Value(s) ──────────────────────────────────────────────────
            if (_vitalType.hasSecondaryValue) ...[
              const _SectionLabel(label: 'Systolic (mmHg)'),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('vital_value_field'),
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '120',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _valueError ? 'Enter a valid number' : null,
                ),
                onChanged: (_) {
                  if (_valueError) setState(() => _valueError = false);
                },
              ),
              const SizedBox(height: 16),
              const _SectionLabel(label: 'Diastolic (mmHg)'),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('vital_value2_field'),
                controller: _value2Controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '80',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _value2Error ? 'Enter a valid number' : null,
                ),
                onChanged: (_) {
                  if (_value2Error) setState(() => _value2Error = false);
                },
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel(label: 'Value'),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: const Key('vital_value_field'),
                          controller: _valueController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: '72',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorText: _valueError
                                ? 'Enter a valid number'
                                : null,
                          ),
                          onChanged: (_) {
                            if (_valueError) {
                              setState(() => _valueError = false);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel(label: 'Unit'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          key: const Key('vital_unit_dropdown'),
                          initialValue: _unit,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _vitalType.availableUnits
                              .map(
                                (u) =>
                                    DropdownMenuItem(value: u, child: Text(u)),
                              )
                              .toList(),
                          onChanged: (u) {
                            if (u == null) return;
                            setState(() => _unit = u);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // ── Date / time ───────────────────────────────────────────────
            const _SectionLabel(label: 'Date and time'),
            const SizedBox(height: 8),
            _DateTimeField(value: fmt.format(_loggedAt), onTap: _pickLoggedAt),

            const SizedBox(height: 24),

            // ── Notes ─────────────────────────────────────────────────────
            const _SectionLabel(label: 'Notes (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('vital_notes_field'),
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Taken after exercise',
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
                : Text(isEdit ? 'Save changes' : 'Add to profile'),
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

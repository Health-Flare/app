import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Full-screen form for adding or editing a medication/supplement.
///
/// Pass [medication] to open in edit mode; leave null for a new entry.
class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({super.key, this.medication});

  final Medication? medication;

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _doseAmountController;
  late TextEditingController _doseUnitController;
  late TextEditingController _frequencyLabelController;
  late TextEditingController _notesController;

  late String _medicationType; // "medication" | "supplement"
  late String _frequency;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _submitting = false;
  bool _nameError = false;
  bool _doseAmountError = false;
  bool _startDateError = false;

  static const _frequencies = [
    ('once_daily', 'Once daily'),
    ('twice_daily', 'Twice daily'),
    ('three_times_daily', 'Three times daily'),
    ('as_needed', 'As needed'),
    ('weekly', 'Weekly'),
    ('custom', 'Custom'),
  ];

  static const _commonUnits = ['mg', 'mL', 'IU', 'mcg', 'g', 'tablets', '%'];

  @override
  void initState() {
    super.initState();
    final m = widget.medication;
    if (m != null) {
      _nameController = TextEditingController(text: m.name);
      _doseAmountController = TextEditingController(
        text: m.doseAmount == m.doseAmount.truncateToDouble()
            ? m.doseAmount.toStringAsFixed(0)
            : m.doseAmount.toString(),
      );
      _doseUnitController = TextEditingController(text: m.doseUnit);
      _frequencyLabelController = TextEditingController(
        text: m.frequencyLabel ?? '',
      );
      _notesController = TextEditingController(text: m.notes ?? '');
      _medicationType = m.medicationType;
      _frequency = m.frequency;
      _startDate = m.startDate;
      _endDate = m.endDate;
    } else {
      _nameController = TextEditingController();
      _doseAmountController = TextEditingController();
      _doseUnitController = TextEditingController(text: 'mg');
      _frequencyLabelController = TextEditingController();
      _notesController = TextEditingController();
      _medicationType = 'medication';
      _frequency = 'once_daily';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseAmountController.dispose();
    _doseUnitController.dispose();
    _frequencyLabelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (date == null || !mounted) return;
    setState(() {
      _startDate = date;
      _startDateError = false;
    });
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (!mounted) return;
    setState(() => _endDate = date);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amountText = _doseAmountController.text.trim();
    final amount = double.tryParse(amountText);

    setState(() {
      _nameError = name.isEmpty;
      _doseAmountError = amount == null || amount <= 0;
      _startDateError = _startDate == null;
    });

    if (_nameError || _doseAmountError || _startDateError || _submitting) {
      return;
    }

    setState(() => _submitting = true);

    final unit = _doseUnitController.text.trim().isEmpty
        ? 'mg'
        : _doseUnitController.text.trim();
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
    final freqLabel =
        _frequency == 'custom' &&
            _frequencyLabelController.text.trim().isNotEmpty
        ? _frequencyLabelController.text.trim()
        : null;

    if (widget.medication == null) {
      final profileId = ref.read(activeProfileProvider)!;
      await ref
          .read(medicationListProvider.notifier)
          .add(
            profileId: profileId,
            name: name,
            medicationType: _medicationType,
            doseAmount: amount!,
            doseUnit: unit,
            frequency: _frequency,
            frequencyLabel: freqLabel,
            startDate: _startDate!,
            endDate: _endDate,
            notes: notes,
          );
    } else {
      await ref
          .read(medicationListProvider.notifier)
          .update(
            widget.medication!.copyWith(
              name: name,
              medicationType: _medicationType,
              doseAmount: amount!,
              doseUnit: unit,
              frequency: _frequency,
              frequencyLabel: freqLabel,
              clearFrequencyLabel: freqLabel == null,
              startDate: _startDate,
              endDate: _endDate,
              clearEndDate: _endDate == null,
              notes: notes,
              clearNotes: notes == null,
              updatedAt: DateTime.now(),
            ),
          );
    }

    if (mounted) context.pop();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete medication?'),
        content: const Text(
          'This medication and all its dose history will be permanently removed.',
        ),
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
      await ref
          .read(medicationListProvider.notifier)
          .remove(widget.medication!.id);
      if (mounted) {
        // Pop twice: once for detail, once for form
        context.go(AppRoutes.medications);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dateFmt = DateFormat('d MMM yyyy');
    final activeProfile = ref.watch(activeProfileDataProvider);
    final isEdit = widget.medication != null;

    return Scaffold(
      appBar: HFAppBar(
        title: Text(isEdit ? 'Edit medication' : 'Add medication'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete medication',
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

            // ── Type toggle ───────────────────────────────────────────────
            const _SectionLabel(label: 'Type'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              key: const Key('medication_type_toggle'),
              segments: const [
                ButtonSegment(value: 'medication', label: Text('Medication')),
                ButtonSegment(value: 'supplement', label: Text('Supplement')),
              ],
              selected: {_medicationType},
              onSelectionChanged: (s) =>
                  setState(() => _medicationType = s.first),
            ),

            const SizedBox(height: 24),

            // ── Name ──────────────────────────────────────────────────────
            _SectionLabel(
              label: _medicationType == 'supplement'
                  ? 'Supplement name'
                  : 'Medication name',
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('medication_name_field'),
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: _medicationType == 'supplement'
                    ? 'e.g. Vitamin D3, Magnesium'
                    : 'e.g. Metformin, Ibuprofen',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _nameError ? 'Name is required' : null,
              ),
              onChanged: (_) {
                if (_nameError) setState(() => _nameError = false);
              },
            ),

            const SizedBox(height: 24),

            // ── Dose ──────────────────────────────────────────────────────
            const _SectionLabel(label: 'Dose'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    key: const Key('dose_amount_field'),
                    controller: _doseAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: _doseAmountError ? 'Enter a valid dose' : null,
                    ),
                    onChanged: (_) {
                      if (_doseAmountError) {
                        setState(() => _doseAmountError = false);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _UnitDropdown(
                    value: _doseUnitController.text,
                    units: _commonUnits,
                    onChanged: (v) =>
                        setState(() => _doseUnitController.text = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Frequency ─────────────────────────────────────────────────
            const _SectionLabel(label: 'Frequency'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: const Key('frequency_dropdown'),
              initialValue: _frequency,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _frequencies
                  .map((f) => DropdownMenuItem(value: f.$1, child: Text(f.$2)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _frequency = v);
              },
            ),

            if (_frequency == 'custom') ...[
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('frequency_label_field'),
                controller: _frequencyLabelController,
                decoration: InputDecoration(
                  hintText: 'Describe frequency, e.g. Every other day',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Start date ────────────────────────────────────────────────
            const _SectionLabel(label: 'Start date'),
            const SizedBox(height: 8),
            _DateField(
              value: _startDate != null ? dateFmt.format(_startDate!) : null,
              placeholder: 'Select start date',
              errorText: _startDateError ? 'Start date is required' : null,
              onTap: _pickStartDate,
            ),

            const SizedBox(height: 24),

            // ── End date (optional) ───────────────────────────────────────
            const _SectionLabel(label: 'End date (optional)'),
            const SizedBox(height: 4),
            Text(
              'Set to mark as discontinued',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    value: _endDate != null ? dateFmt.format(_endDate!) : null,
                    placeholder: 'None (still active)',
                    onTap: _pickEndDate,
                  ),
                ),
                if (_endDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear end date',
                    onPressed: () => setState(() => _endDate = null),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Notes (optional) ──────────────────────────────────────────
            const _SectionLabel(label: 'Notes (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('medication_notes_field'),
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Take in the morning with food',
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
// Unit dropdown
// ---------------------------------------------------------------------------

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({
    required this.value,
    required this.units,
    required this.onChanged,
  });

  final String value;
  final List<String> units;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final effectiveValue = units.contains(value) ? value : units.first;
    return DropdownButtonFormField<String>(
      key: const Key('dose_unit_dropdown'),
      initialValue: effectiveValue,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: units
          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.errorText,
  });

  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null ? cs.error : cs.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  value ?? placeholder,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: value != null ? null : cs.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ),
      ],
    );
  }
}

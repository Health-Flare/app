import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/models/flare.dart';

/// Screen to start a new flare or edit an existing (active) one.
///
/// Pass [flare] to open in edit mode; leave null to start a new flare.
class FlareFormScreen extends ConsumerStatefulWidget {
  const FlareFormScreen({super.key, this.flare});

  final Flare? flare;

  @override
  ConsumerState<FlareFormScreen> createState() => _FlareFormScreenState();
}

class _FlareFormScreenState extends ConsumerState<FlareFormScreen> {
  late TextEditingController _notesController;
  late DateTime _startedAt;
  late List<int> _conditionIsarIds;
  int? _initialSeverity;
  bool _submitting = false;

  bool get _isEdit => widget.flare != null;

  @override
  void initState() {
    super.initState();
    final f = widget.flare;
    if (f != null) {
      _notesController = TextEditingController(text: f.notes ?? '');
      _startedAt = f.startedAt;
      _conditionIsarIds = List.of(f.conditionIsarIds);
      _initialSeverity = f.initialSeverity;
    } else {
      _notesController = TextEditingController();
      _startedAt = DateTime.now();
      _conditionIsarIds = [];
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartedAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startedAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _startedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    setState(() => _submitting = true);
    final notifier = ref.read(flareListProvider.notifier);
    final notes = _notesController.text.trim();

    try {
      if (_isEdit) {
        await notifier.update(
          widget.flare!.copyWith(
            startedAt: _startedAt,
            conditionIsarIds: _conditionIsarIds,
            initialSeverity: _initialSeverity,
            notes: notes.isEmpty ? null : notes,
            updatedAt: DateTime.now(),
            clearNotes: notes.isEmpty,
            clearInitialSeverity: _initialSeverity == null,
          ),
        );
      } else {
        final profileId = ref.read(activeProfileProvider);
        if (profileId == null) {
          setState(() => _submitting = false);
          return;
        }
        await notifier.add(
          profileId: profileId,
          startedAt: _startedAt,
          conditionIsarIds: _conditionIsarIds,
          initialSeverity: _initialSeverity,
          notes: notes.isEmpty ? null : notes,
        );
      }
      if (!mounted) return;
      context.pop();
    } on StateError catch (e) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final conditions = ref.watch(userConditionListProvider);
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit flare' : 'Start flare')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Attribution
            if (activeProfile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Logging for ${activeProfile.name}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),

            // Start date/time
            InkWell(
              onTap: _pickStartedAt,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Started at',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(fmt.format(_startedAt)),
              ),
            ),
            const SizedBox(height: 16),

            // Initial severity
            _SeverityPicker(
              label: 'Initial severity',
              value: _initialSeverity,
              onChanged: (v) => setState(() => _initialSeverity = v),
            ),
            const SizedBox(height: 16),

            // Condition attribution
            if (conditions.isNotEmpty) ...[
              Text(
                'Attribute to condition (optional)',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: conditions.map((c) {
                  final selected = _conditionIsarIds.contains(c.id);
                  return FilterChip(
                    label: Text(c.conditionName),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _conditionIsarIds.add(c.id);
                        } else {
                          _conditionIsarIds.remove(c.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'What triggered this flare?',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _submitting ? null : _save,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEdit ? 'Save changes' : 'Start flare'),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Severity picker (1–10 chip grid)
// ---------------------------------------------------------------------------

class _SeverityPicker extends StatelessWidget {
  const _SeverityPicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label (optional)',
          style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: List.generate(10, (i) {
            final v = i + 1;
            final selected = value == v;
            return ChoiceChip(
              label: Text('$v'),
              selected: selected,
              onSelected: (_) => onChanged(selected ? null : v),
            );
          }),
        ),
      ],
    );
  }
}

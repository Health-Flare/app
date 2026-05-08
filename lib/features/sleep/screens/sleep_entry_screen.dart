import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/features/sleep/widgets/sleep_quality_selector.dart';
import 'package:health_flare/models/sleep_entry.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Full-screen form for creating or editing a sleep entry.
///
/// Pass [entry] to open in edit mode; leave null for a new entry.
/// Defaults: bedtime = yesterday 23:00, wake = today 07:00.
class SleepEntryScreen extends ConsumerStatefulWidget {
  const SleepEntryScreen({super.key, this.entry});

  final SleepEntry? entry;

  @override
  ConsumerState<SleepEntryScreen> createState() => _SleepEntryScreenState();
}

class _SleepEntryScreenState extends ConsumerState<SleepEntryScreen> {
  late DateTime _bedtime;
  late DateTime _wakeTime;
  int? _qualityRating;
  late TextEditingController _notesController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      final e = widget.entry!;
      _bedtime = e.bedtime;
      _wakeTime = e.wakeTime;
      _qualityRating = e.qualityRating;
      _notesController = TextEditingController(text: e.notes ?? '');
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      _bedtime = yesterday.add(const Duration(hours: 23));
      _wakeTime = today.add(const Duration(hours: 7));
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ── Derived ───────────────────────────────────────────────────────────────

  bool get _timingValid => _wakeTime.isAfter(_bedtime);

  Duration get _duration => _wakeTime.difference(_bedtime);

  String get _formattedDuration {
    final h = _duration.inHours;
    final m = _duration.inMinutes.remainder(60);
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  // ── Pickers ───────────────────────────────────────────────────────────────

  Future<void> _pickBedtime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _bedtime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_bedtime),
    );
    if (time == null || !mounted) return;
    setState(() {
      _bedtime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickWakeTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _wakeTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(hours: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_wakeTime),
    );
    if (time == null || !mounted) return;
    setState(() {
      _wakeTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_timingValid || _submitting) return;
    setState(() => _submitting = true);

    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    if (widget.entry == null) {
      final profileId = ref.read(activeProfileProvider)!;
      await ref
          .read(sleepEntryListProvider.notifier)
          .add(
            profileId: profileId,
            bedtime: _bedtime,
            wakeTime: _wakeTime,
            qualityRating: _qualityRating,
            notes: notes,
          );
    } else {
      await ref
          .read(sleepEntryListProvider.notifier)
          .update(
            widget.entry!.copyWith(
              bedtime: _bedtime,
              wakeTime: _wakeTime,
              qualityRating: _qualityRating,
              clearQuality: _qualityRating == null,
              notes: notes,
              clearNotes: notes == null,
            ),
          );
    }

    if (mounted) context.pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('EEE d MMM, HH:mm');

    return Scaffold(
      appBar: HFAppBar(
        title: Text(widget.entry == null ? 'Log sleep' : 'Edit sleep'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Bedtime ──────────────────────────────────────────────────
            const _SectionLabel(label: 'Bedtime'),
            _TimeField(value: fmt.format(_bedtime), onTap: _pickBedtime),

            const SizedBox(height: 16),

            // ── Wake time ────────────────────────────────────────────────
            const _SectionLabel(label: 'Wake time'),
            _TimeField(value: fmt.format(_wakeTime), onTap: _pickWakeTime),

            const SizedBox(height: 12),

            // ── Duration / validation ────────────────────────────────────
            if (_timingValid)
              Center(
                child: Text(
                  _formattedDuration,
                  style: tt.headlineSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text(
                'Wake time must be after bedtime',
                style: tt.bodySmall?.copyWith(color: cs.error),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 24),

            // ── Quality ──────────────────────────────────────────────────
            const _SectionLabel(label: 'Sleep quality (optional)'),
            const SizedBox(height: 8),
            SleepQualitySelector(
              value: _qualityRating,
              onChanged: (v) => setState(() => _qualityRating = v),
            ),

            const SizedBox(height: 24),

            // ── Notes ────────────────────────────────────────────────────
            const _SectionLabel(label: 'Notes (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('sleep_notes_field'),
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Woke up twice, hot and restless',
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
            onPressed: _timingValid && !_submitting ? _save : null,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save entry'),
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

class _TimeField extends StatelessWidget {
  const _TimeField({required this.value, required this.onTap});
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

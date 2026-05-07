import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/weather_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/activity_entry.dart';
import 'package:health_flare/models/weather_snapshot.dart';

/// Full-screen form for creating or editing an activity entry.
///
/// Pass [entry] to open in edit mode; leave null for a new entry.
/// Pass [prefillText] to pre-populate the description (quick-log promotion).
class ActivityEntryFormScreen extends ConsumerStatefulWidget {
  const ActivityEntryFormScreen({super.key, this.entry, this.prefillText});

  final ActivityEntry? entry;
  final String? prefillText;

  @override
  ConsumerState<ActivityEntryFormScreen> createState() =>
      _ActivityEntryFormScreenState();
}

class _ActivityEntryFormScreenState
    extends ConsumerState<ActivityEntryFormScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _notesController;
  late DateTime _loggedAt;
  ActivityType? _activityType;
  int? _effortLevel;
  bool _submitting = false;
  bool _descriptionError = false;

  // Captured once when the form opens (new entry only).
  WeatherSnapshot? _capturedWeather;

  bool get _isEdit => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    if (e != null) {
      _descriptionController = TextEditingController(text: e.description);
      _durationController = TextEditingController(
        text: e.durationMinutes != null ? '${e.durationMinutes}' : '',
      );
      _notesController = TextEditingController(text: e.notes ?? '');
      _loggedAt = e.loggedAt;
      _activityType = e.activityType;
      _effortLevel = e.effortLevel;
    } else {
      _descriptionController = TextEditingController(
        text: widget.prefillText ?? '',
      );
      _durationController = TextEditingController();
      _notesController = TextEditingController();
      _loggedAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _durationController.dispose();
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
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      setState(() => _descriptionError = true);
      return;
    }

    setState(() => _submitting = true);

    final notifier = ref.read(activityEntryListProvider.notifier);
    final notes = _notesController.text.trim();
    final durationText = _durationController.text.trim();
    final durationMinutes = durationText.isNotEmpty
        ? int.tryParse(durationText)
        : null;

    if (_isEdit) {
      await notifier.update(
        widget.entry!.copyWith(
          description: description,
          activityType: _activityType,
          effortLevel: _effortLevel,
          durationMinutes: durationMinutes,
          loggedAt: _loggedAt,
          updatedAt: DateTime.now(),
          notes: notes.isEmpty ? null : notes,
          clearActivityType: _activityType == null,
          clearEffortLevel: _effortLevel == null,
          clearDurationMinutes: durationMinutes == null,
          clearNotes: notes.isEmpty,
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
        description: description,
        activityType: _activityType,
        effortLevel: _effortLevel,
        durationMinutes: durationMinutes,
        loggedAt: _loggedAt,
        notes: notes.isEmpty ? null : notes,
        weatherSnapshot: _capturedWeather,
      );
    }

    if (!mounted) return;
    context.pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete activity entry?'),
        content: const Text(
          'This will permanently remove this activity entry.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(activityEntryListProvider.notifier).delete(widget.entry!.id);
    if (!mounted) return;
    context.go(AppRoutes.activity);
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM yyyy, HH:mm');

    // Watch weather for new entries — capture when available.
    final weatherAsync = _isEdit ? null : ref.watch(currentWeatherProvider);
    weatherAsync?.whenData((w) {
      if (w != null && _capturedWeather == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _capturedWeather = w);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit activity' : 'Log activity'),
        actions: [
          if (_isEdit)
            IconButton(
              onPressed: _submitting ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete entry',
            ),
        ],
      ),
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

            // Weather chip (new entries only)
            if (!_isEdit && _capturedWeather != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WeatherChip(snapshot: _capturedWeather!),
              ),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'What did you do?',
                errorText: _descriptionError ? 'Description is required' : null,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              onChanged: (_) {
                if (_descriptionError) {
                  setState(() => _descriptionError = false);
                }
              },
            ),
            const SizedBox(height: 16),

            // Date & time
            InkWell(
              onTap: _pickLoggedAt,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date & time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(fmt.format(_loggedAt)),
              ),
            ),
            const SizedBox(height: 16),

            // Activity type
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Activity type (optional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              child: DropdownButton<ActivityType?>(
                value: _activityType,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Not specified'),
                  ),
                  ...ActivityType.values.map(
                    (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                  ),
                ],
                onChanged: (v) => setState(() => _activityType = v),
              ),
            ),
            const SizedBox(height: 16),

            // Effort level
            _EffortSelector(
              value: _effortLevel,
              onChanged: (v) => setState(() => _effortLevel = v),
            ),
            const SizedBox(height: 16),

            // Duration
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (optional)',
                hintText: 'Minutes',
                border: OutlineInputBorder(),
                suffixText: 'min',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'How did it go? Any observations',
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
                : Text(_isEdit ? 'Save changes' : 'Log activity'),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weather chip
// ---------------------------------------------------------------------------

class _WeatherChip extends StatelessWidget {
  const _WeatherChip({required this.snapshot});

  final WeatherSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(snapshot.icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          snapshot.displayString,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Effort selector
// ---------------------------------------------------------------------------

class _EffortSelector extends StatelessWidget {
  const _EffortSelector({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Effort level (optional)', style: tt.bodySmall),
        const SizedBox(height: 4),
        Text(
          'How hard did this feel for you personally?',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 1; i <= 5; i++) ...[
              if (i > 1) const SizedBox(width: 8),
              Expanded(
                child: _EffortChip(
                  level: i,
                  selected: value == i,
                  onTap: () => onChanged(value == i ? null : i),
                ),
              ),
            ],
          ],
        ),
        if (value != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${effortLabels[value]} for ${_profileLabel(value!)}',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
      ],
    );
  }

  String _profileLabel(int level) => switch (level) {
    1 => 'this profile',
    2 => 'this profile',
    3 => 'this profile',
    4 => 'this profile',
    5 => 'this profile',
    _ => 'this profile',
  };
}

class _EffortChip extends StatelessWidget {
  const _EffortChip({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final int level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? cs.primary : cs.outline,
            width: selected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$level',
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? cs.onPrimaryContainer : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

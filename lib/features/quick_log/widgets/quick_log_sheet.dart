import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/quick_log/quick_log_classifier.dart';
import 'package:health_flare/models/journal_entry.dart';

/// Opens the quick-log bottom sheet. Call from any screen that has a FAB.
Future<void> showQuickLogSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _QuickLogSheet(),
  );
}

class _QuickLogSheet extends ConsumerStatefulWidget {
  const _QuickLogSheet();

  @override
  ConsumerState<_QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends ConsumerState<_QuickLogSheet> {
  final _textController = TextEditingController();
  late DateTime _timestamp;
  QuickLogEntryType? _classification;
  bool _saving = false;

  static final _fmt = DateFormat('EEE, d MMM · HH:mm');

  @override
  void initState() {
    super.initState();
    _timestamp = DateTime.now();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final next = QuickLogClassifier.classify(_textController.text);
    if (next != _classification) {
      setState(() => _classification = next);
    }
  }

  String get _text => _textController.text.trim();
  bool get _hasText => _text.isNotEmpty;
  bool get _canSave => _hasText && !_saving;

  // ── Save ────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      final profileId = ref.read(activeProfileProvider);
      if (profileId == null) return;
      await _quickSave(profileId);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _quickSave(int profileId) async {
    switch (_classification) {
      case QuickLogEntryType.meal:
        await ref
            .read(mealEntryListProvider.notifier)
            .add(
              profileId: profileId,
              description: _text,
              hasReaction: false,
              loggedAt: _timestamp,
            );
      case QuickLogEntryType.symptom:
        await ref
            .read(symptomEntryListProvider.notifier)
            .add(
              profileId: profileId,
              name: _text,
              severity: 5,
              loggedAt: _timestamp,
            );
      case QuickLogEntryType.doctorVisit:
        await ref
            .read(appointmentListProvider.notifier)
            .add(profileId: profileId, title: _text, scheduledAt: _timestamp);
      case QuickLogEntryType.activity:
        await ref
            .read(activityEntryListProvider.notifier)
            .add(
              profileId: profileId,
              description: _text,
              loggedAt: _timestamp,
            );
      case QuickLogEntryType.vital:
      case QuickLogEntryType.medication:
      case QuickLogEntryType.journal:
      case null:
        final now = DateTime.now();
        await ref
            .read(journalEntryListProvider.notifier)
            .add(
              profileId: profileId,
              createdAt: _timestamp,
              firstSnapshot: JournalSnapshot(body: _text, savedAt: now),
            );
    }
  }

  // ── Add details ─────────────────────────────────────────────────────────

  void _addDetails() {
    Navigator.of(context).pop();
    switch (_classification) {
      case QuickLogEntryType.meal:
        context.push(AppRoutes.mealsNew, extra: _text);
      case QuickLogEntryType.symptom:
        context.push(AppRoutes.symptomsNew, extra: _text);
      case QuickLogEntryType.doctorVisit:
        context.push(AppRoutes.appointmentNew, extra: {'title': _text});
      case QuickLogEntryType.activity:
        context.push(AppRoutes.activityNew, extra: _text);
      case QuickLogEntryType.vital:
      case QuickLogEntryType.medication:
      case QuickLogEntryType.journal:
      case null:
        context.push(AppRoutes.journalNew, extra: _text);
    }
  }

  // ── Timestamp picker ────────────────────────────────────────────────────

  Future<void> _pickTimestamp() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (!mounted) return;
    setState(() {
      _timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _timestamp.hour,
        time?.minute ?? _timestamp.minute,
      );
    });
  }

  // ── Dismiss guard ───────────────────────────────────────────────────────

  Future<void> _handlePop() async {
    if (!_hasText) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave without saving?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard entry'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final profile = ref.watch(activeProfileDataProvider);
    final profileName = profile?.name ?? '';
    final kbHeight = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_hasText,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handlePop();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: kbHeight),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  children: [
                    Text(
                      'Logging for $profileName',
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _handlePop,
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              // ── Text field ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _textController,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'What would you like to log?',
                    border: InputBorder.none,
                  ),
                  style: tt.bodyLarge,
                ),
              ),

              const Divider(height: 1),

              // ── Timestamp row ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onTap: _pickTimestamp,
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _fmt.format(_timestamp),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Type chip + Add details ───────────────────────────────
              if (_classification != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Chip(
                        label: Text(_chipLabel(_classification!)),
                        avatar: Icon(
                          _chipIcon(_classification!),
                          size: 16,
                          color: cs.primary,
                        ),
                        backgroundColor: cs.primaryContainer,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _addDetails,
                        child: const Text('Add details'),
                      ),
                    ],
                  ),
                ),

              // ── Save button ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: FilledButton(
                  onPressed: _canSave ? _save : null,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _chipLabel(QuickLogEntryType type) => switch (type) {
  QuickLogEntryType.meal => 'Meal',
  QuickLogEntryType.symptom => 'Symptom',
  QuickLogEntryType.vital => 'Vital',
  QuickLogEntryType.medication => 'Medication',
  QuickLogEntryType.doctorVisit => 'Doctor Visit',
  QuickLogEntryType.activity => 'Activity',
  QuickLogEntryType.journal => 'Journal',
};

IconData _chipIcon(QuickLogEntryType type) => switch (type) {
  QuickLogEntryType.meal => Icons.restaurant_outlined,
  QuickLogEntryType.symptom => Icons.healing_outlined,
  QuickLogEntryType.vital => Icons.monitor_heart_outlined,
  QuickLogEntryType.medication => Icons.medication_outlined,
  QuickLogEntryType.doctorVisit => Icons.local_hospital_outlined,
  QuickLogEntryType.activity => Icons.directions_walk_outlined,
  QuickLogEntryType.journal => Icons.book_outlined,
};

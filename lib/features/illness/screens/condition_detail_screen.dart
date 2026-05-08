import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

class ConditionDetailScreen extends ConsumerStatefulWidget {
  const ConditionDetailScreen({super.key, required this.condition});

  final UserCondition condition;

  @override
  ConsumerState<ConditionDetailScreen> createState() =>
      _ConditionDetailScreenState();
}

class _ConditionDetailScreenState extends ConsumerState<ConditionDetailScreen> {
  // Local editable state — mirrors widget.condition on init
  late DateTime? _diagnosedAt;
  late ConditionStatus _status;
  late List<ConditionStatusEvent> _statusHistory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _diagnosedAt = widget.condition.diagnosedAt;
    _status = widget.condition.status;
    _statusHistory = List.of(widget.condition.statusHistory);
  }

  bool get _isDirty =>
      _diagnosedAt != widget.condition.diagnosedAt ||
      _status != widget.condition.status ||
      _statusHistory.length != widget.condition.statusHistory.length;

  // ── Diagnosis date ─────────────────────────────────────────────────────────

  Future<void> _pickDiagnosisDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _diagnosedAt ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Diagnosis date',
    );
    if (picked != null) setState(() => _diagnosedAt = picked);
  }

  void _clearDiagnosisDate() => setState(() => _diagnosedAt = null);

  // ── Recovery / relapse ─────────────────────────────────────────────────────

  Future<void> _markInRecovery() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Recovery date',
    );
    if (picked == null) return;
    setState(() {
      _status = ConditionStatus.inRecovery;
      _statusHistory = [
        ..._statusHistory,
        ConditionStatusEvent(eventType: 'recovery', date: picked),
      ];
    });
  }

  Future<void> _markRelapsed() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Relapse date',
    );
    if (picked == null) return;
    setState(() {
      _status = ConditionStatus.active;
      _statusHistory = [
        ..._statusHistory,
        ConditionStatusEvent(eventType: 'relapse', date: picked),
      ];
    });
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    // Construct directly so nullable diagnosedAt can be cleared (copyWith
    // can't distinguish "pass null to clear" from "omit to keep").
    await ref
        .read(userConditionListProvider.notifier)
        .update(
          UserCondition(
            id: widget.condition.id,
            profileId: widget.condition.profileId,
            conditionId: widget.condition.conditionId,
            conditionName: widget.condition.conditionName,
            trackedSince: widget.condition.trackedSince,
            diagnosedAt: _diagnosedAt,
            notes: widget.condition.notes,
            status: _status,
            statusHistory: _statusHistory,
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  // ── Timeline ───────────────────────────────────────────────────────────────

  List<({String eventType, DateTime date})> get _timeline {
    final events = <({String eventType, DateTime date})>[];
    if (_diagnosedAt != null) {
      events.add((eventType: 'diagnosed', date: _diagnosedAt!));
    }
    for (final e in _statusHistory) {
      events.add((eventType: e.eventType, date: e.date));
    }
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM yyyy');
    final activeProfile = ref.watch(activeProfileDataProvider);
    final timeline = _timeline;

    return Scaffold(
      appBar: HFAppBar(title: Text(widget.condition.conditionName)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: _isDirty && !_isSaving ? _save : null,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save changes'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Attribution
          if (activeProfile != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Tracking for ${activeProfile.name}',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),

          const SizedBox(height: 16),

          // ── Tracking since ───────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Tracking since'),
            subtitle: Text(fmt.format(widget.condition.trackedSince)),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ── Diagnosis date ───────────────────────────────────────────────
          ListTile(
            leading: Icon(
              Icons.medical_information_outlined,
              color: _diagnosedAt != null ? cs.primary : null,
            ),
            title: const Text('Diagnosis date'),
            subtitle: _diagnosedAt != null
                ? Text(
                    fmt.format(_diagnosedAt!),
                    style: TextStyle(color: cs.primary),
                  )
                : Text(
                    'Not set — tap to add',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
            trailing: _diagnosedAt != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear diagnosis date',
                    onPressed: _clearDiagnosisDate,
                  )
                : null,
            onTap: _pickDiagnosisDate,
          ),

          const Divider(indent: 16, endIndent: 16),

          // ── Status ───────────────────────────────────────────────────────
          ListTile(
            leading: Icon(
              _status == ConditionStatus.inRecovery
                  ? Icons.health_and_safety_outlined
                  : Icons.monitor_heart_outlined,
              color: _status == ConditionStatus.inRecovery
                  ? cs.secondary
                  : cs.primary,
            ),
            title: const Text('Status'),
            subtitle: Text(
              _status == ConditionStatus.inRecovery ? 'In recovery' : 'Active',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _status == ConditionStatus.active
                ? OutlinedButton.icon(
                    onPressed: _markInRecovery,
                    icon: const Icon(Icons.health_and_safety_outlined),
                    label: const Text('Mark as in recovery'),
                  )
                : OutlinedButton.icon(
                    onPressed: _markRelapsed,
                    icon: const Icon(Icons.replay_outlined),
                    label: const Text('Mark as relapsed'),
                  ),
          ),

          // ── History timeline ─────────────────────────────────────────────
          if (timeline.isNotEmpty) ...[
            const Divider(indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'HISTORY',
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...timeline.map(
              (e) => _TimelineEventTile(eventType: e.eventType, date: e.date),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline event tile
// ---------------------------------------------------------------------------

class _TimelineEventTile extends StatelessWidget {
  const _TimelineEventTile({required this.eventType, required this.date});

  final String eventType;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM yyyy');

    final (icon, label, color) = switch (eventType) {
      'diagnosed' => (
        Icons.medical_information_outlined,
        'Diagnosed',
        cs.primary,
      ),
      'recovery' => (
        Icons.health_and_safety_outlined,
        'In recovery',
        cs.secondary,
      ),
      'relapse' => (Icons.replay_outlined, 'Relapsed', cs.error),
      _ => (Icons.circle_outlined, eventType, cs.onSurfaceVariant),
    };

    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(label),
      trailing: Text(
        fmt.format(date),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

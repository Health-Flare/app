import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/models/user_condition.dart';

class ConditionDetailScreen extends ConsumerStatefulWidget {
  const ConditionDetailScreen({super.key, required this.condition});

  final UserCondition condition;

  @override
  ConsumerState<ConditionDetailScreen> createState() =>
      _ConditionDetailScreenState();
}

class _ConditionDetailScreenState extends ConsumerState<ConditionDetailScreen> {
  late DateTime? _diagnosedAt;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _diagnosedAt = widget.condition.diagnosedAt;
  }

  bool get _isDirty => _diagnosedAt != widget.condition.diagnosedAt;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _diagnosedAt ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Diagnosis date',
    );
    if (picked != null) setState(() => _diagnosedAt = picked);
  }

  void _clearDate() => setState(() => _diagnosedAt = null);

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    await ref
        .read(userConditionListProvider.notifier)
        .update(widget.condition.copyWith(diagnosedAt: _diagnosedAt));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM yyyy');
    final activeProfile = ref.watch(activeProfileDataProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.condition.conditionName)),
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

          // Tracked since
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Tracking since'),
            subtitle: Text(fmt.format(widget.condition.trackedSince)),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Diagnosis date
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
                    onPressed: _clearDate,
                  )
                : null,
            onTap: _pickDate,
          ),
        ],
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/appointment.dart';

/// Full detail view for an appointment.
///
/// Shows header info, question checklist, outcome notes, medication changes,
/// and status actions (complete / cancel / missed / follow-up).
class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  final int appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointment = ref
        .watch(appointmentListProvider)
        .cast<Appointment?>()
        .firstWhere((a) => a?.id == appointmentId, orElse: () => null);

    if (appointment == null) {
      return const Scaffold(body: Center(child: Text('Appointment not found')));
    }

    return _AppointmentDetailView(appointment: appointment);
  }
}

class _AppointmentDetailView extends ConsumerStatefulWidget {
  const _AppointmentDetailView({required this.appointment});
  final Appointment appointment;

  @override
  ConsumerState<_AppointmentDetailView> createState() =>
      _AppointmentDetailViewState();
}

class _AppointmentDetailViewState
    extends ConsumerState<_AppointmentDetailView> {
  late TextEditingController _outcomeController;
  late TextEditingController _questionController;
  late TextEditingController _medChangeController;

  @override
  void initState() {
    super.initState();
    _outcomeController = TextEditingController(
      text: widget.appointment.outcomeNotes ?? '',
    );
    _questionController = TextEditingController();
    _medChangeController = TextEditingController();
  }

  @override
  void dispose() {
    _outcomeController.dispose();
    _questionController.dispose();
    _medChangeController.dispose();
    super.dispose();
  }

  Future<void> _updateAppointment(Appointment updated) async {
    await ref.read(appointmentListProvider.notifier).update(updated);
  }

  Future<void> _setStatus(String status) async {
    await _updateAppointment(
      widget.appointment.copyWith(status: status, updatedAt: DateTime.now()),
    );
  }

  Future<void> _saveOutcome() async {
    final notes = _outcomeController.text.trim();
    await _updateAppointment(
      widget.appointment.copyWith(
        outcomeNotes: notes.isEmpty ? null : notes,
        clearOutcomeNotes: notes.isEmpty,
        status: AppointmentStatus.completed,
        updatedAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Outcome saved')));
  }

  Future<void> _toggleQuestion(AppointmentQuestion q) async {
    final updated = widget.appointment.copyWith(
      questions: widget.appointment.questions
          .map(
            (x) => x.questionId == q.questionId
                ? x.copyWith(discussed: !x.discussed)
                : x,
          )
          .toList(),
      updatedAt: DateTime.now(),
    );
    await _updateAppointment(updated);
  }

  Future<void> _addQuestion() async {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;
    final q = AppointmentQuestion(questionId: _uuid(), question: text);
    await _updateAppointment(
      widget.appointment.copyWith(
        questions: [...widget.appointment.questions, q],
        updatedAt: DateTime.now(),
      ),
    );
    _questionController.clear();
  }

  Future<void> _removeQuestion(String questionId) async {
    await _updateAppointment(
      widget.appointment.copyWith(
        questions: widget.appointment.questions
            .where((q) => q.questionId != questionId)
            .toList(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _addMedChange() async {
    final text = _medChangeController.text.trim();
    if (text.isEmpty) return;
    final change = MedicationChange(changeId: _uuid(), description: text);
    await _updateAppointment(
      widget.appointment.copyWith(
        medicationChanges: [...widget.appointment.medicationChanges, change],
        updatedAt: DateTime.now(),
      ),
    );
    _medChangeController.clear();
  }

  Future<void> _removeMedChange(String changeId) async {
    await _updateAppointment(
      widget.appointment.copyWith(
        medicationChanges: widget.appointment.medicationChanges
            .where((c) => c.changeId != changeId)
            .toList(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete appointment?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(appointmentListProvider.notifier)
        .remove(widget.appointment.id);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    // Re-read from provider to get live updates after mutations.
    final appt =
        ref
            .watch(appointmentListProvider)
            .cast<Appointment?>()
            .firstWhere(
              (a) => a?.id == widget.appointment.id,
              orElse: () => null,
            ) ??
        widget.appointment;

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appt.isUpcoming ? 'Upcoming appointment' : 'Appointment detail',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () =>
                context.push(AppRoutes.appointmentEdit(appt.id), extra: appt),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ────────────────────────────────────────────────────────
          _HeaderCard(appointment: appt),
          const SizedBox(height: 16),

          // ── Status actions ────────────────────────────────────────────────
          if (appt.isUpcoming) ...[
            _StatusActionsRow(
              onComplete: () => _setStatus(AppointmentStatus.completed),
              onCancel: () => _setStatus(AppointmentStatus.cancelled),
              onMissed: () => _setStatus(AppointmentStatus.missed),
            ),
            const SizedBox(height: 16),
          ],

          // ── Follow-up button ──────────────────────────────────────────────
          if (appt.isCompleted) ...[
            OutlinedButton.icon(
              onPressed: () => context.push(
                AppRoutes.appointmentNew,
                extra: appt.providerName,
              ),
              icon: const Icon(Icons.event_repeat_outlined),
              label: const Text('Schedule follow-up'),
            ),
            const SizedBox(height: 16),
          ],

          // ── Questions ─────────────────────────────────────────────────────
          _SectionTitle(
            title: appt.questions.isEmpty
                ? 'Questions'
                : 'Questions (${appt.questions.length})',
            cs: cs,
            tt: tt,
          ),
          ...appt.questions.map(
            (q) => _QuestionTile(
              question: q,
              onToggle: () => _toggleQuestion(q),
              onDelete: () => _removeQuestion(q.questionId),
            ),
          ),
          _AddItemRow(
            controller: _questionController,
            hintText: 'Add a question',
            onAdd: _addQuestion,
          ),
          const SizedBox(height: 16),

          // ── Outcome notes ─────────────────────────────────────────────────
          _SectionTitle(title: 'Outcome notes', cs: cs, tt: tt),
          TextField(
            controller: _outcomeController,
            decoration: const InputDecoration(
              hintText: 'What did the doctor say?',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: _saveOutcome,
              child: const Text('Save outcome'),
            ),
          ),
          const SizedBox(height: 16),

          // ── Medication changes ─────────────────────────────────────────────
          _SectionTitle(
            title: appt.medicationChanges.isEmpty
                ? 'Medication changes'
                : 'Medication changes (${appt.medicationChanges.length})',
            cs: cs,
            tt: tt,
          ),
          ...appt.medicationChanges.map(
            (c) => _MedChangeTile(
              change: c,
              onDelete: () => _removeMedChange(c.changeId),
            ),
          ),
          _AddItemRow(
            controller: _medChangeController,
            hintText: 'Add medication change',
            onAdd: _addMedChange,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('EEE d MMM yyyy, HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.title,
                    style: tt.titleMedium?.copyWith(color: cs.onSurface),
                  ),
                ),
                _StatusChip(status: appointment.status),
              ],
            ),
            if (appointment.providerName != null) ...[
              const SizedBox(height: 4),
              Text(
                appointment.providerName!,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              fmt.format(appointment.scheduledAt),
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      AppointmentStatus.upcoming => ('Upcoming', cs.primary),
      AppointmentStatus.completed => ('Completed', Colors.green),
      AppointmentStatus.cancelled => ('Cancelled', cs.onSurfaceVariant),
      AppointmentStatus.missed => ('Missed', cs.error),
      _ => (status, cs.primary),
    };
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color.withAlpha(20),
      side: BorderSide(color: color.withAlpha(80)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _StatusActionsRow extends StatelessWidget {
  const _StatusActionsRow({
    required this.onComplete,
    required this.onCancel,
    required this.onMissed,
  });

  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final VoidCallback onMissed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        FilledButton.tonal(
          onPressed: onComplete,
          child: const Text('Mark completed'),
        ),
        OutlinedButton(onPressed: onCancel, child: const Text('Cancel')),
        OutlinedButton(onPressed: onMissed, child: const Text('Missed')),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.cs,
    required this.tt,
  });

  final String title;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    required this.question,
    required this.onToggle,
    required this.onDelete,
  });

  final AppointmentQuestion question;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: question.discussed,
        onChanged: (_) => onToggle(),
      ),
      title: Text(
        question.question,
        style: TextStyle(
          decoration: question.discussed ? TextDecoration.lineThrough : null,
          color: question.discussed ? cs.onSurfaceVariant : cs.onSurface,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: onDelete,
      ),
    );
  }
}

class _MedChangeTile extends StatelessWidget {
  const _MedChangeTile({required this.change, required this.onDelete});

  final MedicationChange change;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.medication_outlined, color: cs.primary),
      title: Text(change.description),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: onDelete,
      ),
    );
  }
}

class _AddItemRow extends StatelessWidget {
  const _AddItemRow({
    required this.controller,
    required this.hintText,
    required this.onAdd,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          tooltip: 'Add',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _uuid() {
  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int n) => n.toRadixString(16).padLeft(2, '0');
  final b = bytes.map(hex).join();
  return '${b.substring(0, 8)}-${b.substring(8, 12)}-${b.substring(12, 16)}-${b.substring(16, 20)}-${b.substring(20)}';
}

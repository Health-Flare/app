import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/models/appointment.dart';

/// Screen to create a new appointment or edit an existing one.
///
/// Pass [appointment] to open in edit mode; [prefillProvider] to pre-fill
/// provider name (e.g. when scheduling a follow-up); [prefillTitle] to
/// pre-fill the title (e.g. from quick-log promotion).
class AppointmentFormScreen extends ConsumerStatefulWidget {
  const AppointmentFormScreen({
    super.key,
    this.appointment,
    this.prefillProvider,
    this.prefillTitle,
  });

  final Appointment? appointment;
  final String? prefillProvider;
  final String? prefillTitle;

  @override
  ConsumerState<AppointmentFormScreen> createState() =>
      _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends ConsumerState<AppointmentFormScreen> {
  late TextEditingController _titleController;
  late TextEditingController _providerController;
  late DateTime _scheduledAt;
  bool _submitting = false;

  bool get _isEdit => widget.appointment != null;

  @override
  void initState() {
    super.initState();
    final a = widget.appointment;
    _titleController = TextEditingController(
      text: a?.title ?? widget.prefillTitle ?? '',
    );
    _providerController = TextEditingController(
      text: a?.providerName ?? widget.prefillProvider ?? '',
    );
    _scheduledAt = a?.scheduledAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _providerController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _submitting = true);
    final notifier = ref.read(appointmentListProvider.notifier);
    final provider = _providerController.text.trim();

    try {
      if (_isEdit) {
        await notifier.update(
          widget.appointment!.copyWith(
            title: title,
            providerName: provider.isEmpty ? null : provider,
            clearProviderName: provider.isEmpty,
            scheduledAt: _scheduledAt,
            updatedAt: DateTime.now(),
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
          title: title,
          providerName: provider.isEmpty ? null : provider,
          scheduledAt: _scheduledAt,
        );
      }
      if (!mounted) return;
      context.pop();
    } catch (e) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit appointment' : 'New appointment'),
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
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),

            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Appointment title',
                hintText: 'e.g. Rheumatology follow-up',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Provider
            TextField(
              controller: _providerController,
              decoration: const InputDecoration(
                labelText: 'Provider name (optional)',
                hintText: 'e.g. Dr. Chen',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Date & time
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date & time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(fmt.format(_scheduledAt)),
              ),
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
                : Text(_isEdit ? 'Save changes' : 'Save appointment'),
          ),
        ),
      ),
    );
  }
}

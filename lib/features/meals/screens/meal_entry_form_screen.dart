import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/weather_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/shared/widgets/weather_chip.dart';
import 'package:health_flare/models/meal_entry.dart';
import 'package:health_flare/models/weather_snapshot.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Full-screen form for creating or editing a meal entry.
///
/// Pass [entry] to open in edit mode; leave null for a new entry.
/// Pass [prefillText] to pre-populate the description (quick-log promotion).
class MealEntryFormScreen extends ConsumerStatefulWidget {
  const MealEntryFormScreen({super.key, this.entry, this.prefillText});

  final MealEntry? entry;
  final String? prefillText;

  @override
  ConsumerState<MealEntryFormScreen> createState() =>
      _MealEntryFormScreenState();
}

class _MealEntryFormScreenState extends ConsumerState<MealEntryFormScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late DateTime _loggedAt;
  late bool _hasReaction;
  String? _photoPath;
  bool _submitting = false;
  bool _descriptionError = false;
  final _picker = ImagePicker();

  // Captured once when the form opens (new entry only).
  WeatherSnapshot? _capturedWeather;

  bool get _isEdit => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    if (e != null) {
      _descriptionController = TextEditingController(text: e.description);
      _notesController = TextEditingController(text: e.notes ?? '');
      _loggedAt = e.loggedAt;
      _hasReaction = e.hasReaction;
      _photoPath = e.photoPath;
    } else {
      _descriptionController = TextEditingController(
        text: widget.prefillText ?? '',
      );
      _notesController = TextEditingController();
      _loggedAt = DateTime.now();
      _hasReaction = false;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
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

  Future<void> _pickPhoto(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;
    setState(() {
      _photoPath = file.path;
    });
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from library'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      setState(() => _descriptionError = true);
      return;
    }

    setState(() => _submitting = true);

    final notifier = ref.read(mealEntryListProvider.notifier);
    final notes = _notesController.text.trim();

    if (_isEdit) {
      await notifier.update(
        widget.entry!.copyWith(
          description: description,
          notes: notes.isEmpty ? null : notes,
          photoPath: _photoPath,
          hasReaction: _hasReaction,
          loggedAt: _loggedAt,
          updatedAt: DateTime.now(),
          clearNotes: notes.isEmpty,
          clearPhotoPath: _photoPath == null,
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
        notes: notes.isEmpty ? null : notes,
        photoPath: _photoPath,
        hasReaction: _hasReaction,
        loggedAt: _loggedAt,
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
        title: const Text('Delete meal entry?'),
        content: const Text('This will permanently remove this meal entry.'),
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

    await ref.read(mealEntryListProvider.notifier).remove(widget.entry!.id);
    if (!mounted) return;
    context.go(AppRoutes.meals);
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
      appBar: HFAppBar(
        title: Text(_isEdit ? 'Edit meal' : 'Log meal'),
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
            // Logging for attribution
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

            // Weather chip (new entries show live weather; edit shows saved snapshot)
            if ((_isEdit ? widget.entry?.weatherSnapshot : _capturedWeather) !=
                null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WeatherChip(
                  snapshot: _isEdit
                      ? widget.entry?.weatherSnapshot
                      : _capturedWeather,
                ),
              ),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'What did you eat?',
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

            // Date / time
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

            // Reaction flag
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reaction flag'),
              subtitle: const Text('Mark this meal as followed by a reaction'),
              value: _hasReaction,
              onChanged: (v) => setState(() => _hasReaction = v),
            ),
            const SizedBox(height: 8),

            // Photo
            _PhotoSection(
              photoPath: _photoPath,
              onAddPhoto: _showPhotoOptions,
              onRemove: () => setState(() => _photoPath = null),
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any observations about this meal',
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
                : Text(_isEdit ? 'Save changes' : 'Add meal'),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Photo section widget
// ---------------------------------------------------------------------------

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.photoPath,
    required this.onAddPhoto,
    required this.onRemove,
  });

  final String? photoPath;
  final VoidCallback onAddPhoto;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (photoPath != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(photoPath!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                height: 200,
                color: cs.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: onAddPhoto,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Change photo'),
              ),
              TextButton.icon(
                onPressed: onRemove,
                icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                label: Text('Remove', style: TextStyle(color: cs.error)),
              ),
            ],
          ),
        ],
      );
    }

    return OutlinedButton.icon(
      onPressed: onAddPhoto,
      icon: const Icon(Icons.add_photo_alternate_outlined),
      label: const Text('Add photo'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}

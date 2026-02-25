import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/models/profile.dart';
import 'package:health_flare/features/profiles/widgets/profile_avatar.dart';

/// Modal bottom sheet for adding a new profile or editing an existing one.
///
/// When [existing] is null → "Add profile" mode (adds to list, sets active).
/// When [existing] is set  → "Edit profile" mode (updates in place).
///
/// Opened via [showAddOrEditProfileSheet].
class AddProfileSheet extends ConsumerStatefulWidget {
  const AddProfileSheet({super.key, this.existing});

  /// Pass a [Profile] to enter edit mode.
  final Profile? existing;

  @override
  ConsumerState<AddProfileSheet> createState() => _AddProfileSheetState();
}

class _AddProfileSheetState extends ConsumerState<AddProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _dobController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _avatarPath;
  bool _isSaving = false;

  final _picker = ImagePicker();

  bool get _isEditMode => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    if (existing?.dateOfBirth != null) {
      _dateOfBirth = existing!.dateOfBirth;
      _dobController.text = _formatDate(_dateOfBirth!);
    }
    _avatarPath = existing?.avatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / '
      '${d.month.toString().padLeft(2, '0')} / '
      '${d.year}';

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Date of birth',
      fieldLabelText: 'Date of birth',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateOfBirth = picked;
      _dobController.text = _formatDate(picked);
    });
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() => _avatarPath = file.path);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final listNotifier = ref.read(profileListProvider.notifier);

    if (_isEditMode) {
      // Update existing profile and persist to the database.
      final updated = widget.existing!.copyWith(
        name: _nameController.text.trim(),
        dateOfBirth: _dateOfBirth,
        avatarPath: _avatarPath,
        clearDateOfBirth: _dateOfBirth == null,
      );
      await listNotifier.update(updated);
    } else {
      // Add new profile. Isar assigns the id and makes it active.
      await listNotifier.add(
        name: _nameController.text.trim(),
        dateOfBirth: _dateOfBirth,
        avatarPath: _avatarPath,
      );
    }
    if (!mounted) return;

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteProfile() async {
    final profile = widget.existing;
    if (profile == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remove ${profile.name}?'),
        content: Text(
          'All health data recorded for ${profile.name} will be permanently '
          'removed from this device. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref.read(profileListProvider.notifier).remove(profile.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    // Build a temporary profile for the avatar preview.
    // _avatarPath takes precedence — it reflects any newly picked image.
    final previewProfile = Profile(
      id: widget.existing?.id ?? 0,
      name: _nameController.text.trim().isEmpty
          ? '?'
          : _nameController.text.trim(),
      dateOfBirth: _dateOfBirth,
      avatarPath: _avatarPath,
    );

    return Padding(
      // Push form above keyboard when it appears
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Drag handle ─────────────────────────────────────────
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.fromLTRB(0, 12, 0, 24),
                    decoration: BoxDecoration(
                      color: cs.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Header row: avatar preview + title ───────────────────
                Row(
                  children: [
                    // Live avatar preview
                    GestureDetector(
                      onTap: () => _showPhotoOptions(context),
                      child: Semantics(
                        button: true,
                        label: 'Choose profile photo — optional',
                        child: Stack(
                          children: [
                            // Rebuild avatar preview as name changes
                            ListenableBuilder(
                              listenable: _nameController,
                              builder: (context, child) => ProfileAvatar(
                                profile: Profile(
                                  id: widget.existing?.id ?? 0,
                                  name: _nameController.text.trim().isEmpty
                                      ? '?'
                                      : _nameController.text.trim(),
                                  dateOfBirth: _dateOfBirth,
                                  avatarPath: previewProfile.avatarPath,
                                ),
                                radius: 32,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cs.surface,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 12,
                                  color: cs.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Text(
                        _isEditMode ? 'Edit profile' : 'New profile',
                        style: tt.titleLarge?.copyWith(color: cs.onSurface),
                      ),
                    ),

                    // Delete button (edit mode only)
                    if (_isEditMode)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: cs.error,
                        ),
                        tooltip: 'Remove profile',
                        onPressed: _deleteProfile,
                      ),
                  ],
                ),

                const SizedBox(height: 28),

                // ── Name field ───────────────────────────────────────────
                Semantics(
                  label: 'Profile name, required',
                  child: TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'e.g. Sarah, Dad, Myself',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'A name is required.';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Date of birth field ──────────────────────────────────
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date of birth',
                    hintText: 'DD / MM / YYYY',
                    helperText: 'Optional — useful for reports',
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  onTap: _pickDob,
                ),

                const SizedBox(height: 32),

                // ── Save button ──────────────────────────────────────────
                Semantics(
                  label: _isEditMode ? 'Save changes' : 'Add profile',
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditMode ? 'Save changes' : 'Add profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from library'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Public helper ────────────────────────────────────────────────────────────

/// Show the add/edit profile sheet.
///
/// Pass [existing] to edit a profile, or omit for adding a new one.
Future<void> showAddOrEditProfileSheet(
  BuildContext context, {
  Profile? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => AddProfileSheet(existing: existing),
  );
}

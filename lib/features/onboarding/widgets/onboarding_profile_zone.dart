import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Zone 3 — Profile creation form (inline, no navigation away).
///
/// The CTA button is always visible but disabled until [nameController]
/// has a non-empty, valid value. This follows the requirement that the
/// button "never disappears" (docs/onboarding-copy.md).
///
/// Copy source: docs/onboarding-copy.md › Zone 3
class OnboardingProfileZone extends StatefulWidget {
  const OnboardingProfileZone({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final bool isSubmitting;

  /// Called when the user taps the CTA. Receives the optional date of birth
  /// selected in this zone so the caller can include it when saving the profile.
  final void Function(DateTime? dateOfBirth) onSubmit;

  @override
  State<OnboardingProfileZone> createState() => _OnboardingProfileZoneState();
}

class _OnboardingProfileZoneState extends State<OnboardingProfileZone> {
  // Tracks whether the CTA button should be enabled.
  bool _hasName = false;

  // Holds the picked date of birth so it can be displayed and submitted.
  DateTime? _dateOfBirth;

  // Read-only controller that shows the formatted date in the DOB field.
  final _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_onNameChanged);
    _dobController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final hasName = widget.nameController.text.trim().isNotEmpty;
    if (hasName != _hasName) {
      setState(() => _hasName = hasName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eyebrow label
            Text(
              "LET'S GET STARTED",
              style: tt.labelSmall?.copyWith(
                color: cs.primary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            // Section heading
            Text(
              'Who are we tracking?',
              style: tt.headlineSmall?.copyWith(color: cs.onSurface),
            ),

            const SizedBox(height: 8),

            // Supporting line
            Text(
              'You can track your own health, or set up a profile for someone '
              'you care for. You can always add more people later.',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Name field
            Semantics(
              label: 'Profile name, required',
              child: TextFormField(
                controller: widget.nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Sarah, Dad, Myself',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'A name helps keep records organised. Please enter one to continue.';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 20),

            // Date of birth field
            TextFormField(
              controller: _dobController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                hintText: 'DD / MM / YYYY',
                helperText: 'Optional — useful for reports',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              onTap: () => _pickDateOfBirth(context),
            ),

            const SizedBox(height: 20),

            // Avatar / photo field
            _AvatarPicker(),

            const SizedBox(height: 40),

            // CTA button — always visible, disabled until name is entered
            Semantics(
              label: 'Create profile and get started',
              child: ElevatedButton(
                onPressed: (_hasName && !widget.isSubmitting)
                    ? () => widget.onSubmit(_dateOfBirth)
                    : null,
                child: widget.isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create profile and get started  →'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Date of birth',
      fieldLabelText: 'Date of birth',
    );

    // User dismissed the picker without choosing — leave existing value alone.
    if (picked == null) return;

    setState(() {
      _dateOfBirth = picked;
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')} / '
          '${picked.month.toString().padLeft(2, '0')} / '
          '${picked.year}';
    });
  }
}

/// Inline avatar picker widget.
///
/// Shows a circular placeholder that the user can tap to select a photo.
/// In MVP the picked image is held in local state only — persisting to the
/// profile record is wired up when the Isar data layer is added.
class _AvatarPicker extends StatefulWidget {
  @override
  State<_AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<_AvatarPicker> {
  // ignore: unused_field — will be used when image_picker is wired up
  Object? _pickedImage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          'Optional',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showPhotoOptions(context),
          child: Semantics(
            button: true,
            label: 'Choose profile photo — optional',
            child: CircleAvatar(
              radius: 44,
              backgroundColor: cs.surfaceContainerHighest,
              child: Icon(
                Icons.add_a_photo_outlined,
                size: 28,
                color: cs.onSurfaceVariant,
                semanticLabel: '',
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: wire up image_picker camera source
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from library'),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: wire up image_picker gallery source
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }
}

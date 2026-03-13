import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/theme/app_colors.dart';
import 'package:health_flare/models/condition.dart';

/// Zone 3 — Profile creation form (inline, no navigation away).
///
/// The CTA button is always visible but disabled until [nameController]
/// has a non-empty, valid value. This follows the requirement that the
/// button "never disappears" (docs/onboarding-copy.md).
///
/// Copy source: docs/onboarding-copy.md › Zone 3
class OnboardingProfileZone extends ConsumerStatefulWidget {
  const OnboardingProfileZone({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.nameFocusNode,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;

  /// Focus node for the name field. Owned by the parent so that focus can be
  /// requested without causing a scroll jump on initial load.
  final FocusNode nameFocusNode;
  final bool isSubmitting;

  /// Called when the user taps the CTA. Receives the optional date of birth,
  /// avatar file path, and list of conditions selected during onboarding.
  final void Function(
    DateTime? dateOfBirth,
    String? avatarPath,
    List<Condition> conditions,
  ) onSubmit;

  @override
  ConsumerState<OnboardingProfileZone> createState() =>
      _OnboardingProfileZoneState();
}

class _OnboardingProfileZoneState
    extends ConsumerState<OnboardingProfileZone> {
  bool _hasName = false;
  DateTime? _dateOfBirth;
  String? _avatarPath;

  final _dobController = TextEditingController();
  final _conditionSearchController = TextEditingController();
  String _conditionQuery = '';

  final List<Condition> _selectedConditions = [];

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_onNameChanged);
    _conditionSearchController.addListener(() {
      setState(
        () => _conditionQuery = _conditionSearchController.text.trim(),
      );
    });
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_onNameChanged);
    _dobController.dispose();
    _conditionSearchController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final hasName = widget.nameController.text.trim().isNotEmpty;
    if (hasName != _hasName) {
      setState(() => _hasName = hasName);
    }
  }

  List<Condition> _filteredResults(List<Condition> catalog) {
    if (_conditionQuery.isEmpty) return [];
    final selectedIds = _selectedConditions.map((c) => c.id).toSet();
    final available = catalog.where((c) => !selectedIds.contains(c.id));
    return rankSearch(available.toList(), _conditionQuery, (c) => c.name)
        .take(6)
        .toList();
  }

  void _selectCondition(Condition condition) {
    setState(() {
      _selectedConditions.add(condition);
      _conditionSearchController.clear();
      _conditionQuery = '';
    });
  }

  void _removeCondition(Condition condition) {
    setState(() => _selectedConditions.remove(condition));
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(conditionCatalogProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final results = _filteredResults(catalog);

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
                focusNode: widget.nameFocusNode,
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
            _AvatarPicker(
              onChanged: (path) => setState(() => _avatarPath = path),
            ),

            const SizedBox(height: 32),

            // ── Illness selector ────────────────────────────────────────────
            Text(
              'What are you managing?',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Optional — search and add the conditions you want to track',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),

            const SizedBox(height: 12),

            // Selected condition chips
            if (_selectedConditions.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _selectedConditions
                    .map(
                      (c) => InputChip(
                        label: Text(c.name),
                        onDeleted: () => _removeCondition(c),
                        deleteIcon: const Icon(Icons.cancel, size: 18),
                        deleteIconColor: cs.onSurfaceVariant,
                        backgroundColor: cs.surfaceContainerHighest,
                        labelStyle: tt.bodySmall,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
            ],

            // Condition search field
            TextFormField(
              key: const Key('onboarding_condition_search'),
              controller: _conditionSearchController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Search conditions...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _conditionQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _conditionSearchController.clear();
                          setState(() => _conditionQuery = '');
                        },
                      )
                    : null,
              ),
            ),

            // Search results
            if (results.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border.all(color: cs.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: results
                      .map(
                        (c) => ListTile(
                          dense: true,
                          title: Text(c.name, style: tt.bodyMedium),
                          onTap: () => _selectCondition(c),
                        ),
                      )
                      .toList(),
                ),
              ),

            const SizedBox(height: 40),

            // CTA button — always visible, disabled until name is entered
            Semantics(
              label: 'Create profile and get started',
              child: ElevatedButton(
                onPressed: (_hasName && !widget.isSubmitting)
                    ? () => widget.onSubmit(
                          _dateOfBirth,
                          _avatarPath,
                          List.unmodifiable(_selectedConditions),
                        )
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
class _AvatarPicker extends StatefulWidget {
  const _AvatarPicker({required this.onChanged});

  final ValueChanged<String?> onChanged;

  @override
  State<_AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<_AvatarPicker> {
  final _picker = ImagePicker();
  XFile? _pickedFile;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _pickedFile = file);
    widget.onChanged(file.path);
  }

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
              backgroundImage: _pickedFile != null
                  ? FileImage(File(_pickedFile!.path))
                  : null,
              child: _pickedFile == null
                  ? Icon(
                      Icons.add_a_photo_outlined,
                      size: 28,
                      color: cs.onSurfaceVariant,
                      semanticLabel: '',
                    )
                  : null,
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
                  _pick(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from library'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pick(ImageSource.gallery);
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

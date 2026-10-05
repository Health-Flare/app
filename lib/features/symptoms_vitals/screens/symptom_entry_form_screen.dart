import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/weather_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/core/theme/app_colors.dart';
import 'package:health_flare/features/quick_log/quick_log_parser.dart';
import 'package:health_flare/features/shared/widgets/move_entry_action.dart';
import 'package:health_flare/features/shared/widgets/weather_chip.dart';
import 'package:health_flare/features/symptoms_vitals/symptom_add_ons.dart';
import 'package:health_flare/features/symptoms_vitals/widgets/interference_selector.dart';
import 'package:health_flare/models/symptom_entry.dart';
import 'package:health_flare/models/weather_snapshot.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// Full-screen form for creating or editing a symptom entry.
///
/// Pass [entry] to open in edit mode; leave null for a new entry.
/// Pass [prefillText] to pre-populate the name field (quick-log promotion).
class SymptomEntryFormScreen extends ConsumerStatefulWidget {
  const SymptomEntryFormScreen({super.key, this.entry, this.prefillText});

  final SymptomEntry? entry;
  final String? prefillText;

  @override
  ConsumerState<SymptomEntryFormScreen> createState() =>
      _SymptomEntryFormScreenState();
}

class _SymptomEntryFormScreenState
    extends ConsumerState<SymptomEntryFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _impactController;
  late FocusNode _nameFocusNode;
  int? _severity;
  int? _interference;
  late List<String> _locations;
  late DateTime _loggedAt;
  bool _timeChanged = false;
  bool _submitting = false;
  bool _nameError = false;
  bool _severityError = false;

  // ── Optional details ("Add if it helps") ───────────────────────────────
  // Spec: symptoms_and_vitals.feature, "Optional details: add only what
  // helps". Credit: Dr Cat Hicks, Informed Patient.

  /// Add-ons whose question is shown in the form.
  final Set<SymptomAddOn> _open = {};

  /// Add-ons opened because the last entry for this symptom used them.
  /// Maps to the symptom name as it was logged, for the hint line.
  final Map<SymptomAddOn, String> _fromLastTime = {};

  /// Normalised symptom name that [_fromLastTime] was worked out for.
  String _lastTimeKey = '';

  /// "N more" tapped: folded add-ons are offered again for this entry.
  bool _showFolded = false;

  /// "Keep showing" tapped on the note.
  bool _keepShowing = false;

  /// The one-time folding note: decided once, then stays until dismissed.
  bool _noteDecided = false;
  bool _noteVisible = false;

  bool get _isEdit => widget.entry != null;

  // Captured once when the form opens (new entry only).
  WeatherSnapshot? _capturedWeather;

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    if (widget.entry != null) {
      final e = widget.entry!;
      _nameController = TextEditingController(text: e.name);
      _notesController = TextEditingController(text: e.notes ?? '');
      _impactController = TextEditingController(text: e.impact ?? '');
      _severity = e.severity;
      _interference = e.interference;
      _locations = List.of(e.locations);
      _loggedAt = e.loggedAt;
      // Editing opens exactly what the entry already has.
      _open.addAll(SymptomAddOns.usedIn(e));
    } else {
      _nameController = TextEditingController(text: widget.prefillText ?? '');
      _notesController = TextEditingController();
      _impactController = TextEditingController();
      _locations = QuickLogParser.parseLocations(widget.prefillText ?? '');
      _loggedAt = DateTime.now();
      if (_locations.isNotEmpty) _open.add(SymptomAddOn.where);
      _nameController.addListener(_onNameChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onNameChanged();
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameFocusNode.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _impactController.dispose();
    super.dispose();
  }

  /// Whether [a] has a value in the form right now.
  bool _answered(SymptomAddOn a) => switch (a) {
    SymptomAddOn.where => _locations.isNotEmpty,
    SymptomAddOn.interference => _interference != null,
    SymptomAddOn.impact => _impactController.text.trim().isNotEmpty,
    SymptomAddOn.notes => _notesController.text.trim().isNotEmpty,
  };

  /// New entries only: open what was used last time for this symptom.
  /// When the name changes, close auto-opened add-ons that were never
  /// answered; anything answered stays.
  void _onNameChanged() {
    if (_isEdit || !mounted) return;
    final key = _nameController.text.trim().toLowerCase();
    if (key == _lastTimeKey) return;
    _lastTimeKey = key;

    final profileId = ref.read(activeProfileProvider);
    if (profileId == null) return;
    final entries = ref.read(symptomEntryListProvider);
    final last = SymptomAddOns.lastEntryFor(
      entries: entries,
      profileId: profileId,
      name: key,
    );
    final next = last == null ? <SymptomAddOn>{} : SymptomAddOns.usedIn(last);

    setState(() {
      for (final a in _fromLastTime.keys.toList()) {
        if (next.contains(a)) continue;
        if (!_answered(a)) _open.remove(a);
        _fromLastTime.remove(a);
      }
      for (final a in next) {
        if (_open.contains(a) && !_fromLastTime.containsKey(a)) continue;
        _open.add(a);
        _fromLastTime[a] = last!.name.trim();
      }
    });
  }

  void _addOn(SymptomAddOn a) => setState(() => _open.add(a));

  /// Close [a] and clear its value, so nothing hidden gets saved.
  void _removeAddOn(SymptomAddOn a) => setState(() {
    _open.remove(a);
    _fromLastTime.remove(a);
    switch (a) {
      case SymptomAddOn.where:
        _locations = [];
      case SymptomAddOn.interference:
        _interference = null;
      case SymptomAddOn.impact:
        _impactController.clear();
      case SymptomAddOn.notes:
        _notesController.clear();
    }
  });

  Future<void> _keepAllShowing(int profileId) async {
    setState(() {
      _keepShowing = true;
      _noteVisible = false;
    });
    await ref
        .read(profileListProvider.notifier)
        .setShowAllSymptomOptions(profileId, true);
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
      _timeChanged = true;
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
    if (_submitting) return;
    setState(() => _submitting = true);
    final saved = await _persist();
    if (!mounted) return;
    if (!saved) {
      setState(() => _submitting = false);
      return;
    }
    context.pop();
  }

  /// Validates and writes the form without leaving the screen. Returns
  /// false (writing nothing) if a required field is missing. Used by Save,
  /// and by Move so pending edits travel with the entry.
  Future<bool> _persist() async {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty;
      _severityError = _severity == null;
    });
    if (_nameError || _severityError) return false;

    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
    // Impact is kept exactly as typed, apart from surrounding whitespace.
    final impact = _impactController.text.trim().isEmpty
        ? null
        : _impactController.text.trim();

    if (widget.entry == null) {
      final profileId = ref.read(activeProfileProvider)!;
      await ref
          .read(symptomEntryListProvider.notifier)
          .add(
            profileId: profileId,
            name: _nameController.text.trim(),
            severity: _severity!,
            locations: _locations,
            loggedAt: _loggedAt,
            notes: notes,
            weatherSnapshot: _capturedWeather,
            interference: _interference,
            impact: impact,
          );
    } else {
      await ref
          .read(symptomEntryListProvider.notifier)
          .update(
            widget.entry!.copyWith(
              name: _nameController.text.trim(),
              severity: _severity,
              locations: _locations,
              loggedAt: _loggedAt,
              notes: notes,
              clearNotes: notes == null,
              interference: _interference,
              clearInterference: _interference == null,
              impact: impact,
              clearImpact: impact == null,
            ),
          );
    }
    return true;
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This symptom entry will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(symptomEntryListProvider.notifier)
          .remove(widget.entry!.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final activeProfile = ref.watch(activeProfileDataProvider);
    final isEdit = _isEdit;
    final suggestionNames = ref.watch(recentSymptomNamesProvider);

    // Watch weather for new entries: capture and display when available.
    final weatherAsync = isEdit ? null : ref.watch(currentWeatherProvider);
    weatherAsync?.whenData((w) {
      if (w != null && _capturedWeather == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _capturedWeather = w);
        });
      }
    });

    // ── Which add-ons to offer ──────────────────────────────────────────
    final profileId = widget.entry?.profileId ?? activeProfile?.id;
    final folded = profileId == null
        ? <SymptomAddOn>{}
        : SymptomAddOns.folded(
            entries: ref.watch(symptomEntryListProvider),
            profileId: profileId,
            showAll:
                (activeProfile?.showAllSymptomOptions ?? false) || _keepShowing,
          );
    final hidden = (_showFolded || _keepShowing)
        ? <SymptomAddOn>{}
        : folded.difference(_open);
    final offered = [
      for (final a in SymptomAddOn.values)
        if (!_open.contains(a) && !hidden.contains(a)) a,
    ];

    // The note shows once per profile, on a new entry, the first time
    // something is actually folded away.
    if (!_noteDecided &&
        !isEdit &&
        hidden.isNotEmpty &&
        activeProfile != null &&
        !activeProfile.symptomFoldNoteShown) {
      _noteDecided = true;
      _noteVisible = true;
      final id = activeProfile.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(profileListProvider.notifier).markSymptomFoldNoteShown(id);
      });
    }

    Widget addOnSection(SymptomAddOn a, String label, Widget body) => Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _SectionLabel(label: label)),
              IconButton(
                key: Key('remove_${a.name}'),
                visualDensity: VisualDensity.compact,
                tooltip: 'Remove',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => _removeAddOn(a),
              ),
            ],
          ),
          if (_fromLastTime[a] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.history, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _SectionHint(
                      text:
                          'Added because you used it last time for '
                          '${_fromLastTime[a]}.',
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 4),
          body,
        ],
      ),
    );

    return Scaffold(
      appBar: HFAppBar(
        title: Text(isEdit ? 'Edit symptom' : 'Log symptom'),
        actions: [
          if (isEdit)
            MoveEntryAction(
              beforeMove: _persist,
              notices: [
                if (widget.entry!.flareIsarId != null)
                  'It will no longer be part of '
                      "${ref.read(activeProfileDataProvider)?.name ?? 'this profile'}'s flare.",
              ],
              onMove: (target) => ref
                  .read(symptomEntryListProvider.notifier)
                  .moveToProfile(widget.entry!.id, target.id),
            ),
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete entry',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Logging for [name] ────────────────────────────────────────
            if (activeProfile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Logging for ${activeProfile.name}',
                  style: tt.labelLarge?.copyWith(color: cs.primary),
                ),
              ),

            // ── Weather chip ──────────────────────────────────────────────
            if ((isEdit ? widget.entry?.weatherSnapshot : _capturedWeather) !=
                null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: WeatherChip(
                  snapshot: isEdit
                      ? widget.entry?.weatherSnapshot
                      : _capturedWeather,
                  showDetails: isEdit,
                ),
              ),

            // ── What are you feeling? ─────────────────────────────────────
            const _SectionLabel(label: 'What are you feeling?'),
            const SizedBox(height: 8),
            RawAutocomplete<String>(
              textEditingController: _nameController,
              focusNode: _nameFocusNode,
              optionsBuilder: (textEditingValue) {
                if (suggestionNames.isEmpty) {
                  return const Iterable<String>.empty();
                }
                if (textEditingValue.text.isEmpty) {
                  return suggestionNames.take(8);
                }
                final query = textEditingValue.text.toLowerCase();
                return suggestionNames.where(
                  (name) => name.toLowerCase().contains(query),
                );
              },
              fieldViewBuilder: (context, controller, focusNode, _) {
                return TextFormField(
                  key: const Key('symptom_name_field'),
                  controller: controller,
                  focusNode: focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'e.g. Headache, Fatigue, Nausea',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: _nameError ? 'Symptom name is required' : null,
                  ),
                  onChanged: (_) {
                    if (_nameError) setState(() => _nameError = false);
                  },
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Text(option),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Intensity ─────────────────────────────────────────────────
            // Stored as `severity`; shown as intensity. Kept separate from
            // interference: how bad a symptom is and how much it gets in
            // the way are different things (Dr Cat Hicks, Informed Patient;
            // PROMIS research). Our wording, not PROMIS items.
            const _SectionLabel(label: 'How intense was it?'),
            const SizedBox(height: 8),
            _SeveritySelector(
              value: _severity,
              onChanged: (v) => setState(() {
                _severity = v;
                _severityError = false;
              }),
            ),
            const SizedBox(height: 4),
            const _ScaleAnchors(
              low: '1  Barely noticeable',
              high: 'Worst you can imagine  10',
            ),
            if (_severityError)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Intensity is required',
                  style: tt.bodySmall?.copyWith(color: cs.error),
                ),
              ),

            const SizedBox(height: 16),

            // ── When ──────────────────────────────────────────────────────
            _WhenLine(
              text: (!isEdit && !_timeChanged)
                  ? 'Now, ${DateFormat('EEE d MMM HH:mm').format(_loggedAt)}'
                  : DateFormat('EEE d MMM yyyy, HH:mm').format(_loggedAt),
              onChange: _pickLoggedAt,
            ),

            // ── Open add-ons, in a fixed order ────────────────────────────
            if (_open.contains(SymptomAddOn.where))
              addOnSection(
                SymptomAddOn.where,
                'Where',
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final label in QuickLogParser.bodyLocationLabels)
                      FilterChip(
                        label: Text(label),
                        selected: _locations.contains(label),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _locations = [..._locations, label];
                          } else {
                            _locations = [
                              for (final item in _locations)
                                if (item != label) item,
                            ];
                          }
                        }),
                      ),
                  ],
                ),
              ),
            if (_open.contains(SymptomAddOn.interference))
              addOnSection(
                SymptomAddOn.interference,
                'How much did it get in the way?',
                InterferenceSelector(
                  value: _interference,
                  onChanged: (v) => setState(() => _interference = v),
                ),
              ),
            if (_open.contains(SymptomAddOn.impact))
              addOnSection(
                SymptomAddOn.impact,
                'What did it stop you doing, or make harder?',
                TextFormField(
                  key: const Key('symptom_impact_field'),
                  controller: _impactController,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText:
                        "e.g. Missed work, couldn't climb the stairs, "
                        'cancelled plans',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (_open.contains(SymptomAddOn.notes))
              addOnSection(
                SymptomAddOn.notes,
                "Anything else we didn't ask about?",
                TextFormField(
                  key: const Key('symptom_notes_field'),
                  controller: _notesController,
                  maxLines: 3,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'e.g. Worse after eating, lasted about 2 hours',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // ── Add if it helps ───────────────────────────────────────────
            if (offered.isNotEmpty || hidden.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: _AddIfItHelpsCard(
                  offered: offered,
                  hidden: hidden,
                  showNote: _noteVisible && hidden.isNotEmpty,
                  onAdd: _addOn,
                  onShowMore: () => setState(() => _showFolded = true),
                  onKeepShowing: profileId == null
                      ? null
                      : () => _keepAllShowing(profileId),
                  onWhyWeAsk: () => context.push(AppRoutes.settingsSources),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: !_submitting ? _save : null,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isEdit ? 'Save changes' : 'Add to profile'),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Add if it helps": optional details offered by name
// ---------------------------------------------------------------------------

/// Offers the add-ons not yet in the form. Says why in plain words (no
/// "Patient-Reported Outcomes" on the form); "Why we ask" leads to the
/// sources and credit screen. When unused options are folded away, shows
/// "N more" and, once per profile, a note saying what was tucked away.
class _AddIfItHelpsCard extends StatelessWidget {
  const _AddIfItHelpsCard({
    required this.offered,
    required this.hidden,
    required this.showNote,
    required this.onAdd,
    required this.onShowMore,
    required this.onKeepShowing,
    required this.onWhyWeAsk,
  });

  final List<SymptomAddOn> offered;
  final Set<SymptomAddOn> hidden;
  final bool showNote;
  final ValueChanged<SymptomAddOn> onAdd;
  final VoidCallback onShowMore;
  final VoidCallback? onKeepShowing;
  final VoidCallback onWhyWeAsk;

  String _noteText() {
    final names = [
      for (final a in SymptomAddOn.values)
        if (hidden.contains(a)) a.chipLabel,
    ];
    final one = names.length == 1;
    return 'We tucked away ${names.join(' and ')}. '
        "You haven't used ${one ? 'it' : 'them'} in your last "
        '${SymptomAddOns.quietAfter} entries. '
        "${one ? "It's" : "They're"} under \"${names.length} more\" "
        'whenever you want ${one ? 'it' : 'them'}.';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      key: const Key('add_if_it_helps'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.sunrisePeach.withAlpha(150),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.flareAmber.withAlpha(110)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 20,
                color: AppColors.flareAmber,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Add if it helps', style: tt.titleSmall)),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: onWhyWeAsk,
                child: const Text('Why we ask'),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const _SectionHint(
            text:
                'Tap any of these to add it to this entry. A line about how '
                'it affected your day tells your clinician more than a '
                'number.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in offered)
                ActionChip(
                  avatar: Icon(a.icon, size: 18, color: cs.onSurface),
                  label: Text(a.chipLabel),
                  backgroundColor: cs.surface,
                  side: BorderSide(color: AppColors.flareAmber.withAlpha(140)),
                  onPressed: () => onAdd(a),
                ),
              if (hidden.isNotEmpty)
                ActionChip(
                  avatar: Icon(
                    Icons.more_horiz,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                  label: Text('${hidden.length} more'),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: cs.outlineVariant),
                  onPressed: onShowMore,
                ),
            ],
          ),
          if (showNote) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility_off_outlined,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _SectionHint(text: _noteText())),
                  if (onKeepShowing != null)
                    TextButton(
                      onPressed: onKeepShowing,
                      child: const Text('Keep showing'),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WhenLine extends StatelessWidget {
  const _WhenLine({required this.text, required this.onChange});
  final String text;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.schedule, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
        TextButton(onPressed: onChange, child: const Text('Change')),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Severity selector: 10 numbered buttons
// ---------------------------------------------------------------------------

class _SeveritySelector extends StatelessWidget {
  const _SeveritySelector({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // One row: 10 used to wrap onto its own line on phones.
    return Row(
      key: const Key('severity_selector'),
      children: [
        for (var n = 1; n <= 10; n++) ...[
          if (n > 1) const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(n),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 40,
                decoration: BoxDecoration(
                  color: value == n ? cs.primary : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$n',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: value == n ? cs.onPrimary : cs.onSurface,
                    fontWeight: value == n
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Small helper widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _SectionHint extends StatelessWidget {
  const _SectionHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ScaleAnchors extends StatelessWidget {
  const _ScaleAnchors({required this.low, required this.high});
  final String low;
  final String high;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(low, style: style)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(high, style: style, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}

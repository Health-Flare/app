import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/weather_provider.dart';
import 'package:health_flare/features/quick_log/quick_log_parser.dart';
import 'package:health_flare/features/shared/widgets/move_entry_action.dart';
import 'package:health_flare/features/shared/widgets/weather_chip.dart';
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
  bool _submitting = false;
  bool _nameError = false;
  bool _severityError = false;

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
    } else {
      _nameController = TextEditingController(text: widget.prefillText ?? '');
      _notesController = TextEditingController();
      _impactController = TextEditingController();
      _locations = QuickLogParser.parseLocations(widget.prefillText ?? '');
      _loggedAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _nameController.dispose();
    _notesController.dispose();
    _impactController.dispose();
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
    final fmt = DateFormat('EEE d MMM yyyy, HH:mm');
    final activeProfile = ref.watch(activeProfileDataProvider);
    final isEdit = widget.entry != null;
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
            // New entries: show live weather when available.
            // Edit entries: show the snapshot captured at time of logging.
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

            // ── Symptom name ──────────────────────────────────────────────
            const _SectionLabel(label: 'Symptom name'),
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

            const _SectionLabel(label: 'Where'),
            const SizedBox(height: 8),
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

            const SizedBox(height: 24),

            // ── Intensity ─────────────────────────────────────────────────
            // Stored as `severity`; shown as intensity. Kept separate from
            // interference below: how bad a symptom is and how much it gets
            // in the way are different things (Dr Cat Hicks, Informed
            // Patient; PROMIS research). Our wording, not PROMIS items.
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

            const SizedBox(height: 24),

            // ── Interference ──────────────────────────────────────────────
            const _SectionLabel(label: 'How much did it get in the way?'),
            const SizedBox(height: 2),
            const _SectionHint(text: 'Optional. Tap again to clear.'),
            const SizedBox(height: 8),
            InterferenceSelector(
              value: _interference,
              onChanged: (v) => setState(() => _interference = v),
            ),

            const SizedBox(height: 24),

            // ── Impact in your own words ──────────────────────────────────
            const _SectionLabel(
              label: 'What did it stop you doing, or make harder?',
            ),
            const SizedBox(height: 2),
            const _SectionHint(
              text: 'Optional. A clinician can act on this more than a number.',
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('symptom_impact_field'),
              controller: _impactController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText:
                    "e.g. Missed work, couldn't climb the stairs, cancelled plans",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Date / time ───────────────────────────────────────────────
            const _SectionLabel(label: 'Date and time'),
            const SizedBox(height: 8),
            _DateTimeField(value: fmt.format(_loggedAt), onTap: _pickLoggedAt),

            const SizedBox(height: 24),

            // ── Anything else ─────────────────────────────────────────────
            // A closing open question catches what our fields missed.
            const _SectionLabel(
              label: "Anything else we didn't ask about? (optional)",
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('symptom_notes_field'),
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Worse after eating, lasted about 2 hours',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
// Severity selector: 10 numbered buttons
// ---------------------------------------------------------------------------

class _SeveritySelector extends StatelessWidget {
  const _SeveritySelector({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      key: const Key('severity_selector'),
      spacing: 8,
      runSpacing: 8,
      children: List.generate(10, (i) {
        final n = i + 1;
        final selected = value == n;
        return GestureDetector(
          onTap: () => onChanged(n),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selected ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$n',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? cs.onPrimary : cs.onSurface,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
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

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({required this.value, required this.onTap});
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

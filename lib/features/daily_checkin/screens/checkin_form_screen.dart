import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/weather_provider.dart';
import 'package:health_flare/features/shared/widgets/weather_chip.dart';
import 'package:health_flare/models/daily_checkin.dart';
import 'package:health_flare/models/weather_snapshot.dart';

/// Full-screen form to record or edit a daily check-in.
///
/// Pass [checkin] to open in edit mode; leave null to create a new check-in
/// for [date] (defaults to today).
class CheckInFormScreen extends ConsumerStatefulWidget {
  const CheckInFormScreen({super.key, this.checkin, this.date});

  final DailyCheckin? checkin;
  final DateTime? date;

  @override
  ConsumerState<CheckInFormScreen> createState() => _CheckInFormScreenState();
}

class _CheckInFormScreenState extends ConsumerState<CheckInFormScreen> {
  late int _wellbeing;
  String? _stressLevel;
  String? _cyclePhase;
  late TextEditingController _notesController;
  late DateTime _date;
  bool _submitting = false;

  // Captured once when the form opens (new check-in only).
  WeatherSnapshot? _capturedWeather;

  bool get _isEdit => widget.checkin != null;

  @override
  void initState() {
    super.initState();
    final c = widget.checkin;
    if (c != null) {
      _wellbeing = c.wellbeing;
      _stressLevel = c.stressLevel;
      _cyclePhase = c.cyclePhase;
      _notesController = TextEditingController(text: c.notes ?? '');
      _date = c.checkinDate;
    } else {
      _wellbeing = 0; // 0 = not yet selected
      _notesController = TextEditingController();
      _date = _dateOnly(widget.date ?? DateTime.now());
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = _dateOnly(picked));
  }

  Future<void> _save() async {
    if (_wellbeing == 0) return; // must select wellbeing

    setState(() => _submitting = true);
    final notifier = ref.read(dailyCheckinListProvider.notifier);
    final notes = _notesController.text.trim();

    try {
      if (_isEdit) {
        await notifier.update(
          widget.checkin!.copyWith(
            wellbeing: _wellbeing,
            stressLevel: _stressLevel,
            clearStress: _stressLevel == null,
            cyclePhase: _cyclePhase,
            clearCyclePhase: _cyclePhase == null,
            notes: notes.isEmpty ? null : notes,
            clearNotes: notes.isEmpty,
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
          checkinDate: _date,
          wellbeing: _wellbeing,
          stressLevel: _stressLevel,
          cyclePhase: _cyclePhase,
          notes: notes.isEmpty ? null : notes,
          weatherSnapshot: _capturedWeather,
        );
      }
      if (!mounted) return;
      context.pop();
    } on StateError catch (e) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final showCycle = activeProfile?.cycleTrackingEnabled ?? false;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM yyyy');

    // Watch weather for new check-ins — capture when available.
    final weatherAsync = _isEdit ? null : ref.watch(currentWeatherProvider);
    weatherAsync?.whenData((w) {
      if (w != null && _capturedWeather == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _capturedWeather = w);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit check-in' : 'Daily check-in')),
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

            // Weather chip (new check-ins show live weather; edit shows saved snapshot)
            if ((_isEdit
                    ? widget.checkin?.weatherSnapshot
                    : _capturedWeather) !=
                null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WeatherChip(
                  snapshot: _isEdit
                      ? widget.checkin?.weatherSnapshot
                      : _capturedWeather,
                ),
              ),

            // Date picker (only shown when creating from history)
            if (!_isEdit)
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(fmt.format(_date)),
                ),
              ),
            if (!_isEdit) const SizedBox(height: 16),

            // Wellbeing
            Text(
              'How is ${activeProfile?.name ?? 'this person'} doing overall today?',
              style: tt.titleSmall?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            _WellbeingPicker(
              value: _wellbeing,
              onChanged: (v) => setState(() => _wellbeing = v),
            ),
            const SizedBox(height: 20),

            // Stress level
            Text(
              'Stress level (optional)',
              style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            _StressPicker(
              value: _stressLevel,
              onChanged: (v) => setState(() => _stressLevel = v),
            ),
            const SizedBox(height: 20),

            // Cycle phase — only when enabled
            if (showCycle) ...[
              Text(
                'Cycle phase (optional)',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              _CyclePhasePicker(
                value: _cyclePhase,
                onChanged: (v) => setState(() => _cyclePhase = v),
              ),
              const SizedBox(height: 20),
            ],

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: (_submitting || _wellbeing == 0) ? null : _save,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEdit ? 'Save changes' : 'Save check-in'),
          ),
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

// ---------------------------------------------------------------------------
// Wellbeing picker (1–10)
// ---------------------------------------------------------------------------

class _WellbeingPicker extends StatelessWidget {
  const _WellbeingPicker({required this.value, required this.onChanged});

  final int value; // 0 = none selected
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: List.generate(10, (i) {
        final v = i + 1;
        final selected = value == v;
        return ChoiceChip(
          label: Text('$v'),
          selected: selected,
          onSelected: (_) => onChanged(selected ? 0 : v),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Stress picker
// ---------------------------------------------------------------------------

class _StressPicker extends StatelessWidget {
  const _StressPicker({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  static const _options = [
    ('low', 'Low'),
    ('medium', 'Medium'),
    ('high', 'High'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _options.map(((String, String) opt) {
        final (key, label) = opt;
        final selected = value == key;
        return FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onChanged(selected ? null : key),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Cycle phase picker
// ---------------------------------------------------------------------------

class _CyclePhasePicker extends StatelessWidget {
  const _CyclePhasePicker({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  static const _options = [
    ('period', 'Period'),
    ('follicular', 'Follicular'),
    ('ovulation', 'Ovulation'),
    ('luteal', 'Luteal'),
    ('not_sure', 'Not sure'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _options.map(((String, String) opt) {
        final (key, label) = opt;
        final selected = value == key;
        return FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onChanged(selected ? null : key),
        );
      }).toList(),
    );
  }
}

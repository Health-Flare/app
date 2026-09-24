import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/activity_entry_provider.dart';
import 'package:health_flare/core/providers/appointment_provider.dart';
import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/daily_checkin_provider.dart';
import 'package:health_flare/core/providers/dose_log_provider.dart';
import 'package:health_flare/core/providers/elimination_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/core/providers/fluid_intake_provider.dart';
import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/meal_entry_provider.dart';
import 'package:health_flare/core/providers/medication_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/providers/sleep_provider.dart';
import 'package:health_flare/core/providers/symptom_entry_provider.dart';
import 'package:health_flare/core/providers/vital_entry_provider.dart';
import 'package:health_flare/core/providers/weather_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/features/illness/screens/illness_screen.dart';
import 'package:health_flare/features/quick_log/quick_log_classifier.dart';
import 'package:health_flare/features/quick_log/quick_log_parser.dart';
import 'package:health_flare/features/quick_log/quick_log_text.dart';
import 'package:health_flare/features/shared/widgets/weather_chip.dart';
import 'package:health_flare/features/sleep/screens/sleep_entry_screen.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/models/medication.dart';
import 'package:health_flare/models/user_condition.dart';
import 'package:health_flare/models/weather_snapshot.dart';

/// Opens the quick-log bottom sheet. Call from any screen that has a FAB.
Future<void> showQuickLogSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _QuickLogSheet(),
  );
}

class _QuickLogSheet extends ConsumerStatefulWidget {
  const _QuickLogSheet();

  @override
  ConsumerState<_QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends ConsumerState<_QuickLogSheet> {
  final _textController = TextEditingController();
  late DateTime _openedAt;
  late DateTime _timestamp;
  bool _timestampManual = false;
  QuickLogEntryType? _classification;
  QuickLogEntryType? _typeOverride;
  bool _saving = false;

  static final _fmt = DateFormat('EEE, d MMM · HH:mm');

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
    _timestamp = _openedAt;
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return;
    if (_textController.text.trim().isEmpty) {
      setState(() {
        _classification = null;
        _typeOverride = null;
        if (!_timestampManual) _timestamp = _openedAt;
      });
      return;
    }
    final next = _classify(_textController.text);
    setState(() {
      _classification = next;
      _typeOverride = null;
      if (!_timestampManual) {
        _timestamp = _resolvedTimestamp(next);
      }
    });
  }

  QuickLogEntryType? _classify(String text) {
    final profile = ref.read(activeProfileDataProvider);
    final medications = ref.read(activeProfileMedicationsProvider);
    return QuickLogClassifier.classify(
      text,
      conditionCatalog: ref.read(conditionCatalogProvider),
      trackedConditions: ref.read(userConditionListProvider),
      symptomCatalog: ref.read(symptomCatalogProvider),
      trackedSymptoms: ref.read(userSymptomListProvider),
      loggedSymptomNames: ref.read(recentSymptomNamesProvider),
      medicationNames: [for (final med in medications) med.name],
      cycleTrackingEnabled: profile?.cycleTrackingEnabled ?? false,
      bowelTrackingEnabled: profile?.bowelTrackingEnabled ?? false,
    );
  }

  DateTime _resolvedTimestamp(QuickLogEntryType? type) {
    final parsed = QuickLogParser.parseRelativeTimestamp(
      _textController.text,
      _openedAt,
      preserveLastNight: type == QuickLogEntryType.sleep,
    );
    return parsed ?? _openedAt;
  }

  String get _text => _textController.text.trim();
  bool get _hasText => _text.isNotEmpty;
  QuickLogEntryType? get _effectiveType => _typeOverride ?? _classification;
  bool get _canSave => _hasText && !_saving;

  WeatherSnapshot? get _weather =>
      ref.read(currentWeatherProvider).asData?.value;

  bool _canQuickAdd(QuickLogEntryType? type) {
    switch (type) {
      case null:
      case QuickLogEntryType.journal:
        return false;
      case QuickLogEntryType.vital:
        return QuickLogParser.parseVitals(_text).isNotEmpty;
      case QuickLogEntryType.medication:
        if (QuickLogParser.isDoseChange(_text) &&
            QuickLogParser.parseDoseStatus(_text) == null) {
          return false;
        }
        return _matchedMedication() != null;
      case QuickLogEntryType.sleep:
        return QuickLogParser.parseSleepTimeRange(_text, _timestamp) != null ||
            QuickLogParser.parseSleepDuration(_text) != null;
      case QuickLogEntryType.condition:
        return _matchedCondition();
      case QuickLogEntryType.hydration:
        return QuickLogParser.parseFluid(_text) != null;
      case QuickLogEntryType.bowel:
        final profile = ref.read(activeProfileDataProvider);
        return profile?.bowelTrackingEnabled == true &&
            QuickLogParser.parseElimination(_text) != null;
      case QuickLogEntryType.cycle:
        final profile = ref.read(activeProfileDataProvider);
        return profile?.cycleTrackingEnabled == true &&
            QuickLogParser.parseCyclePhase(_text) != null;
      case QuickLogEntryType.flare:
        final intent = QuickLogParser.parseFlareIntent(_text);
        if (intent == FlareIntent.start) return true;
        if (intent == FlareIntent.end) {
          return ref.read(activeFlareProvider) != null;
        }
        return false;
      case QuickLogEntryType.meal:
      case QuickLogEntryType.symptom:
      case QuickLogEntryType.doctorVisit:
      case QuickLogEntryType.activity:
      case QuickLogEntryType.mood:
        return true;
    }
  }

  Medication? _matchedMedication() => QuickLogParser.matchMedication(
    _text,
    ref.read(activeProfileMedicationsProvider),
  );

  UserCondition? _trackedForMatchedCondition() {
    final condition = QuickLogParser.matchCondition(
      _text,
      ref.read(conditionCatalogProvider),
      ref.read(userConditionListProvider),
    );
    if (condition == null) return null;
    return ref
        .read(userConditionListProvider)
        .where((item) => item.conditionId == condition.id)
        .firstOrNull;
  }

  /// Catalogue condition, or null when the name is not in the catalogue.
  bool _matchedCondition() =>
      QuickLogParser.matchCondition(
        _text,
        ref.read(conditionCatalogProvider),
        ref.read(userConditionListProvider),
      ) !=
      null;

  // ── Save ────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      final profileId = ref.read(activeProfileProvider);
      if (profileId == null) return;
      final type = _effectiveType;
      if (_canQuickAdd(type)) {
        await _quickSave(profileId, type!);
      } else {
        await _saveJournal(profileId);
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _quickSave(int profileId, QuickLogEntryType type) async {
    switch (type) {
      case QuickLogEntryType.meal:
        await ref
            .read(mealEntryListProvider.notifier)
            .add(
              profileId: profileId,
              description: _text,
              hasReaction: QuickLogParser.hasMealReaction(_text),
              loggedAt: _timestamp,
              weatherSnapshot: _weather,
            );
      case QuickLogEntryType.symptom:
        await _saveSymptom(profileId);
      case QuickLogEntryType.doctorVisit:
        await ref
            .read(appointmentListProvider.notifier)
            .add(profileId: profileId, title: _text, scheduledAt: _timestamp);
      case QuickLogEntryType.activity:
        final parsed = QuickLogParser.parseActivity(_text);
        await ref
            .read(activityEntryListProvider.notifier)
            .add(
              profileId: profileId,
              description: _text,
              activityType: parsed.type,
              effortLevel: parsed.effortLevel,
              durationMinutes: parsed.durationMinutes,
              loggedAt: _timestamp,
              weatherSnapshot: _weather,
            );
      case QuickLogEntryType.vital:
        for (final vital in QuickLogParser.parseVitals(_text)) {
          await ref
              .read(vitalEntryListProvider.notifier)
              .add(
                profileId: profileId,
                vitalType: vital.vitalType,
                value: vital.value,
                value2: vital.value2,
                unit: vital.unit,
                loggedAt: _timestamp,
                notes: _text,
              );
        }
      case QuickLogEntryType.medication:
        final medication = _matchedMedication();
        if (medication == null) {
          await _saveJournal(profileId);
          return;
        }
        await ref
            .read(doseLogListProvider.notifier)
            .add(
              profileId: profileId,
              medicationIsarId: medication.id,
              loggedAt: _timestamp,
              amount: medication.doseAmount,
              unit: medication.doseUnit,
              status: QuickLogParser.parseDoseStatus(_text) ?? 'taken',
              notes: _text,
            );
      case QuickLogEntryType.sleep:
        final nap = QuickLogParser.isNap(_text) ? true : null;
        final range = QuickLogParser.parseSleepTimeRange(_text, _timestamp);
        if (range != null) {
          await ref
              .read(sleepEntryListProvider.notifier)
              .add(
                profileId: profileId,
                bedtime: range.$1,
                wakeTime: range.$2,
                notes: _text,
                isNap: nap,
              );
          return;
        }
        final duration = QuickLogParser.parseSleepDuration(_text);
        if (duration == null) {
          await _saveJournal(profileId);
          return;
        }
        await ref
            .read(sleepEntryListProvider.notifier)
            .add(
              profileId: profileId,
              bedtime: _timestamp.subtract(duration),
              wakeTime: _timestamp,
              notes: _text,
              isNap: nap,
            );
      case QuickLogEntryType.condition:
        await _saveCondition(profileId);
      case QuickLogEntryType.journal:
        await _saveJournal(profileId);
      case QuickLogEntryType.flare:
        await _saveFlare(profileId);
      case QuickLogEntryType.mood:
        await _upsertCheckin(
          profileId,
          wellbeing: QuickLogParser.parseExplicitWellbeing(_text),
          stressLevel: QuickLogParser.parseStress(_text),
        );
      case QuickLogEntryType.cycle:
        await _upsertCheckin(
          profileId,
          cyclePhase: QuickLogParser.parseCyclePhase(_text),
          stressLevel: QuickLogParser.parseStress(_text),
          wellbeing: QuickLogParser.parseExplicitWellbeing(_text),
        );
        if (QuickLogText.mentionsAny(_text, const ['cramp', 'pain', 'ache'])) {
          final matched = QuickLogParser.matchSymptom(
            _text,
            ref.read(symptomCatalogProvider),
            ref.read(userSymptomListProvider),
            loggedNames: ref.read(recentSymptomNamesProvider),
          );
          final name =
              matched?.name ??
              (QuickLogText.mentions(_text, 'cramp') ? 'Cramps' : 'Pain');
          await _saveSymptom(profileId, name: name);
        }
      case QuickLogEntryType.hydration:
        final fluid = QuickLogParser.parseFluid(_text);
        if (fluid == null) {
          await _saveJournal(profileId);
          return;
        }
        await ref
            .read(fluidIntakeListProvider.notifier)
            .add(
              profileId: profileId,
              loggedAt: _timestamp,
              volumeMl: fluid.volumeMl,
              drinkType: fluid.drinkType,
              notes: _text,
            );
      case QuickLogEntryType.bowel:
        final parsed = QuickLogParser.parseElimination(_text);
        if (parsed == null) {
          await _saveJournal(profileId);
          return;
        }
        final copies = parsed.count <= 0 ? 1 : parsed.count;
        for (var i = 0; i < copies; i++) {
          await ref
              .read(eliminationListProvider.notifier)
              .add(
                profileId: profileId,
                loggedAt: _timestamp,
                kind: parsed.kind,
                bristolType: parsed.bristolType,
                count: parsed.count <= 0 ? 0 : 1,
                blood: parsed.blood,
                urgency: parsed.urgency,
                notes: _text,
              );
        }
    }
  }

  Future<void> _saveSymptom(
    int profileId, {
    String? name,
    int? flareIsarId,
  }) async {
    final matched = QuickLogParser.matchSymptom(
      _text,
      ref.read(symptomCatalogProvider),
      ref.read(userSymptomListProvider),
      loggedNames: ref.read(recentSymptomNamesProvider),
    );
    final resolvedName = name ?? matched?.name ?? _text;
    await ref
        .read(symptomEntryListProvider.notifier)
        .add(
          profileId: profileId,
          name: resolvedName,
          severity: QuickLogParser.parseSeverity(_text) ?? 5,
          locations: QuickLogParser.parseLocations(_text),
          loggedAt: _timestamp,
          notes: matched != null || name != null ? _text : null,
          flareIsarId: flareIsarId,
          weatherSnapshot: _weather,
        );
  }

  Future<void> _saveCondition(int profileId) async {
    final trackedConditions = ref.read(userConditionListProvider);
    final condition = QuickLogParser.matchCondition(
      _text,
      ref.read(conditionCatalogProvider),
      trackedConditions,
    );
    if (condition == null) {
      await _saveJournal(profileId);
      return;
    }
    final existing = trackedConditions
        .where((item) => item.conditionId == condition.id)
        .firstOrNull;
    final parsedStatus = QuickLogParser.parseConditionStatus(_text);

    if (existing == null) {
      await ref
          .read(userConditionListProvider.notifier)
          .add(
            conditionId: condition.id,
            conditionName: condition.name,
            diagnosedAt: QuickLogParser.mentionsNewDiagnosis(_text)
                ? _timestamp
                : null,
            status: parsedStatus ?? ConditionStatus.active,
          );
    } else if (parsedStatus != null && parsedStatus != existing.status) {
      await ref
          .read(userConditionListProvider.notifier)
          .update(
            existing.copyWith(
              status: parsedStatus,
              statusHistory: [
                ...existing.statusHistory,
                ConditionStatusEvent(
                  eventType: parsedStatus == ConditionStatus.inRecovery
                      ? 'recovery'
                      : 'relapse',
                  date: _timestamp,
                ),
              ],
            ),
          );
    }
  }

  Future<void> _saveFlare(int profileId) async {
    final intent = QuickLogParser.parseFlareIntent(_text);
    final active = ref.read(activeFlareProvider);
    final severity = QuickLogParser.parseSeverity(_text);
    if (intent == FlareIntent.end) {
      if (active == null) {
        await _saveJournal(profileId);
        return;
      }
      await ref
          .read(flareListProvider.notifier)
          .update(
            active.copyWith(
              endedAt: _timestamp,
              peakSeverity: severity,
              notes: _appendNotes(active.notes, _text),
              updatedAt: DateTime.now(),
            ),
          );
      return;
    }
    if (intent == FlareIntent.start && active != null) {
      await _saveSymptom(profileId, flareIsarId: active.id);
      return;
    }
    final tracked = _trackedForMatchedCondition();
    await ref
        .read(flareListProvider.notifier)
        .add(
          profileId: profileId,
          startedAt: _timestamp,
          conditionIsarIds: tracked == null ? const [] : [tracked.id],
          initialSeverity: severity,
          notes: _text,
        );
  }

  Future<void> _upsertCheckin(
    int profileId, {
    int? wellbeing,
    String? stressLevel,
    String? cyclePhase,
  }) async {
    final notifier = ref.read(dailyCheckinListProvider.notifier);
    final existing = notifier.checkinForDate(profileId, _timestamp);
    if (existing == null) {
      await notifier.add(
        profileId: profileId,
        checkinDate: _timestamp,
        wellbeing: wellbeing,
        stressLevel: stressLevel,
        cyclePhase: cyclePhase,
        notes: _text,
        weatherSnapshot: _weather,
      );
      return;
    }
    await notifier.update(
      existing.copyWith(
        wellbeing: wellbeing,
        stressLevel: stressLevel,
        cyclePhase: cyclePhase,
        notes: _appendNotes(existing.notes, _text),
        updatedAt: DateTime.now(),
        weatherSnapshot: existing.weatherSnapshot ?? _weather,
      ),
    );
  }

  String _appendNotes(String? existing, String addition) {
    if (existing == null || existing.trim().isEmpty) return addition;
    if (existing.contains(addition)) return existing;
    return '$existing\n$addition';
  }

  Future<void> _saveJournal(int profileId) {
    return ref
        .read(journalEntryListProvider.notifier)
        .add(
          profileId: profileId,
          createdAt: _timestamp,
          firstSnapshot: JournalSnapshot(body: _text, savedAt: DateTime.now()),
          weatherSnapshot: _weather,
        );
  }

  // ── Add details ─────────────────────────────────────────────────────────

  void _addDetails() {
    final type = _effectiveType;
    Navigator.of(context).pop();
    switch (type) {
      case QuickLogEntryType.meal:
        context.push(AppRoutes.mealsNew, extra: _text);
      case QuickLogEntryType.symptom:
        context.push(AppRoutes.symptomsNew, extra: _text);
      case QuickLogEntryType.doctorVisit:
        context.push(AppRoutes.appointmentNew, extra: {'title': _text});
      case QuickLogEntryType.activity:
        context.push(AppRoutes.activityNew, extra: _text);
      case QuickLogEntryType.vital:
        context.push(AppRoutes.vitalsNew, extra: _text);
      case QuickLogEntryType.sleep:
        final range = QuickLogParser.parseSleepTimeRange(_text, _timestamp);
        final duration = QuickLogParser.parseSleepDuration(_text);
        context.push(
          AppRoutes.sleepNew,
          extra: SleepEntryPrefill(
            notes: _text,
            bedtime:
                range?.$1 ??
                (duration == null ? null : _timestamp.subtract(duration)),
            wakeTime: range?.$2 ?? (duration == null ? null : _timestamp),
            isNap: QuickLogParser.isNap(_text) ? true : null,
          ),
        );
      case QuickLogEntryType.medication:
        final medication = _matchedMedication();
        if (medication != null) {
          context.push(
            AppRoutes.medicationsDoseNew(medication.id),
            extra: {
              'med': medication,
              'notes': _text,
              'status': QuickLogParser.parseDoseStatus(_text) ?? 'taken',
            },
          );
        } else {
          context.push(AppRoutes.medicationsNew, extra: _text);
        }
      case QuickLogEntryType.condition:
        final matched = QuickLogParser.matchCondition(
          _text,
          ref.read(conditionCatalogProvider),
          ref.read(userConditionListProvider),
        );
        context.push(
          AppRoutes.illness,
          extra: IllnessScreenPrefill(query: _text, conditionId: matched?.id),
        );
      case QuickLogEntryType.flare:
        context.push(AppRoutes.flareNew, extra: _text);
      case QuickLogEntryType.mood:
      case QuickLogEntryType.cycle:
        context.push(AppRoutes.checkinNew, extra: _text);
      case QuickLogEntryType.hydration:
      case QuickLogEntryType.bowel:
      case QuickLogEntryType.journal:
      case null:
        context.push(AppRoutes.journalNew, extra: _text);
    }
  }

  // ── Timestamp picker ────────────────────────────────────────────────────

  Future<void> _pickTimestamp() async {
    final now = DateTime.now();
    final horizon = now.add(const Duration(days: 730));
    final lastDate = _timestamp.isAfter(horizon) ? _timestamp : horizon;
    var initial = _timestamp;
    if (initial.isAfter(lastDate)) initial = lastDate;
    if (initial.isBefore(DateTime(2000))) initial = DateTime(2000);
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: lastDate,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (!mounted) return;
    setState(() {
      _timestampManual = true;
      _timestamp = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _timestamp.hour,
        time?.minute ?? _timestamp.minute,
      );
    });
  }

  List<QuickLogEntryType> get _typeChoices {
    final profile = ref.read(activeProfileDataProvider);
    return [
      for (final type in QuickLogEntryType.values)
        if (type != QuickLogEntryType.cycle ||
            profile?.cycleTrackingEnabled == true)
          if (type != QuickLogEntryType.bowel ||
              profile?.bowelTrackingEnabled == true)
            type,
    ];
  }

  // ── Dismiss guard ───────────────────────────────────────────────────────

  Future<void> _handlePop() async {
    if (!_hasText) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave without saving?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard entry'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final profile = ref.watch(activeProfileDataProvider);
    final profileName = profile?.name ?? '';
    final kbHeight = MediaQuery.of(context).viewInsets.bottom;
    final weather = ref.watch(currentWeatherProvider).asData?.value;
    final type = _effectiveType;
    final quickAdd = _canQuickAdd(type);

    return PopScope(
      canPop: !_hasText,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handlePop();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: kbHeight),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                child: Row(
                  children: [
                    Text(
                      'Logging for $profileName',
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _handlePop,
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _textController,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'What would you like to log?',
                    border: InputBorder.none,
                  ),
                  style: tt.bodyLarge,
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _pickTimestamp,
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _fmt.format(_timestamp),
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (weather != null) ...[
                      const SizedBox(width: 12),
                      WeatherChip(snapshot: weather),
                    ],
                  ],
                ),
              ),
              if (type != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      PopupMenuButton<QuickLogEntryType>(
                        tooltip: 'Change entry type',
                        onSelected: (picked) =>
                            setState(() => _typeOverride = picked),
                        itemBuilder: (context) => [
                          for (final choice in _typeChoices)
                            PopupMenuItem(
                              value: choice,
                              child: Text(_chipLabel(choice)),
                            ),
                        ],
                        child: Semantics(
                          liveRegion: true,
                          label: 'Classified as ${_chipLabel(type)}',
                          child: Chip(
                            label: Text(_chipLabel(type)),
                            avatar: Icon(
                              _chipIcon(type),
                              size: 16,
                              color: cs.primary,
                            ),
                            backgroundColor: cs.primaryContainer,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _addDetails,
                        child: const Text('Add details'),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: FilledButton(
                  onPressed: _canSave ? _save : null,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Semantics(
                          liveRegion: true,
                          child: Text(_primaryButtonLabel(type, quickAdd)),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _chipLabel(QuickLogEntryType type) => switch (type) {
  QuickLogEntryType.meal => 'Meal',
  QuickLogEntryType.symptom => 'Symptom',
  QuickLogEntryType.vital => 'Vital',
  QuickLogEntryType.medication => 'Medication',
  QuickLogEntryType.doctorVisit => 'Doctor Visit',
  QuickLogEntryType.activity => 'Activity',
  QuickLogEntryType.sleep => 'Sleep',
  QuickLogEntryType.condition => 'Condition',
  QuickLogEntryType.journal => 'Journal',
  QuickLogEntryType.flare => 'Flare',
  QuickLogEntryType.mood => 'Mood',
  QuickLogEntryType.cycle => 'Cycle',
  QuickLogEntryType.hydration => 'Fluids',
  QuickLogEntryType.bowel => 'Bowel',
};

IconData _chipIcon(QuickLogEntryType type) => switch (type) {
  QuickLogEntryType.meal => Icons.restaurant_outlined,
  QuickLogEntryType.symptom => Icons.healing_outlined,
  QuickLogEntryType.vital => Icons.monitor_heart_outlined,
  QuickLogEntryType.medication => Icons.medication_outlined,
  QuickLogEntryType.doctorVisit => Icons.local_hospital_outlined,
  QuickLogEntryType.activity => Icons.directions_walk_outlined,
  QuickLogEntryType.sleep => Icons.bedtime_outlined,
  QuickLogEntryType.condition => Icons.assignment_late_outlined,
  QuickLogEntryType.journal => Icons.book_outlined,
  QuickLogEntryType.flare => Icons.local_fire_department_outlined,
  QuickLogEntryType.mood => Icons.mood_outlined,
  QuickLogEntryType.cycle => Icons.water_drop_outlined,
  QuickLogEntryType.hydration => Icons.local_drink_outlined,
  QuickLogEntryType.bowel => Icons.health_and_safety_outlined,
};

/// Names the record that will actually be saved. A detected type that cannot
/// be persisted (no matching medication, no vital reading, and so on) uses
/// "Add to Journal" so the button, the chip, and the database agree.
String _primaryButtonLabel(QuickLogEntryType? type, bool canQuickAdd) {
  if (type == null || type == QuickLogEntryType.journal || !canQuickAdd) {
    return 'Add to Journal';
  }
  return 'Quick Add: ${_chipLabel(type)}';
}

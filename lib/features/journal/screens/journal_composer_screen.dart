import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/features/journal/widgets/journal_enrichment_bar.dart';

/// Full-screen journal entry composer — used for both creating a new entry
/// and editing an existing one.
///
/// ## Autosave behaviour
/// Content is saved automatically 800 ms after the user stops typing.
/// There is no manual Save button. The AppBar title shows when the entry
/// was last saved so the user always knows their work is safe.
///
/// ## Undo history
/// Every autosave appends a [JournalSnapshot]. The undo button in the
/// AppBar steps back through snapshots:
/// - While the entry was created today, snapshots are labelled with times
///   (giving ~5-minute granularity in practice).
/// - For older entries, snapshots are labelled by date.
///
/// [entryId] null = create mode; non-null = edit mode.
class JournalComposerScreen extends ConsumerStatefulWidget {
  const JournalComposerScreen({super.key, this.entryId});

  final int? entryId;

  @override
  ConsumerState<JournalComposerScreen> createState() =>
      _JournalComposerScreenState();
}

class _JournalComposerScreenState
    extends ConsumerState<JournalComposerScreen> {
  final _bodyController = TextEditingController();
  final _titleController = TextEditingController();
  bool _titleVisible = false;

  // The id of the in-progress entry. Null until first autosave in create mode.
  int? _entryId;

  // Autosave debounce timer.
  Timer? _debounce;

  // Ticks every minute to refresh the "Saved X min ago" label.
  Timer? _clockTimer;

  // Tracks content at last save to detect meaningful changes.
  String _lastSavedBody = '';
  String _lastSavedTitle = '';

  // Time of last save — shown in the AppBar title.
  DateTime? _lastSavedAt;

  static const _autosaveDelay = Duration(milliseconds: 800);

  static const _prompts = [
    'How are you feeling today?',
    'What\'s been on your mind?',
    'Anything you want to remember?',
    'What do you want to tell your doctor?',
    'What helped today? What didn\'t?',
  ];

  static final _timeFormat = DateFormat('h:mm a');
  static final _dateFormat = DateFormat('d MMM');

  @override
  void initState() {
    super.initState();

    if (widget.entryId != null) {
      _entryId = widget.entryId;
      final entry =
          ref.read(journalEntryListProvider.notifier).byId(_entryId!);
      if (entry != null) {
        _bodyController.text = entry.body;
        _lastSavedBody = entry.body;
        _lastSavedAt = entry.lastSavedAt;
        if (entry.title != null && entry.title!.trim().isNotEmpty) {
          _titleController.text = entry.title!;
          _lastSavedTitle = entry.title!;
          _titleVisible = true;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(journalComposerStateProvider.notifier).state =
              JournalComposerState(
            mood: entry.moodValue,
            energyLevel: entry.energyLevel,
          );
        });
      }
    }

    _bodyController.addListener(_onTextChanged);
    _titleController.addListener(_onTextChanged);

    // Refresh the saved-time label every minute without user interaction.
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _clockTimer?.cancel();
    _bodyController.removeListener(_onTextChanged);
    _titleController.removeListener(_onTextChanged);
    _bodyController.dispose();
    _titleController.dispose();
    ref.read(journalComposerStateProvider.notifier).state =
        JournalComposerState.empty;
    super.dispose();
  }

  bool get _hasContent => _bodyController.text.trim().isNotEmpty;

  bool get _contentChanged =>
      _bodyController.text != _lastSavedBody ||
      _titleController.text != _lastSavedTitle;

  void _onTextChanged() {
    _debounce?.cancel();
    if (_hasContent && _contentChanged) {
      _debounce = Timer(_autosaveDelay, _autosave);
    }
    if (mounted) setState(() {});
  }

  Future<void> _autosave() async {
    if (!_hasContent) return;

    final profileId = ref.read(activeProfileProvider);
    if (profileId == null) return;

    final bodyText = _bodyController.text;
    final titleText = _titleController.text.trim();
    final now = DateTime.now();

    final snapshot = JournalSnapshot(
      body: bodyText,
      title: titleText.isNotEmpty ? titleText : null,
      savedAt: now,
    );

    if (_entryId == null) {
      // First save in create mode — Isar assigns the id.
      _entryId = await ref.read(journalEntryListProvider.notifier).add(
            profileId: profileId,
            createdAt: now,
            firstSnapshot: snapshot,
            mood: ref.read(journalComposerStateProvider).mood?.index,
            energyLevel: ref.read(journalComposerStateProvider).energyLevel,
          );
    } else {
      await ref
          .read(journalEntryListProvider.notifier)
          .appendSnapshot(_entryId!, snapshot);
    }

    _lastSavedBody = bodyText;
    _lastSavedTitle = titleText;
    if (mounted) setState(() => _lastSavedAt = now);
  }

  Future<void> _undo() async {
    if (_entryId == null) return;
    final entry = ref.read(journalEntryListProvider.notifier).byId(_entryId!);
    if (entry == null || !entry.canUndo) return;

    await ref.read(journalEntryListProvider.notifier).undo(_entryId!);

    // After the Isar write, the watchLazy fires and _reload() updates state.
    // Read the freshly-loaded entry from the in-memory cache.
    final restored =
        ref.read(journalEntryListProvider.notifier).byId(_entryId!);
    if (restored == null) return;

    // Pause listener while restoring to avoid triggering another autosave.
    _bodyController.removeListener(_onTextChanged);
    _titleController.removeListener(_onTextChanged);

    _bodyController.text = restored.body;
    _titleController.text = restored.title ?? '';
    _lastSavedBody = restored.body;
    _lastSavedTitle = restored.title ?? '';

    setState(() => _lastSavedAt = restored.lastSavedAt);

    _bodyController.addListener(_onTextChanged);
    _titleController.addListener(_onTextChanged);
  }

  String _savedLabel() {
    final saved = _lastSavedAt;
    if (saved == null) return '';
    final diff = DateTime.now().difference(saved);
    if (diff.inSeconds < 10) return 'Saved just now';
    if (diff.inMinutes < 1) return 'Saved less than a minute ago';
    if (diff.inMinutes == 1) return 'Saved 1 minute ago';
    if (diff.inMinutes < 60) return 'Saved ${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return 'Saved at ${_timeFormat.format(saved)}';
    return 'Saved ${_dateFormat.format(saved)}';
  }

  String _undoLabel(JournalEntry entry) {
    if (!entry.canUndo) return 'Nothing to undo';
    final previous = entry.snapshots[entry.snapshots.length - 2];
    final now = DateTime.now();
    if (_isSameDay(previous.savedAt, now)) {
      return 'Undo to ${_timeFormat.format(previous.savedAt)}';
    }
    return 'Undo to ${_dateFormat.format(previous.savedAt)}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _hintText() => _prompts[DateTime.now().day % _prompts.length];

  void _persistEnrichment(JournalComposerState composerState) {
    if (_entryId == null) {
      if (_hasContent) {
        _debounce?.cancel();
        _autosave();
      }
      return;
    }

    final entry = ref.read(journalEntryListProvider.notifier).byId(_entryId!);
    if (entry == null) return;

    final updated = entry.withEnrichment(
      mood: composerState.mood?.index,
      clearMood: composerState.mood == null,
      energyLevel: composerState.energyLevel,
      clearEnergyLevel: composerState.energyLevel == null,
    );
    ref.read(journalEntryListProvider.notifier).update(updated);
    // update() is async but fire-and-forget is fine here — the watchLazy
    // subscription will reload state once the write completes.
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final composerState = ref.watch(journalComposerStateProvider);

    final liveEntry = _entryId != null
        ? ref.watch(journalEntryListProvider.notifier).byId(_entryId!)
        : null;
    final canUndo = liveEntry?.canUndo ?? false;
    final undoLabel = liveEntry != null ? _undoLabel(liveEntry) : '';

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          // AppBar title shows saved state — the only feedback the user needs.
          title: _lastSavedAt != null
              ? Text(
                  _savedLabel(),
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                )
              : _hasContent
                  ? Text(
                      'Saving…',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    )
                  : null,
          actions: [
            if (canUndo)
              Tooltip(
                message: undoLabel,
                child: IconButton(
                  icon: const Icon(Icons.undo_rounded),
                  onPressed: _undo,
                ),
              ),
            // Leave space for the shell overlay profile avatar.
            const SizedBox(width: 56),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_titleVisible)
                      TextField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        style: tt.titleMedium?.copyWith(color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Title (optional)',
                          border: InputBorder.none,
                          hintStyle: tt.titleMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => setState(() => _titleVisible = true),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '+ Add title',
                            style: tt.labelMedium?.copyWith(color: cs.primary),
                          ),
                        ),
                      ),
                    TextField(
                      controller: _bodyController,
                      autofocus: true,
                      maxLines: null,
                      minLines: 12,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
                      style: tt.bodyLarge?.copyWith(color: cs.onSurface),
                      decoration: InputDecoration(
                        hintText: _hintText(),
                        border: InputBorder.none,
                        hintStyle: tt.bodyLarge
                            ?.copyWith(color: cs.onSurfaceVariant),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            JournalEnrichmentBar(
              mood: composerState.mood,
              energyLevel: composerState.energyLevel,
              onMoodChanged: (mood) {
                final updated = composerState.copyWith(
                  mood: mood,
                  clearMood: mood == null,
                );
                ref.read(journalComposerStateProvider.notifier).state = updated;
                _persistEnrichment(updated);
              },
              onEnergyChanged: (level) {
                final updated = composerState.copyWith(
                  energyLevel: level,
                  clearEnergy: level == null,
                );
                ref.read(journalComposerStateProvider.notifier).state = updated;
                _persistEnrichment(updated);
              },
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}

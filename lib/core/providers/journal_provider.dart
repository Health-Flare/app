import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:health_flare/data/models/journal_entry_isar.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Journal entry list — all entries across all profiles
// ---------------------------------------------------------------------------

/// Holds all journal entries for all profiles.
///
/// Uses a synchronous [Notifier] (state type [List<JournalEntry>]) so that
/// all existing UI consumers continue to work unchanged. Data is loaded
/// asynchronously in [_init] and the [watchLazy] subscription keeps the
/// list up to date whenever Isar writes occur.
///
/// Per-profile filtering is done in [activeProfileJournalProvider].
class JournalEntryListNotifier extends Notifier<List<JournalEntry>> {
  @override
  List<JournalEntry> build() {
    _init();
    return [];
  }

  Future<void> _init() async {
    final isar = ref.read(isarProvider);

    final subscription = isar.journalEntryIsars
        .watchLazy(fireImmediately: false)
        .listen((_) => _reload(isar));
    ref.onDispose(subscription.cancel);

    await _reload(isar);
  }

  Future<void> _reload(Isar isar) async {
    final rows = await isar.journalEntryIsars.where().findAll();
    state = rows.map((r) => r.toDomain()).toList();
  }

  /// Add a new entry. Returns the Isar-assigned id.
  Future<int> add({
    required int profileId,
    required DateTime createdAt,
    required JournalSnapshot firstSnapshot,
    int? mood,
    int? energyLevel,
  }) async {
    final isar = ref.read(isarProvider);
    final row = JournalEntryIsar()
      ..id = Isar.autoIncrement
      ..profileId = profileId
      ..createdAt = createdAt
      ..snapshots = [JournalSnapshotIsar.fromDomain(firstSnapshot)]
      ..mood = mood
      ..energyLevel = energyLevel;
    await isar.writeTxn(() async {
      await isar.journalEntryIsars.put(row);
    });
    return row.id; // Isar populates this after put().
  }

  /// Replace an existing entry by id (used for mood/energy updates).
  Future<void> update(JournalEntry updated) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.journalEntryIsars.put(JournalEntryIsar.fromDomain(updated));
    });
  }

  /// Append a new snapshot to an existing entry (autosave).
  Future<void> appendSnapshot(int id, JournalSnapshot snapshot) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      final row = await isar.journalEntryIsars.get(id);
      if (row == null) return;
      row.snapshots = [
        ...row.snapshots,
        JournalSnapshotIsar.fromDomain(snapshot),
      ];
      await isar.journalEntryIsars.put(row);
    });
  }

  /// Remove the last snapshot from an entry (undo).
  /// No-op if only one snapshot remains.
  Future<void> undo(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      final row = await isar.journalEntryIsars.get(id);
      if (row == null || row.snapshots.length <= 1) return;
      row.snapshots = row.snapshots.sublist(0, row.snapshots.length - 1);
      await isar.journalEntryIsars.put(row);
    });
  }

  /// Remove an entry by id.
  Future<void> remove(int id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.journalEntryIsars.delete(id);
    });
  }

  /// Convenience: look up an entry by id from the in-memory state cache.
  JournalEntry? byId(int id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

final journalEntryListProvider =
    NotifierProvider<JournalEntryListNotifier, List<JournalEntry>>(
  JournalEntryListNotifier.new,
);

// ---------------------------------------------------------------------------
// Active profile's journal entries
// ---------------------------------------------------------------------------

/// The journal entries for the currently active profile, in reverse
/// chronological order. Rebuilds whenever the active profile or the
/// entry list changes.
final activeProfileJournalProvider = Provider<List<JournalEntry>>((ref) {
  final profileId = ref.watch(activeProfileProvider);
  if (profileId == null) return [];
  final entries = ref.watch(journalEntryListProvider);
  return entries
      .where((e) => e.profileId == profileId)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------

/// The current journal search query string. Empty = no filter active.
final journalSearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered view of the active profile's journal entries.
/// Case-insensitive substring match across [body] and [title].
final filteredJournalProvider = Provider<List<JournalEntry>>((ref) {
  final entries = ref.watch(activeProfileJournalProvider);
  final query = ref.watch(journalSearchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return entries;
  return entries.where((e) {
    final bodyMatch = e.body.toLowerCase().contains(query);
    final titleMatch = e.title?.toLowerCase().contains(query) ?? false;
    return bodyMatch || titleMatch;
  }).toList();
});

// ---------------------------------------------------------------------------
// Composer transient state
// ---------------------------------------------------------------------------

/// Holds the optional mood and energy selections while the journal composer
/// is open. These survive sub-sheet presentations (mood picker, energy picker)
/// because those open and close without destroying the composer's widget.
///
/// [TextEditingController]s for the body and title fields are held in widget
/// state — not here — because they require [dispose()].
///
/// Reset to [JournalComposerState.empty] when the composer closes.
class JournalComposerState {
  const JournalComposerState({
    this.mood,
    this.energyLevel,
  });

  final JournalMood? mood;
  final int? energyLevel;

  static const empty = JournalComposerState();

  JournalComposerState copyWith({
    JournalMood? mood,
    int? energyLevel,
    bool clearMood = false,
    bool clearEnergy = false,
  }) {
    return JournalComposerState(
      mood: clearMood ? null : (mood ?? this.mood),
      energyLevel: clearEnergy ? null : (energyLevel ?? this.energyLevel),
    );
  }
}

final journalComposerStateProvider =
    StateProvider<JournalComposerState>((ref) => JournalComposerState.empty);

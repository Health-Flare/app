import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:health_flare/core/providers/journal_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/core/router/app_router.dart';
import 'package:health_flare/models/journal_entry.dart';
import 'package:health_flare/features/journal/widgets/journal_empty_state.dart';
import 'package:health_flare/features/journal/widgets/journal_entry_card.dart';
import 'package:health_flare/features/shell/widgets/hf_app_bar.dart';

/// The journal tab: shows all journal entries for the active profile,
/// grouped by month in reverse chronological order, with optional search.
class JournalListScreen extends ConsumerStatefulWidget {
  const JournalListScreen({super.key});

  @override
  ConsumerState<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends ConsumerState<JournalListScreen> {
  bool _searchActive = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searchActive = true);
  }

  void _closeSearch() {
    _searchController.clear();
    ref.read(journalSearchQueryProvider.notifier).state = '';
    setState(() => _searchActive = false);
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileDataProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final title = activeProfile?.name ?? 'Health Flare';

    return Scaffold(
      appBar: HFAppBar(
        title: _searchActive
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search journal…',
                  border: InputBorder.none,
                  hintStyle: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
                style: tt.bodyLarge?.copyWith(color: cs.onSurface),
                onChanged: (value) {
                  ref.read(journalSearchQueryProvider.notifier).state = value;
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Journal',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    title,
                    style: tt.titleMedium?.copyWith(color: cs.onSurface),
                  ),
                ],
              ),
        actions: [
          if (_searchActive)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Close search',
              onPressed: _closeSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search journal',
              onPressed: _openSearch,
            ),
          // Leave space for the shell overlay profile avatar.
        ],
      ),
      body: JournalEntriesBody(onClearSearch: _closeSearch),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.journalNew),
        tooltip: 'New journal entry',
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }
}

/// Renders the entry list grouped by month with sticky month headers.
class _GroupedEntryList extends StatelessWidget {
  const _GroupedEntryList({required this.entries});

  final List<JournalEntry> entries;

  static final _monthFormat = DateFormat('MMMM yyyy');

  @override
  Widget build(BuildContext context) {
    // Build a list of items interleaved with month headers.
    final items = <_ListItem>[];
    String? lastMonthKey;

    for (final entry in entries) {
      final monthKey = _monthFormat.format(entry.createdAt);
      if (monthKey != lastMonthKey) {
        items.add(_MonthHeader(monthKey));
        lastMonthKey = monthKey;
      }
      items.add(_EntryItem(entry));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is _MonthHeader) {
          return _buildMonthHeader(context, item.month);
        }
        if (item is _EntryItem) {
          return _buildEntryCard(context, item.entry);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMonthHeader(BuildContext context, String month) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        month,
        style: tt.labelMedium?.copyWith(
          color: cs.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, JournalEntry entry) {
    return JournalEntryCard(
      entry: entry,
      onTap: () => context.push(AppRoutes.journalDetail(entry.id)),
    );
  }
}

// ---------------------------------------------------------------------------
// Simple sealed-class-style helpers for list item types
// ---------------------------------------------------------------------------

abstract class _ListItem {}

class _MonthHeader extends _ListItem {
  _MonthHeader(this.month);
  final String month;
}

class _EntryItem extends _ListItem {
  _EntryItem(this.entry);
  final JournalEntry entry;
}

/// Whether the search field is open on Journal > Entries (#141). The
/// standalone screen keeps its own search in the app bar.
final journalTabSearchOpenProvider = StateProvider<bool>((ref) => false);

/// The search button for Journal > Entries' top bar (#141).
class JournalSearchAction extends ConsumerWidget {
  const JournalSearchAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(journalTabSearchOpenProvider);
    return IconButton(
      icon: Icon(open ? Icons.close_rounded : Icons.search_rounded),
      tooltip: open ? 'Close search' : 'Search journal',
      onPressed: () {
        if (open) ref.read(journalSearchQueryProvider.notifier).state = '';
        ref.read(journalTabSearchOpenProvider.notifier).state = !open;
      },
    );
  }
}

/// The journal list grouped by month, shared by this screen and
/// Journal > Entries (#141). [showSearchField] puts the search field at the
/// top when Journal > Entries' search is open.
class JournalEntriesBody extends ConsumerWidget {
  const JournalEntriesBody({
    super.key,
    this.onClearSearch,
    this.showSearchField = false,
  });

  final VoidCallback? onClearSearch;
  final bool showSearchField;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(filteredJournalProvider);
    final hasEntries = ref.watch(activeProfileJournalProvider).isNotEmpty;
    final searchQuery = ref.watch(journalSearchQueryProvider);
    final searchOpen =
        showSearchField && ref.watch(journalTabSearchOpenProvider);
    void clear() {
      ref.read(journalSearchQueryProvider.notifier).state = '';
      if (showSearchField) {
        ref.read(journalTabSearchOpenProvider.notifier).state = false;
      }
      onClearSearch?.call();
    }

    final Widget list = !hasEntries
        ? const JournalEmptyState(isSearch: false)
        : entries.isEmpty && searchQuery.isNotEmpty
        ? JournalEmptyState(isSearch: true, onClearSearch: clear)
        : _GroupedEntryList(entries: entries);
    if (!searchOpen) return list;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search journal…',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (value) =>
                ref.read(journalSearchQueryProvider.notifier).state = value,
          ),
        ),
        Expanded(child: list),
      ],
    );
  }
}

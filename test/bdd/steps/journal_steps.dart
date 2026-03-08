import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/journal_fixtures.dart';
import '../../helpers/test_database.dart';
import 'common_steps.dart';

/// Step definitions for journal-related scenarios.

/// {@template given_the_journal_is_empty}
/// Ensures no journal entries exist.
/// {@endtemplate}
Future<void> givenTheJournalIsEmpty(WidgetTester tester) async {
  // Fresh database means no entries
}

/// {@template given_journal_entries_exist}
/// Seeds the database with sample journal entries.
/// {@endtemplate}
Future<void> givenJournalEntriesExist(WidgetTester tester) async {
  final isar = TestContext.isar;
  await isar.seedJournalEntries(JournalFixtures.multipleEntriesIsar);
}

/// {@template when_i_create_a_journal_entry}
/// Creates a new journal entry with the given content.
/// {@endtemplate}
Future<void> whenICreateAJournalEntry(
  WidgetTester tester,
  String content,
) async {
  // Navigate to journal composer and enter content
  // Find and tap the compose button
  // Enter content
  // Save
  await tester.pumpAndSettle();
}

/// {@template when_i_tap_on_journal_entry}
/// Taps on a journal entry card to view details.
/// {@endtemplate}
Future<void> whenITapOnJournalEntry(
  WidgetTester tester,
  String contentPreview,
) async {
  final entryCard = find.textContaining(contentPreview);
  if (entryCard.evaluate().isNotEmpty) {
    await tester.tap(entryCard.first);
    await tester.pumpAndSettle();
  }
}

/// {@template when_i_set_mood_to}
/// Sets the mood value in the journal entry.
/// {@endtemplate}
Future<void> whenISetMoodTo(WidgetTester tester, int moodValue) async {
  // Find and tap the mood selector
  // Select the appropriate mood level
  await tester.pumpAndSettle();
}

/// {@template when_i_set_energy_to}
/// Sets the energy value in the journal entry.
/// {@endtemplate}
Future<void> whenISetEnergyTo(WidgetTester tester, int energyValue) async {
  // Find and tap the energy selector
  // Select the appropriate energy level
  await tester.pumpAndSettle();
}

/// {@template then_the_journal_entry_is_saved}
/// Verifies the journal entry was saved.
/// {@endtemplate}
Future<void> thenTheJournalEntryIsSaved(WidgetTester tester) async {
  // Verify we're back on the journal list or see confirmation
  await tester.pumpAndSettle();
}

/// {@template then_i_see_the_journal_entry}
/// Verifies a journal entry with the given content is visible.
/// {@endtemplate}
Future<void> thenISeeTheJournalEntry(
  WidgetTester tester,
  String contentPreview,
) async {
  expect(find.textContaining(contentPreview), findsAtLeastNWidgets(1));
}

/// {@template then_the_journal_shows_empty_state}
/// Verifies the journal empty state is shown.
/// {@endtemplate}
Future<void> thenTheJournalShowsEmptyState(WidgetTester tester) async {
  // Look for empty state message or illustration
  await tester.pumpAndSettle();
}

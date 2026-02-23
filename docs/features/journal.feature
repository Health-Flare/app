Feature: Journaling
  As a primary user
  I want to write personal journal entries for the active profile
  So that I can capture the qualitative experience of living with illness
  in my own words, and read back over time to notice patterns my structured
  logs cannot capture

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Creating an entry — minimal (quick) path
  # ---------------------------------------------------------------------------

  Scenario: Write a minimal entry with body text only
    When I navigate to the Journal tab
    And I tap the + button
    Then the entry composer opens with the keyboard raised
    And the body text field is focused immediately
    When I type "Really rough morning. Joints bad."
    And I tap Save
    Then an entry is saved for "Sarah" with that body text
    And I am returned to the journal list
    And the new entry appears at the top of the list

  Scenario: Cannot save an entry with an empty body
    When I open the journal composer
    And I leave the body text empty
    Then the Save button is disabled

  Scenario: Discarding an empty composer requires no confirmation
    When I open the journal composer
    And I do not type anything
    And I tap the close button
    Then I am returned to the journal list without a confirmation dialog
    And no entry is saved

  # ---------------------------------------------------------------------------
  # Creating an entry — enriched path
  # ---------------------------------------------------------------------------

  Scenario: Write an entry with a title
    When I open the journal composer
    And I tap "+ Add title"
    Then a title field appears
    When I type "Appointment with Dr. Chen"
    And I type a body and tap Save
    Then the entry is saved with the title "Appointment with Dr. Chen"
    And the title is visible in the journal list

  Scenario: Write an entry with a mood
    When I open the journal composer
    And I type a body
    And I tap the Mood chip
    Then I see five mood options: Great, Okay, Not great, Rough, Terrible
    When I select "Not great"
    Then the Mood chip updates to show "Not great"
    When I tap Save
    Then the entry is saved with mood "Not great"

  Scenario: Write an entry with an energy level
    When I open the journal composer
    And I type a body
    And I tap the Energy chip
    Then I see energy levels 1 through 5
    And level 1 is labelled "Exhausted" and level 5 is labelled "Great"
    When I select level 2
    Then the Energy chip updates to show "Energy: 2"
    When I tap Save
    Then the entry is saved with energy level 2

  Scenario: Write an entry with all optional fields
    When I open the journal composer
    And I add a title "Flare week notes"
    And I type a body
    And I set mood to "Rough"
    And I set energy to 1
    And I tap Save
    Then the entry is saved with the title, body, mood, and energy level

  Scenario: Clearing a selected mood removes it from the entry
    When I open the journal composer
    And I set mood to "Okay"
    And I tap the Mood chip again
    And I tap "Okay" again in the mood picker
    Then the Mood chip returns to the unset state
    And the entry is saved without a mood value

  Scenario: Leaving the composer with typed text shows a discard confirmation
    When I open the journal composer
    And I type "Half a thought"
    And I tap the close button
    Then I see a dialog: "Leave without saving? Your entry won't be saved."
    When I tap "Keep writing"
    Then the composer remains open with my text intact

  Scenario: Confirming discard closes the composer and loses the entry
    When I open the journal composer
    And I type "Half a thought"
    And I tap the close button
    And I tap "Discard" in the confirmation dialog
    Then the composer closes
    And no entry is saved

  # ---------------------------------------------------------------------------
  # Viewing the entry list
  # ---------------------------------------------------------------------------

  Scenario: Journal entries appear in reverse chronological order
    Given "Sarah" has the following journal entries:
      | Body                | Created at          |
      | "Rough start"       | 2026-02-10 09:00    |
      | "Better this week"  | 2026-02-14 20:30    |
      | "Post-appointment"  | 2026-02-17 16:00    |
    When I navigate to the Journal tab
    Then I see all three entries
    And "Post-appointment" appears first
    And "Rough start" appears last

  Scenario: Entries are grouped by month with a visible month header
    Given "Sarah" has entries in both January and February 2026
    When I navigate to the Journal tab
    Then I see a "February 2026" header above February entries
    And I see a "January 2026" header above January entries

  Scenario: Each entry card shows date, time, title or preview, and mood if set
    Given "Sarah" has an entry with title "Post-appointment" and mood "Okay"
    When I navigate to the Journal tab
    Then the entry card shows the date and time
    And the entry card shows "Post-appointment"
    And the entry card shows the 🙂 emoji

  Scenario: An entry card without a title shows the first line of body text
    Given "Sarah" has an entry with no title and body "Joint pain all day"
    When I navigate to the Journal tab
    Then the entry card shows "Joint pain all day" as the preview

  Scenario: Energy dots appear on cards when energy level is set
    Given "Sarah" has an entry with energy level 3
    When I navigate to the Journal tab
    Then the entry card shows three filled dots and two empty dots

  # ---------------------------------------------------------------------------
  # Empty states
  # ---------------------------------------------------------------------------

  Scenario: Empty journal shows a warm invitation to write
    Given "Sarah" has no journal entries
    When I navigate to the Journal tab
    Then I see an empty state with an encouraging message
    And the + button is clearly visible

  # ---------------------------------------------------------------------------
  # Viewing entry detail
  # ---------------------------------------------------------------------------

  Scenario: Tapping an entry opens the full detail view
    Given "Sarah" has an entry with title "Week 3 notes" and body text
    When I navigate to the Journal tab
    And I tap the "Week 3 notes" entry
    Then I see the full body text of the entry
    And I see the title "Week 3 notes"
    And I see the creation date and time
    And I see Edit and Delete icons in the app bar

  Scenario: The body text in the detail view is selectable
    Given "Sarah" has an entry with body text
    When I open the entry detail view
    Then I can select and copy text from the body field

  Scenario: Mood and energy are shown in the detail view when set
    Given "Sarah" has an entry with mood "Great" and energy level 5
    When I open the entry detail view
    Then I see a chip showing "😊 Great"
    And I see a chip showing "Energy 5/5"

  Scenario: Edited timestamp is shown if the entry has been modified
    Given "Sarah" has an entry that was edited after creation
    When I open the entry detail view
    Then I see an "Edited" note below the body text

  # ---------------------------------------------------------------------------
  # Searching entries
  # ---------------------------------------------------------------------------

  Scenario: Search filters entries by keyword in body text
    Given "Sarah" has entries containing the word "fatigue" and entries without
    When I navigate to the Journal tab
    And I tap the search icon
    And I type "fatigue"
    Then only entries containing "fatigue" are shown

  Scenario: Search is case-insensitive
    When I search for "Fatigue"
    Then entries containing "fatigue" or "Fatigue" are shown

  Scenario: Search also matches the entry title
    Given "Sarah" has an entry with title "Doctor visit"
    When I search for "doctor"
    Then the "Doctor visit" entry is shown

  Scenario: Search with no results shows an empty state
    When I search for a word that does not appear in any entry
    Then I see "No entries found."
    And I see a "Clear search" option

  Scenario: Clearing search restores the full list
    Given I have performed a search that returned no results
    When I tap "Clear search"
    Then all of "Sarah"'s entries are shown again

  # ---------------------------------------------------------------------------
  # Editing entries
  # ---------------------------------------------------------------------------

  Scenario: Edit an existing entry
    Given "Sarah" has an entry with body "Rough day"
    When I open the entry detail view
    And I tap the Edit icon
    Then the composer opens with "Rough day" pre-filled in the body field
    When I change the text to "Rough day but managed a short walk"
    And I tap Save
    Then the entry now shows "Rough day but managed a short walk"

  Scenario: Editing preserves the original creation timestamp
    Given "Sarah" has an entry created at "2026-02-10 09:00"
    When I edit the entry and save
    Then the entry's creation timestamp is still "2026-02-10 09:00"

  Scenario: Editing sets an "updated at" timestamp
    Given "Sarah" has an entry that has never been edited
    When I open and edit the entry and save
    Then the entry detail view shows an "Edited" timestamp
    And the "Edited" timestamp is approximately the current time

  Scenario: Edit mode pre-fills mood and energy from the original entry
    Given "Sarah" has an entry with mood "Rough" and energy level 2
    When I tap Edit on the entry
    Then the Mood chip shows "Rough"
    And the Energy chip shows "Energy: 2"

  # ---------------------------------------------------------------------------
  # Deleting entries
  # ---------------------------------------------------------------------------

  Scenario: Delete an entry with confirmation
    Given "Sarah" has a journal entry
    When I open the entry detail view
    And I tap the Delete icon
    Then I see a confirmation dialog: "Delete this entry? This cannot be undone."
    When I confirm
    Then the entry is permanently removed from "Sarah"'s journal
    And I am returned to the journal list

  Scenario: Cancel deletion keeps the entry
    Given "Sarah" has a journal entry
    When I open the entry detail view
    And I tap Delete
    And I tap Cancel in the confirmation dialog
    Then the entry is unchanged
    And I remain on the detail view

  # ---------------------------------------------------------------------------
  # Profile scoping
  # ---------------------------------------------------------------------------

  Scenario: Journal entries are scoped to the active profile
    Given the following profiles and entries exist:
      | Profile | Entry body         |
      | Sarah   | "My pain diary"    |
      | Dad     | "Dad's notes"      |
    When "Sarah" is active and I view the Journal tab
    Then I see only "My pain diary"
    When I switch to "Dad" and view the Journal tab
    Then I see only "Dad's notes"

  Scenario: Switching profiles does not affect another profile's journal
    Given "Sarah" has 3 journal entries
    When I switch to a different profile
    And I view the Journal tab
    Then I see no journal entries (or only that profile's own entries)
    When I switch back to "Sarah"
    Then I still see all 3 of Sarah's entries

  # ---------------------------------------------------------------------------
  # Navigation
  # ---------------------------------------------------------------------------

  Scenario: Journal tab is accessible from the bottom navigation bar
    When I am on any tab in the main app
    And I tap "Journal" in the bottom navigation bar
    Then I navigate to the journal list for the active profile

  Scenario: Reports is accessible from the Dashboard app bar
    When I am on the Dashboard
    And I tap the Reports icon in the app bar
    Then I navigate to the Reports screen

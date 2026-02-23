Feature: Persistent local datastore
  As a Health Flare app
  I need a reliable, versioned, local-only datastore
  So that user data survives app restarts, upgrades, and device reboots,
  and so that users can recover from accidental changes to their data

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given the app is installed fresh on the device
    And the datastore is initialised at app startup

  # ---------------------------------------------------------------------------
  # Database initialisation
  # ---------------------------------------------------------------------------

  Scenario: Datastore is opened on first launch
    Given the app has never been launched before
    When the app starts up
    Then the Isar database is created in the app's documents directory
    And the schema version is recorded as 1
    And the database is empty (no profiles, no entries)

  Scenario: Datastore reopens correctly on subsequent launches
    Given the app has been launched and data was saved in a previous session
    When the app starts up again
    Then the Isar database is reopened from the same file path
    And all previously saved data is available
    And no data is lost between sessions

  Scenario: Datastore is initialised before any UI is rendered
    When the app starts up
    Then the datastore initialisation completes before the router resolves the first route
    And the app does not render any screen until the datastore is ready

  # ---------------------------------------------------------------------------
  # Profile persistence
  # ---------------------------------------------------------------------------

  Scenario: A newly created profile is persisted to disk
    Given the datastore is open and empty
    When a new profile named "Sarah" is created
    Then "Sarah" is written to the Isar profiles collection
    And "Sarah" can be read back from disk after a cold app restart

  Scenario: The active profile selection is persisted across restarts
    Given profile "Sarah" exists and is the active profile
    When the app is closed and restarted
    Then "Sarah" is still the active profile

  Scenario: All profiles are loaded on startup in creation order
    Given three profiles exist: "Sarah", "Dad", "Mum"
    When the app starts
    Then all three profiles are available
    And they appear in the order they were created

  Scenario: Updating a profile persists the change
    Given profile "Sarah" exists with no date of birth
    When the user updates Sarah's date of birth to "1990-06-15"
    Then the change is written to the database immediately
    And after a restart Sarah's date of birth is "1990-06-15"

  Scenario: Deleting a profile removes it permanently
    Given profile "Sarah" exists with two journal entries
    When the user deletes the "Sarah" profile
    Then "Sarah" is removed from the profiles collection
    And all journal entries belonging to "Sarah" are also removed
    And the data is gone after a restart

  # ---------------------------------------------------------------------------
  # Journal entry persistence
  # ---------------------------------------------------------------------------

  Scenario: A saved journal entry is written to disk
    Given profile "Sarah" is active
    When a new journal entry with body "Rough morning" is saved
    Then the entry is written to the Isar journal entries collection
    And the entry can be read back after a cold restart
    And the entry belongs to "Sarah"

  Scenario: All journal entries for a profile are loaded on startup
    Given "Sarah" has three saved journal entries
    When the app restarts
    Then all three entries are loaded for "Sarah"
    And they are presented in reverse chronological order (newest first)

  Scenario: Updating a journal entry persists the change
    Given "Sarah" has a journal entry with body "Rough morning"
    When the entry body is changed to "Rough morning, but improved by afternoon"
    And the autosave fires
    Then the updated entry is persisted to disk
    And a new snapshot is appended (the old snapshot is still present)
    And after a restart the entry shows the updated body

  Scenario: Deleting a journal entry removes it permanently
    Given "Sarah" has a journal entry
    When the user deletes the entry
    Then the entry is removed from the database
    And the entry is gone after a restart

  # ---------------------------------------------------------------------------
  # Snapshot (version) persistence
  # ---------------------------------------------------------------------------

  Scenario: All snapshots for a journal entry are persisted
    Given "Sarah" has a journal entry that has been autosaved three times
    When the app restarts
    Then the entry has all three snapshots preserved
    And the snapshots are in chronological order (oldest first)

  Scenario: Undo is available after a restart if multiple snapshots exist
    Given "Sarah" has a journal entry with two autosave snapshots
    When the app restarts and the user opens that entry for editing
    Then the undo button is available
    And tapping undo restores the previous snapshot

  Scenario: The first snapshot (creation state) is never discarded
    Given "Sarah" has a journal entry with a single snapshot
    When the user taps undo in the composer
    Then the entry still has exactly one snapshot
    And the body text is unchanged

  Scenario: Snapshots record accurate timestamps
    Given a journal entry is autosaved at "2026-02-17 14:00"
    And the same entry is autosaved again at "2026-02-17 14:10"
    Then the first snapshot has savedAt "2026-02-17 14:00"
    And the second snapshot has savedAt "2026-02-17 14:10"

  # ---------------------------------------------------------------------------
  # Data integrity across app version upgrades
  # ---------------------------------------------------------------------------

  Scenario: Existing data survives an app update that does not change the schema
    Given the app has been updated from version 1.0.0 to 1.1.0
    And the schema version has not changed
    When the app starts up after the update
    Then all previously saved profiles and journal entries are intact
    And the schema version remains unchanged

  Scenario: Schema migration runs automatically on first launch after an upgrade
    Given the database is on schema version 1
    And the app has been updated to a build that requires schema version 2
    When the app starts up
    Then the migration from version 1 to version 2 runs once automatically
    And all existing data is preserved (or migrated) according to the migration rules
    And the schema version is updated to 2

  Scenario: A failed migration does not corrupt existing data
    Given the database is on schema version 1
    And a migration to version 2 encounters an error
    When the app starts up
    Then the database remains on schema version 1
    And the user's existing data is intact
    And an error is logged for diagnosis

  Scenario: The app handles a database file from an older app build
    Given the user downgrades the app to a version that expects schema version 1
    And the database file on disk is at schema version 2
    When the app starts up
    Then the app detects the schema version mismatch
    And the app does not crash or corrupt the data
    And a user-visible error or recovery prompt is shown

  # ---------------------------------------------------------------------------
  # Data isolation between profiles
  # ---------------------------------------------------------------------------

  Scenario: Journal entries from different profiles do not intermix
    Given profile "Sarah" has entries: "My notes"
    And profile "Dad" has entries: "Dad's notes"
    When the datastore loads entries for "Sarah"
    Then only "My notes" is returned
    And "Dad's notes" is not included

  Scenario: Deleting one profile's entries does not affect another profile
    Given "Sarah" has 3 journal entries
    And "Dad" has 2 journal entries
    When all of "Sarah"'s entries are deleted
    Then "Dad" still has 2 journal entries

  # ---------------------------------------------------------------------------
  # Active profile ID persistence
  # ---------------------------------------------------------------------------

  Scenario: Active profile ID is stored persistently
    Given "Sarah" is set as the active profile
    When the app is closed and relaunched
    Then "Sarah" is automatically the active profile

  Scenario: If the active profile is deleted, no profile is active on restart
    Given "Sarah" is the active profile
    When "Sarah"'s profile is deleted
    And the app is restarted
    Then no active profile is set
    And the user is prompted to select or create a profile

  # ---------------------------------------------------------------------------
  # Onboarding state persistence
  # ---------------------------------------------------------------------------

  Scenario: Onboarding completion is persisted across restarts
    Given the user has completed onboarding
    When the app is closed and restarted
    Then the onboarding screen is not shown
    And the app navigates directly to the home screen

  Scenario: Onboarding is shown again only if app data is cleared
    Given the user has completed onboarding
    When the device's app data is cleared (equivalent to a fresh install)
    And the app is launched
    Then the onboarding screen is shown

  # ---------------------------------------------------------------------------
  # Storage location and lifecycle
  # ---------------------------------------------------------------------------

  Scenario: Database is stored in the platform app documents directory
    When the datastore is initialised
    Then the Isar database file is located inside the platform's app documents directory
    And it is not stored in a temporary or cache directory

  Scenario: Database file is not accessible to other apps
    When the datastore is initialised on iOS or Android
    Then the database file resides in the app's private sandbox directory
    And other applications cannot read or write the file

  Scenario: Database is closed gracefully when the app is terminated
    When the operating system sends a termination signal
    Then all pending writes are flushed to disk
    And the database file is not left in a corrupt state

  # ---------------------------------------------------------------------------
  # Observability and reactive updates
  # ---------------------------------------------------------------------------

  Scenario: Riverpod providers reactively reflect database writes
    Given the datastore is open and the journal list is being displayed
    When a new journal entry is written to the database
    Then the journal list provider emits the updated list
    And the UI updates without requiring a manual refresh

  Scenario: Riverpod providers reflect profile changes immediately
    Given the profile list screen is visible
    When a new profile is saved to the database
    Then the profile list provider emits the updated list
    And the new profile appears in the UI without a restart

  # ---------------------------------------------------------------------------
  # Dependency and package constraints
  # ---------------------------------------------------------------------------

  Scenario: The isar_community package (v3.3.0) is used as the database engine
    Given the pubspec.yaml is checked
    Then "isar_community" appears under dependencies at version 3.3.0
    And "isar_community_flutter_libs" appears under dependencies at version 3.3.0
    And "isar_community_generator" appears under dev_dependencies at version 3.3.0
    And "build_runner" appears under dev_dependencies

  Scenario: The path_provider package is present for resolving the documents directory
    Given the pubspec.yaml is checked
    Then "path_provider" appears under dependencies

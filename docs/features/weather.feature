Feature: Weather context on log entries
  As a person with a chronic illness
  I want weather conditions automatically captured when I log entries
  So I can look back and spot correlations between weather and my symptoms

  Background:
    Given the active profile has weather tracking enabled

  # ── Opt-in ────────────────────────────────────────────────────────────────

  Scenario: Weather opt-in appears during onboarding
    Given I have just created a new profile
    When onboarding completes
    Then the weather opt-in sheet is shown
    And it explains that weather data is fetched from Open-Meteo using my device location
    And it explains that no data ever leaves my device

  Scenario: Accepting weather opt-in enables tracking
    Given the weather opt-in sheet is shown
    When I tap "Enable weather tracking"
    Then weather tracking is enabled on my profile
    And the opt-in sheet is dismissed

  Scenario: Declining weather opt-in leaves tracking disabled
    Given the weather opt-in sheet is shown
    When I tap "No thanks"
    Then weather tracking remains disabled on my profile

  # ── Shared snapshot window ────────────────────────────────────────────────

  Scenario: Weather is fetched once and reused within 30 minutes
    Given a weather snapshot was captured 15 minutes ago
    When I open any entry form
    Then the same snapshot is shown without a new network fetch

  Scenario: Stale snapshot triggers a fresh fetch after 30 minutes
    Given a weather snapshot was captured 31 minutes ago
    When I open any entry form
    Then a new weather fetch is performed

  Scenario: Weather snapshot is nil when permission is denied
    Given location permission is denied
    When I open a symptom log form
    Then no weather chip is shown on the form

  # ── Symptom entry ─────────────────────────────────────────────────────────

  Scenario: Weather chip appears on new symptom entry form
    When I open the "Log symptom" form
    Then the weather chip is visible showing the current conditions and temperature

  Scenario: Weather snapshot is saved with the symptom entry
    Given the weather chip shows "Mainly clear, 18°C"
    When I save the symptom entry
    Then the saved entry includes the weather snapshot "Mainly clear, 18°C"

  Scenario: Weather chip does not appear on symptom edit form
    Given an existing symptom entry with no weather snapshot
    When I open that entry for editing
    Then no weather chip is shown on the form

  Scenario: Saved weather snapshot is shown when editing an entry that has one
    Given an existing symptom entry with weather snapshot "Rain, 12°C"
    When I open that entry for editing
    Then the weather chip shows "Rain, 12°C"

  # ── Meal entry ────────────────────────────────────────────────────────────

  Scenario: Weather chip appears on new meal entry form
    When I open the "Log meal" form
    Then the weather chip is visible showing the current conditions and temperature

  Scenario: Weather snapshot is saved with the meal entry
    Given the weather chip shows "Overcast, 15°C"
    When I save the meal entry
    Then the saved entry includes the weather snapshot "Overcast, 15°C"

  Scenario: Weather snapshot is shown on the meal detail screen
    Given a saved meal entry with weather snapshot "Clear sky, 22°C"
    When I open that meal's detail screen
    Then the weather information "Clear sky, 22°C" is visible on the screen

  # ── Activity entry ────────────────────────────────────────────────────────

  Scenario: Weather chip appears on new activity entry form
    When I open the "Log activity" form
    Then the weather chip is visible showing the current conditions and temperature

  Scenario: Weather snapshot is saved with the activity entry
    Given the weather chip shows "Drizzle, 10°C"
    When I save the activity entry
    Then the saved entry includes the weather snapshot "Drizzle, 10°C"

  # ── Daily check-in ────────────────────────────────────────────────────────

  Scenario: Weather chip appears on new daily check-in form
    When I open the check-in form
    Then the weather chip is visible showing the current conditions and temperature

  Scenario: Weather snapshot is saved with the daily check-in
    Given the weather chip shows "Clear sky, 25°C"
    When I save the check-in
    Then the saved entry includes the weather snapshot "Clear sky, 25°C"

  Scenario: Weather snapshot is shown in the check-in history list
    Given a saved check-in with weather snapshot "Foggy, 8°C"
    When I view the check-in history screen
    Then "Foggy, 8°C" appears in the subtitle of that check-in row

  # ── Journal entry ─────────────────────────────────────────────────────────

  Scenario: Weather chip appears in the journal composer for a new entry
    When I open the journal composer to write a new entry
    Then the weather chip is visible showing the current conditions and temperature

  Scenario: Weather snapshot is saved with the journal entry
    Given the weather chip shows "Rain showers, 13°C"
    When the journal entry is autosaved
    Then the saved entry includes the weather snapshot "Rain showers, 13°C"

  Scenario: Weather snapshot is attached when it resolves after first autosave
    Given a journal entry was autosaved before weather resolved
    When the weather snapshot becomes available
    Then the entry is updated to include the weather snapshot

  Scenario: Weather snapshot is shown on the journal detail screen
    Given a saved journal entry with weather snapshot "Snow, 0°C"
    When I open that entry's detail screen
    Then the weather information "Snow, 0°C" is visible on the screen

  Scenario: Weather chip does not appear in the journal composer when editing
    Given an existing journal entry
    When I open that entry in the composer for editing
    Then no weather chip is shown

  Scenario: Saved weather snapshot is shown in the composer when editing an entry that has one
    Given an existing journal entry with weather snapshot "Thunderstorm, 18°C"
    When I open that entry in the composer for editing
    Then the weather chip shows "Thunderstorm, 18°C"

  # ── Disabled ──────────────────────────────────────────────────────────────

  Scenario: No weather chip shown when weather tracking is disabled
    Given the active profile has weather tracking disabled
    When I open any entry form
    Then no weather chip is visible on the form

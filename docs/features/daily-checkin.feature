Feature: Daily Check-in
  As a user managing a chronic illness
  I want to record a brief daily wellbeing rating, stress level, and optional context
  So that I have a single anchor point for each day that all other logged data can be
  compared against — and so I can see my overall health trajectory over time

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # The check-in concept
  # ---------------------------------------------------------------------------

  # The daily check-in is a lightweight, once-per-day entry that captures:
  #   - Overall wellbeing (1–10)
  #   - Stress level (low / medium / high)
  #   - Menstrual cycle phase (optional, profile-level setting)
  # It is distinct from symptom logging: a check-in records "how am I overall today"
  # while symptom logs record specific events. Both contribute to pattern analysis.

  # ---------------------------------------------------------------------------
  # Completing a check-in
  # ---------------------------------------------------------------------------

  Scenario: Dashboard prompts for a check-in when none has been recorded today
    Given "Sarah" has not completed a check-in today
    When I open the dashboard
    Then a check-in prompt is visible on the dashboard
    And the prompt is warm and brief — it does not feel like a medical form
    And completing it takes no more than three taps

  Scenario: Complete today's check-in with a wellbeing rating only
    Given the check-in prompt is visible
    When I select a wellbeing rating of 6
    And I tap Save
    Then a check-in is saved for today with a wellbeing of 6
    And the prompt is replaced by the saved check-in summary

  Scenario: Complete a check-in with wellbeing and stress level
    Given the check-in prompt is visible
    When I select a wellbeing rating of 4
    And I select stress level "High"
    And I tap Save
    Then a check-in is saved with wellbeing 4 and stress "High"

  Scenario: Complete a check-in with all fields
    Given the check-in prompt is visible
    And "Sarah" has menstrual cycle tracking enabled
    When I select a wellbeing rating of 7
    And I select stress level "Low"
    And I mark cycle phase as "Day 2 of period"
    And I add a note "Slept well, gentle morning"
    And I tap Save
    Then a check-in is saved with all four fields recorded

  Scenario: Check-in prompt disappears once a check-in is saved for today
    Given "Sarah" has completed today's check-in
    When I navigate away and return to the dashboard
    Then the check-in prompt is not shown
    And the saved check-in is displayed in its place

  Scenario: Check-in can be edited on the same day
    Given "Sarah" has completed today's check-in with a wellbeing of 5
    When I tap the check-in to edit it
    And I change the wellbeing to 3
    And I tap Save
    Then today's check-in now shows a wellbeing of 3

  # ---------------------------------------------------------------------------
  # Backdating a check-in
  # ---------------------------------------------------------------------------

  Scenario: Log a check-in for a past day where none was recorded
    Given "Sarah" has no check-in recorded for "2026-03-10"
    When I navigate to the check-in history
    And I tap "Add check-in" for "2026-03-10"
    Then I can complete a check-in for that date
    And it is saved with the date "2026-03-10", not today

  Scenario: Cannot log two check-ins for the same day
    Given "Sarah" has a check-in recorded for "2026-03-10"
    When I attempt to add another check-in for "2026-03-10"
    Then I am shown the existing check-in for that date
    And offered the option to edit it, not create a duplicate

  # ---------------------------------------------------------------------------
  # Wellbeing scale
  # ---------------------------------------------------------------------------

  Scenario: Wellbeing scale is 1 to 10 with anchor labels
    Given the check-in prompt is open
    Then the wellbeing selector shows values from 1 to 10
    And 1 is labelled or anchored as "Worst possible"
    And 10 is labelled or anchored as "Best possible"
    And the input method is a single interaction (slider, tap row, or equivalent) — not a text field

  Scenario: No wellbeing rating is pre-selected on the check-in prompt
    When the check-in prompt opens
    Then no wellbeing value is pre-selected
    And the Save button is disabled until a rating is chosen

  # ---------------------------------------------------------------------------
  # Stress level
  # ---------------------------------------------------------------------------

  Scenario: Stress level is an optional three-option selector
    Given the check-in prompt is visible
    Then the stress selector shows three options:
      | Option |
      | Low    |
      | Medium |
      | High   |
    And no option is pre-selected
    And the field is clearly labelled "Stress today"

  Scenario: Check-in can be saved without a stress level
    When I complete a check-in with only a wellbeing rating of 6
    And I leave stress level unset
    And I tap Save
    Then the check-in is saved with no stress value recorded

  # ---------------------------------------------------------------------------
  # Menstrual cycle tracking
  # ---------------------------------------------------------------------------

  Scenario: Menstrual cycle tracking is an opt-in profile setting
    When I open profile settings for "Sarah"
    Then I see an option to enable menstrual cycle tracking
    And it is off by default
    And enabling it does not change any existing check-in data

  Scenario: Cycle phase field appears on the check-in when cycle tracking is enabled
    Given "Sarah" has menstrual cycle tracking enabled
    When the check-in prompt opens
    Then a cycle field is visible with the options:
      | Option           |
      | Period           |
      | Follicular phase |
      | Ovulation        |
      | Luteal phase     |
      | Not sure         |
    And the field is optional

  Scenario: Cycle phase field is absent when cycle tracking is disabled
    Given "Sarah" has menstrual cycle tracking disabled
    When the check-in prompt opens
    Then no cycle field is shown

  Scenario: Log period start
    Given "Sarah" has menstrual cycle tracking enabled
    When I complete a check-in and select "Period" as the cycle phase
    And I tap Save
    Then the check-in records cycle phase "Period" for today

  Scenario: Cycle phase data is scoped to the profile
    Given "Sarah" has cycle tracking enabled and "Dad" does not
    When "Dad" is the active profile
    Then no cycle field appears in the check-in prompt

  # ---------------------------------------------------------------------------
  # Check-in history
  # ---------------------------------------------------------------------------

  Scenario: View check-in history as a calendar or list
    Given "Sarah" has check-ins spanning multiple weeks
    When I navigate to the check-in history view
    Then I see each day's wellbeing rating displayed
    And days without a check-in are visually distinguished from days with one
    And I can browse backwards through the history

  Scenario: Days with no check-in show a gap, not a zero
    Given "Sarah" has no check-in for "2026-03-09"
    When I view the check-in history
    Then "2026-03-09" is shown as a missing entry
    And it is not treated as a wellbeing of zero or any default value

  Scenario: Wellbeing trend is visible across the history view
    Given "Sarah" has daily check-ins for the last 30 days
    When I view the check-in history
    Then I can see the wellbeing trend across that period as a simple visual
    And I can identify better and worse periods at a glance

  # ---------------------------------------------------------------------------
  # Correlation with other data
  # ---------------------------------------------------------------------------

  Scenario: Check-in wellbeing correlates with symptom severity on the same day
    Given "Sarah" has 30 days of check-ins and daily symptom logs
    When I view the pattern insights for "Sarah"
    Then I can see average symptom severity plotted against daily wellbeing score
    And days with wellbeing ≤ 3 are highlighted as "difficult days"

  Scenario: Check-in stress correlates with flare onset
    Given "Sarah" has flare history and daily check-ins with stress levels
    When I view the pattern insights
    Then I can see how many flares were preceded by one or more "High" stress check-ins
    And this is presented as a correlation observation, not a diagnosis

  Scenario: Check-in data is included in exported reports
    When I generate a report for "Last 30 days" including check-ins
    Then the report includes a row for each day showing wellbeing, stress, and cycle phase
    And days without a check-in are shown as blank rows, not missing rows

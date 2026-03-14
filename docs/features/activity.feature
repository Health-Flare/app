Feature: Activity and Exertion Logging
  As a user managing a chronic illness
  I want to log physical activity and exertion levels
  So that I can identify whether overexertion triggers flares,
  understand how rest days compare to active days,
  and give my medical team an honest picture of my activity tolerance

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # The exertion model
  # ---------------------------------------------------------------------------

  # This is not a fitness app. Activity is logged as perceived exertion, not
  # performance metrics. The goal is to capture the effort experienced, not
  # calories burned or distance covered. A short walk at high personal effort
  # is more important to log than a gym session that felt easy.
  #
  # Activity types are broad and inclusive of what chronic illness patients
  # actually do: resting, gentle movement, household tasks, social obligations.

  # ---------------------------------------------------------------------------
  # Logging an activity
  # ---------------------------------------------------------------------------

  Scenario: Log an activity from the quick log sheet
    When I tap the + button
    And I type "Short walk to the shops"
    And the app classifies it as "Activity"
    And I save the entry
    Then an activity entry is saved for "Sarah" with the description and current timestamp

  Scenario: Log an activity with a perceived effort level
    When I open the new activity entry screen
    And I enter "Housework — vacuumed and mopped" as the description
    And I set perceived effort to 3 out of 5
    And I save the entry
    Then the activity entry is saved with effort level 3

  Scenario: Log an activity with a duration
    When I open the new activity entry screen
    And I enter "Gentle yoga session" as the description
    And I enter 30 as the duration in minutes
    And I save the entry
    Then the activity entry records a duration of 30 minutes

  Scenario: Log an activity with optional notes
    When I open the new activity entry screen
    And I enter "Walked to the park" as the description
    And I enter "Legs felt heavy after 10 mins, had to stop and rest twice" as the notes
    And I save the entry
    Then the activity notes are saved with the entry

  Scenario: Log a rest day
    When I open the new activity entry screen
    And I select "Rest day" as the activity type
    And I save the entry
    Then a rest day is recorded for today
    And no effort level or duration is required

  Scenario: Cannot save an activity entry without a description
    When I open the new activity entry screen
    And I leave the description empty
    And I attempt to save the entry
    Then I see a validation error indicating a description is required
    And no entry is saved

  # ---------------------------------------------------------------------------
  # Effort scale
  # ---------------------------------------------------------------------------

  Scenario: Perceived effort is a 1 to 5 scale with anchor labels
    When the activity entry form is open
    Then the effort selector shows values 1 to 5
    And 1 is labelled "Very light"
    And 3 is labelled "Moderate"
    And 5 is labelled "Maximum effort"
    And the scale includes a visible note that effort is personal — not compared to anyone else

  Scenario: Effort level is optional
    When I open the new activity entry screen
    And I enter "Light stretching" as the description
    And I leave effort level unset
    And I save the entry
    Then the activity entry is saved with no effort value recorded

  # ---------------------------------------------------------------------------
  # Activity types
  # ---------------------------------------------------------------------------

  Scenario: Activity type selector includes chronic-illness-appropriate options
    When I open the new activity entry screen
    And I tap the activity type field
    Then I see types including:
      | Type                      |
      | Walking                   |
      | Gentle exercise / yoga    |
      | Household tasks           |
      | Work / desk activity      |
      | Social obligation         |
      | Medical appointment       |
      | Rest day                  |
      | Other                     |
    And I can also type a custom description instead of using a preset type

  # ---------------------------------------------------------------------------
  # Post-exertional malaise (PEM) flag
  # ---------------------------------------------------------------------------

  # PEM is a defining feature of ME/CFS and affects many other conditions:
  # symptoms worsen 12–48 hours after exertion. Flagging a crash as
  # potentially exertion-related enables the app to surface the connection.

  Scenario: Flag a symptom flare as a possible post-exertional crash
    Given "Sarah" logged high-effort activity on "2026-03-10"
    And she has symptom entries on "2026-03-11" and "2026-03-12"
    When I view the symptom entries for "2026-03-12"
    Then a contextual note suggests "High effort logged 2 days ago — possible PEM?"
    And I can tap to view the activity entry that triggered the suggestion

  Scenario: PEM flag can be dismissed if not relevant
    Given a PEM suggestion is shown on a symptom entry
    When I tap "Not relevant"
    Then the suggestion is dismissed for that specific pairing
    And it does not reappear

  # ---------------------------------------------------------------------------
  # Viewing activity history
  # ---------------------------------------------------------------------------

  Scenario: View activity log in reverse chronological order
    Given "Sarah" has the following activity entries:
      | Date       | Description      | Effort |
      | 2026-03-09 | Rest day         | —      |
      | 2026-03-10 | Walked to clinic | 3      |
      | 2026-03-11 | Gentle yoga      | 2      |
    When I navigate to the activity log for "Sarah"
    Then I see all three entries listed with most recent first

  Scenario: Edit an activity entry
    Given "Sarah" has an activity entry "Walked to park" with effort 2
    When I open the entry and change the effort to 4
    And I save the changes
    Then the entry now shows effort level 4

  Scenario: Delete an activity entry with confirmation
    Given "Sarah" has an activity entry for "2026-03-10"
    When I choose to delete the entry
    Then I am shown a confirmation dialog
    When I confirm
    Then the entry is permanently removed

  # ---------------------------------------------------------------------------
  # Correlation with flares and symptoms
  # ---------------------------------------------------------------------------

  Scenario: Activity and rest day distribution is visible in pattern insights
    Given "Sarah" has 30 days of activity and symptom data
    When I view the pattern insights
    Then I can see average symptom severity on days following high-effort activity (effort 4–5)
    And average symptom severity on rest days and low-effort days (effort 1–2)

  Scenario: Activity data is included in exported reports
    When I generate a report including activity data
    Then the report contains a row for each activity entry with date, description, type, effort, duration, and notes

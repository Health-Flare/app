Feature: Sleep Logging
  As a user managing a chronic illness
  I want to log my sleep duration and quality each day
  So that I can identify correlations between poor sleep and symptom flares,
  and track whether my sleep patterns are improving or worsening over time

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Logging sleep
  # ---------------------------------------------------------------------------

  Scenario: Log last night's sleep from the dashboard
    Given "Sarah" has not logged sleep for today
    When I tap "Log sleep" on the dashboard or from the quick log sheet
    Then the sleep entry form opens
    And the bedtime defaults to yesterday at 23:00
    And the wake time defaults to today at 07:00

  Scenario: Log sleep with bedtime and wake time
    When I open the sleep entry form
    And I set bedtime to "22:30"
    And I set wake time to "06:45"
    And I save the entry
    Then a sleep entry is saved with 8 hours 15 minutes of sleep
    And the duration is calculated automatically

  Scenario: Log sleep quality
    When I open the sleep entry form
    And I set bedtime to "23:00" and wake time to "07:00"
    And I set the sleep quality to 3 out of 5
    And I save the entry
    Then the sleep entry records both the duration and a quality of 3

  Scenario: Log sleep with optional notes
    When I open the sleep entry form
    And I enter "Woke up twice, hot and restless" as the sleep notes
    And I save the entry
    Then the sleep notes are saved with the entry

  Scenario: Log sleep without setting quality
    When I open the sleep entry form
    And I set bedtime to "22:00" and wake time to "06:30"
    And I leave quality unset
    And I save the entry
    Then a sleep entry is saved with duration only and no quality value

  Scenario: Wake time cannot be before bedtime on the same calendar day
    When I open the sleep entry form
    And I set bedtime to "08:00" and wake time to "06:00" on the same date
    Then I see a validation error indicating the wake time must be after the bedtime
    And no sleep entry is saved

  Scenario: Bedtime crossing midnight is handled correctly
    When I open the sleep entry form
    And I set bedtime to "2026-03-10 23:30"
    And I set wake time to "2026-03-11 07:15"
    Then the duration is calculated as 7 hours 45 minutes
    And the sleep entry is dated to the morning it ended: "2026-03-11"

  Scenario: Log a nap as a separate sleep entry
    Given "Sarah" already has a sleep entry for "2026-03-11"
    When I log another sleep entry for "2026-03-11" with duration 1 hour
    Then a second sleep entry for that day is saved and labelled as a nap
    And both entries are visible in the sleep history for that day

  # ---------------------------------------------------------------------------
  # Sleep quality scale
  # ---------------------------------------------------------------------------

  Scenario: Sleep quality is a 1 to 5 scale with anchor labels
    When the sleep entry form is open
    Then the quality selector shows values 1 to 5
    And 1 is labelled "Very poor"
    And 5 is labelled "Restful"

  # ---------------------------------------------------------------------------
  # Viewing sleep history
  # ---------------------------------------------------------------------------

  Scenario: View sleep history in reverse chronological order
    Given "Sarah" has the following sleep entries:
      | Date       | Duration | Quality |
      | 2026-03-09 | 6h 30m   | 2       |
      | 2026-03-10 | 7h 45m   | 4       |
      | 2026-03-11 | 5h 00m   | 1       |
    When I navigate to the sleep log for "Sarah"
    Then I see all three entries listed with most recent first

  Scenario: Average sleep duration and quality are shown in the sleep history header
    Given "Sarah" has sleep entries over the last 14 days
    When I navigate to the sleep log
    Then I see an average duration and average quality for the last 7 days

  Scenario: Days with no sleep entry are shown as gaps, not zeros
    Given "Sarah" logged sleep on Monday and Wednesday but not Tuesday
    When I view the sleep history
    Then Tuesday shows as a day with no entry recorded
    And it does not appear as a zero-duration or zero-quality entry

  # ---------------------------------------------------------------------------
  # Editing and deleting sleep entries
  # ---------------------------------------------------------------------------

  Scenario: Edit a sleep entry
    Given "Sarah" has a sleep entry for "2026-03-10" with wake time "07:00"
    When I open the entry and change the wake time to "07:30"
    And I save the changes
    Then the duration updates to reflect the new wake time

  Scenario: Delete a sleep entry with confirmation
    Given "Sarah" has a sleep entry for "2026-03-10"
    When I choose to delete the entry
    Then I am shown a confirmation dialog
    When I confirm
    Then the sleep entry is permanently removed

  # ---------------------------------------------------------------------------
  # Correlation with other data
  # ---------------------------------------------------------------------------

  Scenario: Poor sleep nights are flagged next to symptom entries on the following day
    Given "Sarah" has a sleep entry for "2026-03-10" with quality 1
    And she has symptom entries on "2026-03-11"
    When I view the symptom entries for "2026-03-11"
    Then a contextual note indicates "Poor sleep the night before (quality 1/5)"

  Scenario: Sleep data appears in pattern analysis
    Given "Sarah" has 30 days of sleep and symptom data
    When I view the pattern insights
    Then I can see average symptom severity on days following poor sleep (quality 1–2)
    And average symptom severity on days following good sleep (quality 4–5)

  Scenario: Sleep is included in exported reports
    When I generate a report including sleep data
    Then the report contains a row for each sleep entry with date, duration, quality, and notes

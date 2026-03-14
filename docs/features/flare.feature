Feature: Flare Tracking
  As a user managing a chronic illness
  I want to mark and track flare periods with a start and end
  So that I can see how often I flare, how long flares last, which conditions are active,
  and correlate all other logged data against my flare history

  Background:
    Given a profile named "Sarah" exists and is active
    And "Sarah" is tracking "Fibromyalgia" and "Arthritis"

  # ---------------------------------------------------------------------------
  # What is a flare
  # ---------------------------------------------------------------------------

  # A flare is a period of elevated disease activity — a user-declared state
  # that persists until the user marks it as over. All health data logged during
  # an active flare is implicitly associated with that flare period.
  # The app never auto-detects flares; the user always initiates and closes them.

  # ---------------------------------------------------------------------------
  # Starting a flare
  # ---------------------------------------------------------------------------

  Scenario: Start a flare from the dashboard
    Given "Sarah" has no active flare
    When I tap "I'm flaring" on the dashboard
    Then a flare period begins with the current date and time as the start
    And the dashboard shows an active flare indicator
    And the flare is open (no end date)

  Scenario: Start a flare and attribute it to a condition
    Given "Sarah" is tracking "Fibromyalgia" and "Arthritis"
    When I start a flare
    Then I am shown a list of Sarah's tracked conditions
    And I can select one or more conditions to attribute the flare to
    When I select "Fibromyalgia"
    Then the flare is attributed to "Fibromyalgia"

  Scenario: Start a flare without attributing it to a condition
    When I start a flare
    And I skip condition attribution
    Then the flare is recorded without a condition attribution
    And I can add attribution later from the flare detail view

  Scenario: Start a flare with a past start time
    When I start a flare
    And I change the start time to "2026-03-10 14:00"
    Then the flare period begins at "2026-03-10 14:00"
    And all entries saved after that timestamp are associated with the flare

  Scenario: Start a flare with a severity rating
    When I start a flare
    And I set the severity to 7 out of 10
    Then the flare is recorded with an initial severity of 7

  Scenario: Cannot start a flare when one is already active
    Given "Sarah" has an active flare started on "2026-03-10"
    When I attempt to start a new flare
    Then I see a message indicating a flare is already active
    And I am offered the option to end the current flare first or view the active flare

  # ---------------------------------------------------------------------------
  # Active flare state
  # ---------------------------------------------------------------------------

  Scenario: Active flare indicator is visible on the dashboard
    Given "Sarah" has an active flare
    When I am on the dashboard
    Then a persistent flare indicator is visible
    And it shows how long the flare has been active (e.g. "Day 3 of current flare")
    And tapping the indicator opens the active flare detail view

  Scenario: Active flare banner shows attributed conditions
    Given "Sarah" has an active flare attributed to "Fibromyalgia"
    When I am on the dashboard
    Then the flare indicator shows "Fibromyalgia flare"

  Scenario: Active flare banner is not shown when no flare is active
    Given "Sarah" has no active flare
    When I am on the dashboard
    Then no flare indicator is visible

  Scenario: All entries logged during an active flare are tagged with that flare
    Given "Sarah" has an active flare
    When I log a symptom "Joint pain"
    And I log a meal "Pasta with tomato sauce"
    And I log a medication dose for "Ibuprofen"
    Then all three entries are associated with the active flare
    And this association is visible in each entry's detail view

  # ---------------------------------------------------------------------------
  # Updating a flare in progress
  # ---------------------------------------------------------------------------

  Scenario: Update flare severity during an active flare
    Given "Sarah" has an active flare with severity 6
    When I open the active flare detail view
    And I update the severity to 8
    And I save the changes
    Then the flare severity is updated to 8

  Scenario: Add a note to an active flare
    Given "Sarah" has an active flare
    When I open the active flare detail view
    And I enter "Triggered after the long drive" as the flare note
    And I save
    Then the note is saved against the active flare

  Scenario: Add a condition attribution to a flare that was started without one
    Given "Sarah" has an active flare with no condition attribution
    When I open the active flare detail view
    And I select "Arthritis" as the attributed condition
    And I save
    Then the flare is now attributed to "Arthritis"

  # ---------------------------------------------------------------------------
  # Ending a flare
  # ---------------------------------------------------------------------------

  Scenario: End an active flare
    Given "Sarah" has an active flare started on "2026-03-10"
    When I tap "End flare" from the active flare view
    Then I am prompted to confirm the end date and time
    And the end date defaults to now
    When I confirm
    Then the flare period is closed with the current date and time as the end
    And the dashboard flare indicator is no longer shown

  Scenario: End a flare with a past end time
    Given "Sarah" has an active flare
    When I tap "End flare"
    And I change the end time to "2026-03-12 09:00"
    Then the flare closes at "2026-03-12 09:00"

  Scenario: Ending a flare asks for a closing severity
    Given "Sarah" has an active flare
    When I tap "End flare"
    Then I am shown a closing severity field
    And I can record how severe the flare was at its peak or at its end

  # ---------------------------------------------------------------------------
  # Flare history
  # ---------------------------------------------------------------------------

  Scenario: View flare history in reverse chronological order
    Given "Sarah" has the following flare history:
      | Start       | End         | Condition      | Severity |
      | 2026-01-05  | 2026-01-09  | Fibromyalgia   | 7        |
      | 2026-02-14  | 2026-02-17  | Arthritis      | 5        |
      | 2026-03-10  | (active)    | Fibromyalgia   | 8        |
    When I navigate to the flare history screen
    Then I see all three flares listed with most recent first
    And the active flare shows "In progress" instead of an end date

  Scenario: View detail of a past flare
    Given "Sarah" has a completed flare from "2026-01-05" to "2026-01-09"
    When I tap the flare in the history list
    Then I see the start and end dates
    And I see the duration "4 days"
    And I see the attributed condition
    And I see the peak severity
    And I see the note if one was added
    And I see a list of all entries logged during that flare period

  Scenario: Flare history shows entries logged during each flare
    Given "Sarah" has a completed flare from "2026-01-05" to "2026-01-09"
    And she logged 12 symptoms and 3 meal reactions during that period
    When I view the flare detail
    Then I see a count: "12 symptoms, 3 meal reactions logged during this flare"
    And I can browse the full entry list within that flare period

  # ---------------------------------------------------------------------------
  # Flare statistics
  # ---------------------------------------------------------------------------

  Scenario: Flare summary statistics are available for the active profile
    Given "Sarah" has a flare history spanning 6 months
    When I navigate to the flare statistics view
    Then I see:
      | Statistic                          |
      | Total number of flares             |
      | Average flare duration in days     |
      | Most frequently flaring condition  |
      | Average time between flares        |
      | Longest flare recorded             |

  Scenario: Flare statistics can be filtered by condition
    Given "Sarah" is tracking "Fibromyalgia" and "Arthritis"
    And she has flare history for both conditions
    When I filter the flare statistics by "Fibromyalgia"
    Then the statistics reflect only flares attributed to "Fibromyalgia"

  # ---------------------------------------------------------------------------
  # Correlation with other data
  # ---------------------------------------------------------------------------

  Scenario: Symptom severity during flares is compared to baseline
    Given "Sarah" has flare history and non-flare symptom logs
    When I view the flare statistics
    Then I see average symptom severity during flare periods
    And I see average symptom severity outside of flare periods
    And the comparison is labelled "During flare" and "Baseline"

  Scenario: Meals logged during flares are available for review
    Given "Sarah" has a completed flare
    When I view the flare detail
    Then I can filter the associated entries to show only meals
    And I can see whether any meals were flagged with a reaction during the flare

  Scenario: Weather conditions during a flare are summarised
    Given "Sarah" has weather tracking enabled
    And she has a completed flare where weather was captured on each entry
    When I view the flare detail
    Then I see a weather summary for the flare period (e.g. average pressure, temperature range)

  # ---------------------------------------------------------------------------
  # Edge cases
  # ---------------------------------------------------------------------------

  Scenario: Flare data is scoped to the active profile
    Given "Sarah" has an active flare
    And "Dad" has no active flare
    When I switch to the "Dad" profile
    Then no flare indicator is shown on the dashboard
    And Sarah's flare is unchanged

  Scenario: Deleting a flare record requires confirmation
    Given "Sarah" has a completed flare in her history
    When I choose to delete the flare record
    Then I am shown a confirmation dialog warning that the flare record will be removed
    And entries logged during that period are not deleted — only the flare association is removed
    When I confirm
    Then the flare record is removed
    And the associated entries remain in Sarah's logs without a flare tag

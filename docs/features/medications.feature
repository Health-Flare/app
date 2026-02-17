Feature: Medication Tracking
  As a primary user
  I want to manage medications and log doses for the active profile
  So that I have an accurate record of what is being taken, when, and how consistently

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Adding a medication
  # ---------------------------------------------------------------------------

  Scenario: Add a scheduled medication with required fields only
    When I navigate to the medications screen
    And I open the add medication form
    And I enter "Metformin" as the medication name
    And I enter "500" as the dose amount and "mg" as the unit
    And I select "Twice daily" as the frequency
    And I enter "2026-01-15" as the start date
    And I save the medication
    Then a medication named "Metformin" is added to "Sarah"'s medication list
    And it shows a dose of "500mg" taken "Twice daily" from "2026-01-15"

  Scenario: Add an as-needed medication
    When I open the add medication form
    And I enter "Ibuprofen" as the medication name
    And I enter "400" as the dose amount and "mg" as the unit
    And I select "As needed" as the frequency
    And I enter "2026-02-01" as the start date
    And I save the medication
    Then "Ibuprofen" is added to "Sarah"'s medication list with frequency "As needed"

  Scenario: Add a medication with all optional fields
    When I open the add medication form
    And I enter "Prednisolone" as the medication name
    And I enter "5" as the dose amount and "mg" as the unit
    And I select "Once daily" as the frequency
    And I enter "2026-02-01" as the start date
    And I enter "2026-02-14" as the end date
    And I enter "Take in the morning with food" as the notes
    And I save the medication
    Then "Prednisolone" is saved with the end date "2026-02-14" and the notes intact

  Scenario: Cannot add a medication without a name
    When I open the add medication form
    And I leave the medication name empty
    And I attempt to save the medication
    Then I see a validation error indicating the medication name is required
    And no medication is added

  Scenario: Cannot add a medication without a start date
    When I open the add medication form
    And I enter "Amoxicillin" as the medication name
    And I leave the start date empty
    And I attempt to save the medication
    Then I see a validation error indicating the start date is required
    And no medication is added

  # ---------------------------------------------------------------------------
  # Logging a dose taken
  # ---------------------------------------------------------------------------

  Scenario: Log a dose taken now
    Given "Sarah" has a medication "Metformin" at "500mg" twice daily
    When I navigate to the medications screen
    And I select "Metformin"
    And I log a dose taken
    Then a dose log entry is created for "Metformin" with the current timestamp
    And the dose amount defaults to "500mg"

  Scenario: Log a dose taken at a past time
    Given "Sarah" has a medication "Metformin" at "500mg" twice daily
    When I log a dose for "Metformin"
    And I change the timestamp to "2026-02-16 07:30"
    And I save the dose
    Then the dose log entry for "Metformin" is recorded at "2026-02-16 07:30"

  Scenario: Log an as-needed dose with a custom amount
    Given "Sarah" has a medication "Ibuprofen" at "400mg" as needed
    When I log a dose for "Ibuprofen"
    And I change the dose amount to "800"
    And I save the dose
    Then the dose log entry records "800mg" of "Ibuprofen"

  Scenario: Log a dose with notes
    Given "Sarah" has a medication "Metformin" at "500mg" twice daily
    When I log a dose for "Metformin"
    And I enter "Took with breakfast" as the dose notes
    And I save the dose
    Then the dose log entry for "Metformin" includes the note "Took with breakfast"

  # ---------------------------------------------------------------------------
  # Skipped or missed doses
  # ---------------------------------------------------------------------------

  Scenario: Mark a dose as skipped
    Given "Sarah" has a medication "Metformin" at "500mg" twice daily
    When I log a dose for "Metformin"
    And I mark it as "Skipped"
    And I save the entry
    Then a dose log entry is recorded for "Metformin" with the status "Skipped"

  Scenario: Mark a dose as missed with a reason
    Given "Sarah" has a medication "Prednisolone" at "5mg" once daily
    When I log a dose for "Prednisolone"
    And I mark it as "Missed"
    And I enter "Forgot while travelling" as the reason
    And I save the entry
    Then a dose log entry is recorded for "Prednisolone" with status "Missed" and reason "Forgot while travelling"

  # ---------------------------------------------------------------------------
  # Viewing medication history
  # ---------------------------------------------------------------------------

  Scenario: View the active medications list
    Given "Sarah" has the following active medications:
      | Name          | Dose  | Frequency    |
      | Metformin     | 500mg | Twice daily  |
      | Ibuprofen     | 400mg | As needed    |
      | Vitamin D     | 1000IU| Once daily   |
    When I navigate to the medications screen
    Then I see all three medications listed

  Scenario: View dose history for a specific medication
    Given "Sarah" has a medication "Metformin" with the following dose log:
      | Timestamp           | Amount | Status |
      | 2026-02-15 07:30    | 500mg  | Taken  |
      | 2026-02-15 19:00    | 500mg  | Taken  |
      | 2026-02-16 07:30    | 500mg  | Missed |
    When I navigate to the medications screen
    And I tap "Metformin"
    And I view the dose history
    Then I see all three dose log entries in reverse chronological order
    And the "2026-02-16 07:30" entry shows a status of "Missed"

  Scenario: Edit a dose log entry
    Given "Sarah" has a dose log entry for "Metformin" at "2026-02-15 07:30" with amount "500mg"
    When I tap the dose log entry
    And I edit the amount to "250mg"
    And I save the changes
    Then the dose log entry now shows "250mg"

  Scenario: Delete a dose log entry with confirmation
    Given "Sarah" has a dose log entry for "Ibuprofen" at "2026-02-14 15:00"
    When I choose to delete that dose log entry
    Then I am shown a confirmation dialog
    When I confirm the deletion
    Then the dose log entry is permanently removed

  Scenario: Edit a medication record
    Given "Sarah" has a medication "Metformin" at "500mg"
    When I open the edit form for "Metformin"
    And I change the dose to "1000mg"
    And I save the changes
    Then the medication "Metformin" now shows a dose of "1000mg"

  Scenario: Delete a medication with confirmation
    Given "Sarah" has a medication "Ibuprofen"
    When I choose to delete the medication "Ibuprofen"
    Then I am shown a confirmation dialog warning that the medication and all its dose history will be removed
    When I confirm the deletion
    Then "Ibuprofen" and all its dose log entries are permanently removed from "Sarah"'s records

  # ---------------------------------------------------------------------------
  # Discontinuing a medication
  # ---------------------------------------------------------------------------

  Scenario: Discontinue a medication by setting an end date
    Given "Sarah" has an active medication "Prednisolone" with no end date
    When I open the edit form for "Prednisolone"
    And I set the end date to today's date
    And I save the changes
    Then "Prednisolone" is marked as discontinued
    And the historical dose log for "Prednisolone" is preserved

  Scenario: Discontinued medications are visually distinguished from active ones
    Given "Sarah" has the following medications:
      | Name         | Status       |
      | Metformin    | Active       |
      | Prednisolone | Discontinued |
    When I navigate to the medications screen
    Then "Metformin" appears in the active medications section
    And "Prednisolone" appears in a discontinued or past medications section
    And the full dose history for "Prednisolone" is still accessible

  # ---------------------------------------------------------------------------
  # Empty state
  # ---------------------------------------------------------------------------

  Scenario: Empty medications screen shows a helpful prompt
    Given "Sarah" has no medications recorded
    When I navigate to the medications screen
    Then I see an empty state message guiding me to add my first medication

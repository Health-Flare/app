Feature: Doctor Visit and Appointment Tracking
  As a user managing a chronic illness
  I want to log medical appointments before and after they happen
  So that I can prepare questions in advance, record outcomes and prescription changes,
  and give my medical team a complete picture when I share my health history

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Logging an appointment
  # ---------------------------------------------------------------------------

  Scenario: Log an upcoming appointment
    When I open the new appointment form
    And I enter "Rheumatology follow-up" as the appointment title
    And I enter "Dr. Chen" as the provider name
    And I set the date to "2026-03-20" and time to "10:30"
    And I save the appointment
    Then an upcoming appointment for "Dr. Chen" on "2026-03-20 10:30" is saved for "Sarah"
    And it appears in the dashboard with an "Upcoming" label

  Scenario: Log an appointment that has already happened
    When I open the new appointment form
    And I enter "GP check-in" as the appointment title
    And I set the date to "2026-03-08" (a past date)
    And I save the appointment
    Then the appointment is saved with no upcoming label
    And I am prompted to add an outcome

  Scenario: Cannot save an appointment without a title
    When I open the new appointment form
    And I leave the appointment title empty
    And I attempt to save
    Then I see a validation error indicating a title is required
    And no appointment is saved

  # ---------------------------------------------------------------------------
  # Pre-appointment notes and questions
  # ---------------------------------------------------------------------------

  Scenario: Add questions to ask at an upcoming appointment
    Given "Sarah" has an upcoming appointment with "Dr. Chen" on "2026-03-20"
    When I open the appointment detail
    And I tap "Add a question"
    And I enter "Should I increase my Metformin dose given recent glucose readings?"
    And I save
    Then the question is saved against the appointment
    And I can see it listed in the appointment detail view

  Scenario: Add multiple questions to an appointment
    Given "Sarah" has an upcoming appointment
    When I add the following questions:
      | Question                                             |
      | Is my current flare frequency normal for this stage?|
      | Are there any new treatment options for fibromyalgia?|
    Then both questions are saved and listed in the appointment detail

  Scenario: Questions are shown in full during the appointment
    Given "Sarah" has an upcoming appointment with two questions saved
    When I open the appointment on the day of the visit
    Then both questions are visible clearly
    And I can check them off as I discuss them

  Scenario: Tap to check off a question as discussed
    Given "Sarah"'s appointment has the question "Should I increase my Metformin dose?"
    When I tap the question to mark it as discussed
    Then the question is shown as checked
    And the appointment records that the question was discussed

  # ---------------------------------------------------------------------------
  # Post-appointment outcomes
  # ---------------------------------------------------------------------------

  Scenario: Record the outcome of a completed appointment
    Given "Sarah" has a past appointment with "Dr. Chen"
    When I open the appointment detail
    And I enter "Dr. Chen recommended a short course of steroids and a referral to physio" as the outcome
    And I save
    Then the outcome is saved against the appointment

  Scenario: Record a medication change from the appointment
    Given "Sarah"'s appointment resulted in a new prescription
    When I open the appointment detail
    And I tap "Add medication change"
    And I enter "Prednisolone 5mg once daily for 14 days" as the new medication
    And I save
    Then the medication change is recorded in the appointment detail
    And I am offered the option to add "Prednisolone" directly to Sarah's medication list

  Scenario: Record a follow-up appointment from the outcome screen
    Given I have just recorded the outcome for "Sarah"'s appointment
    When I tap "Schedule a follow-up"
    Then the new appointment form opens pre-filled with the same provider name
    And the date is blank for me to set

  Scenario: Mark an appointment as missed or cancelled
    Given "Sarah" has an upcoming appointment on "2026-03-20"
    When I open the appointment and mark it as "Cancelled"
    Then the appointment shows a "Cancelled" status
    And it no longer appears as an upcoming event on the dashboard

  # ---------------------------------------------------------------------------
  # Appointment history and dashboard
  # ---------------------------------------------------------------------------

  Scenario: Upcoming appointments are shown on the dashboard
    Given "Sarah" has an upcoming appointment with "Dr. Chen" in 5 days
    When I am on the dashboard
    Then the appointment is visible in the upcoming section
    And it shows the provider name, appointment title, and date

  Scenario: View appointment history in reverse chronological order
    Given "Sarah" has the following appointments:
      | Title              | Provider   | Date       | Status    |
      | Rheumatology       | Dr. Chen   | 2026-01-15 | Completed |
      | GP check-in        | Dr. Patel  | 2026-02-03 | Completed |
      | Physio assessment  | Emma W.    | 2026-03-20 | Upcoming  |
    When I navigate to the appointments screen
    Then I see all three appointments listed
    And "Physio assessment" appears in an upcoming section
    And the two past appointments are listed below in reverse date order

  Scenario: View full detail of a past appointment
    Given "Sarah" has a completed appointment with an outcome and medication change recorded
    When I tap the appointment in the history list
    Then I see the appointment title, provider, date, and time
    And I see the outcome notes
    And I see the medication change recorded
    And I see which questions were discussed

  # ---------------------------------------------------------------------------
  # Cross-referencing with health data
  # ---------------------------------------------------------------------------

  Scenario: Appointment appears in the dashboard activity feed
    Given "Sarah" has a completed appointment on "2026-03-08"
    When I am on the dashboard and the feed includes "2026-03-08"
    Then the appointment appears in the feed on that date
    And it is visually distinct from symptom or meal entries

  Scenario: Symptoms logged on the day of an appointment are linked in the report
    Given "Sarah" has an appointment with "Dr. Chen" on "2026-03-08"
    And she logged three symptoms on that date
    When I generate a report including appointments and symptoms
    Then the report groups the three symptoms with the appointment entry for "2026-03-08"

  # ---------------------------------------------------------------------------
  # Accessibility and safety
  # ---------------------------------------------------------------------------

  Scenario: Appointment title is used as the accessible label for the upcoming appointment card
    Given a screen reader is active
    And "Sarah" has an upcoming appointment titled "Rheumatology follow-up"
    When I navigate to the dashboard
    Then the screen reader announces "Rheumatology follow-up, upcoming appointment, 2026-03-20"

  Scenario: Appointment data is included in exported reports
    When I generate a report including appointments
    Then the report contains a section for each appointment with title, provider, date, outcome, and any medication changes

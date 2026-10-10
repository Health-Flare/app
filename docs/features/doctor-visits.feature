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
  # Dashboard appointments card (#138)
  # ---------------------------------------------------------------------------
  #
  # The card is the way into the appointments list until Track and Care
  # (#135) gives appointments a tab, so it shows whenever the profile has
  # any appointment at all, and as a one-line prompt when it has none.
  #
  # One rule, used everywhere an appointment is called upcoming (dashboard
  # card, appointments list, detail screen, PDF and CSV exports):
  #
  # - Upcoming: status is Upcoming AND the scheduled time is still ahead.
  # - Outcome not recorded: status is Upcoming AND the scheduled time has
  #   passed. Status is never changed automatically.
  # - Needs an outcome (card only): outcome not recorded, and the scheduled
  #   time was less than 7 days ago.
  #
  # Recording an outcome, or marking it Completed, Missed or Cancelled,
  # clears "Needs an outcome".

  Scenario: Upcoming appointments are shown on the dashboard
    Given "Sarah" has an upcoming appointment with "Dr. Chen" in 5 days
    When I am on the dashboard
    Then the appointments card shows the appointment title, provider name, and date
    And it shows "In 5 days"
    And the card has an "All appointments" link

  Scenario: The card links to all appointments with only one upcoming
    Given "Sarah" has exactly one appointment, upcoming in 2 days
    When I am on the dashboard
    And I tap "All appointments" on the appointments card
    Then the appointments list for "Sarah" opens

  Scenario: The card shows the next three, soonest first
    Given "Sarah" has upcoming appointments in 2, 9, 20 and 40 days
    When I am on the dashboard
    Then the appointments card lists the appointments in 2, 9 and 20 days, in that order
    And the appointment in 40 days is not on the card
    And "All appointments" is shown

  Scenario: Tapping an appointment on the card opens its detail
    Given "Sarah" has an upcoming appointment titled "Rheumatology follow-up"
    When I tap "Rheumatology follow-up" on the appointments card
    Then the detail for "Rheumatology follow-up" opens

  Scenario: An appointment that just happened asks how it went
    Given "Sarah" had an appointment titled "GP check-in" 2 days ago
    And its status is still Upcoming
    When I am on the dashboard
    Then the appointments card shows "GP check-in" with "How did it go?"
    And it is listed above any upcoming appointments
    When I tap "GP check-in" on the card
    Then the detail for "GP check-in" opens with the outcome notes field in view

  Scenario: An appointment earlier today asks how it went once its time has passed
    Given "Sarah" has an appointment titled "Bloods" at 09:00 today
    And its status is still Upcoming
    When I am on the dashboard at 11:00
    Then the appointments card shows "Bloods" with "How did it go?"

  Scenario Outline: Recording what happened clears "How did it go?"
    Given "Sarah" had an appointment titled "GP check-in" 2 days ago
    And it shows "How did it go?" on the appointments card
    When I <action>
    Then "GP check-in" is no longer on the appointments card

    Examples:
      | action                                         |
      | save an outcome for it                         |
      | mark it as "Completed"                         |
      | mark it as "Missed"                            |
      | mark it as "Cancelled"                         |

  Scenario: "How did it go?" stops after 7 days
    Given "Sarah" had an appointment titled "GP check-in" 8 days ago
    And its status is still Upcoming
    When I am on the dashboard
    Then "GP check-in" is not on the appointments card
    And it is in the Past section of the appointments list, labelled "Outcome not recorded"

  Scenario: Appointments needing an outcome count toward the three shown
    Given "Sarah" had appointments 1 and 3 days ago with no outcome recorded
    And she has upcoming appointments in 2 and 9 days
    When I am on the dashboard
    Then the appointments card lists, in order:
      | Appointment  | Shows          |
      | 1 day ago    | How did it go? |
      | 3 days ago   | How did it go? |
      | in 2 days    | In 2 days      |
    And "All appointments" is shown

  Scenario: Only past appointments: the card offers to add one
    Given "Sarah" has completed appointments but none upcoming or needing an outcome
    When I am on the dashboard
    Then the appointments card reads "No appointments coming up."
    And it offers "Add appointment" and "All appointments"

  Scenario: No appointments at all: a one-line prompt
    Given "Sarah" has never added an appointment
    When I am on the dashboard
    Then I see "Got an appointment coming up? Tap to add it."
    And it has no "All appointments" link
    And it has no close button
    When I tap it
    Then the new appointment form opens for "Sarah"
    # Turning this off comes with Features in use (#142). Until then it
    # can't be dismissed, same as the flare prompt.

  Scenario: The prompt shows on an otherwise empty dashboard
    Given "Sarah" has nothing logged and no appointments
    When I am on the dashboard
    Then "Got an appointment coming up? Tap to add it." is shown above the empty state

  Scenario: The card follows the active profile
    Given "Sarah" has an upcoming appointment titled "Physio assessment"
    And "Dad" has no appointments
    When I switch the active profile to "Dad"
    Then the dashboard shows "Got an appointment coming up? Tap to add it."
    And "Physio assessment" is not shown

  Scenario: The card's links work with a screen reader
    Given a screen reader is active
    When I move through the appointments card
    Then "All appointments" and "Add appointment" are each announced as buttons
    And each is at least 48 by 48 dp

  Scenario: The card's links work with a keyboard on desktop
    Given I am using Health Flare on macOS, Linux or Windows
    When I press Tab through the appointments card
    Then each appointment row, "All appointments" and "Add appointment" take focus in reading order
    And Enter on a focused item does the same as tapping it

  # ---------------------------------------------------------------------------
  # Appointment history
  # ---------------------------------------------------------------------------

  Scenario: View appointment history in reverse chronological order
    Given "Sarah" has the following appointments:
      | Title              | Provider   | Date       | Status    |
      | Rheumatology       | Dr. Chen   | 2026-01-15 | Completed |
      | GP check-in        | Dr. Patel  | 2026-02-03 | Completed |
      | Physio assessment  | Emma W.    | 2026-03-20 | Upcoming  |
    When I open Care and tap the "Appointments" tab
    Then I see all three appointments listed
    And "Physio assessment" appears in an upcoming section
    And the two past appointments are listed below in reverse date order

  Scenario: A passed appointment with no outcome is listed under Past
    Given "Sarah" had an appointment titled "GP check-in" 2 days ago
    And its status is still Upcoming
    When I open Care and tap the "Appointments" tab
    Then "GP check-in" is in the Past section, not the Upcoming section
    And it is labelled "Outcome not recorded"
    And its date order among past appointments is by scheduled date

  Scenario: The detail screen doesn't call a passed appointment upcoming
    Given "Sarah" had an appointment titled "GP check-in" 2 days ago
    And its status is still Upcoming
    When I open the detail for "GP check-in"
    Then the title reads "Appointment detail", not "Upcoming appointment"
    And the status reads "Outcome not recorded"
    And "Mark completed", "Cancel" and "Missed" are still offered

  Scenario: Exports don't call a passed appointment upcoming
    Given "Sarah" had an appointment titled "GP check-in" 2 days ago
    And its status is still Upcoming
    When I export a report including appointments as PDF or CSV
    Then the status for "GP check-in" reads "Outcome not recorded"
    And an appointment still ahead with status Upcoming reads "Upcoming"

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

  Scenario: An appointment asking how it went has its own screen reader label
    Given a screen reader is active
    And "Sarah" had an appointment titled "GP check-in" 2 days ago with no outcome recorded
    When I navigate to the dashboard
    Then the screen reader announces "GP check-in, appointment 2 days ago, how did it go?"

  Scenario: Appointment data is included in exported reports
    When I generate a report including appointments
    Then the report contains a section for each appointment with title, provider, date, outcome, and any medication changes

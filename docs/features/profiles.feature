Feature: Profile Management
  As a primary user
  I want to create and manage profiles for myself and my dependants
  So that health data is organised per person and easy to switch between

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given the app is installed and launched for the first time
    And no profiles exist

  # ---------------------------------------------------------------------------
  # Creating a profile
  # ---------------------------------------------------------------------------

  Scenario: Create the first profile with a name only
    When I navigate to the create profile screen
    And I enter "Sarah" as the profile name
    And I save the profile
    Then a profile named "Sarah" is created
    And "Sarah" becomes the active profile
    And I am taken to the dashboard for "Sarah"

  Scenario: Create a profile with all optional fields
    When I navigate to the create profile screen
    And I enter "Dad" as the profile name
    And I enter "1952-04-10" as the date of birth
    And I choose a photo from the library as the avatar
    And I save the profile
    Then a profile named "Dad" is created with the date of birth and avatar stored

  Scenario: Cannot create a profile without a name
    When I navigate to the create profile screen
    And I leave the profile name empty
    And I attempt to save the profile
    Then I see a validation error indicating that a name is required
    And no profile is created

  # ---------------------------------------------------------------------------
  # Switching profiles
  # ---------------------------------------------------------------------------

  Scenario: Switch between profiles
    Given the following profiles exist:
      | Name    |
      | Sarah   |
      | Dad     |
    And "Sarah" is the active profile
    When I open the profile switcher
    And I select "Dad"
    Then "Dad" becomes the active profile
    And the active profile name "Dad" is visible in the persistent header

  Scenario: Active profile name is always visible
    Given a profile named "Sarah" exists and is active
    When I navigate to any screen in the app
    Then the name "Sarah" is displayed in the persistent profile indicator

  # ---------------------------------------------------------------------------
  # Editing a profile
  # ---------------------------------------------------------------------------

  Scenario: Edit a profile name
    Given a profile named "Sarah" exists
    When I open the profile settings for "Sarah"
    And I change the name to "Sarah J"
    And I save the changes
    Then the profile is now named "Sarah J"
    And the active profile indicator shows "Sarah J"

  Scenario: Edit a profile date of birth
    Given a profile named "Dad" exists with no date of birth
    When I open the profile settings for "Dad"
    And I enter "1952-04-10" as the date of birth
    And I save the changes
    Then the profile "Dad" now has a date of birth of "1952-04-10"

  Scenario: Change a profile avatar
    Given a profile named "Sarah" exists with no avatar
    When I open the profile settings for "Sarah"
    And I take a photo using the camera as the avatar
    And I save the changes
    Then the profile "Sarah" displays the new photo as its avatar

  # ---------------------------------------------------------------------------
  # Deleting a profile
  # ---------------------------------------------------------------------------

  Scenario: Delete a profile with confirmation
    Given the following profiles exist:
      | Name    |
      | Sarah   |
      | Dad     |
    And "Sarah" is the active profile
    When I open the profile settings for "Dad"
    And I choose to delete the profile "Dad"
    Then I am shown a confirmation dialog warning that all data for "Dad" will be removed
    When I confirm the deletion
    Then the profile "Dad" is permanently deleted
    And all health data associated with "Dad" is removed
    And "Sarah" remains the active profile

  Scenario: Cancel profile deletion
    Given a profile named "Dad" exists
    When I open the profile settings for "Dad"
    And I choose to delete the profile "Dad"
    And I cancel the confirmation dialog
    Then the profile "Dad" still exists
    And no data is removed

  Scenario: Cannot delete the only remaining profile
    Given only one profile named "Sarah" exists
    When I open the profile settings for "Sarah"
    Then the delete option is disabled or not visible
    And I cannot delete "Sarah"

  # ---------------------------------------------------------------------------
  # Default and remembered profile
  # ---------------------------------------------------------------------------

  Scenario: Single profile is always active
    Given only one profile named "Sarah" exists
    When I close and reopen the app
    Then "Sarah" is still the active profile without any selection required

  Scenario: Last used profile is remembered across sessions
    Given the following profiles exist:
      | Name    |
      | Sarah   |
      | Dad     |
    And I switch to "Dad" as the active profile
    When I close and reopen the app
    Then "Dad" is the active profile

  # ---------------------------------------------------------------------------
  # Dependant attribution on entry screens
  # ---------------------------------------------------------------------------

  Scenario: Every data entry screen shows whose record is being updated
    Given the following profiles exist:
      | Name  |
      | Sarah |
      | Dad   |
    And "Dad" is the active profile
    When I open any of the following screens:
      | Screen                |
      | Add symptom           |
      | Add meal              |
      | Add medication        |
      | Add vital             |
      | Add journal entry     |
      | Add condition         |
      | Quick log sheet       |
    Then each screen shows "Logging for Dad" or "Adding to Dad's record"
    And this label is visible before any save action is taken

  Scenario: Attribution label uses the profile name, not a pronoun
    Given "Dad" is the active profile
    When I open the add symptom screen
    Then the screen says "Logging for Dad"
    And not "Logging for you" or "Logging for me"

  Scenario: Attribution label is visible without scrolling
    Given "Dad" is the active profile
    When I open any data entry form
    Then the attribution label is visible in the initial viewport
    And the user does not need to scroll to see it

  Scenario: Dashboard heading confirms whose feed is being viewed
    Given the following profiles exist:
      | Name  |
      | Sarah |
      | Dad   |
    And "Dad" is the active profile
    When I am on the dashboard
    Then the dashboard heading or subheading confirms "Dad's" name
    And I cannot mistake the feed for Sarah's

  Scenario: Switching profile while a data entry form is open prompts to discard the draft
    Given "Sarah" is the active profile
    And I have opened the add symptom screen and entered "Knee pain"
    When I switch to the "Dad" profile from the profile switcher
    Then I see a confirmation dialog with two equally visible options:
      | Option           |
      | Discard entry    |
      | Keep editing     |
    And the dialog makes clear the entry has not been saved

  Scenario: Confirming profile switch while a form is open discards the draft
    Given "Sarah" is the active profile
    And I have opened the add symptom screen and entered "Knee pain"
    When I switch to "Dad" and tap "Discard entry"
    Then "Dad" becomes the active profile
    And the draft entry is discarded
    And no entry is saved to Sarah's or Dad's record

  Scenario: Cancelling profile switch while a form is open preserves the draft
    Given "Sarah" is the active profile
    And I have opened the add symptom screen and entered "Knee pain"
    When I switch to "Dad" and tap "Keep editing"
    Then I remain on Sarah's add symptom screen
    And the text "Knee pain" is still in the entry field
    And "Sarah" is still the active profile

  Scenario: Saving an entry attributes it only to the profile active at save time
    Given "Dad" is the active profile
    When I open the add meal screen
    And I enter "Chicken soup"
    And I tap "Add to profile"
    Then the meal entry is saved to Dad's record
    And the entry does not appear in any other profile's history

  Scenario: Profile switcher is accessible without leaving a data entry form
    Given "Sarah" is the active profile
    And I have opened the add medication screen
    Then the profile switcher is reachable without closing the form or losing my place in navigation

  # ---------------------------------------------------------------------------
  # Wrong-profile recovery: moving an entry to another profile
  # ---------------------------------------------------------------------------

  Scenario: An existing entry can be moved to another profile
    Given profiles "Sarah" and "Dad" exist
    And "Sarah" is the active profile
    And Sarah's record has a symptom entry "Sore knee after walking"
    When I open that entry
    And I tap "Move to another profile"
    And I choose "Dad"
    Then the entry now belongs to Dad's record
    And the entry no longer appears in Sarah's history
    And the entry keeps its original date, time, and details

  Scenario: Moving an entry shows which profile it went to
    Given profiles "Sarah" and "Dad" exist
    When I move one of Sarah's entries to "Dad"
    Then a confirmation appears saying the entry was moved to "Dad"
    And I am returned to the screen I came from

  Scenario: The move action lists every profile except the current one
    Given profiles "Sarah", "Dad", and "Mia" exist
    And "Sarah" is the active profile
    When I tap "Move to another profile" on one of Sarah's entries
    Then I see "Dad" and "Mia" as destinations
    And I do not see "Sarah"

  Scenario: The move action is hidden when only one profile exists
    Given only the profile "Sarah" exists
    When I open one of Sarah's entries
    Then no "Move to another profile" action is shown

  Scenario: Moving an entry clears any flare link
    Given "Sarah" has an active flare
    And a symptom entry linked to that flare
    When I move that symptom entry to "Dad"
    Then the entry no longer references Sarah's flare

  Scenario: Every kind of entry can be moved
    Given profiles "Sarah" and "Dad" exist
    Then the "Move to another profile" action is available on:
      | Entry type      | Where                      |
      | Journal         | journal detail screen      |
      | Meal            | meal detail screen         |
      | Symptom         | symptom edit screen        |
      | Vital           | vital edit screen          |
      | Sleep           | sleep edit screen          |
      | Activity        | activity edit screen       |
      | Medication dose | dose edit screen           |
      | Appointment     | appointment detail screen  |

  # Doses point at a medication, and medications belong to one profile.
  # A dose can only move where the same medication already exists; the app
  # never creates a medication on someone's record as a side effect. (#77)

  Scenario: A dose moves to a profile that has the same medication
    Given profiles "Sarah" and "Dad" exist
    And both Sarah and Dad have "Ibuprofen" in their medications
    And Sarah's record has an Ibuprofen dose logged at 12:00 rated "Helped a little"
    When I move that dose to "Dad"
    Then the dose appears in Dad's Ibuprofen history
    And it keeps its time, amount, status, rating, and notes
    And it no longer appears in Sarah's Ibuprofen history

  Scenario: Medication names match regardless of capitals and spacing
    Given Sarah has "Ibuprofen" and Dad has " ibuprofen" in their medications
    When I move one of Sarah's Ibuprofen doses to "Dad"
    Then the dose appears in Dad's ibuprofen history

  Scenario: A profile without the medication is shown but can't be chosen
    Given profiles "Sarah", "Dad", and "Mia" exist
    And only Sarah and Dad have "Ibuprofen" in their medications
    When I tap "Move to another profile" on one of Sarah's Ibuprofen doses
    Then "Mia" is listed but disabled
    And it says "No Ibuprofen in Mia's medications"
    And "Dad" can be chosen

  Scenario: A moved dose prefers the target's active medication
    Given Dad has a discontinued "Ibuprofen" and an active "Ibuprofen"
    When I move one of Sarah's Ibuprofen doses to "Dad"
    Then the dose is linked to Dad's active Ibuprofen

  Scenario: Moving a dose clears any flare link
    Given one of Sarah's doses is linked to her active flare
    When I move that dose to "Dad"
    Then the dose no longer references Sarah's flare

  Scenario: An appointment moves with its questions and outcome
    Given Sarah's record has an appointment "Rheumatology follow-up" with Dr. Chen
    And it has a question marked as discussed and outcome notes
    When I move that appointment to "Dad"
    Then the appointment appears in Dad's appointments
    And it keeps its title, provider, date, questions, and outcome notes

  Scenario: Medication changes on a moved appointment keep their text
    Given one of Sarah's appointments has the medication change "Start methotrexate 10 mg weekly"
    And that change is linked to Sarah's methotrexate
    When I move that appointment to "Dad"
    Then the change still reads "Start methotrexate 10 mg weekly"
    And it is no longer linked to Sarah's medication

  # ---------------------------------------------------------------------------
  # First launch / onboarding
  # ---------------------------------------------------------------------------

  Scenario: First launch prompts profile creation
    Given the app has just been installed and launched for the first time
    When the app loads
    Then I am shown an onboarding screen prompting me to create my first profile
    And I am not shown any empty data screens until at least one profile exists

  # ---------------------------------------------------------------------------
  # Opt-in tracking
  # ---------------------------------------------------------------------------

  Scenario: Cycle tracking is off until the profile turns it on
    Given I am editing Sarah's profile
    Then cycle tracking is off
    And Quick Log does not offer a Cycle chip

  Scenario: Turning on cycle tracking is stored on that profile only
    Given I am editing Sarah's profile
    When I turn on cycle tracking
    And I save the profile
    Then Sarah's profile has cycle tracking enabled
    And other profiles are unchanged

  Scenario: Bowel and bladder tracking is off until the profile turns it on
    Given I am editing Sarah's profile
    Then bowel and bladder tracking is off
    And Quick Log does not offer a Bowel chip
    And no bowel or bladder entry is created from ordinary text

  Scenario: Turning on bowel tracking is stored on that profile only
    Given I am editing Sarah's profile
    When I turn on bowel and bladder tracking
    And I save the profile
    Then Sarah's profile has bowel tracking enabled
    And Quick Log may suggest a Bowel chip when the text is about a bowel or bladder event

Feature: Meal and Food Logging
  As a primary user
  I want to log meals and flag reactions for the active profile
  So that I can identify food triggers and share diet history with medical providers

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Logging a meal
  # ---------------------------------------------------------------------------

  Scenario: Log a meal with description only
    When I open the new meal entry screen
    Then the date and time fields default to the current date and time
    When I enter "Grilled salmon with steamed broccoli and rice" as the meal description
    And I save the entry
    Then a meal entry is saved for "Sarah" with that description and the current timestamp

  Scenario: Log a meal with a past date and time
    When I open the new meal entry screen
    And I change the date to "2026-02-16" and the time to "12:30"
    And I enter "Chicken soup and sourdough bread" as the meal description
    And I save the entry
    Then the meal entry is saved with the timestamp "2026-02-16 12:30"

  Scenario: Log a meal with optional notes
    When I open the new meal entry screen
    And I enter "Thai green curry, restaurant meal" as the meal description
    And I enter "Was quite spicy, ate about half a portion" as the notes
    And I save the entry
    Then the meal entry is saved with the notes intact

  Scenario: Log a meal with a photo taken from the camera
    When I open the new meal entry screen
    And I enter "Homemade pasta" as the meal description
    And I take a photo using the camera
    And I save the entry
    Then the meal entry is saved with the photo attached

  Scenario: Log a meal with a photo chosen from the library
    When I open the new meal entry screen
    And I enter "Avocado toast" as the meal description
    And I choose a photo from the library
    And I save the entry
    Then the meal entry is saved with the selected photo attached

  Scenario: Log a meal without a photo
    When I open the new meal entry screen
    And I enter "Apple and peanut butter" as the meal description
    And I do not add a photo
    And I save the entry
    Then the meal entry is saved without a photo

  Scenario: Cannot save a meal entry without a description
    When I open the new meal entry screen
    And I leave the meal description empty
    And I attempt to save the entry
    Then I see a validation error indicating a description is required
    And no meal entry is saved

  # ---------------------------------------------------------------------------
  # Flagging a reaction
  # ---------------------------------------------------------------------------

  Scenario: Flag a meal as followed by a reaction at time of logging
    When I open the new meal entry screen
    And I enter "Prawn stir-fry" as the meal description
    And I toggle the reaction flag on
    And I save the entry
    Then the meal entry for "Prawn stir-fry" is saved with a reaction flag

  Scenario: Flag a previously saved meal as having caused a reaction
    Given "Sarah" has a meal entry for "Prawn stir-fry" with no reaction flag
    When I open the detail view for the "Prawn stir-fry" meal entry
    And I toggle the reaction flag on
    And I save the changes
    Then the "Prawn stir-fry" meal entry is updated with a reaction flag

  Scenario: A reaction-flagged meal is linked to nearby symptom entries
    Given "Sarah" has the following entries on "2026-02-16":
      | Type    | Description   | Timestamp |
      | Meal    | Prawn stir-fry| 18:30     |
      | Symptom | Hives         | 20:00     |
      | Symptom | Stomach pain  | 20:30     |
    When I open the detail view for the "Prawn stir-fry" meal entry
    And I toggle the reaction flag on
    And I save the changes
    Then the meal entry shows the nearby symptoms "Hives" and "Stomach pain" as potential associations
    And the symptom entries show the meal "Prawn stir-fry" as a potential food-related trigger

  Scenario: Remove a reaction flag from a meal entry
    Given "Sarah" has a meal entry for "Prawn stir-fry" with a reaction flag
    When I open the detail view for the "Prawn stir-fry" entry
    And I toggle the reaction flag off
    And I save the changes
    Then the meal entry no longer has a reaction flag

  # ---------------------------------------------------------------------------
  # Viewing meal history
  # ---------------------------------------------------------------------------

  Scenario: View meal history in reverse chronological order
    Given "Sarah" has the following meal entries:
      | Description          | Timestamp           |
      | Porridge with berries| 2026-02-15 08:00    |
      | Chicken salad        | 2026-02-15 13:00    |
      | Prawn stir-fry       | 2026-02-15 18:30    |
    When I navigate to the meal log for "Sarah"
    Then I see all three entries listed in reverse chronological order
    And the most recent entry "Prawn stir-fry" appears first

  Scenario: View the detail of a meal entry including photo
    Given "Sarah" has a meal entry for "Homemade pasta" with a photo and the note "Used gluten-free pasta"
    When I navigate to the meal log
    And I tap the "Homemade pasta" entry
    Then I see the full detail of the entry including the photo, description, timestamp, and note

  Scenario: Reaction-flagged meals are visually marked in the meal list
    Given "Sarah" has the following meal entries:
      | Description    | Reaction flagged |
      | Toast          | No               |
      | Prawn stir-fry | Yes              |
    When I navigate to the meal log
    Then the "Prawn stir-fry" entry has a visible reaction indicator
    And the "Toast" entry does not

  # ---------------------------------------------------------------------------
  # Editing and deleting meal entries
  # ---------------------------------------------------------------------------

  Scenario: Edit a meal description
    Given "Sarah" has a meal entry for "Pasta"
    When I open the detail view for "Pasta"
    And I edit the description to "Gluten-free pasta with tomato sauce"
    And I save the changes
    Then the meal entry now shows "Gluten-free pasta with tomato sauce"

  Scenario: Remove a photo from a meal entry
    Given "Sarah" has a meal entry for "Avocado toast" with a photo attached
    When I open the detail view for "Avocado toast"
    And I remove the photo
    And I save the changes
    Then the meal entry no longer has a photo attached

  # Where photos are kept (#105). A picked photo is copied into the app's
  # own photos folder, so the OS can't clear it and it goes when its entry
  # does. Profile pictures work the same way (profiles.feature).
  # UNVERIFIED (TODO #105): the scenarios below are agent-written.

  @unverified
  Scenario: A meal photo stays after the app is closed and updated
    Given I log a meal with a photo
    When the app is closed, the phone clears its temporary files, and the app is updated
    Then the meal still shows its photo

  @unverified
  Scenario: Removing a photo or deleting the meal deletes the photo file
    Given "Sarah" has a meal entry with a photo
    When I remove the photo, or delete the meal, or delete Sarah's profile
    Then the photo is deleted from the phone

  @unverified
  Scenario: Deleting a meal with a photo says the photo goes too
    Given "Sarah" has a meal entry with a photo
    When I choose to delete the meal
    Then the confirmation says "This will permanently remove this meal entry and its photo. If the photo isn't saved anywhere else, it will be lost."

  @unverified
  Scenario: Removing a saved photo asks first
    Given "Sarah" has a meal entry with a photo
    When I tap "Remove" on the photo
    Then I am asked "Remove photo?"
    And told "The photo is deleted when you save. If it isn't saved anywhere else, it will be lost."
    When I tap "Cancel"
    Then the photo is still attached

  @unverified
  Scenario: A photo picked but not saved yet is removed without asking
    Given I picked a photo for a meal and haven't saved it
    When I tap "Remove" on the photo
    Then it is removed straight away
    And the picked file itself is left where it was

  @unverified
  Scenario: Photos are shrunk when saved
    When I attach a photo to a meal
    Then it is saved at most 1600 pixels on its longest side

  @unverified
  Scenario: Photos are in the phone's backup, except Android cloud backup
    Given "Sarah" has meals with photos
    Then the photos are in the iPhone's iCloud backup
    And they move to a new Android phone with its transfer tool
    But they are left out of Android's cloud backup, so its 25 MB limit isn't spent on them

  @unverified
  Scenario: Photos from before this update are kept where possible
    Given a meal photo saved by an earlier version
    When Health Flare is updated
    Then the photo is moved into the app's photos folder and still shows
    And a photo the phone had already cleared is removed from the meal instead of showing a broken image

  @unverified
  Scenario: A backup can't make the app show other files
    Given a backup file whose profile picture points at another file on the phone
    When I import it with "Add missing data" or "Replace everything"
    Then that profile shows its initials
    And no file outside the app's photos folder is shown or read as a photo


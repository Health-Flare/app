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

  Scenario: Delete a meal entry with confirmation
    Given "Sarah" has a meal entry for "Prawn stir-fry"
    When I navigate to the meal log
    And I choose to delete the "Prawn stir-fry" entry
    Then I am shown a confirmation dialog
    When I confirm the deletion
    Then the "Prawn stir-fry" meal entry is permanently removed from "Sarah"'s log

  Scenario: Cancel deletion of a meal entry
    Given "Sarah" has a meal entry for "Chicken salad"
    When I choose to delete the "Chicken salad" entry
    And I cancel the confirmation dialog
    Then the "Chicken salad" entry still exists in the meal log

  # ---------------------------------------------------------------------------
  # Empty state
  # ---------------------------------------------------------------------------

  Scenario: Empty meal log shows a helpful prompt
    Given "Sarah" has no meal entries
    When I navigate to the meal log
    Then I see an empty state message guiding me to log my first meal

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
  # First launch / onboarding
  # ---------------------------------------------------------------------------

  Scenario: First launch prompts profile creation
    Given the app has just been installed and launched for the first time
    When the app loads
    Then I am shown an onboarding screen prompting me to create my first profile
    And I am not shown any empty data screens until at least one profile exists

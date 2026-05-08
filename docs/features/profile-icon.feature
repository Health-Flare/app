Feature: Persistent Profile Icon
  As a user managing one or more health profiles
  I want a persistent, always-accessible profile icon in the top navigation
  So that I can see and switch the active profile from any screen without other UI getting in the way

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given the app is installed and at least one profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Placement — single persistent component
  # ---------------------------------------------------------------------------

  Scenario: Profile icon is always visible in the top navigation
    When I navigate to any screen in the app
    Then the profile icon is visible in the top navigation bar
    And the icon occupies a fixed position that does not shift between screens

  Scenario: Profile icon does not obscure any other UI element
    When I am on any screen that has AppBar actions
    Then the profile icon does not overlap any button, label, or interactive element
    And all AppBar actions remain fully visible and tappable

  Scenario: No other UI element is rendered in front of the profile icon
    When I am on any screen in the app
    Then no sheet, overlay, card, or button is rendered on top of the profile icon
    And the profile icon tap and swipe targets are always reachable

  Scenario: Profile icon does not reposition or flash during navigation
    Given "Sarah" is the active profile
    When I navigate from the Dashboard to the Journal screen
    And I navigate back to the Dashboard
    Then the profile icon remains at the same position throughout
    And no visual jump or re-render of the icon occurs

  # ---------------------------------------------------------------------------
  # Tap behaviour
  # ---------------------------------------------------------------------------

  Scenario: Tapping the profile icon opens the profile switcher
    Given "Sarah" is the active profile
    When I tap the profile icon
    Then the profile switcher sheet opens
    And I can see all available profiles

  # ---------------------------------------------------------------------------
  # Swipe to switch — two profiles
  # ---------------------------------------------------------------------------

  Scenario: Swiping up on the profile icon switches to the other profile when two exist
    Given the following profiles exist:
      | Name  |
      | Sarah |
      | Dad   |
    And "Sarah" is the active profile
    When I swipe up on the profile icon
    Then "Dad" becomes the active profile
    And all content on screen updates to reflect "Dad"'s data
    And the profile icon updates to show "Dad"'s avatar

  Scenario: Swiping down on the profile icon switches to the other profile when two exist
    Given the following profiles exist:
      | Name  |
      | Sarah |
      | Dad   |
    And "Dad" is the active profile
    When I swipe down on the profile icon
    Then "Sarah" becomes the active profile
    And all content on screen updates to reflect "Sarah"'s data

  # ---------------------------------------------------------------------------
  # Swipe to switch — three or more profiles
  # ---------------------------------------------------------------------------

  Scenario: Swiping up moves to the profile above the current one in the list
    Given the following profiles exist in order:
      | Name    |
      | Sarah   |
      | Dad     |
      | Brother |
    And "Dad" is the active profile
    When I swipe up on the profile icon
    Then "Sarah" becomes the active profile

  Scenario: Swiping up from the topmost profile wraps around to the bottom profile
    Given the following profiles exist in order:
      | Name    |
      | Sarah   |
      | Dad     |
      | Brother |
    And "Sarah" is the active profile
    When I swipe up on the profile icon
    Then "Brother" becomes the active profile

  Scenario: Swiping down moves to the profile below the current one in the list
    Given the following profiles exist in order:
      | Name    |
      | Sarah   |
      | Dad     |
      | Brother |
    And "Dad" is the active profile
    When I swipe down on the profile icon
    Then "Brother" becomes the active profile

  Scenario: Swiping down from the bottommost profile wraps around to the first profile
    Given the following profiles exist in order:
      | Name    |
      | Sarah   |
      | Dad     |
      | Brother |
    And "Brother" is the active profile
    When I swipe down on the profile icon
    Then "Sarah" becomes the active profile

  # ---------------------------------------------------------------------------
  # Swipe is a no-op when only one profile exists
  # ---------------------------------------------------------------------------

  Scenario: Swiping the profile icon has no effect when only one profile exists
    Given only one profile named "Sarah" exists
    When I swipe up on the profile icon
    Then "Sarah" remains the active profile
    And no switcher sheet or dialog appears
    When I swipe down on the profile icon
    Then "Sarah" remains the active profile

  # ---------------------------------------------------------------------------
  # Draft protection during swipe switch
  # ---------------------------------------------------------------------------

  Scenario: Swiping to switch profile while a data entry form is open prompts to discard
    Given "Sarah" is the active profile
    And I have opened the add symptom screen and entered "Knee pain"
    When I swipe on the profile icon
    Then I see a confirmation dialog with two equally visible options:
      | Option        |
      | Discard entry |
      | Keep editing  |
    And the dialog makes clear the entry has not been saved

  Scenario: Confirming the discard from a swipe switch completes the profile change
    Given "Sarah" is the active profile
    And I have opened the add symptom screen and entered "Knee pain"
    When I swipe on the profile icon
    And I tap "Discard entry"
    Then the next profile in the swipe direction becomes active
    And the draft symptom entry is discarded

  Scenario: Cancelling the discard from a swipe switch returns to the current form
    Given "Sarah" is the active profile
    And I have opened the add symptom screen and entered "Knee pain"
    When I swipe on the profile icon
    And I tap "Keep editing"
    Then I remain on the add symptom screen
    And the text "Knee pain" is still in the entry field
    And "Sarah" is still the active profile

  # ---------------------------------------------------------------------------
  # Visual feedback
  # ---------------------------------------------------------------------------

  Scenario: Profile icon shows the active profile's avatar at all times
    Given a profile named "Sarah" exists with a photo avatar
    And "Sarah" is the active profile
    When I navigate to any screen in the app
    Then the profile icon displays "Sarah"'s photo avatar

  Scenario: Profile icon updates immediately after a swipe switch
    Given the following profiles exist:
      | Name  |
      | Sarah |
      | Dad   |
    And "Sarah" is the active profile
    When I swipe on the profile icon and "Dad" becomes active
    Then the profile icon immediately shows "Dad"'s avatar
    And there is no delay or intermediate blank state

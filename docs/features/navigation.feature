Feature: Navigation and General UX
  As a primary user
  I want clear, fast navigation and quick entry throughout the app
  So that logging health data is effortless and the app never feels confusing

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given a profile named "Sarah" exists and is active
    And "Sarah" has some existing health data

  # ---------------------------------------------------------------------------
  # Primary navigation
  # ---------------------------------------------------------------------------

  Scenario: Primary navigation gives access to all main sections
    When the app is open with "Sarah" as the active profile
    Then the primary navigation contains the following destinations:
      | Destination        |
      | Dashboard          |
      | Symptoms & Vitals  |
      | Medications        |
      | Meals              |
      | Reports            |

  Scenario: Navigate to the Dashboard
    When I tap "Dashboard" in the primary navigation
    Then I am shown the dashboard for "Sarah"
    And the dashboard shows a recent summary of logged data

  Scenario: Navigate to Symptoms and Vitals
    When I tap "Symptoms & Vitals" in the primary navigation
    Then I am shown the symptom and vitals log screen for "Sarah"

  Scenario: Navigate to Medications
    When I tap "Medications" in the primary navigation
    Then I am shown the medications screen for "Sarah"

  Scenario: Navigate to Meals
    When I tap "Meals" in the primary navigation
    Then I am shown the meal log screen for "Sarah"

  Scenario: Navigate to Reports
    When I tap "Reports" in the primary navigation
    Then I am shown the reports configuration screen for "Sarah"

  # ---------------------------------------------------------------------------
  # Quick entry
  # ---------------------------------------------------------------------------

  Scenario: Log a new symptom in 3 taps or fewer from any screen
    When I am on the Dashboard screen
    Then I can open a new symptom entry within 3 taps
    When I am on the Medications screen
    Then I can open a new symptom entry within 3 taps
    When I am on the Meals screen
    Then I can open a new symptom entry within 3 taps

  Scenario: Log a new vital in 3 taps or fewer from any screen
    When I am on any main screen
    Then I can open a new vital entry within 3 taps

  Scenario: Log a new dose in 3 taps or fewer from any screen
    When I am on any main screen
    Then I can open a new dose log entry within 3 taps

  Scenario: Log a new meal in 3 taps or fewer from any screen
    When I am on any main screen
    Then I can open a new meal entry within 3 taps

  Scenario: Quick entry form pre-fills the timestamp with the current date and time
    When I open any quick entry form
    Then the date and time fields are pre-filled with the current date and time

  # ---------------------------------------------------------------------------
  # Profile switcher
  # ---------------------------------------------------------------------------

  Scenario: Active profile name is always visible
    When I navigate to any screen in the app
    Then the active profile name "Sarah" is visible in a persistent location on screen

  Scenario: Profile switcher is accessible from any screen
    Given the following profiles exist:
      | Name  |
      | Sarah |
      | Dad   |
    When I am on any main screen
    Then I can open the profile switcher
    And I can see all available profiles listed

  Scenario: Switching profile from any screen updates all content
    Given the following profiles exist:
      | Name  |
      | Sarah |
      | Dad   |
    And "Sarah" is the active profile
    When I open the profile switcher from the Meals screen
    And I select "Dad"
    Then "Dad" becomes the active profile
    And the Meals screen now shows "Dad"'s meal data
    And the persistent profile indicator shows "Dad"

  # ---------------------------------------------------------------------------
  # First launch / onboarding empty states
  # ---------------------------------------------------------------------------

  Scenario: First launch shows onboarding instead of empty data screens
    Given the app has just been installed
    When I open the app for the first time
    Then I am shown a welcome or onboarding screen
    And I am prompted to create my first profile
    And I am not shown any data lists or logs until a profile is created

  Scenario: Dashboard empty state guides the user
    Given a newly created profile "NewUser" is active with no logged data
    When I navigate to the Dashboard
    Then I see an empty state that clearly communicates that no data has been logged yet
    And I am shown clear calls-to-action to log a symptom, vital, meal, or medication

  Scenario: Each log screen shows a helpful empty state when no data exists
    Given "Sarah" has no data logged
    When I navigate to the "Symptoms & Vitals" screen
    Then I see an empty state message guiding me to log my first symptom or vital
    When I navigate to the "Medications" screen
    Then I see an empty state message guiding me to add my first medication
    When I navigate to the "Meals" screen
    Then I see an empty state message guiding me to log my first meal

  # ---------------------------------------------------------------------------
  # Data privacy
  # ---------------------------------------------------------------------------

  Scenario: No data is transmitted without an explicit user action
    Given the app is running normally
    When the user has not triggered any export or share action
    Then no health data is sent over the network
    And all data remains on the device

  Scenario: Exporting data requires an explicit user action
    When I generate a report and export it as PDF
    Then I must explicitly tap a share or save button before any file leaves the app
    And I am shown the OS share sheet to choose where the file goes

Feature: Onboarding
  As a first-time user
  I want a clear, warm, and trustworthy introduction to Health Flare
  So that I understand what the app does, trust it with my health data,
  and feel genuinely set up for success from my very first session

  # ---------------------------------------------------------------------------
  # Trigger: when onboarding is shown
  # ---------------------------------------------------------------------------

  Scenario: Onboarding is shown on first launch when no profiles exist
    Given the app has been installed and launched for the first time
    And no profiles exist on this device
    When the app loads
    Then I am shown the top of the onboarding screen
    And I am not shown any log screens, dashboard, or navigation

  Scenario: Onboarding is not shown if a profile already exists
    Given at least one profile exists on this device
    When the app launches
    Then I am taken directly to the dashboard for the last active profile
    And the onboarding screen is not shown

  Scenario: Onboarding cannot be skipped or dismissed
    Given I am on the onboarding screen
    When I attempt to navigate away without completing profile creation
    Then I remain on the onboarding screen
    And no navigation to the main app is possible until a profile is saved

  # ---------------------------------------------------------------------------
  # Zone 1: Purpose and welcome message
  # ---------------------------------------------------------------------------

  Scenario: Welcome message is visible on the onboarding screen
    Given I am on the onboarding screen
    Then I see the app name "Health Flare"
    And I see a short welcome headline communicating the app's purpose
    And I see a brief supporting statement that positions the app as a health companion, not a medical device
    And the tone is warm and encouraging, not clinical

  Scenario: Medical disclaimer is present but not alarming
    Given I am on the onboarding screen
    Then I can see a plain-language statement clarifying that Health Flare is not a medical device
    And the statement does not use fear language or warnings
    And the statement is clearly readable without scrolling on a standard screen size

  # ---------------------------------------------------------------------------
  # Zone 2: Privacy and data promise
  # ---------------------------------------------------------------------------

  Scenario: Primary privacy promise is prominently displayed
    Given I am on the onboarding screen
    Then I see a prominent headline stating that all data stays on this device
    And this statement appears before the profile creation form

  Scenario: Supporting privacy facts are visible below the headline
    Given I am on the onboarding screen
    Then I see at least 3 and no more than 4 concise supporting privacy statements
    And one statement confirms no account or login is required
    And one statement confirms no data is uploaded to any cloud or server
    And one statement confirms data only leaves the device when the user explicitly exports or shares it

  Scenario: "Learn more" expands a plain-English privacy detail section
    Given I am on the onboarding screen
    When I tap "Learn more" under the privacy section
    Then an expanded privacy explanation is shown inline without navigating away
    And the expanded content explains in plain English exactly where data is stored, what is collected, and what is never collected
    And the expanded content is written to be understandable by a non-technical user
    And the expanded content contains enough technical detail to satisfy a privacy-conscious technical user

  Scenario: "Learn more" section can be collapsed again
    Given I have expanded the privacy "Learn more" section
    When I tap to collapse it
    Then the expanded content is hidden
    And the onboarding screen returns to its default state

  Scenario: Privacy section uses specific, verifiable language
    Given I am on the onboarding screen
    Then no privacy statement uses vague language such as "we value your privacy" or "we care about your data"
    And every privacy claim is specific and describes a concrete behaviour of the app

  # ---------------------------------------------------------------------------
  # Zone 3: Profile creation (inline, no navigation)
  # ---------------------------------------------------------------------------

  Scenario: Profile creation form is present on the onboarding screen
    Given I am on the onboarding screen
    Then I see a profile creation form below the privacy section
    And the form contains a required name field
    And the form contains an optional date of birth field
    And the form contains an optional avatar or photo field
    And the form contains an optional illness selector
    And there is a clearly labelled primary action button to complete setup

  Scenario: Complete onboarding with a name only
    Given I am on the onboarding screen
    When I enter "Sarah" in the name field
    And I tap the primary action button
    Then a profile named "Sarah" is created
    And I am taken into the main app
    And the first-log prompt is shown

  Scenario: Complete onboarding with all profile fields filled
    Given I am on the onboarding screen
    When I enter "Dad" in the name field
    And I enter "1952-04-10" in the date of birth field
    And I choose a photo from the library as the avatar
    And I tap the primary action button
    Then a profile named "Dad" is created with the date of birth and avatar saved
    And I am taken into the main app
    And the first-log prompt is shown

  Scenario: Cannot complete onboarding without entering a profile name
    Given I am on the onboarding screen
    When I leave the name field empty
    And I tap the primary action button
    Then I see a validation message indicating a name is required
    And I remain on the onboarding screen
    And no profile is created

  Scenario: Profile name field is focused automatically on load
    Given I am on the onboarding screen
    Then the name input field has focus
    And on devices with a software keyboard the keyboard is visible

  Scenario: Profile name containing only whitespace is rejected
    Given I am on the onboarding screen
    When I enter "   " in the name field
    Then the primary action button remains disabled
    And no profile is created

  Scenario: Photo library access denied shows a helpful inline message
    Given I am on the onboarding screen
    When I tap the avatar field
    And I deny photo library permission
    Then a brief message explains that photo access was not granted
    And the profile creation form remains usable without a photo

  # ---------------------------------------------------------------------------
  # Post-setup: first-log prompt
  # ---------------------------------------------------------------------------

  Scenario: First-log prompt is shown immediately after onboarding is complete
    Given I have just completed onboarding and created my first profile
    When I enter the main app
    Then I am shown the first-log prompt
    And the prompt is warm and encouraging in tone
    And the prompt briefly explains why logging regularly helps identify patterns over time

  Scenario: First-log prompt offers five entry options
    Given the first-log prompt is visible
    Then I can see five options:
      | Option        |
      | An illness    |
      | A symptom     |
      | A vital       |
      | A meal        |
      | A medication  |

  Scenario: Tapping a first-log option opens the relevant entry form
    Given the first-log prompt is visible
    When I tap "A symptom"
    Then the new symptom entry form opens
    And when I save it I am returned to the dashboard

  Scenario: Tapping "An illness" from the first-log prompt opens the illness entry form
    Given the first-log prompt is visible
    When I tap "An illness"
    Then the first-log prompt closes
    And the illness entry screen opens full-screen
    And I can see a search bar at the top
    And I can see a scrollable list of conditions below the search bar

  # ---------------------------------------------------------------------------
  # Illness entry screen — search and filter
  # ---------------------------------------------------------------------------

  Scenario: Condition list is shown in alphabetical order on the illness screen
    Given the illness entry screen is open
    And the search bar is empty
    Then all conditions are listed in alphabetical order
    And no conditions are pre-selected

  Scenario: Typing in the search bar filters the condition list live
    Given the illness entry screen is open
    When I type "arth" in the search bar
    Then the condition list updates immediately to show only conditions that contain "arth"
    And conditions whose names begin with "arth" appear before conditions that merely contain "arth"
    And within each group the conditions remain in alphabetical order

  Scenario: Clearing the search bar restores the full alphabetical list
    Given I have typed "arth" in the illness search bar
    When I clear the search bar
    Then the full condition list is shown in alphabetical order again

  Scenario: Search is case-insensitive
    Given the illness entry screen is open
    When I type "CROHN" in the search bar
    Then the condition list shows "Crohn's disease" as a result
    And the match is not affected by the capitalisation I entered

  # ---------------------------------------------------------------------------
  # Illness entry screen — selecting one or more conditions
  # ---------------------------------------------------------------------------

  Scenario: Tapping a condition marks it as selected
    Given the illness entry screen is open
    When I tap "Arthritis" in the condition list
    Then "Arthritis" is marked as selected with a filled check indicator
    And "Arthritis" appears as a removable chip above the condition list

  Scenario: Multiple conditions can be selected simultaneously
    Given the illness entry screen is open
    When I tap "Arthritis" in the condition list
    And I tap "Fibromyalgia" in the condition list
    Then both "Arthritis" and "Fibromyalgia" are marked as selected
    And both appear as removable chips above the condition list

  Scenario: Tapping the remove icon on a selected chip deselects the condition
    Given I have selected "Arthritis" on the illness entry screen
    When I tap the remove icon on the "Arthritis" chip
    Then "Arthritis" is no longer marked as selected in the list
    And the "Arthritis" chip is removed from the chip row

  Scenario: Already-tracked conditions are excluded from the selectable list
    Given the active profile is already tracking "Crohn's disease"
    When I open the illness entry screen
    Then "Crohn's disease" does not appear in the selectable condition list
    And I cannot add it a second time

  # ---------------------------------------------------------------------------
  # Illness entry screen — custom condition entry
  # ---------------------------------------------------------------------------

  Scenario: Custom condition search text containing only whitespace shows no Add option
    Given the illness entry screen is open
    When I type "   " in the search bar
    Then the "Add custom" option is not shown

  Scenario: Searching for an exact catalogue match suppresses the Add custom option
    Given the illness entry screen is open
    When I type "ARTHRITIS" in the search bar
    And "Arthritis" exists in the condition catalogue
    Then the "Add custom" option is not shown
    And "Arthritis" appears in the filtered results

  Scenario: An "Add custom" option appears when no condition matches the search
    Given the illness entry screen is open
    When I type "Myalgic encephalomyelitis" in the search bar
    And no existing condition exactly matches "Myalgic encephalomyelitis"
    Then I see an option to add "Myalgic encephalomyelitis" as a custom illness

  Scenario: Tapping "Add custom" creates and selects the custom condition
    Given no condition matches my search text on the illness entry screen
    When I tap the "Add custom" option for my search text
    Then a new condition with that name is created in the catalogue with global = false
    And the new condition is immediately selected
    And it appears as a chip in the selected chips row
    And the search bar is cleared

  # ---------------------------------------------------------------------------
  # Illness entry screen — common symptom quick-add
  # ---------------------------------------------------------------------------

  Scenario: The symptom quick-add section appears after at least one condition is selected
    Given the illness entry screen is open
    And no conditions are selected
    Then the symptom quick-add section is not visible
    When I select "Arthritis"
    Then a "Common Symptoms" section becomes visible below the condition list
    And I can see a descriptive label explaining that I can tap chips to add symptoms to track

  Scenario: All catalogue symptoms are shown as tappable chips in the quick-add section
    Given I have selected at least one condition on the illness entry screen
    Then I can see the full symptom catalogue presented as filter chips
    And the chips are arranged in a wrapping grid layout
    And the chips are listed in alphabetical order

  Scenario: The symptom chip list is filtered by the same search bar
    Given I have selected at least one condition on the illness entry screen
    When I type "pain" in the search bar
    Then the condition list filters to conditions containing "pain"
    And the symptom chip section also filters to symptoms containing "pain"

  Scenario: Tapping a symptom chip marks it as added
    Given the symptom quick-add section is visible
    When I tap the "Fatigue" chip
    Then the "Fatigue" chip is shown in its selected/added state
    And a checkmark or filled style indicates it has been chosen

  Scenario: Tapping a selected symptom chip removes it from the pending selection
    Given I have tapped "Fatigue" and it is in its selected state
    When I tap the "Fatigue" chip again
    Then the "Fatigue" chip returns to its unselected state
    And it will not be saved when I tap Done

  Scenario: Already-tracked symptoms are shown as added and cannot be removed on this screen
    Given the active profile is already tracking "Joint pain"
    And the symptom quick-add section is visible
    Then the "Joint pain" chip is shown in its added state
    And tapping the "Joint pain" chip has no effect

  Scenario: Symptom quick-add section remains visible with multiple conditions selected
    Given I have selected "Arthritis" and "Lupus" on the illness entry screen
    Then the symptom quick-add section is visible
    And all catalogue symptoms are shown regardless of which conditions are selected

  # ---------------------------------------------------------------------------
  # Illness entry screen — saving and navigation
  # ---------------------------------------------------------------------------

  Scenario: Done button is enabled only when at least one condition or symptom is pending
    Given the illness entry screen is open
    And I have not selected any condition or symptom
    Then the "Done" button is disabled

  Scenario: Selecting a condition enables the Done button
    Given the illness entry screen is open
    When I tap "Arthritis"
    Then the "Done" button becomes enabled

  Scenario: Tapping Done saves all selected conditions to the active profile
    Given I have selected "Arthritis" and "Fibromyalgia" on the illness entry screen
    When I tap "Done"
    Then a UserCondition record is created for "Arthritis" linked to the active profile
    And a UserCondition record is created for "Fibromyalgia" linked to the active profile
    And I am returned to the dashboard

  Scenario: Tapping Done saves all selected symptoms to the active profile
    Given I have selected "Arthritis" on the illness entry screen
    And I have tapped the "Fatigue" and "Joint pain" symptom chips
    When I tap "Done"
    Then a UserSymptom record is created for "Fatigue" linked to the active profile
    And a UserSymptom record is created for "Joint pain" linked to the active profile
    And I am returned to the dashboard

  Scenario: Tapping Done with both conditions and symptoms selected saves all
    Given I have selected "Lupus" and tapped the "Fatigue" and "Rash" chips
    When I tap "Done"
    Then "Lupus" is saved as a tracked condition for the active profile
    And "Fatigue" and "Rash" are saved as tracked symptoms for the active profile
    And I am returned to the dashboard

  Scenario: Navigating back from the illness screen without tapping Done discards all pending selections
    Given I have selected "Arthritis" and the "Fatigue" chip on the illness entry screen
    When I navigate back without tapping "Done"
    Then no new UserCondition or UserSymptom records are created
    And the active profile's tracked conditions and symptoms are unchanged

  Scenario: Tapping "A vital" from the first-log prompt opens the vital entry form
    Given the first-log prompt is visible
    When I tap "A vital"
    Then the new vital entry form opens

  Scenario: Tapping "A meal" from the first-log prompt opens the meal entry form
    Given the first-log prompt is visible
    When I tap "A meal"
    Then the new meal entry form opens

  Scenario: Tapping "A medication" from the first-log prompt opens the add medication form
    Given the first-log prompt is visible
    When I tap "A medication"
    Then the add medication form opens

  Scenario: Closing an entry form without saving does not re-show the first-log prompt
    Given the first-log prompt is visible
    When I tap "An illness"
    And I navigate back from the illness screen without saving
    Then I am returned to the dashboard
    And the first-log prompt is not shown again

  Scenario: First-log prompt can be dismissed to explore freely
    Given the first-log prompt is visible
    When I dismiss the prompt
    Then I am taken to the main dashboard
    And the prompt does not appear again for this profile

  Scenario: First-log prompt only appears once per profile
    Given I dismissed the first-log prompt after creating profile "Sarah"
    When I close and reopen the app
    Then the first-log prompt is not shown again
    And I am taken directly to the dashboard for "Sarah"

  Scenario: First-log prompt does not appear for subsequent profiles
    Given profile "Sarah" already exists and onboarding is complete
    When I create a new profile "Dad" from the profile settings
    Then the first-log prompt is shown for "Dad"
    But the full onboarding screen is not shown again

  # ---------------------------------------------------------------------------
  # Accessibility
  # ---------------------------------------------------------------------------

  Scenario: Onboarding screen meets WCAG 2.1 AA colour contrast requirements
    Given I am on the onboarding screen
    Then all text elements meet a minimum contrast ratio of 4.5:1 against their background
    And all large text elements meet a minimum contrast ratio of 3:1 against their background

  Scenario: All interactive elements on the onboarding screen are accessible via keyboard
    Given I am using a device with a hardware keyboard (desktop or web)
    When I navigate the onboarding screen using the Tab key
    Then every interactive element receives focus in a logical order
    And I can trigger the primary action button using the Enter or Space key

  Scenario: Onboarding screen is compatible with screen readers
    Given a screen reader is active
    When the onboarding screen loads
    Then all text content is announced in a logical reading order
    And the name input field has a descriptive accessible label
    And the primary action button has a descriptive accessible label
    And no information is conveyed by colour alone

  Scenario: Onboarding text is readable at increased system font sizes
    Given the device system font size is set to the largest accessible option
    When the onboarding screen loads
    Then all text remains readable and does not overflow or overlap other elements
    And the profile creation form remains fully usable

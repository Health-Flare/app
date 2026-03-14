Feature: Illness Tracking
  As a user managing a chronic illness
  I want to find, select, and save conditions and symptoms
  So that my health data is organised around what I actually live with

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Initial state
  # ---------------------------------------------------------------------------

  Scenario: Condition list is shown in alphabetical order on the illness screen
    Given the illness entry screen is open
    And the search bar is empty
    Then all conditions are listed in alphabetical order
    And no conditions are pre-selected

  # ---------------------------------------------------------------------------
  # Search and filter
  # ---------------------------------------------------------------------------

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
  # Selecting conditions
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
  # Custom condition entry
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
  # Common symptom quick-add
  # ---------------------------------------------------------------------------

  Scenario: The symptom quick-add section is hidden when no condition is selected
    Given the illness entry screen is open
    And no conditions are selected
    Then the symptom quick-add section is not visible

  Scenario: The symptom quick-add section appears after at least one condition is selected
    Given the illness entry screen is open
    And no conditions are selected
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
  # "Add to profile" button — layout and state
  # ---------------------------------------------------------------------------

  Scenario: A prominent "Add to profile" button is fixed at the bottom of the screen
    Given the illness entry screen is open
    Then I can see an "Add to profile" button fixed at the bottom of the screen
    And the button is not in the app bar
    And the condition list scrolls independently above the button

  Scenario: "Add to profile" is disabled when nothing is selected
    Given the illness entry screen is open
    And I have not selected any condition or symptom
    Then the "Add to profile" button is disabled

  Scenario: Selecting a condition enables "Add to profile"
    Given the illness entry screen is open
    When I tap "Arthritis"
    Then the "Add to profile" button becomes enabled

  Scenario: Selecting only a symptom also enables "Add to profile"
    Given I have selected at least one condition on the illness entry screen
    When I tap the "Fatigue" chip
    Then the "Add to profile" button becomes enabled

  # ---------------------------------------------------------------------------
  # Saving and navigation
  # ---------------------------------------------------------------------------

  Scenario: Tapping "Add to profile" saves all selected conditions to the active profile
    Given I have selected "Arthritis" and "Fibromyalgia" on the illness entry screen
    When I tap "Add to profile"
    Then a UserCondition record is created for "Arthritis" linked to the active profile
    And a UserCondition record is created for "Fibromyalgia" linked to the active profile
    And I am returned to the dashboard

  Scenario: Tapping "Add to profile" saves all selected symptoms to the active profile
    Given I have selected "Arthritis" on the illness entry screen
    And I have tapped the "Fatigue" and "Joint pain" symptom chips
    When I tap "Add to profile"
    Then a UserSymptom record is created for "Fatigue" linked to the active profile
    And a UserSymptom record is created for "Joint pain" linked to the active profile
    And I am returned to the dashboard

  Scenario: Tapping "Add to profile" with both conditions and symptoms selected saves all
    Given I have selected "Lupus" and tapped the "Fatigue" and "Rash" chips
    When I tap "Add to profile"
    Then "Lupus" is saved as a tracked condition for the active profile
    And "Fatigue" and "Rash" are saved as tracked symptoms for the active profile
    And I am returned to the dashboard

  Scenario: Navigating back without tapping "Add to profile" discards all pending selections
    Given I have selected "Arthritis" and the "Fatigue" chip on the illness entry screen
    When I navigate back without tapping "Add to profile"
    Then no new UserCondition or UserSymptom records are created
    And the active profile's tracked conditions and symptoms are unchanged

  # ---------------------------------------------------------------------------
  # Diagnosis date
  # ---------------------------------------------------------------------------

  Scenario: Add a diagnosis date to a tracked condition
    Given the active profile is already tracking "Arthritis"
    When I open the details for "Arthritis"
    And I enter "2024-06-15" as the diagnosis date
    And I save the changes
    Then the "Arthritis" entry records a diagnosis date of "2024-06-15"

  # ---------------------------------------------------------------------------
  # Condition-symptom linking
  # ---------------------------------------------------------------------------

  # Symptoms are tracked at the profile level, but many users live with multiple
  # conditions that cause different and sometimes overlapping symptoms.
  # Linking symptoms to conditions lets the user and the app distinguish
  # "my fibromyalgia symptoms" from "my arthritis symptoms" in reports and flare tracking.

  Scenario: Link a tracked symptom to a tracked condition
    Given "Sarah" is tracking "Fibromyalgia" and "Joint pain" as a symptom
    When I open the details for "Joint pain" in her symptom list
    And I tap "Link to condition"
    And I select "Fibromyalgia"
    And I save
    Then "Joint pain" is linked to "Fibromyalgia" in Sarah's profile

  Scenario: A symptom can be linked to more than one condition
    Given "Sarah" is tracking "Fatigue", "Fibromyalgia", and "Lupus"
    When I link "Fatigue" to both "Fibromyalgia" and "Lupus"
    Then "Fatigue" is shown as associated with both conditions in the symptom detail

  Scenario: Symptom log entries can be attributed to a specific condition at logging time
    Given "Sarah" is tracking "Fibromyalgia" and "Arthritis"
    When I open the new symptom entry screen for "Joint pain"
    And I tap "Which condition is this related to?"
    And I select "Arthritis"
    And I save
    Then the symptom log entry records "Arthritis" as the associated condition

  Scenario: Condition attribution on a symptom entry is optional
    When I log a symptom entry and leave condition attribution blank
    And I save the entry
    Then the entry is saved without a condition attribution
    And it appears in the general symptom list

  Scenario: Tracked condition detail view shows its associated symptoms
    Given "Sarah" is tracking "Fibromyalgia"
    And the following symptoms are linked to "Fibromyalgia":
      | Symptom        |
      | Fatigue        |
      | Brain fog      |
      | Widespread pain|
    When I open the detail view for "Fibromyalgia"
    Then I see a "Linked symptoms" section listing all three
    And I can tap any symptom to view its log history

  Scenario: Symptom log filtered by condition shows only relevant entries
    Given "Sarah" has symptom entries attributed to "Fibromyalgia" and "Arthritis"
    When I navigate to the symptom log
    And I filter by "Fibromyalgia"
    Then only symptom entries attributed to "Fibromyalgia" are shown

  Scenario: Removing a condition does not delete linked symptom log entries
    Given "Sarah" is tracking "Arthritis" with linked symptom entries
    When I remove "Arthritis" from her tracked conditions
    Then the symptom log entries that were attributed to "Arthritis" are preserved
    And they remain in the symptom log without a condition attribution

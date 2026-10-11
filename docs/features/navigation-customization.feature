Feature: Your layout: features in use and the bottom bar
  As someone who tracks some things and not others
  I want to turn off what I don't use and put what I do use in the bottom bar
  So that the app fits how I manage my health, and updates don't undo that

  # Two settings, one idea: the app should fit the person.
  #
  # - Features in use (per profile): turn off a whole kind of tracking.
  #   Its tab and dashboard card go away. Its data does not, and Quick Log
  #   can still log it, with a warning (see "Quick Log").
  # - Bottom bar (per device): choose what goes in the bar and in what order.
  #
  # "Keep the old layout" from the Track and Care guide is a bar preset,
  # not a separate mode. There is one navigation system to maintain.
  #
  # Rules that keep this safe across future layout changes:
  #
  # 1. Nothing is ever unreachable by accident. A turned-off feature is one
  #    switch away in Settings. A section left out of the bar is in "More".
  # 2. Sections, tabs and features have stable ids (track, care.medications,
  #    meals, ...). Labels can change; ids cannot. A retired id must have a
  #    replacement in a mapping kept in code, with a test.
  # 3. A bar the user hasn't changed follows the default and moves with it.
  #    A bar the user has changed is never rearranged by an update.
  # 4. What's stored is the user's choice (ordered ids), never a copy of
  #    the default, plus the default-bar version last shown on this device.
  #    "Use default" stores no ids.
  # 5. Turning a feature off never deletes, hides from reports, or changes
  #    logged data. It changes what the app offers, not what it keeps.
  # 6. Layout and features in use are part of backups.

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Where it lives
  # ---------------------------------------------------------------------------

  Scenario: Layout settings are in Settings
    When I open Settings
    Then I see a "Your layout" section with "Features in use" and "Bottom bar"
    And "Bottom bar" reads "Default" until the bar is changed, then "Customized"

  # ---------------------------------------------------------------------------
  # Features in use (per profile)
  # ---------------------------------------------------------------------------

  Scenario: Features in use lists what can be turned off
    When I open Settings > Your layout > Features in use
    Then I see a switch for each of these, all on by default:
      | Feature      | Section |
      | Vitals       | Track   |
      | Meals        | Track   |
      | Sleep        | Track   |
      | Activity     | Track   |
      | Medications  | Care    |
      | Appointments | Care    |
      | Flares       | Care    |
      | Journal      | Journal |
      | Check-ins    | Journal |
    And Symptoms and Conditions are listed as always on
    And the screen says these switches apply to "Sarah"

  Scenario: Turning a feature off removes it from everyday use
    When I turn off "Meals" for "Sarah"
    Then the Meals tab is not shown in Track
    And no Meals card or prompt is shown on the dashboard
    And "Meals" is not listed when adding to the bottom bar

  Scenario: Turning a feature off keeps its data
    Given "Sarah" has 40 meals logged
    When I turn off "Meals" for "Sarah"
    Then I am told "Sarah's 40 meals are kept. Turn Meals back on any time to see them."
    And no meal is deleted or changed
    And reports and exports still offer Meals while "Sarah" has meal data

  # UNVERIFIED (TODO): agent-written wording for the case the scenario
  # above doesn't cover (#142).
  @unverified
  Scenario: Turning off a feature with nothing logged
    Given "Sarah" has no meals logged
    When I turn off "Meals" for "Sarah"
    Then I am told "Meals is off for Sarah. Turn it back on any time."

  Scenario: Turning a feature back on brings everything back
    Given "Meals" is off for "Sarah" and she has 40 meals logged
    When I turn "Meals" back on
    Then the Meals tab shows all 40 meals

  Scenario: A turned-off feature's list opened directly still shows
    Given "Meals" is off for "Sarah" and she has 40 meals logged
    When something opens the Meals list directly, such as an old link, a
      notification, or Back from a meal opened in recent activity
    Then the Meals list opens with all 40 meals
    And a line at the top reads "Meals is turned off for Sarah" with a
      "Turn on" button
    And Meals stays out of the tab row once I move to another tab
    # Data is never hidden, only not offered (#142 review).

  Scenario: Quick Log still logs a turned-off feature, and says so
    Given "Meals" is off for "Sarah"
    When I quick-log "Toast and eggs for breakfast"
    Then the Meals chip is still offered and selected
    And a warning under the sheet reads "Meals is turned off for Sarah. This
      meal will be saved and shown in recent activity, but not in Track
      until Meals is back on." with a "Turn Meals on" button
    And I can also tick "Save as a journal note too"
    When I save
    Then a meal is saved with the text as typed
    And a journal note is saved too only if I ticked it
    And the meal shows in the dashboard's recent activity
    And no Meals card comes back on the dashboard
    # Turning a feature off changes what the app offers, never what someone
    # can record. Nothing typed is lost or quietly filed somewhere else.

  Scenario: Features in use is per profile
    Given profiles "Sarah" and "Dad" exist
    When I turn off "Meals" for "Dad"
    Then the Meals tab is still shown when "Sarah" is active
    And it is hidden when "Dad" is active

  Scenario: A section with every tab turned off leaves the bar
    Given Journal and Check-ins are both off for "Sarah"
    When "Sarah" is active
    Then Journal is not shown in the bottom bar or in "More"
    And Settings > Your layout > Features in use is where it comes back

  Scenario: A section with one tab left shows no tab row
    Given Check-ins is off for "Sarah"
    When I tap "Journal"
    Then the Journal entries list opens with no tab row above it
    # Was "only Medications is on in Care", which can't happen: Conditions
    # is always on (#142).

  Scenario: Onboarding never asks this up front
    When a new profile is created
    Then every feature is on
    And Features in use is not part of onboarding
    # Asking someone to predict what they'll track before they've used the
    # app leads to turning off things they later need.

  # ---------------------------------------------------------------------------
  # Bottom bar (per device)
  # ---------------------------------------------------------------------------

  Scenario: The bottom bar screen shows the current bar
    When I open Settings > Your layout > Bottom bar
    Then I see a preview of the bar as it looks now
    And below it an ordered list of what is in the bar
    And a list of sections and screens that can be added

  Scenario: The bar holds three to five items
    When I edit the bottom bar
    Then I can't remove an item when three are left
    And I can't add an item when five are in the bar
    And each limit is explained in a line of text, not a disabled control alone

  Scenario: Dashboard is always first
    When I open Settings > Your layout > Bottom bar
    Then Dashboard is shown first with no remove or move control

  Scenario: Pin a screen to the bar
    Given the bar shows Dashboard, Track, Care and Journal
    When I add "Medications" to the bar
    Then the bar shows Dashboard, Track, Care, Journal and Medications
    And tapping "Medications" opens the Medications tab in Care
    And Care is not highlighted while Medications is open

  Scenario: A section left out of the bar goes into More
    Given the bar shows Dashboard, Track, Care and Journal
    When I remove "Journal" from the bar
    Then the bar shows Dashboard, Track, Care and More
    And More lists Journal with its tabs
    And More counts toward the five-item limit

  Scenario: More only appears when it has something in it
    Given every section with a feature on is in the bar
    Then no More item is shown

  Scenario: Reorder without dragging
    When I open Settings > Your layout > Bottom bar
    Then each item except Dashboard and More has "Move up" and "Move down" buttons
    And dragging also works
    And after each move the new position is announced, e.g. "Medications, position 3 of 5"

  Scenario: Changes apply straight away and can be undone
    When I make any change to the bar
    Then the real bar updates at once
    And a message offers "Undo" for that change

  Scenario: Reset to the default
    Given the bar is customized
    When I tap "Use default"
    Then I am asked "Go back to the default bar?" with Cancel
    And confirming restores Dashboard, Track, Care and Journal
    And "Bottom bar" reads "Default"

  Scenario: The bar can be set up close to the old one
    When I choose the "Like before" preset
    Then the bar shows Dashboard, Track, Medications, Meals and More
    And More lists Care and Journal
    And a note says "The old bar had six items. Sleep is now in Track."
    And the note has a "Change it" button that opens the bar editor
    # The release guide's "Where things moved" step shows where every old
    # button went at update time (release-guides.feature).
    # The old bar can't come back exactly: six items doesn't fit at large
    # text sizes, and it still left four screens unreachable.

  Scenario: The guide's "Keep it like before" choice uses the preset
    Given I chose "Keep it like before" in the Track and Care guide
    When I open Settings > Your layout > Bottom bar
    Then the bar matches the "Like before" preset
    And "Bottom bar" reads "Customized"

  Scenario: Pinned screens for a turned-off feature drop out quietly
    Given "Meals" is pinned to the bar
    When "Dad", who has Meals off, becomes the active profile
    Then the Meals item is not shown while "Dad" is active
    And it is back when "Sarah" is active
    And the stored bar is not changed

  # ---------------------------------------------------------------------------
  # Later updates
  # ---------------------------------------------------------------------------

  Scenario: A default bar follows a new default
    Given I never changed the bar
    When an update changes the default bar
    Then my bar becomes the new default
    And I am shown what changed: my old bar beside the new one, and where
      each item went (release-guides.feature)
    # Nobody's bar changes without them being told, customized or not.

  Scenario: Updating from 1.9.1 or earlier counts as using the default bar
    Given I last used Health Flare 1.9.1 or earlier, where the bar could not
      be changed
    When I update to a version whose default bar is different
    Then my bar becomes the new default
    And I am shown what changed, the same as anyone on the default bar
    # 1.9.1 and earlier only had the one fixed bar (Dashboard, Tracking,
    # Meds, Meals, Journal, Sleep). Every version from 1.10.0 on records
    # which default bar was last shown, so a later change can be explained.

  Scenario: Skipping versions shows the bar I last had, not one I never saw
    Given I never changed the bar
    And I skipped a version that changed the default bar
    When I update to a version that changes it again
    Then what changed is shown from the bar I last had to the new one

  Scenario: A customized bar is kept as it is
    Given I customized the bar
    When an update changes the default bar
    Then my bar stays exactly as I set it
    And the release guide says the default changed and mine was kept

  Scenario: A new tab in a later version lands in its section, switched on
    Given I customized the bar and turned off some features
    When an update adds a new tab to Track
    Then the new tab appears in Track, switched on
    And my bar and my other feature switches are not changed
    And the release guide says where the new tab is and how to turn it off

  Scenario: A pinned screen that was merged follows its replacement
    Given "Activity" is pinned to my bar
    When an update merges Activity into another tab
    Then the pin points at the tab it was merged into
    And if that tab is already in the bar, the duplicate is removed
    And the release guide names the old and the new screen

  Scenario: A turned-off feature that was merged keeps the user's choice
    Given "Activity" is off for "Sarah"
    When an update merges Activity into another tab that is on
    Then the merged tab stays on
    And the release guide tells "Sarah" that Activity data is now in that tab
    # Turning off one part of a merged feature is not the same as turning
    # off the whole thing. Tell, don't guess.

  Scenario: An id the app doesn't recognise is skipped safely
    Given the stored bar contains an id this version doesn't know
    When the app starts
    Then that item is left out of the bar
    And the rest of the bar keeps its order
    And if fewer than three items remain, the default bar is used
    And the stored choice is not rewritten until I change it

  # ---------------------------------------------------------------------------
  # Backups
  # ---------------------------------------------------------------------------

  Scenario: Replace everything restores layout and features in use
    Given a backup was made with a customized bar and Meals off for "Sarah"
    When I restore it with "Replace everything"
    Then the bar is as it was in the backup
    And Meals is off for "Sarah"

  Scenario: Add missing data keeps this device's bar if it was customized
    Given this device has a customized bar
    And the backup has a different customized bar
    When I import with "Add missing data"
    Then this device's bar is kept

  Scenario: Add missing data takes the backup's bar onto a default device
    Given this device has never changed the bar
    And the backup has a customized bar
    When I import with "Add missing data"
    Then the bar becomes the backup's bar
    And a message says "Bottom bar restored from the backup. Change it in Settings > Your layout."

  Scenario: Features in use travel with their profile
    Given the backup has profile "Dad" with Meals off
    And this device has no profile "Dad"
    When I import with "Add missing data"
    Then "Dad" is added with Meals off

  Scenario: A profile that exists on both keeps this device's switches
    Given "Sarah" exists on this device with Meals on
    And the backup has "Sarah" with Meals off
    When I import with "Add missing data"
    Then Meals stays on for "Sarah"

  Scenario: Choose what to import lists layout as its own item
    When I import with "Choose what to import"
    Then "Bottom bar and layout" is listed with the data categories
    And it is unticked by default when this device's bar is customized

  Scenario: A backup from a newer version with unknown ids still imports
    Given the backup's bar contains ids this version doesn't know
    When I restore it
    Then the bar follows the "id the app doesn't recognise" rule
    And the import does not fail

  # ---------------------------------------------------------------------------
  # Accessibility
  # ---------------------------------------------------------------------------

  Scenario: Bar labels stay readable with large text
    Given the system text size is set to 200%
    When the bar has five items
    Then the bar shows icons only
    And each item's label is read by screen readers
    And a long press on an item shows its label
    And every item is at least 48 by 48 dp

  Scenario: The settings screens work with a screen reader
    Given a screen reader is active
    When I open Settings > Your layout > Bottom bar
    Then each item is read with its position and available actions
    And the preview is read as "Bottom bar: Dashboard, Track, Care, Journal"
    And each feature switch in Features in use is read with its on or off state and the profile name

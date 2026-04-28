Feature: Quick Log
  As a primary user
  I want to tap a single + button from the dashboard and type freely
  So that I can capture anything relevant to my health in one motion,
  without deciding in advance what type of entry I am making

  Background:
    Given a profile named "Sarah" exists and is active
    And I am on the Dashboard screen

  # ---------------------------------------------------------------------------
  # Log entry button — placement and visibility
  # ---------------------------------------------------------------------------

  Scenario: A log entry button is persistently visible on the dashboard
    Given "Sarah" is the active profile
    And I am on the Dashboard screen
    Then a log entry button is visible without scrolling
    And it is positioned in the bottom-right corner of the screen
    And it does not obscure dashboard content beneath it

  Scenario: The log entry button is visible on every main screen
    Given "Sarah" is the active profile
    When I navigate to the Dashboard screen
    Then the log entry button is visible
    When I navigate to the Symptoms & Vitals screen
    Then the log entry button is visible
    When I navigate to the Medications screen
    Then the log entry button is visible
    When I navigate to the Meals screen
    Then the log entry button is visible
    When I navigate to the Reports screen
    Then the log entry button is visible

  Scenario: The log entry button is a FloatingActionButton with a + icon
    Given I am on any main screen
    Then the log entry button is a FloatingActionButton
    And it displays a + icon
    And it uses the primary colour token

  Scenario: The log entry button is the single entry point for all new health entries from the dashboard
    Given I am on the Dashboard screen
    Then the only way to begin a new health entry from the dashboard is via the log entry button
    And there are no separate per-type "Add" buttons on the dashboard itself

  Scenario: The log entry button is available during a dashboard empty state
    Given "Sarah" has no logged data
    And I am on the Dashboard screen
    Then the log entry button is still visible and tappable
    And the empty state copy invites me to tap it to make my first entry

  # ---------------------------------------------------------------------------
  # Opening the quick log sheet
  # ---------------------------------------------------------------------------

  Scenario: Tapping the + button on the dashboard opens the quick log sheet
    When I tap the + button
    Then the quick log sheet slides up
    And the freeform text field is focused with the keyboard raised
    And the current date and time are shown
    And a Save button is visible

  Scenario: The keyboard is raised immediately with no extra tap
    When I tap the + button
    Then the text field is already focused
    And the keyboard is visible without any additional interaction

  # ---------------------------------------------------------------------------
  # Profile attribution — caregiver safety
  # ---------------------------------------------------------------------------

  Scenario: Quick log sheet shows whose record the entry will be saved to
    Given "Sarah" is the active profile
    When I tap the + button
    Then the sheet header shows "Logging for Sarah"
    And the entry will be saved to Sarah's record

  Scenario: Quick log sheet attributes the entry to the currently active profile
    Given "Dad" is the active profile
    When I tap the + button
    Then the sheet header shows "Logging for Dad"
    And the entry will be saved to Dad's record, not Sarah's

  Scenario: Saving a quick log entry from a dependant profile does not affect other profiles
    Given "Dad" is the active profile
    When I tap the + button
    And I type "Pain in right hip after walking"
    And I tap Save
    Then the entry appears in Dad's activity feed
    And the entry does not appear in any other profile's feed

  # ---------------------------------------------------------------------------
  # Timestamp capture
  # ---------------------------------------------------------------------------

  Scenario: Entry timestamp defaults to the current time
    When I tap the + button
    Then the timestamp shown is the current date and time
    And no manual input is required to record when the entry was made

  Scenario: User can adjust the entry time before saving
    When I tap the + button
    And I tap the timestamp
    Then I can change the date and time to any past value
    When I tap Save
    Then the entry is saved with the adjusted timestamp, not the time the sheet was opened

  # ---------------------------------------------------------------------------
  # Smart classification
  # ---------------------------------------------------------------------------

  Scenario: Typing about food suggests a Meal entry type
    When I tap the + button
    And I type "Had grilled salmon with rice for dinner"
    Then a suggestion chip labelled "Meal" appears below the text field

  Scenario: Typing about a doctor visit suggests a Doctor Visit entry type
    When I tap the + button
    And I type "Saw Dr. Chen about my joint inflammation"
    Then a suggestion chip labelled "Doctor Visit" appears

  Scenario: Typing about symptoms suggests a Symptom entry type
    When I tap the + button
    And I type "Bad flare today, knees and wrists both swollen"
    Then a suggestion chip labelled "Symptom" appears

  Scenario: Typing about medication suggests a Medication entry type
    When I tap the + button
    And I type "Took 400mg ibuprofen at noon"
    Then a suggestion chip labelled "Medication" appears

  Scenario: Typing about a measurable vital suggests a Vital entry type
    When I tap the + button
    And I type "Blood pressure was 128 over 84 this morning"
    Then a suggestion chip labelled "Vital" appears

  Scenario: Typing about sleep suggests a Sleep entry type
    When I tap the + button
    And I type "Slept for 6 hours last night, woke up twice"
    Then a suggestion chip labelled "Sleep" appears below the text field

  Scenario: Typing a reflective thought suggests a Journal entry type
    When I tap the + button
    And I type "Feeling overwhelmed but had a decent morning"
    Then a suggestion chip labelled "Journal" appears

  Scenario: Typing about a new diagnosis does not force a misclassification
    When I tap the + button
    And I type "Just found out I have fibromyalgia"
    Then the suggestion chip, if shown, is "Journal" or no chip is shown
    And the entry is not forced into a Symptom or Medication type

  Scenario: Low-confidence or ambiguous input shows no chip rather than a wrong one
    When I tap the + button
    And I type "43"
    Then no type suggestion chip is shown
    And the entry will save as a general note if saved

  Scenario: Classification runs locally with no network call
    When I tap the + button
    And I type "Took naproxen after lunch"
    Then the type suggestion appears with no internet connection required
    And no text is transmitted off the device for classification

  Scenario: The type chip updates live as the user continues typing
    When I tap the + button
    And I type "Tired"
    And the app suggests "Journal"
    And I continue typing " after eating the pasta"
    Then the suggestion chip updates to "Meal"

  Scenario: Pasted text triggers classification the same as typed text
    When I tap the + button
    And I paste "Took 50mg tramadol after lunch"
    Then a suggestion chip labelled "Medication" appears

  Scenario: User can override the suggested entry type
    When I tap the + button
    And I type "Took ibuprofen for the pain"
    And the app suggests "Medication"
    And I tap the suggestion chip
    Then I see alternative entry type options
    When I select "Journal"
    Then the chip updates to "Journal"
    And the entry will be saved as a Journal entry

  Scenario: Unclassifiable input saves as a general note
    When I tap the + button
    And I type "Not sure how to describe today"
    Then no type chip is forced on the entry
    And the entry saves as a general note

  # ---------------------------------------------------------------------------
  # Expanding to a full entry form
  # ---------------------------------------------------------------------------

  Scenario: A classified entry offers an option to add more detail
    When I tap the + button
    And I type "Saw Dr. Chen about my joints"
    And the app suggests "Doctor Visit"
    Then I see an "Add details" link alongside the type chip

  Scenario: Tapping "Add details" on a Meal entry opens the full meal form
    When I tap the + button
    And I type "Grilled salmon for dinner"
    And the app suggests "Meal"
    And I tap "Add details"
    Then the full meal entry form opens
    And the description field is pre-filled with "Grilled salmon for dinner"
    And all additional meal fields are available (photo, reaction flag, notes)

  Scenario: Tapping "Add details" on a Doctor Visit entry opens the full visit form
    When I tap the + button
    And I type "Saw Dr. Chen about my joints"
    And I tap "Add details"
    Then the full doctor visit form opens
    And the summary field is pre-filled with "Saw Dr. Chen about my joints"
    And fields for outcome, follow-up date, and notes are available

  Scenario: Tapping "Add details" on a Symptom entry opens the full symptom form
    When I tap the + button
    And I type "Wrists really swollen and painful"
    And the app suggests "Symptom"
    And I tap "Add details"
    Then the full symptom entry form opens
    And the description is pre-filled
    And severity, affected area, and notes fields are available

  Scenario: Tapping "Add details" on a Sleep entry opens the full sleep form
    When I tap the + button
    And I type "Slept about 7 hours, felt groggy"
    And the app suggests "Sleep"
    And I tap "Add details"
    Then the full sleep entry form opens
    And the notes field is pre-filled with "Slept about 7 hours, felt groggy"
    And bedtime, wake time, and quality fields are available

  Scenario: Saving without tapping "Add details" still creates a complete entry
    When I tap the + button
    And I type "Had soup for lunch"
    And the app suggests "Meal"
    And I tap Save without tapping "Add details"
    Then a Meal entry is saved with the text "Had soup for lunch"
    And the entry is visible in the Meals section
    And I can tap into the full Meal detail view later to add more

  Scenario: A saved quick log entry can be expanded into a full form later
    Given "Sarah" has a quick log Meal entry "Prawn stir-fry at the Thai place"
    When I tap the entry in the dashboard feed
    And I tap "Add details"
    Then the full meal form opens pre-filled with "Prawn stir-fry at the Thai place"
    And I can add a photo, reaction flag, and notes
    And saving promotes the entry to a full Meal record

  # ---------------------------------------------------------------------------
  # Saving
  # ---------------------------------------------------------------------------

  Scenario: Save button is disabled when the text field is empty
    When I tap the + button
    And I have not typed anything
    Then the Save button is disabled

  Scenario: Save button is disabled when the text field contains only whitespace
    When I tap the + button
    And I type "     "
    Then the Save button is disabled
    And no entry is created

  Scenario: Dismissing with typed text shows a discard confirmation with equally clear buttons
    When I tap the + button
    And I type "Half a thought"
    And I swipe down to dismiss
    Then I see a dialog asking "Leave without saving?"
    And the dialog has two equally visible buttons
    And one button is labelled "Discard entry"
    And the other button is labelled "Keep editing"

  Scenario: Tapping "Discard entry" closes the sheet without saving
    When I tap the + button
    And I type "Half a thought"
    And I swipe down to dismiss
    And I tap "Discard entry"
    Then the sheet closes and no entry is saved

  Scenario: Tapping "Keep editing" returns focus to the text field
    When I tap the + button
    And I type "Half a thought"
    And I swipe down to dismiss
    And I tap "Keep editing"
    Then the sheet remains open
    And the text "Half a thought" is still in the text field

  Scenario: Dismissing an empty sheet requires no confirmation
    When I tap the + button
    And I have not typed anything
    And I swipe down to dismiss
    Then the sheet closes immediately without a confirmation dialog

  # ---------------------------------------------------------------------------
  # Weather context
  # ---------------------------------------------------------------------------

  Scenario: Weather is captured automatically when weather tracking is enabled
    Given "Sarah" has weather tracking enabled
    And location permission has been granted
    When I tap the + button
    Then a weather chip is shown (e.g. "Cloudy, 12°C")
    And the weather data will be attached to the entry on save

  Scenario: Weather chip shows conditions relevant to chronic illness
    Given "Sarah" has weather tracking enabled
    And location permission has been granted
    When I tap the + button
    Then the weather chip includes temperature and general conditions
    And barometric pressure is stored with the entry even if not shown on the chip

  Scenario: Weather chip is not shown when weather tracking is disabled
    Given "Sarah" has weather tracking disabled
    When I tap the + button
    Then no weather chip is shown
    And the entry saves normally without weather data

  Scenario: Weather chip is not shown when location permission is denied
    Given "Sarah" has weather tracking enabled
    And location permission has been denied
    When I tap the + button
    Then no weather chip is shown
    And the entry saves without weather data

  Scenario: Weather chip is not shown when the device has no connectivity
    Given "Sarah" has weather tracking enabled
    And location permission has been granted
    And the device has no internet connectivity
    When I tap the + button
    Then no weather chip is shown
    And the entry saves without weather data

  Scenario: Entry detail view shows the weather at the time of logging
    Given "Sarah" has weather tracking enabled
    And the weather at the time of logging is "Sunny, 22°C"
    When I save a quick log entry
    Then the entry detail shows "Sunny, 22°C" as the weather context

  Scenario: Weather is the only network call the app makes
    Given "Sarah" has weather tracking enabled
    When I use the app normally
    Then the only outbound network request is to fetch current weather
    And no other data leaves the device over the network

  Scenario: Weather and location data are never stored outside the device
    Given weather data has been captured for an entry
    Then the weather data is stored only on the device
    And no location or weather information is transmitted to any server beyond fetching the current conditions

  # ---------------------------------------------------------------------------
  # Cross-feature routing
  # ---------------------------------------------------------------------------

  Scenario: Quick log entries appear in the dashboard activity feed
    When I save a quick log entry with text "Rough morning"
    Then the entry appears in the dashboard activity feed
    And it shows the entry text, type chip, and timestamp

  Scenario: A Meal-typed entry is visible in the Meals section
    When I save a quick log entry classified as "Meal"
    Then the entry appears in the Meals section alongside fully-formed meal entries

  Scenario: A Journal-typed entry is visible in the Journal tab
    When I save a quick log entry classified as "Journal"
    Then the entry appears in the Journal list alongside fully-composed journal entries

  Scenario: A Symptom-typed entry is visible in Symptoms and Vitals
    When I save a quick log entry classified as "Symptom"
    Then the entry appears in the Symptoms & Vitals section

  Scenario: A Vital-typed entry is visible in Symptoms and Vitals
    When I save a quick log entry classified as "Vital"
    Then the entry appears in the Symptoms & Vitals section

  Scenario: A Medication-typed entry is visible in the Medications section
    When I save a quick log entry classified as "Medication"
    Then the entry appears in the Medications log

  Scenario: A Doctor Visit-typed entry is accessible from the dashboard
    When I save a quick log entry classified as "Doctor Visit"
    Then the entry appears in a "Doctor Visits" section on the dashboard

  Scenario: A Sleep-typed entry is visible in the sleep log
    When I save a quick log entry classified as "Sleep"
    Then the entry appears in the sleep log alongside fully-formed sleep entries
    And the duration is shown as "Unknown" until the user expands and provides bedtime/wake time

  # ---------------------------------------------------------------------------
  # Accessibility
  # ---------------------------------------------------------------------------

  Scenario: The + button has a descriptive accessible label
    Given a screen reader is active
    Then the + button is announced as "Open quick log" or equivalent
    And not as an unlabelled or generic "Button"

  Scenario: The type suggestion chip is announced when it appears
    Given a screen reader is active
    When I tap the + button
    And I type "Took 400mg ibuprofen"
    Then the screen reader announces that the entry has been classified as "Medication"
    And focus remains on the text field unless the user navigates to the chip

  Scenario: Quick log sheet is usable at maximum system font size
    Given the device system font size is set to the largest accessible option
    When I tap the + button
    Then the text field, type chip, timestamp, and Save button remain visible and usable
    And no elements overflow or overlap each other

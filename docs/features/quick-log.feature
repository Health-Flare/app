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
    And a primary button labelled "Add to Journal" is visible

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
    And I tap the primary button
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
    When I tap the primary button
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

  # ---------------------------------------------------------------------------
  # Catalogue- and user-aware symptom detection
  # ---------------------------------------------------------------------------
  #
  # Symptom classification is not limited to a fixed generic keyword list. It
  # also matches against the app's symptom catalogue (Symptom, global = true)
  # and, critically, against symptoms the active profile has already created
  # or logged (UserSymptom / custom Symptom records with global = false) —
  # including symptoms the user typed themselves rather than picked from a
  # list. The first mention of a brand-new custom symptom still requires the
  # full entry form; every mention after that is fast from Quick Log.

  Scenario: A symptom catalogue name not covered by the generic keyword list is still recognised
    Given "Photophobia" exists in the symptom catalogue
    When I tap the + button
    And I type "Photophobia again this afternoon"
    Then a suggestion chip labelled "Symptom" appears
    And accepting it links the entry to the "Photophobia" catalogue symptom

  Scenario: A custom symptom the user previously created is recognised on later quick log entries
    Given "Sarah" previously created the custom symptom "Brain fog" using the full symptom entry form
    When I tap the + button
    And I type "Brain fog again, hard to focus"
    Then a suggestion chip labelled "Symptom" appears
    And accepting it links the entry to Sarah's existing "Brain fog" symptom
    And no duplicate symptom is created

  Scenario: A brand-new custom symptom is not guaranteed a chip on its first mention
    Given "Sarah" has never logged or created a symptom called "Pins and needles in feet"
    When I tap the + button
    And I type "Pins and needles in feet"
    Then no Symptom chip is guaranteed, since the phrase matches no catalogue entry, user history, or generic keyword

  Scenario: Once created via the full form, a custom symptom is recognised on every subsequent quick log entry
    Given "Sarah" has never logged or created a symptom called "Pins and needles in feet"
    When I tap the + button
    And I type "Pins and needles in feet"
    And I tap "Add details" and save it as a new custom symptom via the full symptom entry form
    And I later tap the + button
    And I type "Pins and needles in feet again"
    Then a suggestion chip labelled "Symptom" appears
    And accepting it links the entry to the "Pins and needles in feet" symptom created earlier

  Scenario: Typing about medication suggests a Medication entry type
    When I tap the + button
    And I type "Took 400mg ibuprofen at noon"
    Then a suggestion chip labelled "Medication" appears

  Scenario: Typing about a measurable vital suggests a Vital entry type
    When I tap the + button
    And I type "Blood pressure was 128 over 84 this morning"
    Then a suggestion chip labelled "Vital" appears

  Scenario: Typing a height in centimetres suggests a Vital entry type
    When I tap the + button
    And I type "157cm height"
    Then a suggestion chip labelled "Vital" appears

  Scenario Outline: A short vital reading suggests a Vital entry type without needing more words
    When I tap the + button
    And I type "<text>"
    Then a suggestion chip labelled "Vital" appears

    Examples:
      | text   |
      | 74kg   |
      | 144cm  |
      | 4'8\"  |
      | HR 72  |

  Scenario Outline: A pulse reading with no "bpm" unit still suggests a Vital entry type
    When I tap the + button
    And I type "<text>"
    Then a suggestion chip labelled "Vital" appears

    Examples:
      | text                     |
      | Pulse 72 today           |
      | Pulse was 72 this morning |
      | 72 beats per minute      |

  Scenario: An unrelated slash number does not falsely suggest a Vital entry type
    When I tap the + button
    And I type "Ate 3/4 of a sandwich for lunch"
    Then a suggestion chip labelled "Meal" appears
    And no suggestion chip labelled "Vital" appears

  # ---------------------------------------------------------------------------
  # Full vital type coverage
  # ---------------------------------------------------------------------------
  #
  # Vital classification must cover every VitalType the app tracks
  # (heartRate, bloodPressure, weight, height, temperature, oxygenSaturation,
  # respiratoryRate, bloodGlucose), not a fixed subset chosen by unit regex.

  Scenario Outline: Every documented vital type suggests a Vital entry type
    When I tap the + button
    And I type "<text>"
    Then a suggestion chip labelled "Vital" appears

    Examples:
      | text                        |
      | HR 72                       |
      | Blood pressure 128 over 84  |
      | 74kg                        |
      | 157cm height                |
      | Temp 38.2°C                 |
      | Oxygen sat 96%              |
      | Respiratory rate 16 br/min  |
      | Blood glucose 110 mg/dl     |

  Scenario: Respiratory rate is a recognised vital, not a fallback Journal entry
    When I tap the + button
    And I type "Respiratory rate 18 br/min"
    Then a suggestion chip labelled "Vital" appears
    And no suggestion chip labelled "Journal" appears

  Scenario: Typing about sleep suggests a Sleep entry type
    When I tap the + button
    And I type "Slept for 6 hours last night, woke up twice"
    Then a suggestion chip labelled "Sleep" appears below the text field

  Scenario: Typing a reflective thought suggests a Journal entry type
    When I tap the + button
    And I type "Feeling overwhelmed but had a decent morning"
    Then a suggestion chip labelled "Journal" appears

  # ---------------------------------------------------------------------------
  # Condition detection
  # ---------------------------------------------------------------------------
  #
  # Condition text is matched against the condition catalogue (Condition,
  # global = true) and the active profile's own conditions (UserCondition /
  # custom Condition records with global = false), the same way medication
  # text is matched against the profile's real medication list. Diagnosis
  # text is no longer routed to Journal by default — a Condition type exists
  # and is used when the text names a known or previously-tracked condition.

  Scenario: Typing about a known catalogue condition suggests a Condition entry type
    Given "Fibromyalgia" exists in the condition catalogue
    When I tap the + button
    And I type "Just found out I have fibromyalgia"
    Then a suggestion chip labelled "Condition" appears

  Scenario: Accepting a Condition suggestion for a not-yet-tracked condition starts tracking it
    Given "Fibromyalgia" exists in the condition catalogue but is not tracked by "Sarah"
    When I tap the + button
    And I type "Just found out I have fibromyalgia"
    And the app suggests "Condition"
    And I tap the primary button
    Then a UserCondition record for "Fibromyalgia" is created and linked to "Sarah"

  Scenario: A custom condition the user previously created is recognised on later quick log entries
    Given "Sarah" previously created the custom condition "Myalgic encephalomyelitis" using the illness entry screen
    When I tap the + button
    And I type "Rough ME day today"
    Then a suggestion chip labelled "Condition" appears
    And accepting it attributes the entry to Sarah's existing "Myalgic encephalomyelitis" condition

  Scenario: Free text that only describes symptoms is not misclassified as a Condition
    When I tap the + button
    And I type "Knees and wrists both swollen again"
    Then the suggestion chip, if shown, is "Symptom", not "Condition"

  # Generic diagnosis-status language suggests Condition even when the text
  # names no catalogue or previously-tracked condition — mirroring how
  # Symptom classification also has a generic keyword list alongside its
  # catalogue-aware matching, above.
  Scenario Outline: Generic diagnosis-status language suggests a Condition entry type
    When I tap the + button
    And I type "<text>"
    Then a suggestion chip labelled "Condition" appears

    Examples:
      | text                                          |
      | Just got diagnosed with something new today   |
      | Got my official diagnosis this afternoon       |
      | Officially in remission as of this week        |
      | Had a relapse after months of feeling fine     |

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

  Scenario: Tapping "Add details" on a Condition entry opens the illness entry screen
    When I tap the + button
    And I type "Just found out I have fibromyalgia"
    And the app suggests "Condition"
    And I tap "Add details"
    Then the illness entry screen opens
    And "Fibromyalgia" is pre-selected if it matched the catalogue
    And the search bar is pre-filled with my text if it did not match

  Scenario: Saving without tapping "Add details" still creates a complete entry
    When I tap the + button
    And I type "Had soup for lunch"
    And the app suggests "Meal"
    And I tap the primary button without tapping "Add details"
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
  # Quick-add vs. Journal button language
  # ---------------------------------------------------------------------------
  #
  # The primary button's label must always make it unambiguous whether tapping
  # it will quick-add the detected record type (e.g. a Vital, a Medication
  # dose) or fall back to a plain Journal entry. A generic "Save" label that
  # never changes does not communicate this, so the label tracks the current
  # classification. The secondary "Add details" link (see above) always opens
  # the full, slower entry form for whichever type is currently detected, and
  # is never worded the same as the primary button.

  Scenario: The primary button defaults to "Add to Journal" before any type is detected
    When I tap the + button
    And I have not typed anything
    Then the primary button reads "Add to Journal"

  Scenario Outline: The primary button label names the detected quick-add type
    When I tap the + button
    And I type "<text>"
    And the app suggests "<type>"
    Then the primary button reads "<button label>"

    Examples:
      | text                                | type         | button label             |
      | Had grilled salmon with rice        | Meal         | Quick Add: Meal          |
      | Saw Dr. Chen about my joints         | Doctor Visit | Quick Add: Doctor Visit  |
      | Bad flare today, knees swollen       | Symptom      | Quick Add: Symptom       |
      | Took 400mg ibuprofen at noon         | Medication   | Quick Add: Medication    |
      | Blood pressure was 128 over 84       | Vital        | Quick Add: Vital         |
      | Slept for 6 hours last night         | Sleep        | Quick Add: Sleep         |
      | Just found out I have fibromyalgia   | Condition    | Quick Add: Condition     |

  Scenario: The primary button reads "Add to Journal" when the entry is classified as Journal
    When I tap the + button
    And I type "Feeling overwhelmed but had a decent morning"
    And the app suggests "Journal"
    Then the primary button reads "Add to Journal"

  Scenario: The primary button relabels immediately as the type chip updates live
    When I tap the + button
    And I type "Tired"
    And the app suggests "Journal"
    Then the primary button reads "Add to Journal"
    When I continue typing " after eating the pasta"
    And the app suggests "Meal"
    Then the primary button reads "Quick Add: Meal"

  Scenario: The primary button reverts to "Add to Journal" when the user overrides the type to Journal
    When I tap the + button
    And I type "Took ibuprofen for the pain"
    And the app suggests "Medication"
    Then the primary button reads "Quick Add: Medication"
    When I tap the suggestion chip
    And I select "Journal"
    Then the primary button reads "Add to Journal"

  Scenario: The Quick Add button and the "Add details" link are never worded the same
    When I tap the + button
    And I type "Grilled salmon for dinner"
    And the app suggests "Meal"
    Then the primary button reads "Quick Add: Meal" and is styled as the prominent filled action
    And the "Add details" link is styled as a secondary, less prominent action
    And the two controls never share the same label text

  # ---------------------------------------------------------------------------
  # Saving
  # ---------------------------------------------------------------------------

  Scenario: Primary button is disabled when the text field is empty
    When I tap the + button
    And I have not typed anything
    Then the primary button is disabled

  Scenario: Primary button is disabled when the text field contains only whitespace
    When I tap the + button
    And I type "     "
    Then the primary button is disabled
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

  Scenario: A respiratory-rate quick entry saves a structured value
    When I save the quick log entry "Respiratory rate 18 br/min"
    Then a Respiratory Rate vital entry is saved with value 18 breaths/min
    And the original text is preserved in the entry's notes

  Scenario: A Condition-typed entry is visible in the Illnesses tab
    When I save a quick log entry classified as "Condition"
    Then the entry appears in the Illnesses tab
    And the associated UserCondition record reflects the matched condition

  Scenario: A blood-pressure quick entry saves structured values
    When I save the quick log entry "Blood pressure was 128 over 84 this morning"
    Then a Blood Pressure vital entry is saved with systolic 128 and diastolic 84 mmHg
    And the original text is preserved in the entry's notes

  Scenario: A heart-rate quick entry saves a structured value
    When I save the quick log entry "Resting heart rate 72 bpm before breakfast"
    Then a Heart Rate vital entry is saved with value 72 BPM
    And the original text is preserved in the entry's notes

  Scenario Outline: A pulse reading with no "bpm" unit saves a structured Heart Rate value
    When I save the quick log entry "<text>"
    Then a Heart Rate vital entry is saved with value 72 BPM
    And the original text is preserved in the entry's notes

    Examples:
      | text            |
      | HR 72           |
      | Pulse 72 today  |

  Scenario: A combined blood-pressure and pulse quick entry saves both structured values
    When I save the quick log entry "BP 118/76, pulse 68bpm"
    Then a Blood Pressure vital entry is saved with systolic 118 and diastolic 76 mmHg
    And a Heart Rate vital entry is saved with value 68 BPM
    And the original text is preserved in both entries' notes

  Scenario: A height quick entry in centimetres saves a structured value
    When I save the quick log entry "157cm height"
    Then a Height vital entry is saved with value 157 cm
    And the original text is preserved in the entry's notes

  Scenario: A height quick entry in feet and inches saves a structured value
    When I save the quick log entry "4'8\" tall"
    Then a Height vital entry is saved with value 56 in
    And the original text is preserved in the entry's notes

  Scenario: A weight quick entry with no other words saves a structured value
    When I save the quick log entry "74kg"
    Then a Weight vital entry is saved with value 74 kg
    And the original text is preserved in the entry's notes

  Scenario: Vital text whose values cannot be parsed saves as a general note
    When I save a quick log entry classified as "Vital" whose values cannot be extracted
    Then the entry is saved as a journal entry
    And no text the user typed is lost

  Scenario: A Medication-typed entry is visible in the Medications section
    When I save a quick log entry classified as "Medication"
    Then the entry appears in the Medications log

  Scenario: A Medication-typed entry logs a dose of a known medication
    Given the active profile has a medication named "Ibuprofen"
    When I save the quick log entry "Took ibuprofen after lunch"
    Then a dose log with status "Taken" is recorded against "Ibuprofen"
    And the dose amount and unit default to the medication's usual dose
    And the original text is preserved in the dose log's notes

  Scenario: Medication text with no matching medication saves as a general note
    Given the active profile has no medication whose name appears in the text
    When I save the quick log entry "Took something for the pain"
    Then the entry is saved as a journal entry
    And no text the user typed is lost

  Scenario: A Doctor Visit-typed entry is accessible from the dashboard
    When I save a quick log entry classified as "Doctor Visit"
    Then the entry appears in a "Doctor Visits" section on the dashboard

  Scenario: A Sleep-typed entry with a stated duration is visible in the sleep log
    When I save the quick log entry "Slept for 6 hours last night, woke up twice"
    Then a sleep entry appears in the sleep log alongside fully-formed sleep entries
    And its duration is 6 hours, ending at the entry's timestamp
    And the original text is preserved in the entry's notes

  Scenario: Sleep text without a stated duration saves as a general note
    When I save the quick log entry "Terrible night, kept waking up"
    Then the entry is saved as a journal entry
    And no text the user typed is lost

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

  Scenario: A change in the primary button's label is announced to screen readers
    Given a screen reader is active
    When I tap the + button
    And I type "Took 400mg ibuprofen"
    Then the screen reader announces that the primary button now reads "Quick Add: Medication"

  Scenario: Quick log sheet is usable at maximum system font size
    Given the device system font size is set to the largest accessible option
    When I tap the + button
    Then the text field, type chip, timestamp, and primary button remain visible and usable
    And no elements overflow or overlap each other

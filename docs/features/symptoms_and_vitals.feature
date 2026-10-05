Feature: Symptom and Vitals Logging
  As a primary user
  I want to log symptoms and vital measurements for the active profile
  So that I have a detailed, timestamped health record over time

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Logging a symptom
  # ---------------------------------------------------------------------------

  Scenario: Log a symptom with the current timestamp
    When I open the new symptom entry screen
    Then the date and time fields default to the current date and time
    When I enter "Headache" as the symptom name
    And I set the severity to 7
    And I save the entry
    Then a symptom entry for "Headache" with severity 7 is saved for "Sarah"
    And the entry timestamp matches the time I opened the form

  Scenario: Log a symptom with a past date and time
    When I open the new symptom entry screen
    And I change the date to "2026-02-10" and the time to "14:30"
    And I enter "Fatigue" as the symptom name
    And I set the severity to 5
    And I save the entry
    Then a symptom entry for "Fatigue" is saved with the timestamp "2026-02-10 14:30"

  Scenario: Log a symptom with optional notes
    When I open the new symptom entry screen
    And I enter "Nausea" as the symptom name
    And I set the severity to 4
    And I enter "Worse after eating, lasted about 2 hours" as the notes
    And I save the entry
    Then the symptom entry for "Nausea" is saved with the notes intact

  Scenario: Cannot save a symptom entry without a name
    When I open the new symptom entry screen
    And I leave the symptom name empty
    And I attempt to save the entry
    Then I see a validation error indicating the symptom name is required
    And no entry is saved

  Scenario: Cannot save a symptom entry without an intensity
    # Intensity is the UI name for the stored severity value.
    When I open the new symptom entry screen
    And I enter "Dizziness" as the symptom name
    And I do not set an intensity
    And I attempt to save the entry
    Then I see the validation error "Intensity is required"
    And no entry is saved

  Scenario: Use a saved symptom shortcut
    Given "Sarah" has a saved symptom shortcut named "Migraine"
    When I open the new symptom entry screen
    And I tap the "Migraine" shortcut
    Then the symptom name field is populated with "Migraine"
    And I can adjust the severity and add notes before saving

  # ---------------------------------------------------------------------------
  # Logging vitals
  # ---------------------------------------------------------------------------

  Scenario Outline: Log a vital measurement with the current timestamp
    When I open the new vital entry screen
    And I select "<vital_type>" as the vital type
    And I enter "<value>" as the measurement
    And I select "<unit>" as the unit
    And I save the entry
    Then a vital entry for "<vital_type>" with value "<value> <unit>" is saved for "Sarah"

    Examples:
      | vital_type          | value  | unit  |
      | Heart Rate          | 72     | BPM   |
      | Weight              | 68     | kg    |
      | Height              | 170    | cm    |
      | Temperature         | 37.2   | °C    |
      | Oxygen Saturation   | 98     | %     |
      | Respiratory Rate    | 16     | br/min|
      | Blood Glucose       | 5.4    | mmol/L|

  Scenario: Log a blood pressure reading
    When I open the new vital entry screen
    And I select "Blood Pressure" as the vital type
    And I enter "120" as the systolic value
    And I enter "80" as the diastolic value
    And I save the entry
    Then a vital entry for "Blood Pressure" with value "120/80 mmHg" is saved for "Sarah"

  Scenario: Log a vital with a past date and time
    When I open the new vital entry screen
    And I select "Heart Rate" as the vital type
    And I change the date to "2026-02-15" and the time to "09:00"
    And I enter "88" as the measurement
    And I select "BPM" as the unit
    And I save the entry
    Then the vital entry is saved with the timestamp "2026-02-15 09:00"

  Scenario: Log a vital with optional notes
    When I open the new vital entry screen
    And I select "Blood Pressure" as the vital type
    And I enter "145" as the systolic value
    And I enter "92" as the diastolic value
    And I enter "Taken after stressful meeting" as the notes
    And I save the entry
    Then the blood pressure entry is saved with the notes intact

  Scenario: Cannot save a vital entry with no value entered
    When I open the new vital entry screen
    And I select "Heart Rate" as the vital type
    And I leave the measurement value empty
    And I attempt to save the entry
    Then I see a validation error indicating a value is required
    And no entry is saved

  # ---------------------------------------------------------------------------
  # Temperature unit preference (issue #83)
  # ---------------------------------------------------------------------------

  # The profile's temperature unit only changes what is shown. A reading is
  # saved in the unit it was entered in and is never rewritten.

  Scenario: New temperature entries start in the profile's unit
    Given "Sarah"'s temperature unit is "°F"
    When I open the new vital entry screen
    And I select "Temperature" as the vital type
    Then the unit is "°F"
    And I can still change it to "°C" for this entry

  Scenario: New temperature entries start in °C when the unit is "As logged"
    Given "Sarah"'s temperature unit is "As logged"
    When I open the new vital entry screen
    And I select "Temperature" as the vital type
    Then the unit is "°C"

  Scenario: A reading is saved in the unit it was entered in
    Given "Sarah"'s temperature unit is "°C"
    When I log a temperature of 100.4 °F
    Then the saved reading is 100.4 °F

  Scenario: The vitals list shows temperatures in the profile's unit
    Given "Sarah"'s temperature unit is "°C"
    And she logged a temperature of 100.4 °F
    When I view the vitals log
    Then the entry shows "38.0 °C"

  Scenario: The vitals list shows temperatures as logged when no unit is chosen
    Given "Sarah"'s temperature unit is "As logged"
    And she logged a temperature of 100.4 °F
    When I view the vitals log
    Then the entry shows "100.4 °F"

  Scenario: Editing a reading shows the value that was saved
    Given "Sarah"'s temperature unit is "°C"
    And she logged a temperature of 100.4 °F
    When I edit that entry
    Then the value field shows "100.4" and the unit is "°F"
    And saving without changes leaves the reading at 100.4 °F

  Scenario: Exports keep readings as logged
    Given "Sarah"'s temperature unit is "°C"
    And she logged a temperature of 100.4 °F
    When I export a report as CSV including vitals
    Then the temperature row shows 100.4 in °F

  # ---------------------------------------------------------------------------
  # Viewing symptom and vital history
  # ---------------------------------------------------------------------------

  Scenario: View symptom history in chronological order
    Given "Sarah" has the following symptom entries:
      | Symptom   | Severity | Timestamp           |
      | Headache  | 7        | 2026-02-15 08:00    |
      | Fatigue   | 5        | 2026-02-16 14:00    |
      | Nausea    | 3        | 2026-02-17 09:30    |
    When I navigate to the symptom log for "Sarah"
    Then I see all three entries listed in reverse chronological order
    And the most recent entry "Nausea" appears first

  Scenario: View detail of a symptom entry
    Given "Sarah" has a symptom entry for "Migraine" with severity 9 and notes "Visual aura for 20 mins"
    When I navigate to the symptom log
    And I tap the "Migraine" entry
    Then I see the full detail of the entry including the severity, timestamp, and notes

  Scenario: View vital history in chronological order
    Given "Sarah" has the following vital entries:
      | Vital Type  | Value | Timestamp           |
      | Heart Rate  | 72    | 2026-02-15 08:00    |
      | Heart Rate  | 88    | 2026-02-16 10:00    |
      | Weight      | 68    | 2026-02-17 07:00    |
    When I navigate to the vitals log for "Sarah"
    Then I see all three entries listed in reverse chronological order

  # ---------------------------------------------------------------------------
  # Editing and deleting entries
  # ---------------------------------------------------------------------------

  Scenario: Edit a symptom entry
    Given "Sarah" has a symptom entry for "Headache" with severity 6
    When I navigate to the symptom log
    And I tap the "Headache" entry
    And I edit the severity to 8
    And I save the changes
    Then the "Headache" entry now shows severity 8

  Scenario: Edit a vital entry
    Given "Sarah" has a vital entry for "Weight" with value "68 kg"
    When I navigate to the vitals log
    And I tap the "Weight" entry
    And I change the value to "67.5"
    And I save the changes
    Then the "Weight" entry now shows "67.5 kg"

  Scenario: Delete a symptom entry with confirmation
    Given "Sarah" has a symptom entry for "Fatigue"
    When I navigate to the symptom log
    And I choose to delete the "Fatigue" entry
    Then I am shown a confirmation dialog
    When I confirm the deletion
    Then the "Fatigue" entry is permanently removed from "Sarah"'s log

  Scenario: Delete a vital entry with confirmation
    Given "Sarah" has a vital entry for "Heart Rate" logged at "2026-02-15 08:00"
    When I navigate to the vitals log
    And I choose to delete that entry
    Then I am shown a confirmation dialog
    When I confirm the deletion
    Then the entry is permanently removed from "Sarah"'s vitals log

  Scenario: Cancel deletion of a symptom entry
    Given "Sarah" has a symptom entry for "Nausea"
    When I navigate to the symptom log
    And I choose to delete the "Nausea" entry
    And I cancel the confirmation dialog
    Then the "Nausea" entry still exists in the log

  # ---------------------------------------------------------------------------
  # Empty state
  # ---------------------------------------------------------------------------

  Scenario: Empty symptom log shows a helpful prompt
    Given "Sarah" has no symptom entries
    When I navigate to the symptom log
    Then I see an empty state message guiding me to log my first symptom

  Scenario: Empty vitals log shows a helpful prompt
    Given "Sarah" has no vital entries
    When I navigate to the vitals log
    Then I see an empty state message guiding me to log my first vital measurement

  # ---------------------------------------------------------------------------
  # Intensity, interference, and impact in your own words (PROMIS-informed)
  # ---------------------------------------------------------------------------

  # Credit: these inputs come from Dr Cat Hicks's Informed Patient method
  # (https://github.com/DrCatHicks/informed-patient, https://informed-patient.ai)
  # and its symptom-inventory methodology, which draws on PROMIS
  # (Cella et al. 2010, PMID 20685078). Three ideas carry over:
  #   1. How intense a symptom is and how much it gets in the way are separate
  #      things. Conflating them is a common error.
  #   2. A number alone is a weak record. Pair it with a concrete statement of
  #      what the symptom stopped you doing (Farrar et al. 2001, PMID 11690728).
  #   3. Describe it freely first, rate it second, then ask what was missed.
  # These are PROMIS-informed questions in our own words. They are not PROMIS
  # instruments and are never scored or labelled as such. See
  # promis-instruments.feature for official short forms.
  #
  # Every new field is optional. Nothing is pre-selected. Logging a symptom
  # with only a name and an intensity must stay exactly as quick as today.

  Scenario: The symptom form asks what happened before asking for numbers
    When I open the new symptom entry screen
    Then I see these questions in this order:
      | Question                |
      | What are you feeling?   |
      | How intense was it?     |
      | When                    |
    And the optional details are offered below them, not shown as fields
    # See "Optional details: add only what helps" for how they appear.

  Scenario: Intensity is anchored at both ends in plain words
    When I open the new symptom entry screen
    Then the intensity section is labelled "How intense was it?"
    And 1 is anchored as "Barely noticeable"
    And 10 is anchored as "Worst you can imagine"

  Scenario: Record how much a symptom got in the way
    When I open the new symptom entry screen
    And I enter "Fatigue" as the symptom name
    And I set the intensity to 5
    And I tap "How much it got in the way" under "Add if it helps"
    And I choose "Quite a bit" for "How much did it get in the way?"
    And I save the entry
    Then the entry for "Fatigue" is saved with intensity 5 and interference "Quite a bit"

  Scenario: Interference is a five-step choice with nothing pre-selected
    When I open the new symptom entry screen
    And I tap "How much it got in the way" under "Add if it helps"
    Then "How much did it get in the way?" offers these options:
      | Option      |
      | Not at all  |
      | A little    |
      | Somewhat    |
      | Quite a bit |
      | Very much   |
    And no option is selected
    And I can clear my choice after making one

  Scenario: A symptom can be saved without interference or impact
    When I open the new symptom entry screen
    And I enter "Headache" as the symptom name
    And I set the intensity to 4
    And I save the entry
    Then the entry is saved with no interference and no impact recorded
    And nothing is shown as "Not at all" for that entry

  Scenario: Low intensity and high interference can be recorded together
    When I log "Brain fog" with intensity 3 and interference "Very much"
    Then the entry is saved with intensity 3 and interference "Very much"
    And I am not warned that the two do not match

  Scenario: Record what the symptom stopped me doing, in my own words
    When I open the new symptom entry screen
    And I enter "Joint pain" as the symptom name
    And I set the intensity to 6
    And I tap "What it stopped you doing" under "Add if it helps"
    And I enter "Couldn't open jars or grip the steering wheel" in "What did it stop you doing, or make harder?"
    And I save the entry
    Then the impact is saved exactly as typed: "Couldn't open jars or grip the steering wheel"

  Scenario: The impact field gives a concrete example, not a form question
    When I open the new symptom entry screen
    And I tap "What it stopped you doing" under "Add if it helps"
    Then the impact field hint reads "e.g. Missed work, couldn't climb the stairs, cancelled plans"

  Scenario: The notes question asks what the form missed
    When I open the new symptom entry screen
    And I tap "Anything else" under "Add if it helps"
    Then the notes section is labelled "Anything else we didn't ask about?"

  Scenario: Entry detail shows intensity and interference as separate lines
    Given "Sarah" has a symptom entry for "Fatigue" with intensity 5, interference "Quite a bit", and impact "Skipped my walk"
    When I view that entry
    Then I see "Intensity: 5/10"
    And I see "Got in the way: Quite a bit"
    And I see "Skipped my walk" in her own words, not rephrased

  Scenario: Symptom log list shows interference only when it was recorded
    Given "Sarah" logged "Headache" with intensity 4 and no interference
    And she logged "Fatigue" with intensity 5 and interference "Quite a bit"
    When I view the symptom log
    Then the "Fatigue" row shows "Quite a bit"
    And the "Headache" row shows no interference label

  Scenario: Edit interference and impact on an existing entry
    Given "Sarah" has a symptom entry for "Fatigue" with interference "Somewhat"
    When I edit the entry and change interference to "Very much"
    And I save the changes
    Then the entry shows interference "Very much"
    And its intensity, impact, notes, and timestamp are unchanged

  # ---------------------------------------------------------------------------
  # Optional details: add only what helps
  # ---------------------------------------------------------------------------

  # Better questions make a longer form, and a long form on a bad day gets
  # skipped. So the form asks only what it needs (what, how intense, when)
  # and offers everything else by name as "Add if it helps". The add-ons are
  # named so people know what exists, and nothing is hidden behind a menu.
  #
  # Two smart parts, both worked out from the person's own entries:
  #   - Last time: logging a symptom you have logged before opens the
  #     add-ons you filled in last time for it. Values are never copied.
  #   - Quieting: "Where" and "Anything else" fold away after going unused
  #     for 10 entries in a row, with one note saying so. "How much it got
  #     in the way" and "What it stopped you doing" are never folded away:
  #     they are the reason this work exists, and a few weeks of skipping
  #     them while unwell must not hide them for good.
  #
  # No badges, counters, or "you didn't fill this in". The words
  # "Patient-Reported Outcomes" do not appear on the form; "Why we ask"
  # leads to the sources and credit screen, where the reasoning lives.
  # Credit: Dr Cat Hicks, Informed Patient (see the section above).

  Scenario: Optional details are offered by name, not as empty fields
    When I open the new symptom entry screen
    Then I see a card titled "Add if it helps"
    And it says "Tap any of these to add it to this entry. A line about how it affected your day tells your clinician more than a number."
    And it offers these, in this order:
      | Add-on                     |
      | Where                      |
      | How much it got in the way |
      | What it stopped you doing  |
      | Anything else              |
    And none of their fields are shown yet

  Scenario: Only the symptom and its intensity are needed to save
    When I open the new symptom entry screen
    And I enter "Headache" as the symptom name
    And I set the intensity to 4
    And I save the entry
    Then a symptom entry for "Headache" with intensity 4 is saved for "Sarah"
    And it has no locations, interference, impact, or notes

  Scenario: Tapping an add-on opens its question in the form
    When I open the new symptom entry screen
    And I tap "How much it got in the way" under "Add if it helps"
    Then the question "How much did it get in the way?" appears in the form
    And "How much it got in the way" is no longer offered under "Add if it helps"

  Scenario: Removing an add-on closes it and leaves nothing behind
    When I open the new symptom entry screen
    And I enter "Fatigue" as the symptom name
    And I set the intensity to 5
    And I tap "What it stopped you doing" under "Add if it helps"
    And I enter "Skipped my walk" in "What did it stop you doing, or make harder?"
    And I remove "What did it stop you doing, or make harder?"
    And I save the entry
    Then the entry for "Fatigue" is saved with no impact recorded
    And "What it stopped you doing" is offered again under "Add if it helps"

  Scenario: The card disappears when every add-on is open
    When I open the new symptom entry screen
    And I add every option under "Add if it helps"
    Then the "Add if it helps" card is not shown

  Scenario: The time defaults to now and can be changed
    When I open the new symptom entry screen
    Then the "When" line starts with "Now"
    And I can tap "Change" to pick another date and time

  Scenario: "Why we ask" explains the questions and credits their source
    When I open the new symptom entry screen
    And I tap "Why we ask"
    Then I see "Where our questions come from"

  Scenario: Editing an entry opens the details it already has
    Given "Sarah" has a symptom entry for "Fatigue" with interference "Somewhat" and no impact, notes, or locations
    When I edit that entry
    Then "How much did it get in the way?" is open with "Somewhat" selected
    And "Where", "What it stopped you doing", and "Anything else" are offered under "Add if it helps"

  Scenario: A quick log that mentions a body part opens "Where" with it chosen
    When I promote the quick log "sore left knee" to a full symptom entry
    Then "Where" is open with "Knees" chosen

  # Last time ----------------------------------------------------------------

  Scenario: Logging a symptom again opens what I added last time
    Given "Sarah" last logged "Fatigue" with interference "Quite a bit" and impact "Skipped my walk"
    When I open the new symptom entry screen
    And I enter "Fatigue" as the symptom name
    Then "How much did it get in the way?" and "What did it stop you doing, or make harder?" open
    And each says "Added because you used it last time for Fatigue."
    And nothing is selected or filled in

  Scenario: Last time looks only at the same symptom
    Given "Sarah" last logged "Fatigue" with impact "Skipped my walk"
    And "Sarah" last logged "Headache" with nothing optional
    When I start a new entry for "Headache"
    Then no optional details open on their own

  Scenario: Last time ignores case and spacing in the symptom name
    Given "Sarah" last logged "Fatigue" with interference "A little"
    When I start a new entry for " fatigue "
    Then "How much did it get in the way?" opens

  Scenario: Last time is per profile
    Given "Dad" last logged "Fatigue" with interference "Very much"
    And "Sarah" has never logged "Fatigue"
    When I start a new entry for "Fatigue" as "Sarah"
    Then no optional details open on their own

  Scenario: Removing a field this time means it won't open next time
    Given "Sarah" last logged "Fatigue" with impact "Skipped my walk"
    When I log "Fatigue" again and remove "What did it stop you doing, or make harder?"
    And I start another new entry for "Fatigue"
    Then "What did it stop you doing, or make harder?" does not open on its own

  Scenario: Changing the symptom name updates what opens
    Given "Sarah" last logged "Fatigue" with interference "A little"
    When I start a new entry for "Fatigue"
    And I change the symptom name to "Nausea", which she has never logged
    Then "How much did it get in the way?" closes, since I hadn't answered it
    And an add-on I already answered stays open

  # Quieting -------------------------------------------------------------------

  Scenario: Unused "Where" and "Anything else" fold away after 10 entries
    Given "Sarah"'s last 10 symptom entries have no locations and no notes
    When I open the new symptom entry screen
    Then "Where" and "Anything else" are not offered directly
    And I see "2 more" under "Add if it helps"
    And "How much it got in the way" and "What it stopped you doing" are still offered

  Scenario: Folded options are one tap away
    Given "Where" and "Anything else" are folded away for "Sarah"
    When I tap "2 more"
    Then "Where" and "Anything else" are offered under "Add if it helps"

  Scenario: Nothing folds away before 10 entries
    Given "Sarah" has 9 symptom entries, none with locations or notes
    When I open the new symptom entry screen
    Then all four add-ons are offered

  Scenario: One recent use keeps an option showing
    Given "Sarah"'s last 10 symptom entries have no notes, except one
    When I open the new symptom entry screen
    Then "Anything else" is offered directly

  Scenario: Interference and impact are never folded away
    Given "Sarah"'s last 10 symptom entries have no interference and no impact
    When I open the new symptom entry screen
    Then "How much it got in the way" and "What it stopped you doing" are offered directly

  Scenario: The first time options fold away, a note says why, once
    Given "Sarah"'s last 10 symptom entries have no locations and no notes
    And she has not seen the folding note before
    When I open the new symptom entry screen
    Then I see "We tucked away Where and Anything else. You haven't used them in your last 10 entries. They're under \"2 more\" whenever you want them."
    When I open the new symptom entry screen again
    Then I do not see that note

  Scenario: Keep everything showing from the note
    Given the folding note is showing for "Sarah"
    When I tap "Keep showing"
    Then all four add-ons are offered directly
    And "Show all symptom options" is turned on for "Sarah"

  Scenario: Last time wins over folding
    Given "Where" is folded away for "Sarah"
    And she last logged "Joint pain" with locations "Hands"
    When I start a new entry for "Joint pain"
    Then "Where" opens, saying "Added because you used it last time for Joint pain."

  Scenario: Folding never changes saved entries
    Given "Where" is folded away for "Sarah"
    When I edit an older entry that has locations "Knees"
    Then "Where" is open with "Knees" chosen

  Scenario: Entries logged before this change keep their data
    Given "Sarah" has a symptom entry for "Nausea" with severity 3 saved before this update
    When the app is updated and opened
    Then the entry shows "Intensity: 3/10"
    And it has no interference and no impact
    And no value is guessed or back-filled

  Scenario: Quick log does not invent interference
    When I quick log "headache 6"
    Then a symptom entry for "Headache" is saved with intensity 6
    And no interference is recorded

  Scenario: Interference and impact survive backup and restore
    Given "Sarah" has a symptom entry with interference "A little" and impact "Left work early"
    When I export a backup and restore it into a fresh install
    Then the restored entry has interference "A little" and impact "Left work early"

  Scenario: Moving an entry to another profile keeps interference and impact
    Given "Sarah" has a symptom entry with interference "Somewhat" and impact "Cancelled dinner"
    When I move that entry to the profile "Alex"
    Then the entry under "Alex" has interference "Somewhat" and impact "Cancelled dinner"

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

  Scenario: Cannot save a symptom entry without a severity
    When I open the new symptom entry screen
    And I enter "Dizziness" as the symptom name
    And I do not set a severity
    And I attempt to save the entry
    Then I see a validation error indicating severity is required
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

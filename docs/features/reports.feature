Feature: Reports and Data Export
  As a primary user
  I want to generate, export, and share health reports for the active profile
  So that I can present a useful summary to a medical provider or process my data myself

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given a profile named "Sarah" exists and is active
    And "Sarah" has health data spanning "2026-01-01" to "2026-02-17"

  # ---------------------------------------------------------------------------
  # Configuring a report
  # ---------------------------------------------------------------------------

  Scenario: Generate a report for the last 7 days
    When I navigate to the reports screen
    And I select "Last 7 days" as the date range
    And I include all data types
    And I generate the report
    Then the report contains only data from the last 7 days for "Sarah"

  Scenario: Generate a report for the last 30 days
    When I navigate to the reports screen
    And I select "Last 30 days" as the date range
    And I include all data types
    And I generate the report
    Then the report contains only data from the last 30 days for "Sarah"

  Scenario: Generate a report for a custom date range
    When I navigate to the reports screen
    And I select "Custom range" as the date range
    And I enter "2026-02-01" as the start date
    And I enter "2026-02-14" as the end date
    And I include all data types
    And I generate the report
    Then the report contains only data between "2026-02-01" and "2026-02-14" for "Sarah"

  Scenario: Generate a report with only symptoms and vitals
    When I navigate to the reports screen
    And I select "Last 30 days" as the date range
    And I include only "Symptoms" and "Vitals"
    And I generate the report
    Then the report contains symptom and vital data only
    And the report does not contain medication or meal data

  Scenario: Generate a report with only medications
    When I navigate to the reports screen
    And I select "Last 30 days" as the date range
    And I include only "Medications"
    And I generate the report
    Then the report contains medication and dose log data only

  Scenario: Generate a report with only meals
    When I navigate to the reports screen
    And I select "Last 30 days" as the date range
    And I include only "Meals"
    And I generate the report
    Then the report contains meal log data only including any reaction flags

  Scenario: Cannot generate a report with no data types selected
    When I navigate to the reports screen
    And I select "Last 7 days" as the date range
    And I deselect all data types
    And I attempt to generate the report
    Then I see a validation error indicating at least one data type must be selected
    And no report is generated

  Scenario: Cannot generate a report when the end date is before the start date
    When I navigate to the reports screen
    And I select "Custom range" as the date range
    And I enter "2026-02-14" as the start date
    And I enter "2026-02-01" as the end date
    And I attempt to generate the report
    Then I see a validation error indicating the end date must be after the start date
    And no report is generated

  # ---------------------------------------------------------------------------
  # Report content
  # ---------------------------------------------------------------------------

  Scenario: Report is organised chronologically
    Given "Sarah" has symptoms, vitals, medications, and meals logged across multiple days
    When I generate a report for "Last 7 days" including all data types
    Then the report displays entries in chronological order by date
    And entries from the same day are grouped together

  Scenario: Report highlights meals followed by flagged reactions
    Given "Sarah" has a meal entry for "Prawn stir-fry" on "2026-02-10" flagged with a reaction
    And "Sarah" has a symptom entry for "Hives" on "2026-02-10" 90 minutes after the meal
    When I generate a report that includes both meals and symptoms for that date range
    Then the report highlights "Prawn stir-fry" as associated with the "Hives" symptom
    And this association is clearly labelled as a potential food trigger

  Scenario: Report includes profile name and date range in the header
    When I generate a report for "Sarah" for "Last 7 days"
    Then the report header shows the profile name "Sarah"
    And the report header shows the date range covered

  Scenario: Report shows a summary when no data exists in the selected range
    Given "Sarah" has no health data between "2026-01-01" and "2026-01-07"
    When I generate a report for a custom range of "2026-01-01" to "2026-01-07"
    Then the report indicates there is no data for the selected period

  # ---------------------------------------------------------------------------
  # PDF export
  # ---------------------------------------------------------------------------

  Scenario: Export a report as a PDF
    When I generate a report for "Last 30 days"
    And I choose to export as PDF
    Then a PDF file is generated containing the report content
    And the PDF is formatted for easy reading and printing

  Scenario: PDF includes the profile name and date range
    When I generate a report for "Sarah" for "Last 30 days"
    And I export it as PDF
    Then the PDF header includes the name "Sarah" and the date range

  # ---------------------------------------------------------------------------
  # Share sheet
  # ---------------------------------------------------------------------------

  Scenario: Share a PDF report via the OS share sheet
    When I generate a report
    And I export it as PDF
    And I tap the share button
    Then the native OS share sheet opens with the PDF file ready to share

  Scenario: Share a CSV export via the OS share sheet
    When I generate a report
    And I choose to export as CSV
    And I tap the share button
    Then the native OS share sheet opens with the CSV file ready to share

  # ---------------------------------------------------------------------------
  # CSV export
  # ---------------------------------------------------------------------------

  Scenario: Export all data types as CSV
    When I generate a report for "Last 30 days" including all data types
    And I choose to export as CSV
    Then a CSV export is generated
    And it contains a separate data set for each included type: symptoms, vitals, medications, and meals
    And each row includes a timestamp and all relevant fields for that data type

  Scenario: CSV symptom export includes all symptom fields
    When I export a report as CSV including symptoms
    Then the symptom CSV contains columns for: timestamp, symptom name, severity, and notes

  Scenario: CSV vitals export includes all vital fields
    When I export a report as CSV including vitals
    Then the vitals CSV contains columns for: timestamp, vital type, value, unit, and notes

  Scenario: CSV medications export includes dose log fields
    When I export a report as CSV including medications
    Then the medications CSV contains columns for: timestamp, medication name, dose amount, unit, status (taken/skipped/missed), and notes

  Scenario: CSV meals export includes all meal fields
    When I export a report as CSV including meals
    Then the meals CSV contains columns for: timestamp, description, reaction flagged (yes/no), and notes

  Scenario: CSV export excludes data types not selected for the report
    When I generate a report including only "Symptoms" and "Vitals"
    And I export as CSV
    Then the CSV does not include meal or medication data

  # ---------------------------------------------------------------------------
  # In-app pattern visualisation
  # ---------------------------------------------------------------------------

  # Exporting to PDF or CSV puts the analytical burden on the user.
  # In-app visualisation surfaces patterns without requiring any external tool.
  # These views are read-only — they help the user understand their data,
  # not create new entries.

  Scenario: View a symptom trend chart for a specific symptom
    Given "Sarah" has symptom entries for "Headache" across the last 30 days
    When I navigate to the pattern insights screen
    And I select "Headache" as the symptom to view
    Then I see a line chart of headache severity over the selected date range
    And the x-axis is time and the y-axis is severity 1–10
    And days with no headache entry are shown as gaps, not zeros

  Scenario: View a vital trend chart for a specific vital type
    Given "Sarah" has blood pressure entries over the last 30 days
    When I navigate to the pattern insights screen
    And I select "Blood Pressure" as the vital to view
    Then I see a chart of systolic and diastolic readings over time

  Scenario: View a daily wellbeing trend from check-in data
    Given "Sarah" has daily check-ins over the last 30 days
    When I navigate to the pattern insights screen
    And I select "Daily wellbeing" as the metric
    Then I see a chart of wellbeing scores over the selected period
    And flare periods are highlighted as shaded regions on the same chart

  Scenario: Flare periods are overlaid on symptom trend charts
    Given "Sarah" has symptom data and flare history
    When I view a symptom trend chart
    Then completed and active flare periods are shown as shaded bands behind the symptom line
    And I can immediately see whether symptoms spike during flares

  Scenario: Symptom severity comparison: during flares vs baseline
    Given "Sarah" has flare history and symptom log data
    When I navigate to the pattern insights screen
    And I select "Flare vs baseline" for "Fatigue"
    Then I see average fatigue severity during flare periods
    And average fatigue severity outside of flare periods
    And the difference is shown as a number and described in plain language

  # ---------------------------------------------------------------------------
  # Weather correlation
  # ---------------------------------------------------------------------------

  Scenario: Weather correlation view shows symptom severity vs barometric pressure
    Given "Sarah" has weather tracking enabled
    And she has at least 14 days of symptom and weather data
    When I navigate to the pattern insights screen
    And I select "Weather correlation"
    Then I see a scatter or overlaid chart of barometric pressure and a chosen symptom's severity
    And days where pressure dropped are visually highlighted
    And the app notes how many times a pressure drop coincided with a symptom spike

  Scenario: Weather correlation is not shown if fewer than 14 days of data exist
    Given "Sarah" has only 5 days of weather and symptom data
    When I navigate to the weather correlation view
    Then I see a message explaining that more data is needed before patterns can be shown
    And I see an indication of how many days of data have been collected

  Scenario: Weather correlation is not shown if weather tracking is disabled
    Given "Sarah" has weather tracking disabled
    When I navigate to the pattern insights screen
    Then the weather correlation section is absent
    And a note explains that enabling weather tracking would make this available

  # ---------------------------------------------------------------------------
  # Food trigger patterns
  # ---------------------------------------------------------------------------

  Scenario: Flagged meals are listed with nearby symptom entries
    Given "Sarah" has meal entries with reaction flags and nearby symptom entries
    When I navigate to the pattern insights screen
    And I select "Food and reactions"
    Then I see each reaction-flagged meal alongside symptoms logged within 6 hours after it
    And meals that appear with symptoms more than once are ranked at the top

  Scenario: Non-flagged meals are not shown in the food trigger view
    When I view the food and reactions pattern insight
    Then only meals that have been reaction-flagged appear in the list
    And unflagged meals are not shown

  # ---------------------------------------------------------------------------
  # Sleep and activity correlations
  # ---------------------------------------------------------------------------

  Scenario: Poor sleep nights and next-day symptoms are correlated
    Given "Sarah" has 30 days of sleep and symptom data
    When I navigate to the pattern insights screen
    And I select "Sleep and symptoms"
    Then I see average next-day symptom severity following poor sleep (quality 1–2)
    And average next-day symptom severity following good sleep (quality 4–5)
    And the data is presented as a plain-language observation, not a diagnosis

  Scenario: High-exertion days and subsequent symptom severity are correlated
    Given "Sarah" has 30 days of activity and symptom data
    When I select "Activity and symptoms" in pattern insights
    Then I see average symptom severity on days following high-effort activity
    And average symptom severity on days following rest or low-effort activity

  # ---------------------------------------------------------------------------
  # Report content — new data types
  # ---------------------------------------------------------------------------

  Scenario: Generate a report including all new data types
    When I navigate to the reports screen
    And I select "Last 30 days" as the date range
    And I include all data types
    Then the available types include:
      | Data type          |
      | Symptoms           |
      | Vitals             |
      | Medications        |
      | Supplements        |
      | Meals              |
      | Journal            |
      | Sleep              |
      | Activity           |
      | Daily check-ins    |
      | Flares             |
      | Doctor visits      |

  Scenario: CSV sleep export includes all sleep fields
    When I export a report as CSV including sleep
    Then the sleep CSV contains columns for: date, bedtime, wake time, duration (minutes), quality, and notes

  Scenario: CSV activity export includes all activity fields
    When I export a report as CSV including activity
    Then the activity CSV contains columns for: timestamp, description, type, effort level, duration (minutes), and notes

  Scenario: CSV check-in export includes all check-in fields
    When I export a report as CSV including daily check-ins
    Then the check-in CSV contains columns for: date, wellbeing score, stress level, cycle phase (if recorded), and notes

  Scenario: CSV flare export includes all flare fields
    When I export a report as CSV including flares
    Then the flare CSV contains columns for: start date, end date, duration (days), attributed condition, peak severity, and notes

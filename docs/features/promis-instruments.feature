@needs-licence
Feature: Official PROMIS short forms (blocked on licensing)
  As someone tracking a chronic illness
  I want to answer an official PROMIS short form now and then
  So that I can give my clinician a validated score they can compare over time

  # Credit: proposed after Dr Cat Hicks's Informed Patient work
  # (https://github.com/DrCatHicks/informed-patient) pointed to PROMIS as the
  # benchmark for good symptom measurement.
  #
  # BLOCKED. PROMIS item text, scoring tables, and score reports are copyrighted
  # by the PROMIS Health Organization. HealthMeasures' terms require written
  # permission (HealthMeasures Electronic Administration Permission, HEAP) to
  # put any PROMIS measure in an app, with a screenshot review, per measure,
  # on a 3-year term. Health-Flare is not a registered 501(c)(3), so it is
  # likely priced as commercial. Do not copy PROMIS item wording into the app,
  # the repo, tests, or fixtures until written permission is in hand.
  #
  # Candidate measures, matched to what people here already track:
  #   - Pain Interference 4a
  #   - Fatigue 4a
  #   - Sleep Disturbance 4a
  #   - Physical Function 4a

  Background:
    Given a profile named "Sarah" exists and is active
    And Health Flare holds written permission for the measure being shown

  Scenario: Short forms are off until the user turns them on
    When "Sarah" opens Settings
    Then "PROMIS short forms" is off by default
    And no short form is ever shown as a prompt while it is off

  Scenario: Complete a short form
    Given "Sarah" has turned on "Fatigue 4a"
    When she opens it from the check-in screen
    Then each item is shown exactly as licensed, with its recall period
    And every item must be answered before Save is enabled
    And the copyright notice required by the licence is shown on the form

  Scenario: A short form is scored with the official table
    Given "Sarah" answers every item of "Fatigue 4a"
    When she saves it
    Then her raw score is converted to a T-score using the official scoring table
    And the raw answers and the T-score are both saved
    And the scoring table version is saved with the result

  Scenario: The T-score is explained without diagnosing
    Given "Sarah" has a "Fatigue 4a" T-score of 60
    When she views the result
    Then she sees that 50 is the average for the reference population and 10 points is one standard deviation
    And she does not see a diagnosis or a severity label that the licence does not provide

  Scenario: A partly answered form is not scored
    Given "Sarah" answers 3 of 4 items of "Fatigue 4a"
    When she leaves the form
    Then she is asked whether to keep a draft or discard it
    And no T-score is calculated

  Scenario: Short form results appear in reports with the measure name and date
    Given "Sarah" has completed "Fatigue 4a" three times in the last 30 days
    When she generates a PDF report for "Last 30 days"
    Then each result shows the measure name, date, and T-score
    And the copyright notice required by the licence appears in the report

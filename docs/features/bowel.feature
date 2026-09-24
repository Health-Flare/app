Feature: Bowel and bladder
  As a person who may want to track bowel or bladder events
  I want that logging to stay off until I opt in
  So that Quick Log never raises the subject on its own

  Background:
    Given a profile named "Sarah" exists and is active
    And bowel and bladder tracking is off

  Scenario: Bowel language does nothing until the profile opts in
    When I quick-log "Bristol type 6 twice"
    Then no bowel entry is saved
    And the chip is not "Bowel"

  Scenario: After opt-in, a Bristol type expands into one row per event
    Given Sarah turns on bowel and bladder tracking
    When I quick-log "Bristol type 6 twice"
    Then the chip reads "Bowel"
    And two bowel entries are saved
    And each entry has Bristol type 6
    And the app does not add medical advice

  Scenario: Blood and an empty day are recorded as stated
    Given bowel and bladder tracking is on
    When I quick-log "Blood in stool"
    Then the bowel entry records blood
    When I quick-log "No bowel movement, nothing today"
    Then an entry is saved with a count of 0

  Scenario: Bladder language uses the same collection
    Given bowel and bladder tracking is on
    When I quick-log "Up peeing twice in the night"
    Then a bladder entry is saved
    And it is stored in the same collection as bowel entries

  Scenario: Bowel records survive backup merge
    Given a backup contains a bowel entry for Sarah
    When I merge that backup
    Then the bowel entry is copied
    And Sarah's bowel-tracking opt-in flag is copied with the profile

Feature: Illness
  As a primary user
    I want to select an illness from a pre-filled list of chronic illnesses
    OR add a new illness to the list
    So that I have an illness to track meals, symptoms, medications and journals against


  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Logging an illness
  # ---------------------------------------------------------------------------

  Scenario: Add an illness to the current profile
    When I open the illness entry screen
    Then I can select from a list of existing illnesses or
    type any part of the illness into the selector that will update
    the dropdown list with illnesses that match the inputted text
    When I enter "arth" is an illness, I will see the dropdown list update
    to show all illnesses that start with "arth" followed by any illnesses
    that contain "arth" in them
    Then the list will be sorted alphabetically
    When I select an illness it will be added to the current profile
    And I can add another illness or select done

   Scenario: Add a diagnosis date to an illness
    When I select an "Arthritis" in a profile
    And I add a diagnosis date
    Then save a diagnosis journal entry for "Arthritis" with the date stamp "2026-02-27


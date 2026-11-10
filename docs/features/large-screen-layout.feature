Feature: Use available space for appointment review
  As a person using Health Flare in a wider window
  I want to keep my appointment list beside the appointment I am reviewing
  So that I can prepare for a visit without losing my place

  # UNVERIFIED (TODO): Agent-written proposal, including these notes.
  # Review every scenario before writing Flutter tests or implementation.
  # The HTML review is a disposable local demonstration, not app code.
  # Start with Care > Appointments. Track remains unchanged in this slice.
  # Use available content width, text scale and safe areas, not device names.
  # Prototype thresholds are illustrative, not agreed Flutter breakpoints.

  Background:
    Given the active profile has Appointments turned on
    And I have opened Care > Appointments

  @unverified
  Scenario: Review an appointment beside the list when both panes fit
    Given the available space fits a readable appointment list and detail pane
    When I select an appointment
    Then its existing details appear beside the list
    And the selected appointment is identified by text and a visible selection state
    And the list keeps its position and upcoming and past ordering
    And the detail shows questions and existing actions without new clinical advice

  @unverified
  Scenario: Keep the compact appointment journey when space is limited
    Given the available space does not fit both panes at the current text size
    When I select an appointment
    Then its details use one readable column
    And Back returns to the appointment list at the same position
    And no sideways page scrolling is required to read or edit the appointment
    And the same behavior applies to a narrow tablet window and a compact phone

  @unverified
  Scenario: Resize an unfinished appointment edit without saving it
    Given I am editing an appointment title, provider or date
    And I have an unsaved draft
    When available width changes between one pane and two panes
    Then the selected appointment, draft, focused field and text selection remain
    And the list and detail retain their logical reading positions
    And no record is created, updated or marked completed by the layout change

  @unverified
  Scenario: Save or cancel only the intended appointment edit
    Given I have changed an appointment title in the editor
    When I choose Save
    Then the existing appointment in its original profile is updated once
    And the list and details show the same saved title
    But when I cancel an unfinished edit
    Then I am asked before discarding changes
    And keeping the draft leaves the editor open
    And discarding the draft leaves the saved appointment unchanged

  @unverified
  Scenario: Recover from validation or storage failure without losing the draft
    Given I am editing an appointment
    When I attempt to save an empty title or the save fails
    Then I see an explanation beside the editor
    And the editor, draft and original saved appointment remain available
    And I can correct the title or retry without duplicate records

  @unverified
  Scenario: Guard a change of selection while editing
    Given I have unsaved changes to the selected appointment
    When I select another appointment or leave the editor
    Then I can keep editing or explicitly discard those changes
    And no navigation or layout event silently saves or discards them

  @unverified
  Scenario: Keep profile data separate across both panes
    Given I have an unfinished appointment edit for profile A
    When I request a switch to profile B
    Then I must resolve the unfinished edit before the switch completes
    And the appointment list, selected detail and draft are cleared before showing profile B
    And a stale appointment link for profile A does not expose its details in profile B
    And resizing cannot transfer an edit to another profile

  @unverified
  Scenario: Keep existing navigation and personal choices
    Given I have customized my bar and turned off an optional feature
    When I widen or narrow the window
    Then my destination ids, order, pins and More access remain unchanged
    And the disabled feature stays off for that profile without deleting its data
    And Reports stays a section top bar action rather than a new destination
    And existing appointment list, detail, edit and outcome links retain their meaning
    And opening a disabled feature directly keeps the existing off notice
    And no new layout preference or backup format is required for this slice

  @unverified
  Scenario: Use large text, assistive technology and a keyboard
    Given text is scaled to 200 percent
    When I review and edit an appointment at a compact or expanded width
    Then the layout falls back to one column before readable pane widths are lost
    And all labels, validation messages and Save and Cancel actions remain reachable
    And controls have at least 48 logical pixels of target space
    And keyboard focus follows navigation, list, detail and actions in a clear order
    And focus remains visible and does not become trapped
    And a screen reader identifies the selection, pane headings and save result
    And the on-screen keyboard and safe areas do not cover the focused field or actions
    And Reduce Motion does not prevent any interaction

  @unverified
  Scenario: Show empty and unavailable appointments honestly
    Given the active profile has no appointments
    When I open Appointments at any width
    Then I see the existing empty state and Add appointment action
    And no other profile's appointment is selected automatically
    But when a selected appointment is removed elsewhere
    Then I see that it is unavailable rather than a stale editable record

  @unverified
  Scenario: Explain a visible layout move without blocking logging
    Given a release introduces the contextual detail pane
    When that change is classified as moving an existing control
    Then it follows the existing release guide and Your layout rules
    And no launch modal or active logging interruption is added
    And the compact navigation is not replaced by a separate legacy mode

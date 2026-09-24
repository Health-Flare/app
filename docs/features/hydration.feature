Feature: Fluid intake
  As a person tracking how much I drink
  I want a glass or a litre to be its own record
  So that fluids are not stored as meals and the volume is in millilitres

  Background:
    Given a profile named "Sarah" exists and is active

  Scenario: A drink with a volume is a fluid record
    When I quick-log "Drank two litres of water"
    Then a fluid intake of 2000 ml is saved
    And the chip reads "Fluids"
    And no meal is created

  Scenario: Household measures convert to millilitres
    When I quick-log "3 glasses of water"
    Then a fluid intake of 750 ml is saved
    When I quick-log "500ml electrolyte"
    Then a fluid intake of 500 ml is saved with drink type electrolyte

  Scenario: Food with a drink stays a meal
    When I quick-log "Coffee and toast for breakfast"
    Then a meal is saved
    And no fluid intake is created

  Scenario: Fluid records survive backup merge
    Given a backup contains a fluid intake for Sarah
    When I merge that backup
    Then the fluid intake is copied onto Sarah's profile

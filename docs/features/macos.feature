Feature: macOS Desktop Application
  As a Health Flare user on macOS
  I want a fully native-feeling desktop experience
  So that the app integrates naturally with my Mac and is recognisable in the Dock and Finder

  # ---------------------------------------------------------------------------
  # App icon — asset completeness
  # ---------------------------------------------------------------------------

  Scenario: The macOS app icon is present and valid at all required sizes
    Given the macOS build asset catalogue at macos/Runner/Assets.xcassets/AppIcon.appiconset/
    Then the following icon sizes are present, non-empty, and correctly named:
      | Logical size (pt) | Scale | Pixel size | Usage                         |
      | 16                | 1x    | 16         | Menu bar, small Finder view   |
      | 16                | 2x    | 32         | Menu bar (Retina)             |
      | 32                | 1x    | 32         | Sidebar, small Dock           |
      | 32                | 2x    | 64         | Sidebar, small Dock (Retina)  |
      | 128               | 1x    | 128        | Finder, medium Dock           |
      | 128               | 2x    | 256        | Finder, medium Dock (Retina)  |
      | 256               | 1x    | 256        | Large Dock                    |
      | 256               | 2x    | 512        | Large Dock (Retina)           |
      | 512               | 1x    | 512        | App Store                     |
      | 512               | 2x    | 1024       | App Store (Retina)            |
    And Contents.json references every size with the correct filename, idiom, and scale
    And no icon file is a zero-byte placeholder

  Scenario: The CI pipeline fails if any required macOS icon size is missing
    Given the macOS build runs in CI
    When `flutter build macos` completes
    Then the build step fails with a descriptive error if Contents.json references a missing file
    And the pipeline does not produce a .app bundle with incomplete icon assets

  # ---------------------------------------------------------------------------
  # App icon — visual identity
  # ---------------------------------------------------------------------------

  Scenario: The macOS icon uses the Health Flare brand identity
    Given the exported macOS app icon set
    Then it uses the same visual identity, colour palette, and mark as the iOS and Android icons
    And the icon artwork is square with a fully opaque (non-transparent) background
    And the icon does not apply manual corner rounding — macOS applies the squircle mask automatically

  Scenario: The icon is not the default Flutter or placeholder icon
    Given the macOS app is built from this repository
    Then the app icon is never the default blue Flutter logo
    And the icon is never a solid colour placeholder with no artwork

  # ---------------------------------------------------------------------------
  # App icon — runtime visibility
  # ---------------------------------------------------------------------------

  Scenario: The Health Flare icon appears in the Dock when the app is running
    Given the app is installed and running on macOS
    When I look at the Dock
    Then the Health Flare icon is shown, not a generic or placeholder icon

  Scenario: The icon appears in Finder, Spotlight, and the App Switcher
    Given the app is installed on macOS
    Then the Health Flare icon appears when browsing Applications in Finder
    And the icon appears in Spotlight search results for "Health Flare"
    And the icon appears in the macOS App Switcher (Cmd+Tab)
    And the icon appears on the app's About panel

  # ---------------------------------------------------------------------------
  # Window behaviour
  # ---------------------------------------------------------------------------

  Scenario: The app window has a descriptive title
    Given the app is running on macOS
    When I look at the window title bar
    Then it reads "Health Flare"
    And not a generic identifier, bundle ID, or empty string

  Scenario: The app window has a sensible minimum size
    Given the app is running on macOS
    Then the window cannot be resized smaller than 800 × 600 logical pixels
    And at the minimum size all primary navigation and content areas remain visible and usable
    And no UI element is clipped or inaccessible at the minimum window size

  Scenario: The app window remembers its last position and size between launches
    Given the user has resized and repositioned the app window
    When the app is quit and relaunched
    Then the window opens at the same position and size as when it was last closed

  # ---------------------------------------------------------------------------
  # Menu bar
  # ---------------------------------------------------------------------------

  Scenario: The macOS menu bar shows standard application menus
    Given the app is running on macOS
    Then the menu bar contains at minimum:
      | Menu      | Items                                   |
      | App name  | About Health Flare, Quit Health Flare   |
      | Edit      | Cut, Copy, Paste, Select All (standard) |
      | Window    | Minimise, Zoom, Close                   |
    And keyboard shortcuts for standard items match macOS conventions

  Scenario: The About panel shows the app name and version
    Given the user opens About Health Flare from the app menu
    Then a panel appears showing "Health Flare" and the current version number
    And the version matches the version in pubspec.yaml

Feature: Linux and Windows Desktop Applications
  As a Health Flare user on Linux or Windows
  I want a fully functional desktop experience
  So that I can track my health on any desktop platform without cloud accounts or network access

  Background:
    Given the app is offline-first with all data stored on-device
    And no network permissions are required or requested

  # ---------------------------------------------------------------------------
  # CI builds
  # ---------------------------------------------------------------------------

  Scenario: The CI pipeline builds the Linux app successfully
    Given the Linux platform directory exists at linux/
    When `flutter build linux --debug` runs on ubuntu-latest in CI
    Then the build exits with code 0
    And a debug executable is produced at build/linux/x64/debug/bundle/health_flare
    And the artifact is archived as healthflare-linux-debug.tar.gz

  Scenario: The CI pipeline builds the Windows app successfully
    Given the Windows platform directory exists at windows/
    When `flutter build windows --debug` runs on windows-latest in CI
    Then the build exits with code 0
    And a debug executable is produced at build/windows/x64/runner/Debug/health_flare.exe
    And the artifact is archived as healthflare-windows-debug.zip

  Scenario: Linux and Windows builds are gated on the same quality checks as other platforms
    Given the CI pipeline runs
    Then the Linux build job requires flutter-analyze, dart-format, url-scan, flutter-pub-audit, and flutter-test to pass first
    And the Windows build job requires the same set of upstream jobs to pass first

  # ---------------------------------------------------------------------------
  # App icon — Linux
  # ---------------------------------------------------------------------------

  Scenario: The Linux app uses the Health Flare icon
    Given the Linux build
    Then linux/runner/my_application.cc (or the equivalent icon registration file) references the Health Flare icon
    And the icon is not the default Flutter or placeholder icon
    And the icon appears in the taskbar and application switcher when the app is running

  # ---------------------------------------------------------------------------
  # App icon — Windows
  # ---------------------------------------------------------------------------

  Scenario: The Windows app uses the Health Flare icon
    Given the Windows build
    Then windows/runner/resources/app_icon.ico is the Health Flare icon, not the default Flutter icon
    And the icon appears in the taskbar, title bar, and Alt+Tab switcher when the app is running

  # ---------------------------------------------------------------------------
  # Window behaviour (shared)
  # ---------------------------------------------------------------------------

  Scenario: The app window has the correct title on Linux and Windows
    Given the app is running on Linux or Windows
    When I look at the window title bar
    Then it reads "Health Flare"
    And not a generic identifier, bundle ID, or empty string

  Scenario: The app window has a sensible minimum size on Linux and Windows
    Given the app is running on Linux or Windows
    Then the window cannot be resized smaller than 800 × 600 logical pixels
    And at the minimum size all primary navigation and content areas remain visible and usable

  Scenario: The app window remembers its last position and size between launches
    Given the user has resized and repositioned the app window on Linux or Windows
    When the app is quit and relaunched
    Then the window opens at the same position and size as when it was last closed

  # ---------------------------------------------------------------------------
  # Distribution — Linux
  # ---------------------------------------------------------------------------

  Scenario: A release Linux build can be packaged as a self-contained archive
    Given a release build is produced with `flutter build linux --release`
    Then the build/linux/x64/release/bundle/ directory contains all required shared libraries
    And the bundle can be archived and run on a compatible Linux system without a Flutter installation
    And no external Flutter SDK is required at runtime

  # ---------------------------------------------------------------------------
  # Distribution — Windows
  # ---------------------------------------------------------------------------

  Scenario: A release Windows build can be packaged as a self-contained archive
    Given a release build is produced with `flutter build windows --release`
    Then the build/windows/x64/runner/Release/ directory contains all required DLLs
    And the directory can be archived and run on a compatible Windows system without a Flutter installation
    And no external Flutter SDK is required at runtime

# macOS Desktop Bug List

Known issues when running Health Flare on macOS. These do not affect iOS or Android.

---

## BUG-01 — Weather capture silently fails on macOS ✓ FIXED (PR #88)

**Symptom:** Weather is never attached to log entries on macOS. The app appears to work normally but `weatherSnapshot` is always null.

**Root cause:** Three missing platform configurations:

1. `macos/Runner/DebugProfile.entitlements` and `Release.entitlements` have `com.apple.security.network.server` (inbound) but not `com.apple.security.network.client` (outbound). The sandbox drops all outbound HTTP requests; `WeatherService.fetch()` catches the `SocketException` and returns null silently.

2. `macos/Runner/Info.plist` has no `NSLocationWhenInUseUsageDescription` key. macOS requires this string for the system permission dialog to appear; without it the permission request is silently denied.

3. Neither entitlements file contains `com.apple.security.personal-information.location`. The sandbox blocks location access regardless of the usage description.

**Files to change:**
- `macos/Runner/DebugProfile.entitlements` — add `com.apple.security.network.client` and `com.apple.security.personal-information.location`
- `macos/Runner/Release.entitlements` — same two keys
- `macos/Runner/Info.plist` — add `NSLocationWhenInUseUsageDescription` string

**Discovered:** 2026-05-25, during weather display fix (`fix/weather-display-on-entries`)

---

## BUG-02 — Profile picture selection crashes / does nothing on macOS ✓ FIXED (PR #88, #89)

**Symptom:** Tapping "Choose from gallery" or "Take photo" on the profile sheet does nothing or throws `UnimplementedError` on macOS.

**Root cause:** `image_picker` v1.x has no macOS implementation. `ImagePicker().pickImage(source: ImageSource.gallery)` throws `UnimplementedError` on macOS at runtime. `ImageSource.camera` is also unavailable on desktop.

**Affected files:**
- `lib/features/profiles/widgets/add_profile_sheet.dart` — `_pickAvatar()` method (line ~82)
- `lib/features/onboarding/widgets/onboarding_profile_zone.dart` — likely same pattern

**Fix approach:** Gate the `image_picker` path behind a platform check. On macOS, use `file_picker` (already a dependency — used by the backup/import flow) with `FileType.image` instead. Remove the camera option on desktop.

**Discovered:** 2026-05-25, noted alongside BUG-01

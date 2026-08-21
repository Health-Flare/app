# Apple App Store Submission Checklist

Health Flare is live on Google Play (`.github/workflows/release-playstore.yaml`, signed with a
Play upload keystore). This document tracks what's still needed to get the same app onto the
Apple App Store. It complements two docs that already exist and should **not** be duplicated:

- `docs/features/app-store.feature` — the BDD acceptance criteria for both stores. Treat every
  scenario in the "Apple App Store" section as a submission gate.
- `docs/store-listing.md` — the actual copy (description, keywords, subtitle) to paste into App
  Store Connect. Reuse it; update the version number to the current release before pasting.

This file is the **gap list and sequencing** — what's missing between where the repo/account
stand today and a submitted build.

---

## Current state (verified against the repo, 2026-08-18)

| Item | Status |
|---|---|
| iOS project | `ios/` exists, builds via standard Flutter tooling. Bundle ID `org.healthflare.app.healthflare`, deployment target 13.0, `TARGETED_DEVICE_FAMILY = "1,2"` (iPhone **and** iPad). Turns out the iOS target had never actually been built in this repo before 2026-08-18 — `ios/Runner.xcworkspace` never referenced `Pods.xcodeproj` and `ios/Podfile.lock` didn't exist, both since the initial commit. First `flutter build ios` / `pod install` now committed. |
| App icon | Full `AppIcon.appiconset` present, including the required 1024×1024 marketing icon. |
| Signing | No iOS distribution certificate, provisioning profile, or App Store Connect API key configured anywhere in CI or docs. |
| CI release automation | `release.yaml` (APK → Gitea/GitHub release), `release-playstore.yaml` (AAB → Play internal track), `release-macos.yaml` (DMG, ad-hoc notarized — **not** Mac App Store). **No iOS/App Store workflow exists.** |
| App Store Connect record | Not created (no evidence of an existing app record — nothing references an Apple Team ID or ASC app ID anywhere in the repo). |
| Screenshots | **Verified 2026-08-18** — `scripts/take_screenshots.sh` sweeps all three required device classes (iPhone 6.9"/6.5", iPad 13") into `screenshots/appstore/<slug>/`, 13/13 real screenshots per class, committed. See Phase 3 for how the first run surfaced and fixed a real app bug along the way. |
| Privacy policy | Published content exists at `docs/privacy-policy.md` / `.html`, referenced as `https://healthflare.org/privacy` in `docs/store-listing.md`. Confirm it's actually deployed and reachable at that URL before submitting — App Store Connect validates the link. |
| Export compliance | **Done (2026-08-21).** `ios/Runner/Info.plist` sets `ITSAppUsesNonExemptEncryption` = `false` — the app's only network call (weather lookup, see `.url-scan-ignore`) is standard HTTPS, which is export-exempt. |

---

## Phase 1 — Account & legal (do first — has lead time)

- [ ] Confirm Apple Developer Program enrollment is active for the entity used in
  `docs/store-listing.md` ("Automated Bytes Incorporated"). An organization account needs a
  D-U-N-S number and legal-entity verification — this can take **days**, so start it before
  anything else. (If enrolling as an individual instead, the seller name in the store listing
  changes from the org name to your legal name — decide this now, it's hard to change later.)
- [ ] Accept the current Apple Developer Program License Agreement in App Store Connect (re-accept
  whenever Apple updates it — this silently blocks builds/TestFlight if missed).
- [ ] Accept the free "Apps" Paid Applications Agreement equivalent — for a free app this is just
  the base agreement, already covered by enrollment, but confirm no banking/tax section is
  outstanding (App Store Connect flags this under Agreements, Tax, and Banking even for $0 apps in
  some regions).

## Phase 2 — App Store Connect record

- [ ] Register the App ID `org.healthflare.app.healthflare` in the Apple Developer portal
  (Certificates, Identifiers & Profiles → Identifiers) if not already present — note the macOS
  DMG workflow (`release-macos.yaml`) notarizes ad-hoc and never required a registered App ID, so
  this is likely a genuinely new step, not something reused from the macOS work.
- [ ] Create the app record in App Store Connect: name "Health Flare", primary language,
  bundle ID above, SKU (any internal string, e.g. `healthflare-ios`).
- [ ] Fill in App Information: category **Health & Fitness** (`docs/store-listing.md` and
  `docs/features/app-store.feature` now agree on this — Medical would carry extra review
  scrutiny around clinical claims), content rights, age rating questionnaire (expected
  result: 4+).
- [ ] Paste in Name / Subtitle / Description / Keywords / Promotional text / Support URL / Privacy
  Policy URL from `docs/store-listing.md` — update the "Version 1.0.0" references there to match
  the actual current `pubspec.yaml` version (currently `1.3.0`) since this will be a first
  submission at a version well past 1.0.0.
- [ ] Complete the App Privacy (nutrition label) questionnaire per the table already drafted in
  `docs/store-listing.md` ("App privacy" section) — all "No" except general on-device use.
- [ ] Write App Review notes explaining offline-first / no-account behavior and give reviewers a
  concrete test flow (add a profile → log a symptom → view dashboard). `app-store.feature` already
  specifies this as a gate — use it as the acceptance check.
- [x] Add `ITSAppUsesNonExemptEncryption` = `false` to `ios/Runner/Info.plist` (the app only makes
  standard HTTPS calls to the weather API — no proprietary encryption) so export-compliance isn't
  a manual per-build prompt. **Done 2026-08-21.**

## Phase 3 — Screenshots

**Automation done (2026-08-17).** `scripts/take_screenshots.sh` now sweeps all three required App
Store device classes in one run — iPhone 6.9", iPhone 6.5", and iPad 13" (the last one because
`TARGETED_DEVICE_FAMILY = "1,2"` means the app targets iPad, not just iPhone) — and writes each
class to its own subdirectory so runs don't clobber each other:

```bash
./scripts/take_screenshots.sh                # sweep: screenshots/appstore/<slug>/*.png
./scripts/take_screenshots.sh "iPhone 16"     # single device: screenshots/adhoc/*.png
./scripts/take_screenshots.sh --list          # list installed simulators
```

`test_driver/integration_test.dart` now reads `$SCREENSHOT_DIR` (set by the wrapper script per
device) instead of hardcoding `screenshots/`, which is what makes the per-class subdirectories
possible without touching the test file itself.

**Verified end-to-end (2026-08-18).** Installed the iOS 26.3 Simulator runtime
(`xcodebuild -downloadPlatform iOS`, ~8.4 GB) and created the three simulators
`DEVICE_CLASS_NAMES` expects (`xcrun simctl create` — Xcode only auto-provisions its newest
device lineup, but the older device *types* still exist and can be created directly). The first
sweep surfaced a real bug: `integration_test/screenshot_test.dart`'s `09b_journal_detail` test
used `find.text('Rough Saturday')`, which was ambiguous — `AppShell`'s nested `ShellRoute`
Navigator keeps the previous tab mounted offstage on `context.go()` rather than disposing it, and
the fixture's dashboard activity feed shows the same journal entries, so the same title text
existed twice in the tree. Fixed by scoping the tap to
`find.descendant(of: find.byType(JournalEntryCard), matching: find.text(...))`. Also fixed
`take_screenshots.sh`'s sweep loop, which previously aborted entirely on the first device's test
failure under `set -e` instead of continuing to the next device class.

Re-ran after both fixes: **all three device classes captured cleanly, 13/13 screenshots each**,
verified visually (correct Sarah Chen persona content, correct per-device resolutions, no
placeholder/lorem-ipsum content, iPad layout renders sensibly rather than breaking). Committed
under `screenshots/appstore/<slug>/` (matches the existing `v1`/`v2` pattern for older captures).

- [ ] Decide whether `TARGETED_DEVICE_FAMILY = "1,2"` (iPad support) is actually intentional —
  the iPad screenshots exist and look fine, but this is still a product decision, not something
  settled by the screenshots working. See "Open questions" below.
- [ ] Building iOS at all turned out to be a first for this repo — see the CocoaPods integration
  note under "Current state" above. Re-run the sweep again before final submission once the app
  has changed further, since these screenshots are a point-in-time capture, not a live artifact.

## Phase 4 — CI: build & sign

- [x] Decide signing approach. **Chosen 2026-08-21: App Store Connect API key + automatic
  signing** — generate an API key in App Store Connect (Users and Access → Integrations), store
  the `.p8` key + Key ID + Issuer ID as secrets, let `xcodebuild -allowProvisioningUpdates` handle
  cert/profile creation and renewal during CI. (Rejected: fastlane match / manual `.p12` +
  provisioning profile — more secrets to rotate, manual yearly profile renewal, no upside here
  since there's no existing fastlane setup in this repo to build on.)
- [x] Add `.github/workflows/release-appstore.yaml`, triggered on the same `v*.*.*` tag as the
  other release workflows. **Added 2026-08-21.** Note it does *not* go through `flutter build ipa`
  — that command has no passthrough for `-allowProvisioningUpdates`/`-authenticationKeyPath`
  (checked via `flutter build ipa --help`), so the workflow runs `flutter build ios --release
  --no-codesign` for the Dart/Flutter half, then calls `xcodebuild archive` and `xcodebuild
  -exportArchive` directly with the API-key auth flags, then `xcrun altool --upload-app`.
- [x] Document the new secrets at the top of the workflow file, following the existing comment
  convention in `release-playstore.yaml` and `release-macos.yaml`. **Done** — secrets are
  `APPSTORE_API_KEY_BASE64`, `APPSTORE_API_KEY_ID`, `APPSTORE_API_ISSUER_ID`, `APPLE_TEAM_ID`, each
  documented inline with where to generate it.
- [ ] **Untested — this workflow has never run.** It can't be exercised until Phase 1 (Developer
  Program enrollment) and Phase 2 (App Store Connect app record + the four secrets above) exist.
  Treat the first tag push through it as a dry run: watch the Actions/Gitea log closely, and
  budget time to debug — automatic-signing CI setups commonly fail on the first attempt over
  provisioning-profile scope or missing capabilities.
- [ ] First upload must be done manually (same caveat as the Play Store workflow's comment about
  needing one manual upload before the API will accept subsequent ones) — verify whether this
  applies to App Store Connect too before assuming the automated path works untested.

## Phase 5 — TestFlight (recommended before public submission)

- [ ] Upload a build to TestFlight first — internal testing only, no App Review required.
- [ ] Verify on a real device (or at minimum a fresh simulator) that: onboarding works, a profile
  can be created, data persists after force-quit, and the export-compliance flag suppressed the
  manual prompt.
- [ ] Optionally invite a couple of external testers (requires a lightweight Beta App Review, much
  faster than full App Review) to catch anything the automated CI can't.

## Phase 6 — Submit for review

- [ ] Attach the build from Phase 4/5 to the App Store Connect version record.
- [ ] Final pass through every scenario in `docs/features/app-store.feature` under "Apple App
  Store" and "Shared metadata" — treat it as the literal submission gate, not just a spec.
- [ ] Submit for review. Typical Apple review turnaround is 24–48 hours; a Health & Fitness app
  with no accounts/network/medical claims is low-risk for rejection as long as the review notes
  (Phase 2) clearly explain the offline, no-login behavior up front.

---

## Open questions to resolve before starting (not code — need a decision from you)

- Individual vs. organization Apple Developer account — affects the seller name shown in the
  store and how long enrollment takes.
- Whether iPad support (`TARGETED_DEVICE_FAMILY = "1,2"`) is intentional. If not, dropping it to
  iPhone-only removes the iPad screenshot requirement in Phase 3.
- If the Play Store listing is already live under a "Medical" category, note that fixing
  `docs/store-listing.md` to say Health & Fitness (done 2026-08-17) only affects future copy/paste
  — updating the *live* Play Console listing to match is a separate manual step, not implied by
  this doc.

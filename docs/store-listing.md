# Health Flare: App Store Listing Metadata

Copy ready to paste into App Store Connect and Google Play Console.
Character counts are noted where limits apply.

---

## Shared identity

| Field | Value |
|---|---|
| App name | Health Flare |
| Developer / seller name | Automated Bytes Incorporated |
| Bundle ID (iOS / macOS) | org.healthflare.app.healthflare |
| Package name (Android) | org.healthflare.app.healthflare |
| Version | 1.7.1 |
| Privacy policy URL | https://healthflare.org/privacy |
| Support URL | https://healthflare.org |
| Category (primary) | Health & Fitness |
| Content rating | 4+ (iOS) / Everyone (Android) |

---

## App Store Connect (iOS + macOS)

### Name
```
Health Flare
```
*(30 chars max: 12 used)*

### Subtitle
```
Chronic illness companion
```
*(30 chars max: 26 used)*

### Keywords
```
chronic illness,symptom tracker,health journal,flare,fibromyalgia,lupus,ME,CFS,medication log,pain tracker
```
*(100 chars max, 104 used; trim one if rejected: remove "pain tracker")*

Trimmed fallback (99 chars):
```
chronic illness,symptom tracker,health journal,flare,fibromyalgia,lupus,ME,CFS,medication log
```

### Description
*(4000 chars max)*

```
Health Flare is a private, offline-first health companion designed for people living with chronic illness.

Track your health story (symptoms, vitals, medications, meals, sleep, flares, activity, and daily check-ins) all in one place, all on your device. There are no accounts and no servers of ours. Your records are stored on your device and are included in your phone's own backup if you use one. Weather tracking is optional; if you turn it on, your approximate location is sent to a weather service to look up the conditions.

──────────────────────────────
WHAT YOU CAN TRACK
──────────────────────────────

• Symptoms: log severity over time to surface patterns
• Vitals: blood pressure, heart rate, temperature, oxygen, weight, blood glucose
• Medications & doses: track what you take and when
• Meals: note what you eat and flag reactions
• Sleep: bedtime, wake time, quality, and naps
• Flares: document flare start, severity, and triggers
• Daily check-ins: wellbeing, stress, and optional cycle tracking
• Activity & rest: log exertion with a PEM (post-exertional malaise) flag for ME/CFS
• Doctor visits: keep a record of appointments and notes
• Journal: long-form entries with mood and energy tagging

──────────────────────────────
BUILT FOR CHRONIC ILLNESS
──────────────────────────────

Health Flare was designed with the chronic illness community in mind, not the casual wellness market. It supports the kinds of tracking that matter for conditions like ME/CFS, fibromyalgia, lupus, EDS, POTS, IBD, MS, and other complex long-term conditions: including a dedicated PEM flag for post-exertional activity logging.

──────────────────────────────
MULTI-PROFILE SUPPORT
──────────────────────────────

Manage health records for yourself and the people you care for. Add profiles for family members, switch between them in seconds, and keep each person's data completely separate.

──────────────────────────────
YOUR DATA STAYS WITH YOU
──────────────────────────────

• No account or login required: ever
• No data uploaded to any server
• No analytics, telemetry, or crash reporting
• No advertising
• Data stored in a private, sandboxed database on your device
• Optional backup lets you export your data as a file and store it wherever you choose

Health Flare is not a medical device and does not provide medical advice. Always consult your healthcare team for medical decisions.
```

### What's New

Written per release in `docs/store-notes/<version>.md`; the latest is [1.10.0](store-notes/1.10.0.md). Older notes are in this file's history.

---

## Google Play Console

### App name
```
Health Flare
```
*(50 chars max: 12 used)*

### Short description
```
Private offline health tracker for chronic illness: no account needed.
```
*(80 chars max: 71 used)*

### Full description
*(4000 chars max)*

```
Health Flare is a private, offline-first health companion designed for people living with chronic illness.

Track your health story (symptoms, vitals, medications, meals, sleep, flares, activity, and daily check-ins) all in one place, all on your device. There are no accounts and no servers of ours. Your records are stored on your device and are included in your phone's own backup if you use one. Weather tracking is optional; if you turn it on, your approximate location is sent to a weather service to look up the conditions.

WHAT YOU CAN TRACK

• Symptoms: log severity over time to surface patterns
• Vitals: blood pressure, heart rate, temperature, oxygen, weight, blood glucose
• Medications & doses: track what you take and when
• Meals: note what you eat and flag reactions
• Sleep: bedtime, wake time, quality, and naps
• Flares: document flare start, severity, and triggers
• Daily check-ins: wellbeing, stress, and optional cycle tracking
• Activity & rest: log exertion with a PEM (post-exertional malaise) flag for ME/CFS
• Doctor visits: keep a record of appointments and notes
• Journal: long-form entries with mood and energy tagging

BUILT FOR CHRONIC ILLNESS

Health Flare was designed with the chronic illness community in mind, not the casual wellness market. It supports the kinds of tracking that matter for conditions like ME/CFS, fibromyalgia, lupus, EDS, POTS, IBD, MS, and other complex long-term conditions: including a dedicated PEM flag for post-exertional activity logging.

MULTI-PROFILE SUPPORT

Manage health records for yourself and the people you care for. Add profiles for family members, switch between them in seconds, and keep each person's data completely separate.

YOUR DATA STAYS WITH YOU

• No account or login required: ever
• No data uploaded to any server
• No analytics, telemetry, or crash reporting
• No advertising
• Data stored in a private, sandboxed database on your device
• Optional backup lets you export your data as a file and store it wherever you choose

Health Flare is not a medical device and does not provide medical advice. Always consult your healthcare team for medical decisions.
```

### Category
```
Health & Fitness
```

### Tags (Play Store)
```
chronic illness, health tracker, symptom log, medication tracker, health journal
```

### Recent changes

500 characters max. Written per release in `docs/store-notes/<version>.md`; the latest is [1.10.0](store-notes/1.10.0.md).

---

## Screenshot captions (suggested: for both stores)

These are short captions to display alongside screenshots. Adapt to your actual screens.

| Screen | Caption |
|---|---|
| Dashboard | Everything at a glance: your recent health activity in one feed |
| Symptom logging | Log symptoms with severity in seconds |
| Medication tracker | Track what you take and when |
| Daily check-in | A quick daily pulse: wellbeing, stress, and more |
| Journal | Long-form entries with mood and energy |
| Privacy / onboarding | Your records live on your device. No account. No server. |

---

## Data safety (Google Play)

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | Yes |
| Is all of the user data collected by your app encrypted in transit? | Yes: the weather request uses HTTPS |
| Do you provide a way for users to request that their data is deleted? | Yes: users can delete profiles and all associated data from within the app |

**Data types collected:** Location > Approximate location. Optional (weather tracking is off by default). Processed ephemerally: not stored by the app. Purpose: App functionality (looking up the weather).
**Data shared with third parties:** Approximate location is sent to Open-Meteo to fetch weather. Play treats a service provider acting on the app's behalf as "collected", not "shared"; Open-Meteo is used only to answer the request. Re-check Play's current definitions when submitting.

Health records are not collected: they never leave the device through the app. The OS backup (Google) is a platform service the user controls and is not declared as collection by the app.

---

## App privacy (App Store Connect: Privacy nutrition label)

Declare **Location > Coarse Location**: used for App Functionality, **not** linked to the user's identity, **not** used for tracking. Every other data type: **No**.

Justification: health records are stored locally in a sandboxed Isar database and are never sent by the app. The one network call is the opt-in weather lookup, which sends a location rounded to about 1 km to Open-Meteo over HTTPS, with no identifier attached. Apple counts data as collected when it is sent off the device and kept longer than needed to answer the request; Open-Meteo's own policy keeps server logs (which may include coordinates) for up to 90 days, so declare it rather than rely on the optional-disclosure exemption. No analytics, crash reporting, or advertising SDKs are included.

---

## Notes for submission

- **Category:** Health & Fitness on both stores (not Medical): the app does not diagnose, treat, or provide clinical recommendations, and Medical would trigger extra Apple review scrutiny around clinical claims that Health & Fitness avoids.
- **iOS minimum deployment target:** check Xcode project settings before submitting.
- **macOS:** submit as a separate listing or use the "Also available on Mac" option via Mac Catalyst / universal purchase if supported.
- **Android:** ensure `targetSdk` matches the current Play Store requirement before submitting.
- **Screenshots:** captured by `scripts/take_screenshots.sh` (App Store) and `scripts/take_screenshots_android.sh` (Play). Each capture folder has more shots than a store accepts, so upload from `bash scripts/store_upload_set.sh`, which builds `build/store_upload/<store>/<device>/` with exactly the right set, in order. Which folder is which: `screenshots/README.md`.
- **Preview videos (optional on both stores):** `scripts/take_video.sh` (iOS) and `scripts/take_video_android.sh` (Android) record the same guided tour used for the App Store "App Preview" slot and the Play Store listing's "Video" field (a YouTube URL: Play doesn't accept an uploaded file directly). See `docs/release-kit.md` for the full workflow, including how "What's New" copy above gets drafted.

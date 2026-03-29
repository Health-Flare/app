# Health Flare — App Store Listing Metadata

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
| Version | 1.0.0 |
| Privacy policy URL | https://healthflare.org/privacy |
| Support URL | https://healthflare.org |
| Category (primary) | Medical |
| Content rating | 4+ (iOS) / Everyone (Android) |

---

## App Store Connect (iOS + macOS)

### Name
```
Health Flare
```
*(30 chars max — 12 used)*

### Subtitle
```
Chronic illness companion
```
*(30 chars max — 26 used)*

### Keywords
```
chronic illness,symptom tracker,health journal,flare,fibromyalgia,lupus,ME,CFS,medication log,pain tracker
```
*(100 chars max — 104 used — trim one if rejected: remove "pain tracker")*

Trimmed fallback (99 chars):
```
chronic illness,symptom tracker,health journal,flare,fibromyalgia,lupus,ME,CFS,medication log
```

### Description
*(4000 chars max)*

```
Health Flare is a private, offline-first health companion designed for people living with chronic illness.

Track your health story — symptoms, vitals, medications, meals, sleep, flares, activity, and daily check-ins — all in one place, all on your device. There are no accounts, no servers, and no cloud. Your data never leaves your phone unless you choose to export it.

──────────────────────────────
WHAT YOU CAN TRACK
──────────────────────────────

• Symptoms — log severity over time to surface patterns
• Vitals — blood pressure, heart rate, temperature, oxygen, weight, blood glucose
• Medications & doses — track what you take and when
• Meals — note what you eat and flag reactions
• Sleep — bedtime, wake time, quality, and naps
• Flares — document flare start, severity, and triggers
• Daily check-ins — wellbeing, stress, and optional cycle tracking
• Activity & rest — log exertion with a PEM (post-exertional malaise) flag for ME/CFS
• Doctor visits — keep a record of appointments and notes
• Journal — long-form entries with mood and energy tagging

──────────────────────────────
BUILT FOR CHRONIC ILLNESS
──────────────────────────────

Health Flare was designed with the chronic illness community in mind, not the casual wellness market. It supports the kinds of tracking that matter for conditions like ME/CFS, fibromyalgia, lupus, EDS, POTS, IBD, MS, and other complex long-term conditions — including a dedicated PEM flag for post-exertional activity logging.

──────────────────────────────
MULTI-PROFILE SUPPORT
──────────────────────────────

Manage health records for yourself and the people you care for. Add profiles for family members, switch between them in seconds, and keep each person's data completely separate.

──────────────────────────────
YOUR DATA STAYS WITH YOU
──────────────────────────────

• No account or login required — ever
• No data uploaded to any server
• No analytics, telemetry, or crash reporting
• No advertising
• Data stored in a private, sandboxed database on your device
• Optional backup lets you export your data as a file and store it wherever you choose

Health Flare is not a medical device and does not provide medical advice. Always consult your healthcare team for medical decisions.
```

### What's New (version 1.0.0)
```
Initial release.
```

---

## Google Play Console

### App name
```
Health Flare
```
*(50 chars max — 12 used)*

### Short description
```
Private offline health tracker for chronic illness — no account needed.
```
*(80 chars max — 71 used)*

### Full description
*(4000 chars max)*

```
Health Flare is a private, offline-first health companion designed for people living with chronic illness.

Track your health story — symptoms, vitals, medications, meals, sleep, flares, activity, and daily check-ins — all in one place, all on your device. There are no accounts, no servers, and no cloud. Your data never leaves your phone unless you choose to export it.

WHAT YOU CAN TRACK

• Symptoms — log severity over time to surface patterns
• Vitals — blood pressure, heart rate, temperature, oxygen, weight, blood glucose
• Medications & doses — track what you take and when
• Meals — note what you eat and flag reactions
• Sleep — bedtime, wake time, quality, and naps
• Flares — document flare start, severity, and triggers
• Daily check-ins — wellbeing, stress, and optional cycle tracking
• Activity & rest — log exertion with a PEM (post-exertional malaise) flag for ME/CFS
• Doctor visits — keep a record of appointments and notes
• Journal — long-form entries with mood and energy tagging

BUILT FOR CHRONIC ILLNESS

Health Flare was designed with the chronic illness community in mind, not the casual wellness market. It supports the kinds of tracking that matter for conditions like ME/CFS, fibromyalgia, lupus, EDS, POTS, IBD, MS, and other complex long-term conditions — including a dedicated PEM flag for post-exertional activity logging.

MULTI-PROFILE SUPPORT

Manage health records for yourself and the people you care for. Add profiles for family members, switch between them in seconds, and keep each person's data completely separate.

YOUR DATA STAYS WITH YOU

• No account or login required — ever
• No data uploaded to any server
• No analytics, telemetry, or crash reporting
• No advertising
• Data stored in a private, sandboxed database on your device
• Optional backup lets you export your data as a file and store it wherever you choose

Health Flare is not a medical device and does not provide medical advice. Always consult your healthcare team for medical decisions.
```

### Category
```
Medical
```

### Tags (Play Store)
```
chronic illness, health tracker, symptom log, medication tracker, health journal
```

---

## Screenshot captions (suggested — for both stores)

These are short captions to display alongside screenshots. Adapt to your actual screens.

| Screen | Caption |
|---|---|
| Dashboard | Everything at a glance — your recent health activity in one feed |
| Symptom logging | Log symptoms with severity in seconds |
| Medication tracker | Track what you take and when |
| Daily check-in | A quick daily pulse — wellbeing, stress, and more |
| Journal | Long-form entries with mood and energy |
| Privacy / onboarding | Your data stays on your device. No account. No cloud. |

---

## Data safety (Google Play)

| Question | Answer |
|---|---|
| Does your app collect or share any of the required user data types? | No |
| Is all of the user data collected by your app encrypted in transit? | N/A — no data leaves the device |
| Do you provide a way for users to request that their data is deleted? | Yes — users can delete profiles and all associated data from within the app |

**Data types collected:** None.
**Data shared with third parties:** None.

---

## App privacy (App Store Connect — Privacy nutrition label)

Select **"No"** for every data type category. The app does not collect, share, or link any data to the user's identity.

Justification: all data is stored locally in a sandboxed Isar database. No network calls are made by the app. No analytics, crash reporting, or advertising SDKs are included.

---

## Notes for submission

- **Medical category review:** Apple may request additional review for apps in the Medical category. The app does not diagnose, treat, or provide clinical recommendations — state this clearly if asked.
- **iOS minimum deployment target:** check Xcode project settings before submitting.
- **macOS:** submit as a separate listing or use the "Also available on Mac" option via Mac Catalyst / universal purchase if supported.
- **Android:** ensure `targetSdk` matches the current Play Store requirement before submitting.

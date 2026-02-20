# Health Flare — Onboarding UX Copy

**Version:** 0.1
**Date:** 2026-02-17
**Status:** Draft — pending design review

This document defines the exact copy for every text element in the onboarding experience. Nothing here should be treated as placeholder text. These words are intentional. Changes to tone, promises, or privacy language must be reviewed before implementation.

---

## Design Principles for This Screen

1. **Warm, not clinical.** We are not a hospital. We are a companion.
2. **Honest, not vague.** Every privacy claim must describe a real, verifiable behaviour.
3. **Short sentences.** One idea. Then stop.
4. **No fear language.** No "warning", "risk", "failure", "data breach".
5. **Action-oriented.** The screen ends with doing something, not reading something.

---

## Zone 1 — Welcome

### App name (displayed as wordmark or heading)
```
Health Flare
```

### Headline
```
Your health story, in your hands.
```

### Supporting body copy
```
Living with a chronic illness means tracking a lot. Symptoms, medications, meals, patterns —
it adds up. Health Flare gives you one calm place to record it all, so nothing gets lost
between appointments.

It's not a doctor. It won't diagnose you. But it will help you walk into your next
appointment with a clear, organised picture of how you've really been feeling.
```

### Medical disclaimer (small text, below body copy)
```
Health Flare is a personal health journal. It is not a medical device and does not
provide medical advice, diagnosis, or treatment.
```

---

## Zone 2 — Privacy and Data Promise

### Section label (small caps or eyebrow text above headline)
```
YOUR DATA
```

### Privacy headline
```
Everything stays on this device.
```

### Supporting privacy facts (bullet list, concise)
```
• No account or login required — ever.
• Nothing is uploaded to any server or cloud.
• Your data only leaves this device when you choose to export or share it.
• We don't see it. We don't store it. We can't access it.
```

### "Learn more" trigger (tappable inline link or chevron)
```
How does this work? ›
```

---

### Expanded "Learn more" content

*This section is shown inline when the user taps "How does this work? ›". It collapses when tapped again.*

#### Expanded section heading
```
How Health Flare handles your data
```

#### Expanded body copy
```
All of your health records — symptoms, vitals, medications, meals, and reports — are stored
in a local database on this device only. This is not a backup. This is the only copy.

No network connection is required to use Health Flare. No data is sent anywhere in the
background. There are no analytics trackers, no usage reports, and no third-party services
with access to your records.

When you export a report as a PDF or CSV, that file is created on your device. You decide
where it goes — whether that's an email to your doctor, a message to a family member, or
a folder on your computer. Health Flare doesn't know what you did with it.

If you delete a profile, it is removed from the main views of the application. You can restore
a profile as long as the data exists on your device. From the profile manager, you can choose
to delete these profiles from your device permanently. There is no backup cloud copy to recover.

A note on backups: because your data lives only on this device, it will be included in
your device's standard backup (iCloud Backup on iOS, Google Backup on Android, or your
desktop's backup system). Those backups are managed by your device, not by Health Flare.
We recommend keeping device backups enabled so you don't lose your records if something
happens to your device.

There is no "Health Flare account". There are no subscription services tied to your data.
Your records belong to you.
```

#### Collapse trigger
```
Got it ‹
```

---

## Zone 3 — Profile Creation

### Section label (small caps or eyebrow text)
```
LET'S GET STARTED
```

### Section heading
```
Who are we tracking?
```

### Supporting line (below heading)
```
You can track your own health, or set up a profile for someone you care for.
You can always add more people later.
```

### Name field

- **Label:** `Name`
- **Placeholder:** `e.g. Sarah, Dad, Myself`
- **Required:** Yes
- **Validation error message:** `A name helps keep records organised. Please enter one to continue.`

### Date of birth field

- **Label:** `Date of birth`
- **Helper text:** `Optional — useful for reports`
- **Placeholder:** `DD / MM / YYYY`
- **Required:** No

### Avatar / photo field

- **Label:** `Photo`
- **Helper text:** `Optional`
- **Action options (shown in sheet):**
  - `Take a photo`
  - `Choose from library`
  - `Cancel`

### Primary action button
```
Create profile and get started →
```

*Button is disabled until a valid name is entered. When disabled it remains visible but visually muted — it does not disappear.*

---

## Post-Setup: First-Log Prompt

*Shown immediately after the primary action button is tapped and the profile is saved. Appears as a modal sheet or full-screen prompt over the dashboard.*

### Heading
```
You're all set, [Name].
```

*(Replace `[Name]` with the profile name entered during setup.)*

### Body copy
```
The best way to spot patterns is to start logging now, while the day is fresh.
What would you like to record first?
```

### Option cards (four, tappable)

| Card | Icon suggestion | Label | Sublabel |
|---|---|---|---|
| Symptom | 🩺 | **A symptom** | How are you feeling right now? |
| Vital | 📊 | **A vital** | Blood pressure, heart rate, and more |
| Meal | 🍽️ | **A meal** | What did you last eat or drink? |
| Medication | 💊 | **A medication** | Add something you're currently taking |

### Dismiss link (below option cards)
```
I'll explore on my own →
```

*Small, clearly tappable, but visually secondary to the option cards. Not hidden.*

---

## Empty States (shown on first use of each section, before any data is logged)

### Dashboard — no data logged yet
**Heading:** `Nothing logged yet.`
**Body:** `Tap the + button to record a symptom, vital, meal, or medication. The more you log, the clearer your health picture becomes.`

### Symptom & Vitals — no entries
**Heading:** `No symptoms or vitals logged yet.`
**Body:** `Tap + to record how you're feeling or add a measurement like blood pressure or heart rate.`

### Medications — no medications added
**Heading:** `No medications added yet.`
**Body:** `Tap + to add a medication you're currently taking or have taken in the past.`

### Meals — no meals logged
**Heading:** `No meals logged yet.`
**Body:** `Tap + to record what you ate. If something caused a reaction, you can flag it — Health Flare will help you spot patterns over time.`

### Reports — no data to report on
**Heading:** `Not enough data yet.`
**Body:** `Start logging symptoms, vitals, meals, or medications and your first report will be ready to generate within a day or two.`

---

## Accessibility Notes for Implementers

- The primary action button's accessible label must be: `"Create profile and get started"`
- The name field's accessible label must be: `"Profile name, required"`
- The "How does this work?" toggle must announce its expanded/collapsed state: `"Privacy details, collapsed, double tap to expand"` / `"Privacy details, expanded, double tap to collapse"`
- The four first-log option cards must each have accessible labels that include both the label and sublabel, e.g.: `"Log a symptom — how are you feeling right now?"`
- The dismiss link must be labelled: `"Skip for now, explore the app on my own"`
- No colour alone is used to distinguish required vs optional fields — the word "Optional" or "Required" is always present in the helper text
- Minimum touch target size: 44×44pt on all interactive elements

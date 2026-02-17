# Healthflare — Product Requirements

**Version:** 0.1
**Date:** 2026-02-17
**Status:** Draft

---

## 1. Purpose and Vision

Healthflare is a chronic illness tracking application. Its purpose is to make it easy for a person to record and review their own health data, or the health data of one or more dependants (such as a child, parent, or partner). The app is designed to be straightforward to use day-to-day and to produce useful summaries that can be shared with medical providers.

The app is not a medical device and does not provide diagnoses or clinical recommendations. It is a personal health journal with structure.

---

## 2. Users

### Primary User (Caregiver / Self-Tracker)
A person who opens the app and records health data. They may be tracking their own health, or acting as a caregiver tracking one or more other people.

### Profile (Tracked Person)
A named person whose health data is being recorded. The primary user may be their own profile, or they may manage multiple profiles (e.g. themselves, a child, and an elderly parent).

> **Future intent:** Profiles are designed to eventually become standalone accounts that the tracked person can take ownership of and manage themselves. This must be kept in mind during data modelling so that migrating a profile to an independent account is possible later without data loss.

---

## 3. Platforms

Healthflare must run on:
- iOS
- Android
- Web (browser)
- macOS
- Windows

All platforms must have feature parity. The app is built with Flutter to support this.

---

## 4. Authentication

**MVP:** No user accounts or login are required. The app is single-instance, local-only. Whoever has the device has access to the data.

**Future:** Authentication will be added when cloud sync or profile hand-off is introduced.

---

## 5. Data Storage

All data is stored locally on the device. There is no cloud sync or remote storage in the MVP. Data must not leave the device unless the user explicitly exports or shares it.

---

## 6. Profiles

### 6.1 Creating a Profile
The user can create one or more profiles. Each profile has:
- A display name (required, e.g. "Sarah", "Dad")
- An optional date of birth
- An optional avatar or photo

### 6.2 Switching Profiles
The user can switch between profiles at any time from within the app. It must always be clear which profile is currently active.

### 6.3 Editing and Deleting Profiles
The user can edit a profile's details. The user can delete a profile, which removes all associated data after an explicit confirmation.

### 6.4 Default Profile
If only one profile exists, it is always active. If multiple exist, the last-used profile is remembered between sessions.

---

## 7. Symptom and Vitals Logging

### 7.1 Logging a Symptom
The user can log a symptom for the active profile. A symptom log entry includes:
- Date and time (defaults to now, editable)
- Symptom name or description (free text, with optional saved shortcuts for commonly used symptoms)
- Severity (a numeric scale of 1–10, or a simple low/medium/high option — to be decided at design time)
- Optional notes

### 7.2 Logging Vitals
The user can log numeric health measurements for the active profile. Supported vital types in MVP:
- Blood pressure (systolic / diastolic)
- Heart rate (BPM)
- Blood glucose
- Temperature
- Weight
- Oxygen saturation (SpO2)
- Respiratory rate

Each vital log entry includes:
- Date and time (defaults to now, editable)
- Measurement value and unit
- Optional notes

### 7.3 Viewing Symptom and Vital History
The user can view a chronological list of past symptom and vital entries for the active profile. The user can tap into any entry to view its full detail. The user can edit or delete any past entry.

---

## 8. Medication Tracking

### 8.1 Adding a Medication
The user can add a medication to the active profile. A medication record includes:
- Medication name (free text)
- Dose amount and unit (e.g. 10mg, 2 tablets)
- Frequency / schedule (e.g. once daily, twice daily, as needed)
- Start date
- Optional end date
- Optional notes

### 8.2 Logging a Dose
The user can log that a dose of a medication was taken. A dose log includes:
- The medication it belongs to
- Date and time taken (defaults to now, editable)
- Dose amount (can differ from the scheduled amount for "as needed" medications)
- Optional notes (e.g. "took with food", "missed evening dose")

### 8.3 Skipped or Missed Doses
The user can mark a dose as skipped or missed, with an optional reason.

### 8.4 Viewing Medication History
The user can view the list of current medications for the active profile. The user can view the dose log history for each medication. The user can edit or delete any medication or dose entry.

### 8.5 Discontinuing a Medication
The user can mark a medication as discontinued (set an end date) rather than deleting it. Historical dose data is preserved.

---

## 9. Meal and Food Logging

### 9.1 Logging a Meal
The user can log a meal or food item for the active profile. A meal log entry includes:
- Date and time (defaults to now, editable)
- Meal description (free text — what was eaten)
- Optional photo (taken from camera or chosen from library)
- Optional notes

### 9.2 Reactions and Symptom Associations
After logging a meal, the user can optionally flag it as having been followed by a reaction or symptom. This creates a soft link between the meal entry and any symptom entries logged nearby in time, allowing the user (and reports) to identify potential food triggers.

### 9.3 Viewing Meal History
The user can view a chronological list of past meal entries for the active profile. The user can tap into any entry to view its full detail including photo if present. The user can edit or delete any past entry.

---

## 10. Reports and Data Export

### 10.1 Report Scope
The user can generate a report for the active profile. The user selects:
- Date range (e.g. last 7 days, last 30 days, custom range)
- Which data types to include (symptoms, vitals, medications, meals — any combination)

### 10.2 Report Content
A report contains a readable summary of the selected data, organised chronologically. Where relevant, it highlights patterns (e.g. meals followed by symptoms). Reports are intended to be useful for a doctor or specialist appointment.

### 10.3 PDF Export
The user can export the report as a PDF. The PDF is formatted for easy reading and printing.

### 10.4 Share Sheet
The user can share the report (PDF or CSV) using the native OS share sheet, allowing them to send it via email, messages, AirDrop, or any installed app.

### 10.5 CSV Export
The user can export raw data as a CSV file. Each data type (symptoms, vitals, medications, meals) is exported as a separate CSV or a multi-sheet file. This is intended for users who want to process or visualise their data in a spreadsheet.

---

## 11. Navigation and General UX

### 11.1 Primary Navigation
The app has a clear primary navigation structure giving access to:
- The current profile's dashboard / summary view
- Symptom and vitals log
- Medications
- Meal log
- Reports

### 11.2 Quick Entry
The user should be able to log a new symptom, vital, dose, or meal within a minimal number of taps from any screen. Speed of entry is important — the app must not be cumbersome to use during a moment of need.

### 11.3 Profile Switcher
Profile switching is accessible from a persistent location (e.g. top of the screen or a settings panel). The active profile name is always visible.

### 11.4 Empty States
When a user first opens the app or creates a new profile, they are guided clearly on what to do first. Empty screens must not feel broken.

---

## 12. Out of Scope for MVP

The following are explicitly out of scope for the first release but should not be architected against:

- User accounts and login
- Cloud sync or remote backup
- Reminders and push notifications
- Integration with Apple HealthKit or Google Health Connect
- Clinician / provider-facing views
- Social or sharing features between users
- Medication interaction checking
- AI or automated analysis

---

## 13. Glossary

| Term | Definition |
|---|---|
| Profile | A named person whose health data is tracked within the app |
| Primary User | The person operating the app (may be their own profile or a caregiver) |
| Caregiver | A primary user who manages profiles for other people |
| Vital | A numeric health measurement (e.g. heart rate, blood pressure) |
| Symptom | A subjective health experience recorded by the user (e.g. headache, fatigue) |
| Dose log | A record that a medication dose was taken, skipped, or missed |
| Reaction | A symptom or response that follows a meal, flagged by the user as a potential food trigger |
| Report | A formatted summary of health data over a chosen time range |

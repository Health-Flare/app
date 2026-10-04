# Privacy Policy

**Health Flare**
Last updated: 3 October 2026

---

## The short version

Health Flare has no servers, no accounts, no analytics and no advertising. We never receive your data. Your records are stored on your device.

Two things can take a copy off your device:

- **Your phone's own backup.** If iCloud Backup or Google backup is turned on, your records are included in it, the same as other apps' data. See Phone backups below.
- **Optional weather tracking.** If you turn it on, your approximate location is sent to Open-Meteo, a weather service, to look up the current conditions. Your health records are never sent. See Weather below.

Anything else leaves your device only when you export or share it yourself.

---

## Who we are

Health Flare is developed and maintained by Automated Bytes Incorporated. References to "we", "us", or "our" in this policy refer to Automated Bytes Incorporated as the developer of Health Flare.

---

## What data Health Flare stores

Health Flare stores the following data on your device:

- Health entries you create: symptoms, vitals, medications, doses, meals, sleep, flares, daily check-ins, appointments, activity logs, and journal entries
- Profile information you enter: names, dates of birth, and optional profile photos
- Weather conditions saved with an entry, if you turn on weather tracking
- App preferences and settings

This data is stored in a private, sandboxed database on your device. Other apps can't read it. Health Flare does not send it to us or to anyone else. It is included in your phone's own backup (see Phone backups below), and it leaves your device in any other way only when you export or share it.

---

## What data Health Flare does NOT collect

We, the developer, receive nothing from the app:

- We do not collect any personal information
- We do not collect any health or medical data
- We do not use analytics or crash reporting tools
- We do not use advertising networks or tracking tools
- We do not collect device identifiers or IP addresses
- We do not collect your location. If you turn on weather tracking, your approximate location goes to Open-Meteo, not to us (see Weather below)
- We do not have any servers that receive data from the app
- We do not require an account or login of any kind

---

## Phone backups

Your Health Flare records are part of the app's data on your phone, so they are included in your phone's own backup if you use one. That is how most people keep their records when a phone breaks, is lost, or is replaced. These backups are run by Apple, Google, or your computer's backup system, not by Health Flare, and we cannot see them.

How they are protected depends on the platform:

- **Android (9 and later):** your backup is stored by Google and locked with your phone's screen lock PIN, pattern, or password, as long as you have one set, so Google cannot read it. Without a screen lock, it is encrypted, but not with a secret only you know.
- **iPhone:** iCloud Backup is encrypted. Under Apple's standard data protection, Apple holds the encryption keys, so Apple can decrypt your backup, for example to restore it, or if required by law. If you turn on Advanced Data Protection for iCloud, only your own devices hold the keys, and Apple cannot read your backup.
- **Computers:** backups made by your computer (for example Time Machine on a Mac) follow that system's own settings.

To leave Health Flare out of iCloud Backup on iPhone: open Settings, tap your name, then iCloud, Manage Account Storage, Backups, choose this iPhone, and turn off Health Flare. Android does not offer a per-app setting; backup can only be turned off for the whole phone, in your phone's backup settings. If you turn phone backups off, use Export backup in Health Flare's settings so you still have a copy.

The database itself is not encrypted by Health Flare. It is protected by your phone's own storage encryption and app sandbox. We are working on encrypting it in a way that still lets you move to a new phone.

---

## Exported backups

Health Flare also lets you export a copy of your data as a file. This export happens **only when you explicitly request it**, and the resulting file goes only where you choose to send it: for example, saving it to your Files app, sending it to yourself via AirDrop, or attaching it to an email.

You can optionally lock an exported backup with a password. The file is then encrypted on your device (AES-256-GCM, with a key derived from your password using Argon2id) before it is shared, so only someone who knows the password can read it. Your password is never stored or sent anywhere, which also means a lost password cannot be recovered and the backup cannot be opened without it. A backup exported without a password is not encrypted, and anyone who has a copy of the file can read it.

We never receive, process, or have access to any backup files you create.

---

## Weather (optional)

Weather tracking is off unless you turn it on, for each profile separately. If it is on, then when you start a new entry Health Flare:

- Asks your device for a low-accuracy location reading
- Rounds it to about 1 kilometre and sends only that latitude and longitude to [Open-Meteo](https://open-meteo.com), a weather service, to fetch the temperature, humidity, pressure, wind speed and general conditions
- Saves the weather with your entry, in the same on-device database as the rest of your data

Health Flare does not save your location, and sends nothing else with it: no account, no device identifier, no health information. A weather lookup is reused for up to 30 minutes, so logging several entries close together sends one request.

Open-Meteo is a separate service with its own privacy policy, which we don't control. Like any web service, it receives your IP address with the request. Its policy says it may keep web server logs, which can include the coordinates, for up to 90 days, does not share them, and does not link them to a person.

You can turn weather tracking off at any time in the profile's settings, and you can deny or revoke location permission in your device's settings.

---

## Camera and photo library access

Health Flare may request access to your camera and photo library to allow you to set a profile photo or add a photo to a meal. Any photo you select or capture is stored on your device as part of the app's private data. Health Flare never uploads or sends photos anywhere. Like the rest of the app's data, they can be included in your phone's own backup.

---

## Children's privacy

Health Flare does not knowingly collect any information from anyone, including children under 13. A parent may keep a profile for a child; that profile's records are stored on the device like everyone else's, covered by the same phone backup and weather rules above.

---

## Changes to this policy

If we make material changes to this policy, we will update the "Last updated" date at the top of this page.

---

## Contact

If you have questions about this privacy policy, you can reach us at:

**Automated Bytes Incorporated**
privacy@healthflare.org

---

*Health Flare is a product of Automated Bytes Incorporated. This privacy policy applies to the Health Flare application on iOS, macOS, and Android.*

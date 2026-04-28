# Security Policy

Thank you for helping keep Health Flare and its users safe. Health Flare stores
sensitive personal health information entirely on-device, so we take security
reports seriously and try to handle them quickly and transparently.

This policy explains what is in scope, how to report a vulnerability, and what
you can expect from us in response.

---

## Supported versions

Health Flare follows a rolling-release model. Only the latest released version
on each supported platform receives security fixes.

| Version          | Supported          |
| ---------------- | ------------------ |
| Latest release   | :white_check_mark: |
| Previous release | Best effort        |
| Older releases   | :x:                |

If you are running an older build, please update to the latest release before
filing a report — the issue may already be fixed.

---

## What is in scope

Health Flare is an **offline-first** mobile and desktop application. It does
not run any servers, does not have user accounts, and does not transmit data
over the network. The threat model is therefore focused on the application,
its on-device data store, and its build/release pipeline.

In-scope examples:

- Vulnerabilities in the Health Flare source code (anything under `lib/`,
  `android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/`, `scripts/`,
  `tools/`).
- Issues that allow another app, user, or attacker with local/physical access
  to read, modify, or exfiltrate Health Flare's on-device data outside of the
  documented export flow.
- Issues in how exports (PDF/CSV/backup files) are generated, named, or
  shared that could leak data unintentionally.
- Issues that cause Health Flare to make unexpected outbound network requests
  (this would violate our offline-first guarantee — see `README.md`).
- Vulnerabilities in our build, signing, or release tooling that could let an
  attacker ship a tampered binary.
- Supply-chain issues in pinned dependencies (`pubspec.lock`) that materially
  affect users of the shipped app.

Out of scope:

- Bugs that require a rooted/jailbroken device, a compromised OS, or another
  app already running with elevated privileges, unless Health Flare meaningfully
  worsens the impact.
- Reports generated solely by automated scanners with no demonstrated impact.
- Social-engineering attacks against maintainers or contributors.
- Issues in third-party services we link to (e.g. an external privacy-policy
  page or app-store listing).
- Missing security headers / TLS configuration on `git.ahosking.com` or other
  infrastructure that does not host user data — please report those to the
  infrastructure operator directly.
- Denial-of-service that requires an attacker to already have full local
  control of the user's device.

If you are unsure whether something is in scope, send it anyway and we'll
triage it.

---

## Reporting a vulnerability

**Please do not open a public issue, pull request, or forum post for security
problems.** Public disclosure before a fix is shipped puts users at risk.

Report vulnerabilities privately by email to:

**security@healthflare.org**

Please include, to the extent you can:

- A clear description of the issue and its impact.
- The affected platform(s) and app version (Settings → About).
- Steps to reproduce, ideally with a minimal proof of concept.
- Any logs, screenshots, or sample data files that help us reproduce it
  (please redact real personal health data).
- Whether you intend to disclose publicly, and on what timeline.

If you would like to encrypt your report, request our PGP key in your first
message and we will respond with the current key fingerprint.

---

## What to expect from us

- **Acknowledgement** within **3 business days** of receiving your report.
- **Initial triage** (severity assessment, scope confirmation, request for
  more information if needed) within **10 business days**.
- **Status updates** at least every **14 days** while the report is open.
- **A fix or mitigation plan** for confirmed vulnerabilities, with a target
  remediation window based on severity:
  - Critical: 7 days
  - High: 30 days
  - Medium: 60 days
  - Low: best effort, typically with the next release
- **Credit** in the release notes / `CHANGELOG.md` for the reporter, if you
  want it. Let us know how you'd like to be credited (name, handle, link), or
  ask to remain anonymous.

If we disagree that a report is a vulnerability, we'll explain why. If we
agree but cannot fix it quickly (for example, because the root cause is in an
upstream dependency), we'll tell you what mitigations are available and track
the upstream fix.

---

## Coordinated disclosure

We follow a coordinated-disclosure model. We ask that you:

- Give us a reasonable opportunity to investigate and ship a fix before
  disclosing the issue publicly — typically **90 days** from the date we
  acknowledge the report, or sooner if a fix has shipped.
- Avoid accessing, modifying, or deleting data that does not belong to you.
- Avoid privacy violations, degradation of service, or destruction of data
  during your testing.
- Use only test profiles and synthetic data when reproducing issues.

If a vulnerability is being actively exploited in the wild, we may shorten
the disclosure window and ship an emergency release.

---

## Safe harbour

We will not pursue legal action against researchers who:

- Make a good-faith effort to comply with this policy,
- Report issues promptly and privately,
- Avoid privacy violations and data destruction, and
- Do not exploit the issue beyond what is necessary to demonstrate it.

This safe-harbour statement is a commitment from the Health Flare maintainers
and Automated Bytes Incorporated. It does not bind any third party (for
example, app-store operators, OS vendors, or upstream dependency authors).

---

## Hardening notes for forks and self-builders

Health Flare is licensed under GPL-3.0 and forks are welcome. If you
distribute a modified build:

- Keep the offline-first guarantees intact, or update the README, privacy
  policy, and store listing to clearly reflect your changes.
- Re-sign builds with your own signing keys; do not reuse upstream keys.
- Re-run `bash scripts/check_urls.sh` and `bash scripts/check_deps.sh` before
  publishing a release.
- Set up your own security contact — the `security@healthflare.org` address
  only handles reports for upstream Health Flare builds distributed by
  Automated Bytes Incorporated.

---

## Contact

- Security reports: **security@healthflare.org**
- Privacy questions (non-security): **privacy@healthflare.org**
- Maintainer: Automated Bytes Incorporated

Thank you for helping protect people who trust Health Flare with their
health data.

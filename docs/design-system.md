# Health Flare Design System

**Version 1.0 — Living Document**

---

## Design Philosophy

Health Flare lives at the intersection of two emotional truths: the weight of managing a child's chronic condition, and the quiet determination of families who do it every day. The design must never feel clinical, anxious, or cluttered. It should feel like morning light — warm, clear, and full of forward momentum.

### Core design principles:

- **Warm clarity over cold sterility.** This is not a hospital app.
- **Calm confidence** — every screen should feel manageable, never overwhelming.
- **Honest softness** — gentle without being saccharine. Parents are the primary users; they need to trust it.
- **Progressive warmth** — the more someone uses the app, the more personalised and familiar it feels.

---

## Brand Concept: The Flare

The name HealthFlare references the medical concept of a "flare" (symptom episode), but the brand reclaims it — transforming a word associated with difficulty into one associated with light, dawn, and visibility. The visual language draws from early morning light breaking through: warm amber rising into soft sky, clear air, the sense that you can see clearly today.

---

## Colour Palette

### Primary Palette

| Name         | Hex       | Usage                                          |
|--------------|-----------|------------------------------------------------|
| Flare Amber  | `#F5A623` | Primary CTA buttons, key highlights, active states |
| Dawn Coral   | `#F07560` | Secondary accents, alert indicators, energy    |
| Morning Sky  | `#6BB8D4` | Links, informational states, calm counterpoint |
| Soft Cloud   | `#F4F1EC` | App background, cards, surface base            |
| Deep Dusk    | `#2C2825` | Primary text, headings                         |

### Extended Palette

| Name          | Hex       | Usage                                          |
|---------------|-----------|------------------------------------------------|
| Sunrise Peach | `#FDE8D8` | Card tints, notification backgrounds, subtle fills |
| Pale Sky      | `#DFF0F7` | Info banners, highlight backgrounds            |
| Sage Mist     | `#B8CCBF` | Success states, stable/good readings           |
| Warm Linen    | `#EDE8DF` | Dividers, borders, secondary surfaces          |
| Ash White     | `#FAFAF8` | Page backgrounds, modals                       |

### Semantic Colours

| Purpose            | Colour      | Hex       |
|--------------------|-------------|-----------|
| Success / Stable   | Sage Mist   | `#B8CCBF` |
| Warning / Mild concern | Flare Amber | `#F5A623` |
| Alert / Active flare | Dawn Coral | `#F07560` |
| Info               | Morning Sky | `#6BB8D4` |
| Destructive / Delete | —         | `#C94F3A` |

### Severity Scale (Symptom Logging)

Used for symptom intensity selectors — a 5-step warm gradient, never red-to-green (avoids traffic light anxiety).

| Level | Name        | Hex       |
|-------|-------------|-----------|
| 1     | Clear       | `#B8CCBF` |
| 2     | Mild        | `#F5E6A3` |
| 3     | Moderate    | `#F5A623` |
| 4     | Significant | `#F07560` |
| 5     | Severe      | `#C94F3A` |

---

## Typography

### Font Families

**Display / Headings: Fraunces**
A variable serif with a warm, optical personality. It has softness without fragility — trustworthy and approachable. Used for app name, marketing headlines, section titles.

**Body / UI: DM Sans**
Clean, humanist sans-serif with a warm baseline. Excellent legibility at small sizes on mobile. Used for all body copy, labels, navigation, data display.

**Mono / Data: DM Mono**
For timestamps, data values, medical codes, and log entries — pairs naturally with DM Sans.

### Type Scale

| Token      | Size              | Weight | Font      | Usage                           |
|------------|-------------------|--------|-----------|--------------------------------|
| display-xl | 40px / 2.5rem     | 600    | Fraunces  | Marketing hero headlines        |
| display-lg | 32px / 2rem       | 600    | Fraunces  | App section headers             |
| display-md | 24px / 1.5rem     | 500    | Fraunces  | Card titles, modal headers      |
| heading-sm | 18px / 1.125rem   | 600    | DM Sans   | Sub-section headers             |
| body-lg    | 16px / 1rem       | 400    | DM Sans   | Primary body copy               |
| body-md    | 14px / 0.875rem   | 400    | DM Sans   | Secondary body, descriptions    |
| label      | 13px / 0.8125rem  | 500    | DM Sans   | Form labels, UI labels          |
| caption    | 12px / 0.75rem    | 400    | DM Sans   | Timestamps, footnotes           |
| data       | 14px / 0.875rem   | 400    | DM Mono   | Log values, stats, codes        |

### Line Heights

- Display: 1.2
- Body: 1.6
- Labels & captions: 1.4

---

## Spacing System

**Base unit: 4px**

| Token    | Value | Usage                            |
|----------|-------|----------------------------------|
| space-1  | 4px   | Micro gaps, icon padding         |
| space-2  | 8px   | Tight component spacing          |
| space-3  | 12px  | List item gaps                   |
| space-4  | 16px  | Standard component padding       |
| space-5  | 20px  | Card inner padding               |
| space-6  | 24px  | Section gaps, form spacing       |
| space-8  | 32px  | Large section breaks             |
| space-10 | 40px  | Page section separation          |
| space-12 | 48px  | Hero/marketing breathing room    |

---

## Border Radius

| Token       | Value   | Usage                              |
|-------------|---------|-----------------------------------|
| radius-sm   | 6px     | Tags, chips, badges               |
| radius-md   | 12px    | Buttons, inputs, small cards      |
| radius-lg   | 18px    | Cards, modals, sheets             |
| radius-xl   | 28px    | Large feature cards, hero elements |
| radius-full | 9999px  | Pills, toggles, avatar circles    |

---

## Elevation & Shadow

Shadows use warm tones (amber-shifted, not grey) to maintain the warm palette feel.

| Token        | Value                                | Usage                    |
|--------------|--------------------------------------|--------------------------|
| shadow-sm    | `0 1px 3px rgba(44,40,37,0.08)`      | Subtle card lift         |
| shadow-md    | `0 4px 12px rgba(44,40,37,0.10)`     | Standard cards, buttons  |
| shadow-lg    | `0 8px 24px rgba(44,40,37,0.12)`     | Modals, bottom sheets    |
| shadow-focus | `0 0 0 3px rgba(245,166,35,0.35)`    | Focus ring (amber)       |

---

## Iconography

**Style:** Rounded line icons with 1.5px stroke weight. Avoid sharp/angular icon sets — they conflict with the warmth of the palette.

**Recommended library:** Phosphor Icons (Duotone weight for feature icons, Regular for UI)

**Feature icon treatment:** Key app icons (log, insights, timeline, share) rendered in Duotone style using Flare Amber + Dawn Coral as fill layers over the line — creates a distinctive branded feel for the app's core verbs.

---

## Component Tokens

### Buttons

| Variant     | Background     | Text       | Border      |
|-------------|----------------|------------|-------------|
| Primary     | Flare Amber    | Deep Dusk  | —           |
| Secondary   | Sunrise Peach  | Deep Dusk  | Warm Linen  |
| Ghost       | Transparent    | Deep Dusk  | Warm Linen  |
| Destructive | `#C94F3A`      | White      | —           |
| Disabled    | Warm Linen     | `#9E9790`  | —           |

- Border radius: radius-md (12px)
- Padding: 12px 20px (standard), 10px 16px (compact)
- Font: DM Sans, 15px, weight 500

### Input Fields

- Background: Ash White
- Border: 1.5px solid Warm Linen
- Border (focused): 1.5px solid Flare Amber
- Focus ring: shadow-focus
- Border radius: radius-md
- Label: caption token, Deep Dusk at 70% opacity

### Cards

- Background: White or Soft Cloud
- Border: 1px solid Warm Linen
- Border radius: radius-lg
- Shadow: shadow-sm at rest, shadow-md on hover/press

---

## Motion & Animation

**Principle:** Purposeful, never decorative. Animations should communicate state changes, guide attention, and reward interaction — not perform.

| Interaction              | Duration | Easing                              |
|--------------------------|----------|-------------------------------------|
| Micro (toggle, tap)      | 150ms    | ease-out                            |
| Standard (card expand, modal) | 250ms | `cubic-bezier(0.4, 0, 0.2, 1)`     |
| Page transitions         | 320ms    | `cubic-bezier(0.4, 0, 0.2, 1)`     |
| Skeleton loading shimmer | 1.5s     | linear (loop)                       |
| Onboarding reveals       | 400ms    | `cubic-bezier(0.16, 1, 0.3, 1)` (spring-like) |

Skeleton loading shimmer uses Warm Linen → Sunrise Peach → Warm Linen — warm, not grey.

---

## Illustration Style

**Style:** Soft, flat vector with organic shapes. No gradients on figures — use flat fills from the palette. Subtle grain overlay (5% opacity noise) to add texture and warmth.

**Character approach:** Abstract/symbolic — no literal child depictions. Use nature metaphors: sun, clouds, waves, growth, light. This avoids age-specific representation and keeps the focus universal.

**Onboarding illustrations:** Loose, expressive brushstroke-adjacent shapes in Sunrise Peach, Flare Amber, and Pale Sky — feels handmade, warm, trustworthy.

---

## Logo Usage

**Wordmark:** "HealthFlare" set in Fraunces, weight 600. The "Flare" portion optionally accented in Flare Amber.

**Symbol:** A stylised sunrise/flare mark — a semicircle base with radiating soft lines, rendered in the amber-to-coral gradient. Works at 16px (favicon) through 512px (app icon).

**Clear space:** Minimum clear space equal to the cap-height of the wordmark on all sides.

**Backgrounds:** Logo renders on Soft Cloud, Ash White, Deep Dusk. Avoid placing on Dawn Coral or Flare Amber directly.

---

## Dark Mode Considerations (v2 scope)

Not in v1 scope, but the palette is designed to adapt. Deep Dusk inverts to Soft Cloud, Ash White surfaces become `#1E1C1A`. Amber and coral accents remain unchanged — they read well on both light and dark surfaces.

---

## Accessibility

- All text/background colour combinations meet WCAG AA minimum (4.5:1 for body, 3:1 for large text).
- Deep Dusk on Soft Cloud: 11.2:1 ✓
- Deep Dusk on Flare Amber: 5.8:1 ✓ (primary button)
- Morning Sky on white requires care — use only for large text or decorative UI, never for small body copy alone.
- Focus states use the amber ring (shadow-focus) — visible and on-brand.
- Minimum touch target: 44×44px on all interactive elements.
- Severity scale deliberately avoids red/green to be colourblind-accessible — uses warm gradient that reads by luminance as well as hue.

---

## Usage by Surface

| Surface              | Background            | Primary text | Card surface |
|----------------------|-----------------------|--------------|--------------|
| Mobile app           | Soft Cloud            | Deep Dusk    | White        |
| Website (marketing)  | Ash White             | Deep Dusk    | Soft Cloud   |
| Website (docs/support) | White               | Deep Dusk    | Ash White    |
| Email/marketing      | Sunrise Peach header  | Deep Dusk    | White        |
| Provider PDF reports | White                 | Deep Dusk    | Soft Cloud   |

---

**HealthFlare Design System — healthflare.org**

*Maintained alongside the PRD. Update version number on any breaking palette or type changes.*

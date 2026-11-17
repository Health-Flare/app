# Brand icon sources (v2.0)

Source files for `flutter_launcher_icons` generation. Pulled from
[Health-Flare/brand](https://github.com/Health-Flare/brand)@`v2.0.0` —
that's the canonical source; if the icon needs to change, change it there
first and re-copy, don't hand-edit these.

- `healthflare-icon-v2.png` — 1024px master, Sunrise background / white
  mark, no transparency. Used as the iOS icon and the Android legacy
  (non-adaptive) fallback.
- `healthflare-icon-v2-android-foreground.png` — the white compact mark
  alone, transparent background, pre-scaled to 44% width/centred to match
  the Android adaptive-icon safe zone. Generated from
  `marks/healthflare-mark-compact-white.svg`, framed identically to the
  monochrome layer below so both layers line up.
- `healthflare-icon-v2-android-monochrome.png` — Android 13+ themed-icon
  layer, straight from the brand kit (`app-icons/healthflare-android-
  monochrome.png`).

Adaptive icon background colour is set directly in `pubspec.yaml`
(`#E0694E`, Sunrise) rather than as an image.

Old v1 source (`assets/images/HealthFlare Icon Light*.png`) is gone:
the README banner and the F-Droid/IzzyOnDroid listing icon
(`fastlane/metadata/android/en-US/images/icon.png`) are both on brand
v2.0 now too.

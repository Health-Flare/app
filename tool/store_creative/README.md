# Store creative generator

Makes the two App Store creative assets that iOS 27 shows for Health Flare:

| Asset | Where it shows | Size | Files |
|---|---|---|---|
| Product page header | Across the top of the app's App Store page | 3840x1646 (21:9) | `header_3840x1646.mp4`, `.png` |
| Search results | The app's tile when it comes up in App Store search | 3840x2560 (3:2) | `search_3840x2560.mp4`, `.png` |

Each one is a 12-second muted loop plus a PNG still (frame 0). They're built
from the committed store screenshots in `screenshots/appstore/iphone-6.3/`,
the brand colours and the app fonts in `assets/fonts/`. So the assets always
show the real app, and remaking them after a screenshot re-shoot takes one
command.

Output goes to `build/store_creative/`, which is gitignored. Only the
generator is committed.

## When to run it

- After the store screenshots are re-shot (`scripts/take_screenshots.sh`), if
  the dashboard, tracking, illnesses, medications or journal screens changed.
- When the copy changes (see [Changing the content](#changing-the-content)).
- When Apple changes the creative asset specs.

Creative assets are reviewed by Apple apart from app versions, so a new set
doesn't need a release.

## Setup

Needs Python 3.10+ and ffmpeg.

```sh
brew install ffmpeg
python3 -m venv ~/.venvs/hf-creative
~/.venvs/hf-creative/bin/pip install -r tool/store_creative/requirements.txt
```

## Run it

From the repo root:

```sh
PY=~/.venvs/hf-creative/bin/python

$PY tool/store_creative/make_creative.py preview   # stills only, a few seconds
$PY tool/store_creative/make_creative.py video     # both MP4s + PNG stills, about 20 s on an M-series Mac
$PY tool/store_creative/make_creative.py verify    # checks the MP4s
```

Options: `--fps 60` (default 30), `--out DIR` (default `build/store_creative`).

`preview` writes `header_preview.png`, `search_preview.png` and
`search_preview_fade.png` (mid crossfade between two screens). Look at
those before spending minutes on a full render.

`verify` checks each MP4 against Apple's rules and that it loops cleanly:

```text
header_3840x1646: ok   size 3840x1646
header_3840x1646: ok   30 fps
header_3840x1646: ok   12.00 s
header_3840x1646: ok   loop wrap 0.53 vs step 0.61
search_3840x2560: ok   size 3840x2560
...
```

"Loop wrap" is how much the picture jumps from the last frame back to the
first. It must be no bigger than an ordinary step between two frames, or
the loop visibly hitches. A video cut short fails here (wrap 8.79 vs step
0.81). It exits non-zero if anything fails.

## Before uploading

`verify` can't judge the picture, so also:

1. Open the header still and check the line sits clear of the phones. On
   iPhone, Apple crops the header to about the centre 2540 px and lays its
   buttons over the top, so the text has to stay in the middle.
2. Watch both videos through once, including the wrap from end to start.
3. Upload in App Store Connect: the app's Product Page > Header and Search
   Results (or the Asset Library).

## Changing the content

Everything is in `make_creative.py`:

- **Copy:** `Header.frame` (`"Your health story," / "in your hands."`) and
  `Search.frame` (`"Track your chronic illness."` and the list under it).
  This is store copy: it's checked by `test/unit/privacy_claims_test.dart`
  like the store listing, and should only say things that are true and
  verifiable. No prices, URLs, awards or other platforms.
- **Screens:** the screenshot names in `Header.__init__` (four phones) and
  `Search.SCREENS` (the front phone cycles through these) plus the tilted
  back phone. The script stops with a list of missing files if a re-shoot
  renamed any.
- **Colours:** the constants at the top match the brand (amber `#F5A623`,
  coral `#F07560`, cloud `#F4F1EC`, dark text `#2C2825`). Keep the text dark
  on the amber gradient: white only gets about 2:1 contrast there.

### Keep the loop seamless

All motion comes from `wave()`, a sine with the loop's full period (12 s),
so every movement is back where it started at the end. The search phone
shows each of its 4 screens for 3 s (4 x 3 = 12). If you change the loop
length or the number of screens, keep them dividing evenly, then run
`verify`.

Backgrounds are rendered larger than the frame and drift within that
margin, so their edges never show. Keep any new drift smaller than the
margin.

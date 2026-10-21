"""App Store creative assets for Health Flare: the iOS 27 product page header
and the search results asset. Built from the committed store screenshots,
the brand palette and the app fonts, with slow looping motion made from
full-period sines so the last frame flows into the first.

Run from anywhere; paths are worked out from this file. See README.md.

  python tool/store_creative/make_creative.py preview   # stills to check
  python tool/store_creative/make_creative.py video     # MP4s + PNG stills
  python tool/store_creative/make_creative.py verify    # check the MP4s

  --fps 30|60   frame rate for video (default 30)
  --out DIR     output folder (default build/store_creative, gitignored)

Specs (Apple, "Creative assets specifications", checked Oct 2026):
  header  3840x1646 (21:9), 5-30 s, 30/60 fps, .mov/.m4v/.mp4
  search  3:2, 1920x1280..3840x2560, same video rules; always muted
"""
import math
import shutil
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

REPO = Path(__file__).resolve().parents[2]
SHOTS = REPO / "screenshots/appstore/iphone-6.3"
FONTS = REPO / "assets/fonts"
ICON = REPO / "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png"
OUT = REPO / "build/store_creative"

AMBER = (245, 166, 35)
CORAL = (240, 117, 96)
CLOUD = (244, 241, 236)
LINEN = (237, 232, 223)
DUSK = (44, 40, 37)
PEACH = (253, 232, 216)

LOOP_S = 12.0


def font(name, size):
    return ImageFont.truetype(str(FONTS / name), size)


def lerp(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


def gradient(w, h, c1, c2, angle_deg=20):
    """Diagonal two-colour gradient as RGB, via numpy."""
    a = math.radians(angle_deg)
    ys, xs = np.mgrid[0:h, 0:w].astype(np.float32)
    proj = xs * math.cos(a) + ys * math.sin(a)
    t = (proj - proj.min()) / (proj.max() - proj.min())
    c1, c2 = np.array(c1, np.float32), np.array(c2, np.float32)
    img = c1[None, None, :] * (1 - t[..., None]) + c2[None, None, :] * t[..., None]
    return Image.fromarray(img.clip(0, 255).astype(np.uint8))


def rounded_mask(size, radius):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius, fill=255)
    return m


def phone(shot_name, height, tilt=0.0):
    """A real screenshot in a simple dark phone body, with a soft shadow.
    Returns RGBA with padding for the shadow."""
    shot = Image.open(SHOTS / f"{shot_name}.png").convert("RGB")
    bezel = int(height * 0.022)
    sh = height - 2 * bezel
    sw = int(shot.width * sh / shot.height)
    shot = shot.resize((sw, sh), Image.LANCZOS)
    bw, bh = sw + 2 * bezel, height
    body = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
    r_out = int(bw * 0.15)
    body.paste((28, 26, 24, 255), (0, 0), rounded_mask((bw, bh), r_out))
    body.paste(shot, (bezel, bezel), rounded_mask((sw, sh), r_out - bezel))
    pad = int(height * 0.12)
    canvas = Image.new("RGBA", (bw + 2 * pad, bh + 2 * pad), (0, 0, 0, 0))
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    smask = Image.new("L", canvas.size, 0)
    smask.paste(rounded_mask((bw, bh), r_out), (pad, pad + int(pad * 0.25)))
    shadow.putalpha(smask.filter(ImageFilter.GaussianBlur(pad * 0.35)).point(lambda v: int(v * 0.32)))
    canvas = Image.alpha_composite(canvas, shadow)
    canvas.alpha_composite(body, (pad, pad))
    if tilt:
        canvas = canvas.rotate(tilt, resample=Image.BICUBIC, expand=True)
    return canvas


def icon(size):
    ic = Image.open(ICON).convert("RGBA").resize((size, size), Image.LANCZOS)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(ic, (0, 0), rounded_mask((size, size), int(size * 0.2237)))
    return out


def text_block(draw, lines, x, y, fnt, fill, spacing, anchor="la"):
    for line in lines:
        draw.text((x, y), line, font=fnt, fill=fill, anchor=anchor)
        y += spacing
    return y


def wave(t, phase=0.0, period=LOOP_S):
    return math.sin(2 * math.pi * (t / period) + phase)


# ── Product page header: 3840 x 1646 ────────────────────────────────────
class Header:
    W, H = 3840, 1646
    # On iPhone the header shows roughly the centre 3:2 (about 2540 px of the
    # 3840): the line lives in the middle, the phones frame it from the edges.

    def __init__(self):
        self.bg = gradient(self.W + 240, self.H + 120, AMBER, CORAL, 12)
        h = 1240
        self.phones = [
            (phone("02_dashboard", h, 7), -260, 250, 0.0),
            (phone("03_tracking_symptoms", h, 4), 380, 420, 1.7),
            (phone("06_medications", h, -4), 2630, 420, 3.3),
            (phone("08_journal", h, -7), 3260, 250, 4.6),
        ]
        self.title = font("Fraunces-SemiBold.ttf", 168)

    def frame(self, t):
        dx = int(120 + 120 * wave(t))
        dy = int(60 + 60 * wave(t, 1.3))
        img = self.bg.crop((dx, dy, dx + self.W, dy + self.H)).convert("RGBA")
        for p, x, y, ph in self.phones:
            img.alpha_composite(p, (x, int(y + 36 * wave(t, ph))))
        d = ImageDraw.Draw(img)
        # One idea, the app's own line; below the App Store's top button row.
        text_block(d, ["Your health story,", "in your hands."], self.W // 2, 660, self.title, DUSK, 200, "ma")
        return img.convert("RGB")


# ── Search results: 3840 x 2560 ─────────────────────────────────────────
class Search:
    W, H = 3840, 2560
    SCREENS = ["02_dashboard", "03_tracking_symptoms", "06_medications", "08_journal"]

    def __init__(self):
        self.bg = gradient(self.W + 200, self.H + 160, CLOUD, LINEN, 70)
        blob = Image.new("L", self.bg.size, 0)
        ImageDraw.Draw(blob).ellipse([2050, 250, 3950, 2350], fill=150)
        blob = blob.filter(ImageFilter.GaussianBlur(300))
        self.bg = Image.composite(gradient(*self.bg.size, AMBER, CORAL, 30), self.bg, blob)
        h = 2050
        self.front = [phone(s, h, 0) for s in self.SCREENS]
        self.back = phone("04_tracking_illnesses", int(h * 0.86), -7)
        self.icon = icon(230)
        self.title = font("Fraunces-SemiBold.ttf", 210)
        self.body = font("DMSans-Medium.ttf", 92)

    def frame(self, t):
        dx = int(100 + 100 * wave(t))
        dy = int(80 + 80 * wave(t, 2.0))
        img = self.bg.crop((dx, dy, dx + self.W, dy + self.H)).convert("RGBA")
        img.alpha_composite(self.back, (2950, int(330 + 30 * wave(t, 2.5))))
        # Front phone shows each screen for 3 s with a 0.9 s crossfade:
        # 4 screens x 3 s = the 12 s loop, so it wraps cleanly.
        seg = LOOP_S / len(self.front)
        k = int(t // seg) % len(self.front)
        local = t - k * seg
        fade = 0.9
        cur = self.front[k]
        if local > seg - fade:
            a = (local - (seg - fade)) / fade
            a = a * a * (3 - 2 * a)  # smoothstep
            cur = Image.blend(cur, self.front[(k + 1) % len(self.front)], a)
        img.alpha_composite(cur, (2050, int(150 + 30 * wave(t, 0.8))))
        d = ImageDraw.Draw(img)
        x = 300
        img.alpha_composite(self.icon, (x, 470))
        y = text_block(d, ["Track your", "chronic illness."], x, 820, self.title, DUSK, 240)
        y = text_block(
            d,
            ["Symptoms, medications, flares,", "meals, sleep and appointments.", "", "No account needed."],
            x, y + 90, self.body, (92, 84, 78), 125,
        )
        return img.convert("RGB")


def render_video(asset, name, fps):
    n = int(LOOP_S * fps)
    path = OUT / f"{name}.mp4"
    cmd = [
        "ffmpeg", "-y", "-loglevel", "error",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{asset.W}x{asset.H}", "-r", str(fps), "-i", "-",
        "-c:v", "libx264", "-profile:v", "high", "-preset", "slow", "-crf", "16",
        "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(path),
    ]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    for i in range(n):
        f = asset.frame(i / fps)
        if i == 0:
            f.save(OUT / f"{name}.png", optimize=True)
        proc.stdin.write(f.tobytes())
        if i % fps == 0:
            print(f"{name}: {i}/{n}", flush=True)
    proc.stdin.close()
    if proc.wait() != 0:
        sys.exit(f"{name}: ffmpeg failed")
    print(f"{name}: wrote {path}")


# ── Checks ──────────────────────────────────────────────────────────────
NAMES = {"header_3840x1646": Header, "search_3840x2560": Search}


def preflight(need_ffmpeg):
    """Fail early with a clear message instead of halfway through a render."""
    missing = [p for p in [FONTS / "Fraunces-SemiBold.ttf", FONTS / "DMSans-Medium.ttf", ICON] if not p.exists()]
    missing += [
        SHOTS / f"{s}.png"
        for s in sorted({*Search.SCREENS, "04_tracking_illnesses"})
        if not (SHOTS / f"{s}.png").exists()
    ]
    if missing:
        sys.exit("Missing inputs (re-shoot screenshots or update the names here):\n  " + "\n  ".join(map(str, missing)))
    if need_ffmpeg and not (shutil.which("ffmpeg") and shutil.which("ffprobe")):
        sys.exit("ffmpeg and ffprobe are needed for video and verify (brew install ffmpeg)")


def probe(path):
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-select_streams", "v:0", "-count_frames",
         "-show_entries", "stream=width,height,r_frame_rate,nb_read_frames:format=duration",
         "-of", "default=nw=1", str(path)],
        check=True, capture_output=True, text=True,
    ).stdout
    d = dict(line.split("=", 1) for line in out.split())
    num, den = d["r_frame_rate"].split("/")
    return int(d["width"]), int(d["height"]), int(num) / int(den), float(d["duration"]), int(d["nb_read_frames"])


def read_frame(path, k, w, h):
    raw = subprocess.run(
        ["ffmpeg", "-v", "error", "-i", str(path), "-vf", f"select=eq(n\\,{k})",
         "-fps_mode", "passthrough", "-frames:v", "1", "-f", "rawvideo", "-pix_fmt", "rgb24", "-"],
        check=True, capture_output=True,
    ).stdout
    return np.frombuffer(raw, np.uint8).reshape(h, w, 3).astype(np.int16)


def verify():
    """Size, fps and length within Apple's rules, and a seamless loop: the
    jump from the last frame back to the first is no bigger than a normal
    frame-to-frame step."""
    ok = True
    for name, asset in NAMES.items():
        path = OUT / f"{name}.mp4"
        if not path.exists():
            print(f"{name}: missing, run video first")
            ok = False
            continue
        w, h, fps, dur, n = probe(path)
        checks = [
            ((w, h) == (asset.W, asset.H), f"size {w}x{h}"),
            (round(fps) in (30, 60), f"{fps:g} fps"),
            (5 <= dur <= 30, f"{dur:.2f} s"),
        ]
        first, second = read_frame(path, 0, w, h), read_frame(path, 1, w, h)
        before_last, last = read_frame(path, n - 2, w, h), read_frame(path, n - 1, w, h)
        step = max(np.abs(second - first).mean(), np.abs(last - before_last).mean())
        wrap = np.abs(first - last).mean()
        checks.append((wrap <= 2 * step + 0.5, f"loop wrap {wrap:.2f} vs step {step:.2f}"))
        for passed, what in checks:
            print(f"{name}: {'ok  ' if passed else 'FAIL'} {what}")
            ok &= passed
    sys.exit(0 if ok else 1)


def arg(flag, default):
    return sys.argv[sys.argv.index(flag) + 1] if flag in sys.argv else default


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 and not sys.argv[1].startswith("--") else "preview"
    if mode not in ("preview", "video", "verify"):
        sys.exit(__doc__)
    fps = int(arg("--fps", 30))
    OUT = Path(arg("--out", OUT)).resolve()
    OUT.mkdir(parents=True, exist_ok=True)
    preflight(need_ffmpeg=mode != "preview")
    if mode == "preview":
        Header().frame(0).save(OUT / "header_preview.png")
        Search().frame(0).save(OUT / "search_preview.png")
        Search().frame(2.6).save(OUT / "search_preview_fade.png")  # mid-crossfade
        print(f"wrote previews to {OUT}")
    elif mode == "video":
        for name, asset in NAMES.items():
            render_video(asset(), name, fps)
    else:
        verify()

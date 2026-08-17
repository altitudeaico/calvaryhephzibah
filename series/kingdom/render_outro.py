#!/usr/bin/env python3
"""Render a multi-card animated outro: statement, turn, landing.

One card is not enough to do anything but restate. Three cards can build an
argument: name the thing the viewer already believes, turn it, then land
somewhere they have to think about. That is the shape this renders.

Usage:
    python3 render_outro.py out.mp4 series/kingdom/closing/q3.json
"""
import json, os, subprocess, sys
from PIL import Image, ImageDraw, ImageFont
import numpy as np

W, H, FPS = 1080, 1920, 25
OBS = (11, 11, 14); BONE = (244, 239, 230); RED = (208, 68, 28)
# Repo root, derived from this file's own location so the script runs on any
# machine. Was hardcoded to /home/claude/calvaryhephzibah, the old sandbox
# path, which meant it only ran there. Override with CALVARY_REPO if needed.
R = os.environ.get("CALVARY_REPO") or os.path.dirname(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FD = R + "/anniversary/overlays/fonts"


def ground():
    img = Image.new("RGB", (W, H), OBS)
    glow = Image.new("L", (W, H), 0)
    gd = ImageDraw.Draw(glow)
    for r in range(1500, 0, -10):
        gd.ellipse([380 - r, 1650 - r, 380 + r, 1650 + r], fill=int(42 * (1 - r / 1500) ** 1.7))
    img = Image.composite(Image.new("RGB", (W, H), (150, 62, 20)), img, glow)
    d = ImageDraw.Draw(img)
    for (x, y, dx, dy) in [(70, 70, 1, 1), (W - 70, 70, -1, 1), (70, H - 70, 1, -1), (W - 70, H - 70, -1, -1)]:
        d.line([(x, y), (x + dx * 66, y)], fill=RED, width=5)
        d.line([(x, y), (x, y + dy * 66)], fill=RED, width=5)
    return img


def ease(t):
    return 1 - (1 - t) ** 3


def fit(d, lines, cap=112):
    size = cap
    while size > 46:
        f = ImageFont.truetype(FD + "/anton-400.ttf", size)
        if max(d.textlength(l, font=f) for l in lines) <= W - 150:
            return f, size
        size -= 4
    return ImageFont.truetype(FD + "/anton-400.ttf", 46), 46


def render(cards, out):
    base = ground()
    d0 = ImageDraw.Draw(base)
    tmp = "/tmp/oframes"
    os.system(f"rm -rf {tmp}; mkdir -p {tmp}")
    n = 0

    # progress rule along the bottom, so the sequence feels like it is going somewhere
    total = sum(c.get("dur", 3.2) for c in cards)
    elapsed = 0.0

    for ci, card in enumerate(cards):
        lines = card["lines"]
        dur = card.get("dur", 3.2)
        red = card.get("red", None)
        fnt, size = fit(d0, lines)
        lh = int(size * 1.14)
        y0 = (H - lh * len(lines)) // 2
        frames = int(dur * FPS)

        for f in range(frames):
            t = f / FPS
            img = base.copy()
            layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
            ld = ImageDraw.Draw(layer)
            for i, line in enumerate(lines):
                st = 0.12 + i * 0.34
                p = min(1.0, max(0.0, (t - st) / 0.5))
                if p <= 0:
                    continue
                e = ease(p)
                col = RED if (red is not None and i == red) else BONE
                x = (W - ld.textlength(line, font=fnt)) / 2
                y = y0 + i * lh + int(30 * (1 - e))
                ld.text((x, y), line, font=fnt, fill=col + (int(255 * e),))
            tail = dur - 0.38
            if t > tail:
                k = 1 - min(1.0, (t - tail) / 0.38)
                arr = np.array(layer)
                arr[:, :, 3] = (arr[:, :, 3] * k).astype(np.uint8)
                layer = Image.fromarray(arr)
            img.paste(layer, (0, 0), layer)

            ref = card.get("ref")
            if ref:
                rp = min(1.0, max(0.0, (t - (0.12 + len(lines) * 0.34)) / 0.6))
                if rp > 0:
                    rf = ImageFont.truetype(FD + "/inter-tight-700.ttf", 34)
                    rl = Image.new("RGBA", (W, H), (0, 0, 0, 0))
                    rd = ImageDraw.Draw(rl)
                    tr = 0.22
                    tw = sum(rd.textlength(c, font=rf) + rf.size * tr for c in ref) - rf.size * tr
                    x = (W - tw) / 2
                    y = y0 + lh * len(lines) + 46
                    a2 = int(210 * ease(rp))
                    for c in ref:
                        rd.text((x, y), c, font=rf, fill=(208, 68, 28, a2))
                        x += rd.textlength(c, font=rf) + rf.size * tr
                    if t > tail:
                        arr2 = np.array(rl)
                        arr2[:, :, 3] = (arr2[:, :, 3] * k).astype(np.uint8)
                        rl = Image.fromarray(arr2)
                    img.paste(rl, (0, 0), rl)

            prog = (elapsed + t) / total
            pd = ImageDraw.Draw(img)
            pd.line([(150, H - 190), (W - 150, H - 190)], fill=(38, 36, 40), width=3)
            pd.line([(150, H - 190), (150 + int((W - 300) * prog), H - 190)], fill=RED, width=3)

            img.save(f"{tmp}/f{n:04d}.png")
            n += 1
        elapsed += dur

    subprocess.run([
        "ffmpeg", "-nostdin", "-v", "error", "-y",
        "-framerate", str(FPS), "-i", f"{tmp}/f%04d.png",
        "-c:v", "libx264", "-crf", "18", "-preset", "veryfast",
        "-pix_fmt", "yuv420p", "-r", str(FPS), out
    ], check=True)
    print(f"{out}  {len(cards)} cards, {round(total,1)}s")


if __name__ == "__main__":
    arg = sys.argv[2]
    spec = json.load(open(arg)) if arg.endswith(".json") else json.loads(arg)
    render(spec["beats"] if isinstance(spec, dict) else spec, sys.argv[1])

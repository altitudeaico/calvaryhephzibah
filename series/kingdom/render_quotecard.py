#!/usr/bin/env python3
"""Render an animated quote card as a video, to sit between the clip and the end card.

Lines fade up one at a time with a small rise, hold, then the whole card eases
off so the end card can take over. Deliberately restrained: this is a beat of
stillness after someone has been talking, not a title sequence.
"""
import os, subprocess, sys
from PIL import Image, ImageDraw, ImageFont
import numpy as np

W, H, FPS = 1080, 1920, 25
OBS = (11, 11, 14); BONE = (244, 239, 230); RED = (208, 68, 28)
R = "/home/claude/calvaryhephzibah"
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


def render(lines, out, dur=4.2, red_line=None):
    base = ground()
    fnt = ImageFont.truetype(FD + "/anton-400.ttf", 108)
    d0 = ImageDraw.Draw(base)

    # shrink until the longest line fits
    size = 108
    while size > 52:
        fnt = ImageFont.truetype(FD + "/anton-400.ttf", size)
        if max(d0.textlength(l, font=fnt) for l in lines) <= W - 150:
            break
        size -= 4

    lh = int(size * 1.12)
    block = lh * len(lines)
    y0 = (H - block) // 2

    n = int(dur * FPS)
    tmp = "/tmp/qframes"
    os.system(f"rm -rf {tmp}; mkdir -p {tmp}")

    STAGGER = 0.42
    RISE = 34

    for f in range(n):
        t = f / FPS
        img = base.copy()
        layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        ld = ImageDraw.Draw(layer)
        for i, line in enumerate(lines):
            st = 0.25 + i * STAGGER
            p = min(1.0, max(0.0, (t - st) / 0.6))
            if p <= 0:
                continue
            e = ease(p)
            a = int(255 * e)
            col = RED if (red_line is not None and i == red_line) else BONE
            x = (W - ld.textlength(line, font=fnt)) / 2
            y = y0 + i * lh + int(RISE * (1 - e))
            ld.text((x, y), line, font=fnt, fill=col + (a,))
        # whole card eases off at the very end
        tail = dur - 0.45
        if t > tail:
            k = 1 - min(1.0, (t - tail) / 0.45)
            arr = np.array(layer)
            arr[:, :, 3] = (arr[:, :, 3] * k).astype(np.uint8)
            layer = Image.fromarray(arr)
        img.paste(layer, (0, 0), layer)
        img.save(f"{tmp}/f{f:04d}.png")

    subprocess.run([
        "ffmpeg", "-nostdin", "-v", "error", "-y",
        "-framerate", str(FPS), "-i", f"{tmp}/f%04d.png",
        "-c:v", "libx264", "-crf", "18", "-preset", "veryfast",
        "-pix_fmt", "yuv420p", "-r", str(FPS), out
    ], check=True)
    print(f"{out}  {len(lines)} lines @ {size}px, {dur}s")


if __name__ == "__main__":
    out = sys.argv[1]
    red = int(sys.argv[2])
    lines = sys.argv[3:]
    render(lines, out, red_line=(red if red >= 0 else None))

#!/usr/bin/env python3
"""Render a text-only concept reel: sectioned cards, house ground, music bed.

Extends render_outro.py to long form. Differences that matter:

- **Sections, not one run of cards.** Each section has its own pacing and its
  own visual note. A hook card wants 1.6 sec; an application card wants 3.
- **Silence is a tool.** A section marked "silence": true cuts the bed dead for
  its whole duration. With no voiceover that is the only dynamic available, so
  spend it where the thought turns rather than sprinkling it about.
- **Section rule.** A thin red line grows across the bottom for the whole
  piece, so a 90 second read still feels like it is going somewhere.

Usage:
    python3 render_reel.py the-price.json out.mp4 [--bed path.mp3]
"""
import argparse, json, os, subprocess, sys
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


def fit(d, lines, cap=104):
    size = cap
    while size > 44:
        f = ImageFont.truetype(FD + "/anton-400.ttf", size)
        if max(d.textlength(l, font=f) for l in lines) <= W - 160:
            return f, size
        size -= 4
    return ImageFont.truetype(FD + "/anton-400.ttf", 44), 44


def build_frames(spec, tmp):
    base = ground()
    d0 = ImageDraw.Draw(base)
    cards = [c for s in spec["sections"] for c in s["cards"]]
    total = sum(c.get("dur", 2.4) for c in cards)
    os.system(f"rm -rf {tmp}; mkdir -p {tmp}")

    n, elapsed = 0, 0.0
    for card in cards:
        lines = card["lines"]
        dur = card.get("dur", 2.4)
        red = card.get("red", None)
        ref = card.get("ref")
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
                st = 0.08 + i * 0.22
                p = min(1.0, max(0.0, (t - st) / 0.42))
                if p <= 0:
                    continue
                e = ease(p)
                col = RED if (red is not None and i == red) else BONE
                x = (W - ld.textlength(line, font=fnt)) / 2
                y = y0 + i * lh + int(26 * (1 - e))
                ld.text((x, y), line, font=fnt, fill=col + (int(255 * e),))

            tail = dur - 0.32
            k = 1.0
            if t > tail:
                k = 1 - min(1.0, (t - tail) / 0.32)
                arr = np.array(layer)
                arr[:, :, 3] = (arr[:, :, 3] * k).astype(np.uint8)
                layer = Image.fromarray(arr)
            img.paste(layer, (0, 0), layer)

            if ref:
                rp = min(1.0, max(0.0, (t - (0.08 + len(lines) * 0.22)) / 0.6))
                if rp > 0:
                    rf = ImageFont.truetype(FD + "/inter-tight-700.ttf", 34)
                    rl = Image.new("RGBA", (W, H), (0, 0, 0, 0))
                    rd = ImageDraw.Draw(rl)
                    tr = 0.22
                    tw = sum(rd.textlength(c, font=rf) + rf.size * tr for c in ref) - rf.size * tr
                    x = (W - tw) / 2
                    y = y0 + lh * len(lines) + 44
                    for c in ref:
                        rd.text((x, y), c, font=rf, fill=(208, 68, 28, int(210 * ease(rp) * k)))
                        x += rd.textlength(c, font=rf) + rf.size * tr
                    img.paste(rl, (0, 0), rl)

            prog = (elapsed + t) / total
            pd = ImageDraw.Draw(img)
            pd.line([(150, H - 175), (W - 150, H - 175)], fill=(34, 32, 36), width=3)
            pd.line([(150, H - 175), (150 + int((W - 300) * prog), H - 175)], fill=RED, width=3)

            img.save(f"{tmp}/f{n:05d}.png")
            n += 1
        elapsed += dur
    return total


def bed_filter(spec, total):
    """Bed at a fixed level, cut dead through any section marked silent."""
    gates, t = [], 0.0
    for s in spec["sections"]:
        d = sum(c.get("dur", 2.4) for c in s["cards"])
        if s.get("silence"):
            gates.append((t, t + d))
        t += d
    expr = "1"
    for a, b in gates:
        expr = f"if(between(t,{a:.2f},{b:.2f}),0,{expr})"
    return (f"volume=-9dB,afade=t=in:st=0:d=1.4,"
            f"volume='{expr}':eval=frame,"
            f"afade=t=out:st={max(0.0, total-2.0):.2f}:d=2.0")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("spec")
    ap.add_argument("out")
    ap.add_argument("--bed", default=None)
    ap.add_argument("--endcard", default=R + "/series/kingdom/social/endcards/endcard-09-aug-2026.jpg")
    a = ap.parse_args()

    spec = json.load(open(a.spec))
    tmp = "/tmp/reelframes"
    total = build_frames(spec, tmp)
    bed = a.bed or (R + f"/series/kingdom/social/music/{spec.get('bed','felt-and-faith-a')}.mp3")

    body = "/tmp/reel_body.mp4"
    subprocess.run(["ffmpeg", "-nostdin", "-v", "error", "-y",
                    "-framerate", str(FPS), "-i", f"{tmp}/f%05d.png",
                    "-c:v", "libx264", "-crf", "19", "-preset", "veryfast",
                    "-pix_fmt", "yuv420p", "-r", str(FPS), body], check=True)

    grand = total + 3.0
    subprocess.run(["ffmpeg", "-nostdin", "-v", "error", "-y",
        "-i", body, "-loop", "1", "-t", "3", "-i", a.endcard, "-stream_loop", "-1", "-i", bed,
        "-filter_complex",
        f"[1:v]scale={W}:{H},fps={FPS},setsar=1,format=yuv420p,fade=t=in:st=0:d=0.5[v1];"
        f"[0:v][v1]concat=n=2:v=1:a=0[v];"
        f"[2:a]{bed_filter(spec, grand)},atrim=0:{grand:.2f},alimiter=limit=0.97[a]",
        "-map", "[v]", "-map", "[a]",
        "-c:v", "libx264", "-crf", "20", "-preset", "veryfast", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k", "-ar", "48000", "-movflags", "+faststart", a.out], check=True)

    print(f"{a.out}  {round(grand,1)}s  ({len([c for s in spec['sections'] for c in s['cards']])} cards)")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Render a 9x16 themed teaching short on the ALTARS identity.

These are ORIGINAL pieces built around a sermon's ideas, not clips of the
preacher. So the words are the church's, not hers, and the end screen credits
the sermon as the source rather than implying she said these lines.

Each beat is composited as a full still (plate crop + type), then given a slow
push in ffmpeg and cross-faded to the next. Text moves with the frame rather
than over it, which reads as a camera move instead of a slideshow.

Only three ALTARS plates have no baked-in text: scene1-ember, scene2-master,
scene3-fire. Everything else in the series folder has "SERMON SERIES" burned
in and cannot be used as background.

Usage:
  python3 render_altars_short.py --repo . --spec short1.json --out out.mp4
"""
import argparse
import json
import os
import subprocess
import urllib.request
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageEnhance

W, H = 1080, 1920
OBS = (11, 11, 14)
BONE = (244, 239, 230)
RED = (208, 68, 28)
GREY = (196, 189, 177)
FG3 = (214, 206, 194)
IS_URL = "https://raw.githubusercontent.com/google/fonts/main/ofl/instrumentserif/InstrumentSerif-Italic.ttf"


def serif(size):
    p = "/tmp/InstrumentSerif-Italic.ttf"
    if not os.path.exists(p):
        urllib.request.urlretrieve(IS_URL, p)
    return ImageFont.truetype(p, size)


def tracked(d, xy, text, font, fill, tr=0.16):
    x, y = xy
    for ch in text:
        d.text((x, y), ch, font=font, fill=fill)
        x += d.textlength(ch, font=font) + font.size * tr
    return x


def tracked_w(d, text, font, tr=0.16):
    return sum(d.textlength(c, font=font) + font.size * tr for c in text) - font.size * tr


def plate_bg(repo, plate, pan, dim):
    """Cover-fit a landscape plate to 9:16, taking a horizontal slice at `pan`."""
    im = Image.open(os.path.join(repo, "series/altars/plates", plate)).convert("RGB")
    s = H / im.height
    im = im.resize((int(im.width * s), H), Image.LANCZOS)
    maxx = im.width - W
    x = int(max(0, min(maxx, maxx * pan)))
    im = im.crop((x, 0, x + W, H))
    im = ImageEnhance.Brightness(im).enhance(dim)
    # centre scrim so type always has ground under it
    a = np.array(im).astype(float)
    ys = np.linspace(0, 1, H)[:, None, None]
    v = (1 - np.abs(ys - 0.5) * 2) ** 1.1 * 0.55
    a = a * (1 - v) + np.array([9, 9, 12], float) * v
    return Image.fromarray(a.clip(0, 255).astype(np.uint8))


def wrap(d, text, font, maxw):
    words, lines, cur = text.split(), [], ""
    for w_ in words:
        t = (cur + " " + w_).strip()
        if d.textlength(t, font=font) <= maxw or not cur:
            cur = t
        else:
            lines.append(cur)
            cur = w_
    if cur:
        lines.append(cur)
    return lines


def beat_frame(repo, beat, plate, pan, dim):
    img = plate_bg(repo, plate, pan, dim)
    d = ImageDraw.Draw(img)
    anton = os.path.join(repo, "anniversary/overlays/fonts/anton-400.ttf")
    inter = os.path.join(repo, "anniversary/overlays/fonts/inter-tight-700.ttf")
    LM, maxw = 96, W - 192

    kind = beat.get("kind", "punch")
    if kind == "scripture":
        f = serif(66)
        lines = wrap(d, beat["text"], f, maxw)
        lh = int(f.size * 1.22)
        total = lh * len(lines) + 90
        y = (H - total) // 2
        for ln in lines:
            d.text(((W - d.textlength(ln, font=f)) / 2, y), ln, font=f, fill=FG3)
            y += lh
        fr = ImageFont.truetype(inter, 30)
        ref = beat["ref"]
        tracked(d, ((W - tracked_w(d, ref, fr, 0.3)) / 2, y + 34), ref, fr, RED, 0.3)
    else:
        size = 118 if kind == "punch" else 86
        f = ImageFont.truetype(anton, size)
        # explicit `lines` wins over auto-wrap, for numbered steps and the like
        lines = beat["lines"] if beat.get("lines") else wrap(d, beat["text"], f, maxw)
        if beat.get("lines"):
            while max(d.textlength(l, font=f) for l in lines) > maxw and size > 44:
                size -= 4
                f = ImageFont.truetype(anton, size)
        while (not beat.get("lines")) and len(lines) > 4 and size > 70:
            size -= 6
            f = ImageFont.truetype(anton, size)
            lines = wrap(d, beat["text"], f, maxw)
        lh = int(size * 1.04)
        y = (H - lh * len(lines)) // 2
        hi = beat.get("red")
        for ln in lines:
            col = RED if hi and hi.lower() in ln.lower() else BONE
            d.text((LM, y), ln, font=f, fill=col)
            y += lh
        if beat.get("sub"):
            fs = serif(48)
            d.text((LM + 4, y + 26), beat["sub"], font=fs, fill=GREY)

    # small persistent series mark, top left
    fb = ImageFont.truetype(inter, 26)
    d.rectangle([LM, 96, LM + 30, 100], fill=RED)
    d.rectangle([LM, 96, LM + 4, 126], fill=RED)
    tracked(d, (LM + 46, 93), "THE ALTARS SERIES", fb, GREY, 0.3)
    return img


def render(a):
    spec = json.load(open(a.spec))
    beats = spec["beats"]
    tmp = "/tmp/short_beats"
    os.makedirs(tmp, exist_ok=True)
    plates = ["scene2-master.png", "scene3-fire.png", "scene1-ember.png"]
    paths = []
    for i, b in enumerate(beats):
        pl = plates[i % len(plates)] if not b.get("plate") else b["plate"]
        img = beat_frame(a.repo, b, pl, b.get("pan", (i * 0.37) % 1.0), b.get("dim", 0.72))
        p = f"{tmp}/{spec['slug']}_{i}.png"
        img.save(p)
        paths.append(p)

    BD = spec.get("beat_seconds", 3.7)
    XF = 0.45
    end = os.path.join(a.repo, "series/altars/short-endcard-9x16.png")

    inputs, filt, labels = [], [], []
    for i, p in enumerate(paths + [end]):
        dur = BD if i < len(paths) else spec.get("end_seconds", 3.6)
        inputs += ["-loop", "1", "-t", str(dur), "-i", p]
        # slow push, alternating direction so consecutive beats don't feel identical
        z = "min(1.06,zoom+0.00035)" if i % 2 == 0 else "if(eq(on,1),1.06,max(1.0,zoom-0.00035))"
        filt.append(
            f"[{i}:v]scale={W*2}:{H*2},zoompan=z='{z}':d={int(dur*30)}:"
            f"x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s={W}x{H}:fps=30,"
            f"setsar=1,format=yuv420p,settb=AVTB[v{i}]"
        )
        labels.append(f"[v{i}]")

    chain, off = "", 0.0
    prev = "[v0]"
    for i in range(1, len(labels)):
        off += (BD if i - 1 < len(paths) else spec.get("end_seconds", 3.6)) - XF
        out = f"[x{i}]" if i < len(labels) - 1 else "[vout]"
        chain += f"{prev}[v{i}]xfade=transition=fade:duration={XF}:offset={round(off,3)}{out};"
        prev = out

    total = BD * len(paths) + spec.get("end_seconds", 3.6) - XF * len(paths)
    bed = os.path.join(a.repo, "assets/audio/beds/bed-beneath-the-same-sky-flat.mp3")
    afilt = (f"[{len(labels)}:a]atrim=duration={round(total,2)},asetpts=PTS-STARTPTS,"
             f"volume=2.2,afade=t=in:st=0:d=1.0,afade=t=out:st={round(total-1.2,2)}:d=1.2[a]")

    cmd = (["ffmpeg", "-v", "error"] + inputs +
           ["-ss", str(spec.get("bed_offset", 0)), "-i", bed,
            "-filter_complex", ";".join(filt) + ";" + chain + afilt,
            "-map", "[vout]", "-map", "[a]",
            "-c:v", "libx264", "-preset", "veryfast", "-crf", "20", "-pix_fmt", "yuv420p",
            "-c:a", "aac", "-b:a", "160k", "-ar", "48000", "-movflags", "+faststart",
            "-t", str(round(total, 2)), a.out, "-y"])
    subprocess.run(cmd, check=True)
    print(a.out, f"{total:.1f}s", f"{len(paths)} beats")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--spec", required=True)
    ap.add_argument("--out", required=True)
    render(ap.parse_args())

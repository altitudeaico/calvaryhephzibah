#!/usr/bin/env python3
"""Render 1080x1350 carousel slides on the ALTARS identity.

Layout is measured, not guessed: every block is sized from its ink box, the
whole stack is centred as a unit, and type steps down until it fits. That
matters here because slide text varies from four words to a full paragraph,
and a fixed grid would either clip the long ones or strand the short ones.

Slide spec keys, all optional except one text-bearing field:
  eyebrow     small tracked red label
  headline    Anton, the statement
  body        list of paragraphs, Inter Tight
  scripture   {"text": ..., "ref": ...}, Instrument Serif italic
  kicker      serif italic line under everything
  red         substring of headline to colour red
"""
import argparse
import json
import os
import urllib.request
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageEnhance

W, H = 1080, 1350
OBS = (11, 11, 14)
BONE = (244, 239, 230)
RED = (208, 68, 28)
RED_B = (226, 96, 58)
GREY = (176, 169, 158)
FG3 = (214, 206, 194)
LM = 96
MAXW = W - LM * 2
IS_URL = "https://raw.githubusercontent.com/google/fonts/main/ofl/instrumentserif/InstrumentSerif-Italic.ttf"


def serif(sz):
    p = "/tmp/InstrumentSerif-Italic.ttf"
    if not os.path.exists(p):
        urllib.request.urlretrieve(IS_URL, p)
    return ImageFont.truetype(p, sz)


def tracked(d, xy, text, font, fill, tr=0.16):
    x, y = xy
    for ch in text:
        d.text((x, y), ch, font=font, fill=fill)
        x += d.textlength(ch, font=font) + font.size * tr
    return x


def wrap(d, text, font, maxw):
    out, cur = [], ""
    for w_ in text.split():
        t = (cur + " " + w_).strip()
        if d.textlength(t, font=font) <= maxw or not cur:
            cur = t
        else:
            out.append(cur)
            cur = w_
    if cur:
        out.append(cur)
    return out


def ground(repo, idx, plate_rel="series/altars/plates/scene2-master.png"):
    """Full-bleed ALTARS plate, faded back far enough that type still reads.

    The plate is landscape and the card is portrait, so it is cover-fitted and
    the horizontal slice is shifted per slide. That stops 48 cards sharing one
    identical background while keeping the same stone pile throughout.

    Two scrims sit on top: a flat one to push the whole image back, and a
    stronger vertical one through the middle band where the type lives. Without
    the second, the brighter stones cut straight through the body copy.
    """
    plate = Image.open(os.path.join(repo, plate_rel)).convert("RGB")
    sc = max(W / plate.width, H / plate.height)
    plate = plate.resize((int(plate.width * sc), int(plate.height * sc)), Image.LANCZOS)
    maxx = max(0, plate.width - W)
    pan = [0.50, 0.28, 0.72, 0.38, 0.62, 0.18, 0.82, 0.44, 0.56, 0.34][idx % 10]
    x = int(maxx * pan)
    y = max(0, (plate.height - H) // 2)
    img = plate.crop((x, y, x + W, y + H))
    img = ImageEnhance.Brightness(img).enhance(1.05)

    a = np.array(img).astype(float)
    ys = np.linspace(0, 1, H)[:, None, None]
    flat = 0.24
    band = np.exp(-((ys - 0.42) ** 2) / (2 * 0.26 ** 2)) * 0.40
    scrim = np.clip(flat + band, 0, 0.95)
    a = a * (1 - scrim) + np.array([10, 10, 13], float) * scrim

    glow = Image.new("L", (W, H), 0)
    gd = ImageDraw.Draw(glow)
    cx, cy, R = int(W * 0.24), int(H * 0.90), 1150
    for r in range(R, 0, -8):
        gd.ellipse([cx - r, cy - r, cx + r, cy + r], fill=int(34 * (1 - r / R) ** 1.8))
    base = Image.fromarray(a.clip(0, 255).astype(np.uint8))
    return Image.composite(Image.new("RGB", (W, H), (150, 62, 20)), base, glow)


def render_slide(repo, spec, idx, total, out,
                 series_mark="THE ALTARS SERIES",
                 plate_rel="series/altars/plates/scene2-master.png"):
    """Render one 1080x1350 carousel slide.

    `series_mark` and `plate_rel` are set per-carousel from the spec, because
    this renderer is now used for more than the ALTARS series. Leaving them
    hardcoded shipped a Kingdom-series carousel branded ALTARS on 23 Aug 2026,
    on a fieldstone plate that belongs to a different message. The defaults
    reproduce ALTARS exactly, so existing specs are unaffected.
    """
    img = ground(repo, idx, plate_rel)
    d = ImageDraw.Draw(img)
    anton = os.path.join(repo, "anniversary/overlays/fonts/anton-400.ttf")
    inter6 = os.path.join(repo, "anniversary/overlays/fonts/inter-tight-600.ttf")
    inter7 = os.path.join(repo, "anniversary/overlays/fonts/inter-tight-700.ttf")

    TOP, BOT = 210, 200
    avail = H - TOP - BOT

    def build(hs, bs, ss):
        blocks = []
        if spec.get("eyebrow"):
            f = ImageFont.truetype(inter7, 27)
            blocks.append(("eyebrow", [spec["eyebrow"]], f, 44, 34))
        if spec.get("headline"):
            f = ImageFont.truetype(anton, hs)
            ln = wrap(d, spec["headline"], f, MAXW)
            blocks.append(("head", ln, f, int(hs * 1.02), 34))
        for p in spec.get("body", []):
            f = ImageFont.truetype(inter6, bs)
            ln = wrap(d, p, f, MAXW)
            blocks.append(("body", ln, f, int(bs * 1.42), 26))
        if spec.get("scripture"):
            f = serif(ss)
            ln = wrap(d, spec["scripture"]["text"], f, MAXW)
            blocks.append(("scr", ln, f, int(ss * 1.24), 18))
            fr = ImageFont.truetype(inter7, 25)
            blocks.append(("ref", [spec["scripture"]["ref"]], fr, 38, 34))
        if spec.get("kicker"):
            f = serif(46)
            ln = wrap(d, spec["kicker"], f, MAXW)
            blocks.append(("kick", ln, f, 58, 0))
        h = sum(len(b[1]) * b[3] + b[4] for b in blocks)
        return blocks, h

    hs, bs, ss = 86, 40, 54
    blocks, total_h = build(hs, bs, ss)
    while total_h > avail and (hs > 44 or bs > 28 or ss > 36):
        hs = max(44, hs - 4)
        bs = max(28, bs - 2)
        ss = max(36, ss - 2)
        blocks, total_h = build(hs, bs, ss)

    y = TOP + max(0, (avail - total_h) // 2)
    for kind, lines, f, lh, gap in blocks:
        for ln in lines:
            if kind == "eyebrow":
                tracked(d, (LM, y), ln, f, RED, 0.34)
            elif kind == "ref":
                tracked(d, (LM, y), ln, f, RED_B, 0.3)
            elif kind == "head":
                col = BONE
                r = spec.get("red")
                if r and r.lower() in ln.lower():
                    col = RED
                d.text((LM - 3, y), ln, font=f, fill=col)
            elif kind == "scr":
                d.text((LM, y), ln, font=f, fill=FG3)
            elif kind == "kick":
                d.text((LM, y), ln, font=f, fill=GREY)
            else:
                d.text((LM, y), ln, font=f, fill=BONE)
            y += lh
        y += gap

    # series mark + pagination
    fb = ImageFont.truetype(inter7, 24)
    d.rectangle([LM, 96, LM + 28, 100], fill=RED)
    d.rectangle([LM, 96, LM + 4, 124], fill=RED)
    tracked(d, (LM + 44, 93), series_mark, fb, GREY, 0.3)
    fp = ImageFont.truetype(inter7, 24)
    tracked(d, (LM, H - 118), f"{idx:02d} / {total:02d}", fp, GREY, 0.22)
    if idx == total:
        fc = ImageFont.truetype(inter7, 24)
        t = "FULL SERMON ON YOUTUBE  ·  CALVARY HEPHZIBAH"
        wpx = sum(d.textlength(c, font=fc) + fc.size * 0.16 for c in t) - fc.size * 0.16
        tracked(d, (W - LM - wpx, H - 118), t, fc, RED_B, 0.16)
    img.save(out, quality=95)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--spec", required=True)
    ap.add_argument("--outdir", required=True)
    a = ap.parse_args()
    c = json.load(open(a.spec))
    os.makedirs(a.outdir, exist_ok=True)
    n = len(c["slides"])
    mark = c.get("series_mark", "THE ALTARS SERIES")
    plate = c.get("plate", "series/altars/plates/scene2-master.png")
    for i, s in enumerate(c["slides"], 1):
        render_slide(a.repo, s, i, n, f"{a.outdir}/{c['slug']}-{i:02d}.png",
                     series_mark=mark, plate_rel=plate)
    print(f"{c['slug']}: {n} slides -> {a.outdir}")

#!/usr/bin/env python3
"""Render 1080x1350 carousel slides for the 9 Aug 2026 sermon.

Same layout engine as render_altars_carousel.py. The only change is the
ground: there is no series plate for this one, so the cards sit on the house
obsidian field with the red glow and a faint eagle watermark, panned per slide
so a nine-card set does not read as nine identical backgrounds.

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


def ground(repo, idx):
    """Obsidian field, warm glow bottom-left, faint eagle watermark.

    The eagle is dropped to a few per cent opacity and panned across the set,
    so it reads as texture rather than a logo stamped on every card.
    """
    img = Image.new("RGB", (W, H), OBS)

    # warm glow, position drifts per slide
    pan = [0.24, 0.62, 0.30, 0.70, 0.20, 0.55, 0.34, 0.66, 0.28, 0.58][idx % 10]
    glow = Image.new("L", (W, H), 0)
    gd = ImageDraw.Draw(glow)
    cx, cy, R = int(W * pan), int(H * 0.90), 1150
    for r in range(R, 0, -8):
        gd.ellipse([cx - r, cy - r, cx + r, cy + r], fill=int(38 * (1 - r / R) ** 1.8))
    img = Image.composite(Image.new("RGB", (W, H), (150, 62, 20)), img, glow)

    # faint eagle watermark
    ep = os.path.join(repo, "anniversary-design-system/assets/logo-eagle.png")
    if os.path.exists(ep):
        eag = Image.open(ep).convert("RGBA")
        ew = int(W * 1.25)
        eag = eag.resize((ew, int(eag.height * ew / eag.width)), Image.LANCZOS)
        # greyscale it first: the yellow beak reads as a coloured blob at low opacity
        rgb = ImageEnhance.Color(eag.convert("RGB")).enhance(0.0)
        al = eag.split()[3].point(lambda v: int(v * 0.038))
        eag = rgb.convert("RGBA")
        eag.putalpha(al)
        ox = int(W * 0.42) - ew // 2 + int((idx % 5) * W * 0.05)
        img.paste(eag, (ox, int(H * 0.16)), eag)

    # second scrim through the type band so nothing cuts through the copy
    a = np.array(img).astype(float)
    ys = np.linspace(0, 1, H)[:, None, None]
    band = np.exp(-((ys - 0.44) ** 2) / (2 * 0.28 ** 2)) * 0.30
    a = a * (1 - band) + np.array([10, 10, 13], float) * band
    return Image.fromarray(a.clip(0, 255).astype(np.uint8))


def render_slide(repo, spec, idx, total, out, series_mark="ENTER INTO THE KINGDOM"):
    img = ground(repo, idx)
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
    # The mark was hardcoded to 9 Aug's sermon title. Every later week in
    # the series carried the wrong one until 23 Aug 2026.
    mark = c.get("series_mark", "ENTER INTO THE KINGDOM")
    for i, s in enumerate(c["slides"], 1):
        render_slide(a.repo, s, i, n, f"{a.outdir}/{c['slug']}-{i:02d}.png", series_mark=mark)
    print(f"{c['slug']}: {n} slides -> {a.outdir}")

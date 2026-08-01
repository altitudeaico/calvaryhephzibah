#!/usr/bin/env python3
"""Render a 1280x720 sermon thumbnail on the locked ALTARS series identity.

Differs from the standard Calvary thumbnail in three ways:
  1. The ground is series/altars/altars-master.png (the locked object), not a
     flat obsidian field. A left-side scrim keeps the type legible over it.
  2. A red tracked series badge sits above the episode title.
  3. The locked series line ("There are altars and there are altars.") is set in
     Instrument Serif italic with the second "altars." in Calvary Red, per the
     series concept — the sentence shows the two categories before it is read.

Everything else (fonts, red bracket, preacher block, portrait column) matches
the house thumbnail so the two sit together in a feed.
"""
import argparse
import os
import urllib.request
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageEnhance

W, H = 1280, 720
BONE = (244, 239, 230)
RED = (208, 68, 28)
GREY = (162, 156, 144)
FG3 = (150, 144, 132)
IS_URL = "https://raw.githubusercontent.com/google/fonts/main/ofl/instrumentserif/InstrumentSerif-Italic.ttf"


def instrument_serif(size):
    path = "/tmp/InstrumentSerif-Italic.ttf"
    if not os.path.exists(path):
        urllib.request.urlretrieve(IS_URL, path)
    return ImageFont.truetype(path, size)


def tracked(draw, xy, text, font, fill, tr=0.16):
    x, y = xy
    em = font.size
    for ch in text:
        draw.text((x, y), ch, font=font, fill=fill)
        x += draw.textlength(ch, font=font) + em * tr
    return x


def render(a):
    anton = os.path.join(a.repo, "anniversary/overlays/fonts/anton-400.ttf")
    inter = os.path.join(a.repo, "anniversary/overlays/fonts/inter-tight-600.ttf")
    plate = os.path.join(a.repo, "series/altars/altars-master.png")

    # ---- ground: the locked object, cover-fitted ----
    base = Image.open(plate).convert("RGB")
    s = max(W / base.size[0], H / base.size[1])
    base = base.resize((int(base.size[0] * s), int(base.size[1] * s)), Image.LANCZOS)
    ox = (base.size[0] - W) // 2
    oy = (base.size[1] - H) // 2
    img = base.crop((ox, oy, ox + W, oy + H))
    img = ImageEnhance.Brightness(img).enhance(a.plate_brightness)

    # ---- left scrim so the type never fights the stones ----
    arr = np.array(img).astype(float)
    xs = np.linspace(0, 1, W)[None, :, None]
    scrim = np.clip((a.scrim_edge - xs) / a.scrim_edge, 0, 1) ** 1.4 * a.scrim_strength
    arr = arr * (1 - scrim) + np.array([9, 9, 12], float) * scrim
    img = Image.fromarray(arr.clip(0, 255).astype(np.uint8))

    # ---- portrait on the right ----
    if a.portrait:
        cut = Image.open(a.portrait).convert("RGBA")
        al = np.array(cut.split()[3])
        ys_, xs_ = np.where(al > 30)
        cut = cut.crop((xs_.min(), ys_.min(), xs_.max() + 1, ys_.max() + 1))
        cw, ch = cut.size
        k = 556 / cw
        cut = cut.resize((int(cw * k), int(ch * k)), Image.LANCZOS)
        rgba = img.convert("RGBA")
        rgba.alpha_composite(cut, (W - cut.size[0] + 18, 46))
        img = rgba.convert("RGB")

    d = ImageDraw.Draw(img)
    LM = 74

    # ---- corner bracket + eyebrow ----
    d.rectangle([LM, 60, LM + 34, 64], fill=RED)
    d.rectangle([LM, 60, LM + 4, 94], fill=RED)
    tracked(d, (LM + 52, 57), a.eyebrow, ImageFont.truetype(inter, 21), GREY, 0.16)

    # ---- series badge ----
    badge_y = a.top
    tracked(d, (LM, badge_y), a.badge, ImageFont.truetype(inter, 20), RED, 0.36)

    # ---- episode title, auto-fit to clear the portrait column ----
    lines = [a.line1, a.line2] + ([a.line3] if a.line3 else [])
    cols = [BONE] * len(lines)
    cols[a.red - 1] = RED
    size = 122
    while size > 64:
        ft = ImageFont.truetype(anton, size)
        if max(d.textlength(t, font=ft) for t in lines) <= 600:
            break
        size -= 2
    ft = ImageFont.truetype(anton, size)
    lh = int(size * 0.98)
    y = badge_y + 44
    for txt, col in zip(lines, cols):
        d.text((LM - 4, y), txt, font=ft, fill=col)
        y += lh

    # ---- locked series line, final word in red ----
    y += 6
    fi = instrument_serif(38)
    head, tail = a.series_line.rsplit(" ", 1)
    d.text((LM, y), head + " ", font=fi, fill=FG3)
    d.text((LM + d.textlength(head + " ", font=fi), y), tail, font=fi, fill=RED)

    # ---- hairline rule ----
    ry = y + 62
    d.rectangle([LM, ry, LM + 470, ry + 1], fill=(70, 66, 62))

    # ---- preacher block ----
    by = 612
    d.rectangle([LM, by, LM + 6, by + 78], fill=RED)
    d.text((LM + 24, by - 6), a.preacher, font=ImageFont.truetype(anton, 50), fill=BONE)
    if a.sub:
        d.text((LM + 26, by + 52), a.sub, font=instrument_serif(30), fill=GREY)

    img.save(a.out, quality=92)
    print(a.out)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--eyebrow", required=True)
    ap.add_argument("--badge", default="THE ALTARS SERIES")
    ap.add_argument("--series-line", default="There are altars and there are altars.")
    ap.add_argument("--line1", required=True)
    ap.add_argument("--line2", required=True)
    ap.add_argument("--line3", default="")
    ap.add_argument("--red", type=int, default=2)
    ap.add_argument("--preacher", required=True)
    ap.add_argument("--sub", default="")
    ap.add_argument("--portrait", default="")
    ap.add_argument("--top", type=int, default=228)
    ap.add_argument("--plate-brightness", type=float, default=0.9)
    ap.add_argument("--scrim-edge", type=float, default=0.62)
    ap.add_argument("--scrim-strength", type=float, default=0.72)
    ap.add_argument("--out", required=True)
    render(ap.parse_args())

#!/usr/bin/env python3
"""Render the 1200x630 run-sheet OG card.

Companion to the stage-view OG card. Same design language, but the accent is
Calvary Red rather than gold, so a media-team link and a band link are
distinguishable at a glance in a WhatsApp thread.

Where the stage card lists songs and keys (what the band needs), this card
carries the facts the media team need before they open anything: sermon,
preacher, reading, and the shape of the worship set.

Usage:
    python3 scripts/render_runsheet_og.py \\
        --repo . \\
        --eyebrow "SUNDAY · 2 AUGUST 2026" \\
        --row "SERMON|Family Altar · ALTARS series" \\
        --row "PREACHER|Dr Titi Sodipo · Guest Minister" \\
        --out media-briefing-og-02-aug-2026.png

Each --row is "LABEL|Value".
"""
import argparse
import os
import urllib.request
from PIL import Image, ImageDraw, ImageFont

W, H = 1200, 630
OBS = (11, 11, 14)
BONE = (244, 239, 230)
RED = (208, 68, 28)
RED_B = (226, 96, 58)
FG3 = (150, 144, 132)
LINE = (42, 42, 48)
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


def tracked_width(draw, text, font, tr=0.16):
    em = font.size
    return sum(draw.textlength(c, font=font) + em * tr for c in text) - em * tr


def render(a):
    anton = os.path.join(a.repo, "anniversary/overlays/fonts/anton-400.ttf")
    inter6 = os.path.join(a.repo, "anniversary/overlays/fonts/inter-tight-600.ttf")
    inter7 = os.path.join(a.repo, "anniversary/overlays/fonts/inter-tight-700.ttf")
    eagle_path = os.path.join(a.repo, "anniversary-design-system/logo-eagle.png")

    img = Image.new("RGB", (W, H), OBS)
    glow = Image.new("L", (W, H), 0)
    gd = ImageDraw.Draw(glow)
    for r in range(620, 0, -3):
        gd.ellipse([120 - r, 40 - r, 120 + r, 40 + r], fill=int(45 * (1 - r / 620) ** 1.8))
    img = Image.composite(Image.new("RGB", (W, H), (120, 55, 18)), img, glow)
    d = ImageDraw.Draw(img)

    LM = 64
    d.rectangle([LM, 58, LM + 30, 62], fill=RED)
    d.rectangle([LM, 58, LM + 4, 88], fill=RED)
    tracked(d, (LM + 48, 54), a.eyebrow, ImageFont.truetype(inter7, 22), RED_B, 0.16)

    d.text((LM - 5, 92), a.headline, font=ImageFont.truetype(anton, 118), fill=BONE)
    d.text((LM, 228), a.subtitle, font=instrument_serif(40), fill=FG3)
    d.line([(LM, 300), (W - 64, 300)], fill=LINE, width=2)

    f_lab = ImageFont.truetype(inter7, 19)
    f_val = ImageFont.truetype(inter6, 29)
    y = 334
    for spec in a.row:
        label, _, value = spec.partition("|")
        tracked(d, (LM, y + 6), label.strip(), f_lab, RED, 0.2)
        d.text((LM + 250, y), value.strip(), font=f_val, fill=BONE)
        y += 52

    eagle = Image.open(eagle_path).convert("RGBA").resize((150, 150))
    img.paste(eagle, (W - 190, 40), eagle)

    fwm = ImageFont.truetype(anton, 34)
    wm = "CALVARY HEPHZIBAH"
    d.text((W - 64 - d.textlength(wm, font=fwm), H - 92), wm, font=fwm, fill=RED_B)
    fsm = ImageFont.truetype(inter7, 16)
    sm = a.footer
    d.text((0, 0), "", font=fsm)
    tracked(d, (W - 64 - tracked_width(d, sm, fsm, 0.14), H - 50), sm, fsm, FG3, 0.14)

    os.makedirs(os.path.dirname(a.out) or ".", exist_ok=True)
    img.save(a.out)
    print(a.out)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--eyebrow", required=True)
    ap.add_argument("--headline", default="RUN SHEET")
    ap.add_argument("--subtitle", default="Order of service, songs & scripture — for the media team.")
    ap.add_argument("--footer", default="FOR THE MEDIA TEAM · BEFORE SERVICE")
    ap.add_argument("--row", action="append", default=[], help='"LABEL|Value"')
    ap.add_argument("--out", required=True)
    render(ap.parse_args())

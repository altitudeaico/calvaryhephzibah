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
GREY = (196, 189, 177)
FG3 = (214, 206, 194)
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
    ys = np.linspace(0, 1, H)[:, None, None]
    left = np.clip((a.scrim_edge - xs) / a.scrim_edge, 0, 1) ** 1.4
    scrim = left * a.scrim_strength
    # bottom-left falloff: the series line, rule and preacher block sit low-left,
    # where stone highlights spike to ~120 and swallow the muted grey type.
    floor = left * np.clip((ys - a.floor_start) / (1 - a.floor_start), 0, 1) ** 1.2 * a.floor_strength
    scrim = np.clip(scrim + floor, 0, 0.985)
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

    # ------------------------------------------------------------------
    # Everything below is positioned by INK BOX, not by nominal line
    # height. Anton carries a lot of internal leading, so laying out on
    # nominal y collides the serif line into the title's descender zone.
    # place(font, text, ink_top) -> the draw-y that puts ink at ink_top.
    # ------------------------------------------------------------------
    def place(font, text, ink_top):
        return ink_top - font.getbbox(text)[1]

    def ink_h(font, text):
        b = font.getbbox(text)
        return b[3] - b[1]

    f_badge = ImageFont.truetype(inter, 20)
    f_ser = instrument_serif(38)
    f_name = ImageFont.truetype(anton, 50)
    f_sub = instrument_serif(30)

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

    # --- bottom block anchors first, then the stack is built upward ---
    name_top = H - a.margin_bottom - ink_h(f_name, a.preacher) - a.gap_name_sub - (
        ink_h(f_sub, a.sub) if a.sub else 0)
    sub_top = name_top + ink_h(f_name, a.preacher) + a.gap_name_sub
    block_bot = (sub_top + ink_h(f_sub, a.sub)) if a.sub else (
        name_top + ink_h(f_name, a.preacher))

    rule_y = name_top - a.gap_rule_preacher
    ser_top = rule_y - a.gap_series_rule - ink_h(f_ser, a.series_line)

    title_bot = ser_top - a.gap_title_series
    title_h = sum(ink_h(ft, t) for t in lines) + a.gap_title_lines * (len(lines) - 1)
    title_top = title_bot - title_h
    badge_top = title_top - a.gap_badge_title - ink_h(f_badge, a.badge)

    # ---- series badge ----
    tracked(d, (LM, place(f_badge, a.badge, badge_top)), a.badge, f_badge, RED, 0.36)

    # ---- episode title ----
    y = title_top
    for txt, col in zip(lines, cols):
        d.text((LM - 4, place(ft, txt, y)), txt, font=ft, fill=col)
        y += ink_h(ft, txt) + a.gap_title_lines

    # ---- locked series line, final word in red ----
    head, tail = a.series_line.rsplit(" ", 1)
    sy = place(f_ser, a.series_line, ser_top)
    d.text((LM, sy), head + " ", font=f_ser, fill=FG3)
    d.text((LM + d.textlength(head + " ", font=f_ser), sy), tail, font=f_ser, fill=RED)

    # ---- hairline rule ----
    # Deliberately short. A full-width rule runs out across the stone pile,
    # where a dark hairline simply disappears. 300px keeps it in the scrimmed
    # zone and reads as an editorial tick rather than a broken line.
    rule_w = a.rule_width
    d.rectangle([LM, rule_y, LM + rule_w, rule_y + 1], fill=(104, 97, 88))

    # ---- preacher block; the red bar spans the whole block ----
    d.rectangle([LM, name_top - 8, LM + 6, block_bot + 8], fill=RED)
    d.text((LM + 24, place(f_name, a.preacher, name_top)), a.preacher, font=f_name, fill=BONE)
    if a.sub:
        d.text((LM + 26, place(f_sub, a.sub, sub_top)), a.sub, font=f_sub, fill=GREY)

    if a.audit:
        print(f"  badge ink      {badge_top} -> {badge_top + ink_h(f_badge, a.badge)}")
        print(f"  title ink      {title_top} -> {title_bot}  (size {size})")
        print(f"  series ink     {ser_top} -> {ser_top + ink_h(f_ser, a.series_line)}")
        print(f"  rule           {rule_y}")
        print(f"  preacher ink   {name_top} -> {block_bot}")
        print(f"  bottom margin  {H - block_bot}   left margin {LM}")

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
    ap.add_argument("--gap-badge-title", type=int, default=40)
    ap.add_argument("--gap-title-lines", type=int, default=16)
    ap.add_argument("--gap-title-series", type=int, default=40)
    ap.add_argument("--gap-series-rule", type=int, default=28)
    ap.add_argument("--gap-rule-preacher", type=int, default=44)
    ap.add_argument("--gap-name-sub", type=int, default=6)
    ap.add_argument("--margin-bottom", type=int, default=64)
    ap.add_argument("--rule-width", type=int, default=300)
    ap.add_argument("--audit", action="store_true")
    ap.add_argument("--plate-brightness", type=float, default=0.9)
    ap.add_argument("--scrim-edge", type=float, default=0.62)
    ap.add_argument("--scrim-strength", type=float, default=0.72)
    ap.add_argument("--floor-start", type=float, default=0.55)
    ap.add_argument("--floor-strength", type=float, default=0.60)
    ap.add_argument("--out", required=True)
    render(ap.parse_args())

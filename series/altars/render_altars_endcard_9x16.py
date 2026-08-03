#!/usr/bin/env python3
"""Build the two 9x16 end-card screens that tail every ALTARS clip.

Screen A - the episode: series badge, episode title, series line, preacher
           portrait and name, on the master plate.
Screen B - the series: where to watch the whole thing, and the handles.

The master plate is landscape (1920x1080). Cropping it to 9:16 would take a
608px-wide slice and throw away the stone pile, which is the whole identity.
So instead the plate is laid in as a full-width BAND across the middle third
and feathered top and bottom into obsidian. The stones stay intact, the type
gets clean dark ground above and below, and the portrait bleeds off the base.

Layout is positioned by ink box, same as render_altars_episode.py, so the
serif line can never collide with the descender zone of the Anton title.
"""
import argparse
import os
import urllib.request
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageEnhance

W, H = 1080, 1920
OBS = (11, 11, 14)
BONE = (244, 239, 230)
RED = (208, 68, 28)
RED_B = (226, 96, 58)
GREY = (196, 189, 177)
FG3 = (214, 206, 194)
IS_URL = "https://raw.githubusercontent.com/google/fonts/main/ofl/instrumentserif/InstrumentSerif-Italic.ttf"


def instrument_serif(size):
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


def ground(repo, band_top, band_h, plate_dim=0.82):
    """Obsidian field + ember glow + the master plate as a feathered band."""
    img = Image.new("RGB", (W, H), OBS)
    glow = Image.new("L", (W, H), 0)
    gd = ImageDraw.Draw(glow)
    cx, cy, R = W // 2, band_top + band_h // 2, 1500
    for r in range(R, 0, -6):
        gd.ellipse([cx - r, cy - r, cx + r, cy + r], fill=int(60 * (1 - r / R) ** 1.7))
    img = Image.composite(Image.new("RGB", (W, H), (128, 52, 16)), img, glow)

    plate = Image.open(os.path.join(repo, "series/altars/altars-master.png")).convert("RGB")
    s = W / plate.width
    plate = plate.resize((W, int(plate.height * s)), Image.LANCZOS)
    top = max(0, (plate.height - band_h) // 2)
    plate = plate.crop((0, top, W, top + band_h))
    plate = ImageEnhance.Brightness(plate).enhance(plate_dim)

    # feather the band into the obsidian, top and bottom
    mask = np.ones((band_h, W), dtype=float)
    fade = int(band_h * 0.34)
    ramp = np.linspace(0, 1, fade) ** 1.5
    mask[:fade] *= ramp[:, None]
    mask[-fade:] *= ramp[::-1][:, None]
    m = Image.fromarray((mask * 255).astype(np.uint8), "L")
    img.paste(plate, (0, band_top), m)
    return img


def screen_a(a):
    anton = os.path.join(a.repo, "anniversary/overlays/fonts/anton-400.ttf")
    inter = os.path.join(a.repo, "anniversary/overlays/fonts/inter-tight-700.ttf")
    img = ground(a.repo, 620, 900)
    d = ImageDraw.Draw(img)
    LM = 84

    def place(f, t, ink_top):
        return ink_top - f.getbbox(t)[1]

    def ih(f, t):
        b = f.getbbox(t)
        return b[3] - b[1]

    # portrait, bleeding off the base on the right
    cut = Image.open(a.portrait).convert("RGBA")
    al = np.array(cut.split()[3])
    ys, xs = np.where(al > 30)
    cut = cut.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    k = a.portrait_h / cut.height
    cut = cut.resize((int(cut.width * k), int(cut.height * k)), Image.LANCZOS)
    rgba = img.convert("RGBA")
    rgba.alpha_composite(cut, (W - cut.width + a.portrait_bleed, H - cut.height))
    img = rgba.convert("RGB")
    d = ImageDraw.Draw(img)

    # bracket + eyebrow
    d.rectangle([LM, 108, LM + 44, 113], fill=RED)
    d.rectangle([LM, 108, LM + 5, 152], fill=RED)
    tracked(d, (LM + 66, 104), a.eyebrow, ImageFont.truetype(inter, 30), GREY, 0.16)

    f_badge = ImageFont.truetype(inter, 30)
    f_ser = instrument_serif(56)
    lines = [a.line1, a.line2]
    size = 200
    while size > 90:
        ft = ImageFont.truetype(anton, size)
        if max(d.textlength(t, font=ft) for t in lines) <= W - LM * 2 - 40:
            break
        size -= 4
    ft = ImageFont.truetype(anton, size)

    badge_top = 300
    title_top = badge_top + ih(f_badge, a.badge) + 54
    tracked(d, (LM, place(f_badge, a.badge, badge_top)), a.badge, f_badge, RED, 0.36)
    y = title_top
    for t, c in zip(lines, [BONE, RED]):
        d.text((LM - 6, place(ft, t, y)), t, font=ft, fill=c)
        y += ih(ft, t) + 22
    ser_top = y - 22 + 56
    head, tail = a.series_line.rsplit(" ", 1)
    sy = place(f_ser, a.series_line, ser_top)
    d.text((LM, sy), head + " ", font=f_ser, fill=FG3)
    d.text((LM + d.textlength(head + " ", font=f_ser), sy), tail, font=f_ser, fill=RED)

    # preacher block, bottom left, clear of the portrait
    f_name = ImageFont.truetype(anton, 76)
    f_sub = instrument_serif(44)
    sub_bot = H - 150
    name_top = sub_bot - ih(f_sub, a.sub) - 10 - ih(f_name, a.preacher)
    sub_top = name_top + ih(f_name, a.preacher) + 10
    d.rectangle([LM, name_top - 12, LM + 8, sub_bot + 12], fill=RED)
    d.text((LM + 32, place(f_name, a.preacher, name_top)), a.preacher, font=f_name, fill=BONE)
    d.text((LM + 34, place(f_sub, a.sub, sub_top)), a.sub, font=f_sub, fill=GREY)

    img.save(a.out_a, quality=95)
    print(a.out_a)
    return dict(badge=badge_top, title=(title_top, y - 22), series=ser_top, name=name_top, sub_bot=sub_bot)


def screen_b(a):
    anton = os.path.join(a.repo, "anniversary/overlays/fonts/anton-400.ttf")
    inter = os.path.join(a.repo, "anniversary/overlays/fonts/inter-tight-700.ttf")
    img = ground(a.repo, 760, 760, plate_dim=0.55)
    d = ImageDraw.Draw(img)

    def ctr(text, font, y, fill, tr=None):
        if tr is None:
            d.text(((W - d.textlength(text, font=font)) / 2, y), text, font=font, fill=fill)
        else:
            tracked(d, ((W - tracked_w(d, text, font, tr)) / 2, y), text, font, fill, tr)

    eagle = Image.open(os.path.join(a.repo, "anniversary-design-system/logo-eagle.png")).convert("RGBA")
    eagle = eagle.resize((250, 250))
    img.paste(eagle, ((W - 250) // 2, 210), eagle)
    d = ImageDraw.Draw(img)

    ctr("THE SERIES", ImageFont.truetype(inter, 32), 540, RED, 0.42)
    ctr("ALTARS", ImageFont.truetype(anton, 230), 590, BONE)
    f_ser = instrument_serif(54)
    head, tail = a.series_line.rsplit(" ", 1)
    tot = d.textlength(head + " ", font=f_ser) + d.textlength(tail, font=f_ser)
    x0 = (W - tot) / 2
    d.text((x0, 860), head + " ", font=f_ser, fill=FG3)
    d.text((x0 + d.textlength(head + " ", font=f_ser), 860), tail, font=f_ser, fill=RED)

    d.rectangle([(W - 240) // 2, 1010, (W + 240) // 2, 1012], fill=(104, 97, 88))

    ctr("WATCH THE FULL SERMON", ImageFont.truetype(inter, 40), 1120, BONE, 0.22)
    ctr("YOUTUBE", ImageFont.truetype(inter, 30), 1220, RED_B, 0.34)
    ctr("CALVARY HEPHZIBAH", ImageFont.truetype(anton, 92), 1268, BONE)

    ctr("@calvaryhephzibahfgc   ·   @calvaryhephzibah", instrument_serif(46), 1450, GREY)
    ctr("calvaryhephzibah.co.uk", ImageFont.truetype(inter, 34), 1560, RED_B, 0.2)

    fwm = ImageFont.truetype(inter, 26)
    ctr("CALVARY HEPHZIBAH FULL GOSPEL CHURCH  ·  MANCHESTER", fwm, 1770, (120, 114, 104), 0.16)

    img.save(a.out_b, quality=95)
    print(a.out_b)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--eyebrow", default="SUNDAY 2 AUGUST 2026")
    ap.add_argument("--badge", default="THE ALTARS SERIES")
    ap.add_argument("--series-line", default="There are altars and there are altars.")
    ap.add_argument("--line1", default="FAMILY")
    ap.add_argument("--line2", default="ALTAR")
    ap.add_argument("--preacher", default="Dr Titi Sodipo")
    ap.add_argument("--sub", default="Guest Minister")
    ap.add_argument("--portrait", required=True)
    ap.add_argument("--portrait-h", type=int, default=1050)
    ap.add_argument("--portrait-bleed", type=int, default=40)
    ap.add_argument("--out-a", required=True)
    ap.add_argument("--out-b", required=True)
    a = ap.parse_args()
    geo = screen_a(a)
    screen_b(a)
    print("geometry:", geo)

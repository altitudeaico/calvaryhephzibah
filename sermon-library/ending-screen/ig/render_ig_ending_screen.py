#!/usr/bin/env python3
"""
Instagram Reel ENDING SCREEN — reusable template.

Locked from the "He Never Fails" build (30 Aug 2026) after a dedicated round
of Instagram-specific feedback. Sibling to render_ig_cover.py — same visual
language, different purpose and layout priorities.

WHAT THIS IS FOR: the final frame of the Reel itself, carrying the CTA that
drives people to the full sermon. Unlike render_ending_screen.py (the
YouTube/general-purpose version with a large CTA sitting near the bottom),
this version has to survive being viewed INSIDE the Instagram app, with
Instagram's own interface chrome overlaid on top of it.

Change only CONFIG for a new sermon.

═══════════════════════════════════════════════════════════════════════════
WHAT'S DIFFERENT ABOUT THE IG ENDING SCREEN (vs. the general one)
═══════════════════════════════════════════════════════════════════════════

1. CTA IS MOVED UP, not left at the bottom. Instagram's own caption text,
   audio row, and right-side action icons (like/comment/share/save) sit
   over the bottom ~30-40% of a Reel. A CTA placed the way the YouTube
   version does it will be obscured. This version's whole layout is
   compressed and shifted upward to compensate -- portrait, logo, and title
   are all genuinely resized/repositioned to make room, not just shrunk.

2. SHORTER CTA WORDING -- "FULL VIDEO ON YOUTUBE" / "SEARCH: [CHURCH]"
   rather than the fuller "WATCH THE FULL VIDEO ON YOUTUBE". Less horizontal
   space is available once the design is compressed to clear the bottom.

3. CTA'S RIGHT MARGIN IS WIDER than a naive centred block would use, to
   clear Instagram's right-side action-icon column. This was caught only
   by checking against an interface mock-up, not by eye -- the CTA block
   technically cleared the documented "safe zone" percentage guide while
   still overlapping the icon column, because the safe-zone guide and the
   icon column aren't the same thing. Check both.

4. LOWER THIRD IS LEFT AS PLAIN BACKGROUND. Don't fill freed-up space with
   more information just because it's available -- Instagram's own chrome
   will occupy it. Adding more content there defeats the point of moving
   the CTA up in the first place.

═══════════════════════════════════════════════════════════════════════════
PLACEMENT VERIFICATION -- read this before trusting a render
═══════════════════════════════════════════════════════════════════════════

Two independent checks, because neither one alone is reliable:

  a) SAFE-ZONE GUIDE: Meta's own Reels-ad placement guidance (a
     conservative starting point, not a guarantee for every organic Reel
     view) suggests keeping key elements out of roughly the top 14%,
     bottom 35%, and outer 6% on each side of a 1080x1920 canvas. See
     `SAFE_ZONE` below. Reference:
     https://www.facebook.com/business/ads-guide/update/image/instagram-reels

  b) INTERFACE MOCK-UP CHECK: build or reuse an approximate overlay of
     Instagram's actual interface (caption area, audio row, right-side
     icon stack) and composite the design underneath it. This is what
     caught the icon-column overlap that the safe-zone guide alone missed.
     Label any such mock-up clearly as approximate -- it is not a real
     screenshot, and placement checked only against it should be treated
     as provisional until verified against an actual current screenshot.
"""

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from PIL import Image, ImageDraw, ImageFont, ImageFilter
from portrait_blend import build_feathered_portrait

W, H = 1080, 1920
WARM_WHITE = (248, 242, 233)
RED_BRIGHT = (214, 58, 48)
RED_DEEP = (120, 24, 24)

# Meta Reels-ad conservative safe zone -- a starting point, not a guarantee
SAFE_ZONE = {
    "top": int(H * 0.14),
    "bottom": H - int(H * 0.35),
    "left": int(W * 0.06),
    "right": W - int(W * 0.06),
}
# Instagram's right-side action-icon column sits roughly here -- separate
# from the safe-zone guide, must be checked independently (see docstring)
ICON_COLUMN_LEFT_EDGE = 956

CONFIG = {
    "source_still": "../source_still.jpg",
    "portrait_crop": (155, 155, 580, 620),
    "title_lines": ["HE NEVER", "FAILS"],
    "speaker_name": "Bishop Henry Emmanuel",
    "speaker_label": "CALVARY HEPHZIBAH \u00b7 GUEST MINISTER",  # verify before use; "" to omit
    "cta_line_1": "FULL VIDEO ON YOUTUBE",
    "cta_line_2": "SEARCH: CALVARY HEPHZIBAH",
    "output_path": "ig_ending_output.jpg",
    "font_anton": "/home/claude/calvaryhephzibah/anniversary/overlays/fonts/anton-400.ttf",
    "font_inter_medium": "/home/claude/calvaryhephzibah/anniversary/overlays/fonts/inter-tight-500.ttf",
    "logo_path": "../logo/calvary-logo-roundel-transparent.png",
}


def build_background(seed=11):
    import random
    bg = Image.new("RGB", (W, H), (15, 14, 15))
    draw = ImageDraw.Draw(bg)
    for y in range(H):
        t = y / H
        base = max(9, min(21, 14 + 6 * (1 - abs(t - 0.4) * 1.3)))
        draw.line([(0, y), (W, y)], fill=(int(base), int(base * 0.95), int(base * 0.97)))
    glow = Image.new("L", (W, H), 0)
    ImageDraw.Draw(glow).ellipse([W // 2 - 560, 120, W // 2 + 560, 1150], fill=42)
    glow = glow.filter(ImageFilter.GaussianBlur(180))
    bg = Image.composite(Image.new("RGB", (W, H), (120, 32, 30)), bg, glow)
    random.seed(seed)
    grain = Image.new("L", (W, H))
    gpix = grain.load()
    for y in range(H):
        for x in range(W):
            gpix[x, y] = random.randint(112, 128)
    grain_rgba = Image.merge("RGBA", (grain, grain, grain, Image.new("L", (W, H), 7)))
    return Image.alpha_composite(bg.convert("RGBA"), grain_rgba).convert("RGB")


def build_interface_mockup():
    """Approximate Instagram Reels interface overlay -- clearly labelled as
    a mock-up. Use for a SECOND, independent placement check alongside the
    safe-zone guide, not as a substitute for verifying against a real
    current screenshot when one is available."""
    from PIL import ImageFont as IF
    mockup = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(mockup)
    for y in range(H - 620, H):
        a = int(190 * min(1, (y - (H - 620)) / 500))
        d.line([(0, y), (W, y)], fill=(0, 0, 0, a))
    icon_x = W - 90
    for iy in [H - 980, H - 860, H - 740, H - 620, H - 500]:
        d.ellipse([icon_x - 34, iy - 34, icon_x + 34, iy + 34], fill=(255, 255, 255, 235))
    inter = "/home/claude/calvaryhephzibah/anniversary/overlays/fonts/inter-tight-700.ttf"
    inter_m = "/home/claude/calvaryhephzibah/anniversary/overlays/fonts/inter-tight-500.ttf"
    font_u, font_c = IF.truetype(inter, 30), IF.truetype(inter_m, 26)
    d.ellipse([40, H - 170, 100, H - 110], fill=(255, 255, 255, 235))
    d.text((115, H - 165), "@calvaryhephzibahfgc", font=font_u, fill=(255, 255, 255, 255))
    d.text((40, H - 105), "Caption text would sit here...", font=font_c, fill=(230, 230, 230, 230))
    d.text((40, H - 60), "\u266a Original audio \u00b7 Calvary Hephzibah", font=font_c, fill=(220, 220, 220, 220))
    font_label = IF.truetype(inter, 26)
    d.rectangle([0, 0, W, 40], fill=(20, 120, 220, 230))
    d.text((16, 6), "MOCK-UP \u2014 approximate interface, provisional check only", font=font_label, fill=(255, 255, 255, 255))
    return mockup


def render(config=CONFIG):
    canvas = build_background().convert("RGBA")

    portrait = build_feathered_portrait(config["source_still"], config["portrait_crop"])
    target_w = 740
    port = portrait.resize((target_w, int(portrait.height * target_w / portrait.width)), Image.LANCZOS)
    ppx, ppy = (W - port.width) // 2, 60
    canvas.alpha_composite(port, (ppx, ppy))
    canvas_rgb = canvas.convert("RGB")

    logo = Image.open(config["logo_path"]).convert("RGBA")
    logo_size = 100
    logo_small = logo.resize((logo_size, logo_size), Image.LANCZOS)
    logo_y = 595
    canvas_rgba = canvas_rgb.convert("RGBA")
    canvas_rgba.alpha_composite(logo_small, (W // 2 - logo_size // 2, logo_y))
    canvas_rgb = canvas_rgba.convert("RGB")
    draw = ImageDraw.Draw(canvas_rgb)

    font_anton = config["font_anton"]
    line1_font = ImageFont.truetype(font_anton, 76)
    line1 = config["title_lines"][0]
    l1w = draw.textlength(line1, font=line1_font)
    l1_y = 722
    sh1 = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(sh1).text(((W - l1w) / 2 + 5, l1_y + 6), line1, font=line1_font, fill=(0, 0, 0, 180))
    sh1 = sh1.filter(ImageFilter.GaussianBlur(3))
    canvas_rgb = Image.alpha_composite(canvas_rgb.convert("RGBA"), sh1).convert("RGB")
    draw = ImageDraw.Draw(canvas_rgb)
    draw.text(((W - l1w) / 2, l1_y), line1, font=line1_font, fill=WARM_WHITE, stroke_width=3, stroke_fill=(10, 8, 8))

    fails_font = ImageFont.truetype(font_anton, 138)
    fails_text = config["title_lines"][-1]
    fw = draw.textlength(fails_text, font=fails_font)
    fx, fy = (W - fw) / 2, l1_y + 82

    probe = Image.new("L", (W, H), 0)
    ImageDraw.Draw(probe).text((fx, fy), fails_text, font=fails_font, fill=255)
    bbox = probe.getbbox()

    shadow_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow_layer).text((fx + 6, fy + 8), fails_text, font=fails_font, fill=(0, 0, 0, 190))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(3))
    canvas_rgb = Image.alpha_composite(canvas_rgb.convert("RGBA"), shadow_layer).convert("RGB")

    edge_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(edge_layer).text((fx, fy), fails_text, font=fails_font, fill=(8, 6, 6, 255),
                                     stroke_width=5, stroke_fill=(8, 6, 6, 255))
    canvas_rgb = Image.alpha_composite(canvas_rgb.convert("RGBA"), edge_layer).convert("RGB")

    grad = Image.new("RGB", (W, H))
    gdraw = ImageDraw.Draw(grad)
    gy0, gy1 = bbox[1], bbox[3]
    for y in range(gy0, gy1 + 1):
        t = (y - gy0) / max(1, (gy1 - gy0))
        col = tuple(int(RED_BRIGHT[i] + (RED_DEEP[i] - RED_BRIGHT[i]) * t) for i in range(3))
        gdraw.line([(0, y), (W, y)], fill=col)
    glyph_mask = Image.new("L", (W, H), 0)
    ImageDraw.Draw(glyph_mask).text((fx, fy), fails_text, font=fails_font, fill=255)
    canvas_rgb.paste(grad, (0, 0), glyph_mask)
    draw = ImageDraw.Draw(canvas_rgb)

    name_font = ImageFont.truetype(config["font_inter_medium"], 32)
    name = config["speaker_name"]
    nw = draw.textlength(name, font=name_font)
    name_y = bbox[3] + 16
    draw.text(((W - nw) / 2, name_y), name, font=name_font, fill=(220, 214, 207))

    label_bottom = name_y + 16
    if config["speaker_label"]:
        label_font = ImageFont.truetype(config["font_inter_medium"], 21)
        label = config["speaker_label"]
        lw = draw.textlength(label, font=label_font)
        draw.text(((W - lw) / 2, name_y + 38), label, font=label_font, fill=(190, 110, 95))
        label_bottom = name_y + 38 + 26

    # CTA -- right margin explicitly clears the icon column, not just the safe zone
    cta_left, cta_right = 100, ICON_COLUMN_LEFT_EDGE - 36
    cta_top = label_bottom + 30
    cta_bottom = cta_top + 165
    draw.rectangle([cta_left, cta_top, cta_right, cta_bottom], fill=RED_BRIGHT)
    draw.rectangle([cta_left, cta_top, cta_right, cta_top + 5], fill=(120, 24, 24))
    cta_cx = (cta_left + cta_right) / 2

    cta1_font = ImageFont.truetype(font_anton, 37)
    cta1 = config["cta_line_1"]
    c1w = draw.textlength(cta1, font=cta1_font)
    draw.text((cta_cx - c1w / 2, cta_top + 28), cta1, font=cta1_font, fill=WARM_WHITE)

    cta2_font = ImageFont.truetype(font_anton, 32)
    cta2 = config["cta_line_2"]
    c2w = draw.textlength(cta2, font=cta2_font)
    draw.text((cta_cx - c2w / 2, cta_top + 96), cta2, font=cta2_font, fill=WARM_WHITE,
               stroke_width=2, stroke_fill=(120, 20, 18))

    if cta_bottom > SAFE_ZONE["bottom"]:
        print(f"WARNING: CTA bottom ({cta_bottom}) exceeds the safe-zone bottom "
              f"({SAFE_ZONE['bottom']}) -- may be obscured by IG's caption area.")

    canvas_rgb.save(config["output_path"], quality=96)
    print(f"Saved: {config['output_path']}")
    phone_path = config["output_path"].replace(".jpg", "-phonesize.jpg")
    canvas_rgb.resize((240, 427)).save(phone_path, quality=92)
    print(f"Saved phone check: {phone_path}")

    # Provisional mock-up check -- see docstring, this is not a substitute
    # for checking against a real current Instagram screenshot
    mockup = build_interface_mockup()
    checked = Image.alpha_composite(canvas_rgb.convert("RGBA"), mockup).convert("RGB")
    mockup_path = config["output_path"].replace(".jpg", "-MOCKUP-CHECK.jpg")
    checked.save(mockup_path, quality=92)
    print(f"Saved provisional mock-up check: {mockup_path} -- LABEL AS PROVISIONAL, not a real screenshot")


if __name__ == "__main__":
    render()

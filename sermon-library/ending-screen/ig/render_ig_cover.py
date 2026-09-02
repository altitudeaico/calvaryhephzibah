#!/usr/bin/env python3
"""
Instagram Reel COVER (profile-grid thumbnail) — reusable template.

Locked from the "He Never Fails" build (30 Aug 2026) after a dedicated round
of Instagram-specific feedback. Sibling to render_ig_ending_screen.py — same
visual language, different purpose and layout priorities.

WHAT THIS IS FOR: the still that represents the Reel in the profile grid and
before someone taps play. No CTA — the CTA lives on the ending screen, not
the cover. Priority here is pure, fast communication: face, title, logo.

Change only CONFIG for a new sermon. See the module docstring in
render_ending_screen.py for the full shared design-rule history (gradient/
stroke/shadow treatment, logo-in-the-shot positioning, etc.) — this file
only documents what's DIFFERENT about the cover specifically.

═══════════════════════════════════════════════════════════════════════════
WHAT'S DIFFERENT ABOUT THE COVER (vs. the ending screen)
═══════════════════════════════════════════════════════════════════════════

1. NO CTA BLOCK. The cover's job is to make someone tap play, not to send
   them to YouTube — that's the ending screen's job. Adding a CTA here is
   clutter, not communication.

2. Speaker's name is optional secondary info — keep it if it's readable at
   grid-thumbnail size, drop the guest-minister label if things feel tight.
   Title completeness beats adding more text.

3. TITLE IS LARGER than on the ending screen (~20-25% bigger) because the
   cover has no CTA competing for space, and because grid-thumbnail size is
   much smaller than a full ending-screen view — it needs to win at a glance.

4. MUST BE CHECKED AGAINST THE ACTUAL PROFILE-GRID CROP, not just viewed at
   full resolution. Instagram's Reels grid tile is roughly 3:4 (portrait),
   cropped from the centre of the 9:16 canvas. For a 1080x1920 source, that
   crop is approximately (0, 240, 1080, 1680) — verify current behaviour
   before assuming this hasn't changed. `render()` below produces this crop
   and a thumbnail-sized version automatically; always look at the actual
   thumbnail output, not just the full-resolution export, before calling a
   cover finished. A design that reads fine at full size can still fail at
   the size it's actually seen.
"""

import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from PIL import Image, ImageDraw, ImageFont, ImageFilter
from portrait_blend import build_feathered_portrait

W, H = 1080, 1920
WARM_WHITE = (248, 242, 233)
RED_BRIGHT = (214, 58, 48)
RED_DEEP = (120, 24, 24)

# Instagram Reels profile-grid crop: roughly 3:4, centred vertically in the
# 9:16 canvas. Re-verify against current IG behaviour periodically.
GRID_CROP_BOX = (0, 240, 1080, 1680)
GRID_THUMBNAIL_SIZE = (162, 216)  # roughly actual on-screen grid tile size

CONFIG = {
    "source_still": "../source_still.jpg",
    "portrait_crop": (155, 155, 580, 620),
    "title_lines": ["HE NEVER", "FAILS"],
    "speaker_name": "Bishop Henry Emmanuel",   # set to "" to omit
    "output_path": "ig_cover_output.jpg",
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


def render(config=CONFIG):
    canvas = build_background().convert("RGBA")

    portrait = build_feathered_portrait(config["source_still"], config["portrait_crop"])
    target_w = 900
    port = portrait.resize((target_w, int(portrait.height * target_w / portrait.width)), Image.LANCZOS)
    ppx, ppy = (W - port.width) // 2, 130
    canvas.alpha_composite(port, (ppx, ppy))
    canvas_rgb = canvas.convert("RGB")

    logo = Image.open(config["logo_path"]).convert("RGBA")
    logo_size = 118
    logo_small = logo.resize((logo_size, logo_size), Image.LANCZOS)
    logo_y = 700
    canvas_rgba = canvas_rgb.convert("RGBA")
    canvas_rgba.alpha_composite(logo_small, (W // 2 - logo_size // 2, logo_y))
    canvas_rgb = canvas_rgba.convert("RGB")
    draw = ImageDraw.Draw(canvas_rgb)

    font_anton = config["font_anton"]
    # Title ~22% larger than the ending-screen version -- no CTA competing for room
    line1_font = ImageFont.truetype(font_anton, 117)
    line1 = config["title_lines"][0]
    l1w = draw.textlength(line1, font=line1_font)
    l1_y = 858
    sh1 = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(sh1).text(((W - l1w) / 2 + 6, l1_y + 8), line1, font=line1_font, fill=(0, 0, 0, 180))
    sh1 = sh1.filter(ImageFilter.GaussianBlur(3))
    canvas_rgb = Image.alpha_composite(canvas_rgb.convert("RGBA"), sh1).convert("RGB")
    draw = ImageDraw.Draw(canvas_rgb)
    draw.text(((W - l1w) / 2, l1_y), line1, font=line1_font, fill=WARM_WHITE, stroke_width=4, stroke_fill=(10, 8, 8))

    fails_font = ImageFont.truetype(font_anton, 232)
    fails_text = config["title_lines"][-1]
    fw = draw.textlength(fails_text, font=fails_font)
    fx, fy = (W - fw) / 2, l1_y + 132

    probe = Image.new("L", (W, H), 0)
    ImageDraw.Draw(probe).text((fx, fy), fails_text, font=fails_font, fill=255)
    bbox = probe.getbbox()

    shadow_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow_layer).text((fx + 9, fy + 13), fails_text, font=fails_font, fill=(0, 0, 0, 190))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(4))
    canvas_rgb = Image.alpha_composite(canvas_rgb.convert("RGBA"), shadow_layer).convert("RGB")

    edge_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(edge_layer).text((fx, fy), fails_text, font=fails_font, fill=(8, 6, 6, 255),
                                     stroke_width=7, stroke_fill=(8, 6, 6, 255))
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

    if config["speaker_name"]:
        name_font = ImageFont.truetype(config["font_inter_medium"], 44)
        name = config["speaker_name"]
        nw = draw.textlength(name, font=name_font)
        draw.text(((W - nw) / 2, bbox[3] + 32), name, font=name_font, fill=(225, 219, 212))

    canvas_rgb.save(config["output_path"], quality=96)
    print(f"Saved: {config['output_path']}")

    # ALWAYS check the actual grid crop and thumbnail, not just full res
    grid_crop = canvas_rgb.crop(GRID_CROP_BOX)
    grid_path = config["output_path"].replace(".jpg", "-grid-crop.jpg")
    grid_crop.save(grid_path, quality=94)
    thumb_path = config["output_path"].replace(".jpg", "-grid-thumbnail.jpg")
    grid_crop.resize(GRID_THUMBNAIL_SIZE).save(thumb_path, quality=90)
    print(f"Saved grid-crop check: {grid_path}")
    print(f"Saved grid-thumbnail check: {thumb_path} -- LOOK AT THIS before calling it done")


if __name__ == "__main__":
    render()

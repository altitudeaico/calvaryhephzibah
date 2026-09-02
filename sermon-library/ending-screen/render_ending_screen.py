#!/usr/bin/env python3
"""
Calvary sermon reel ending screen — reusable template.

Locked from the "He Never Fails" build (30 Aug 2026, Bishop Henry Emmanuel)
after several rounds of real feedback. Change ONLY the values in CONFIG below
for a new sermon — the rendering logic should not need to change.

Usage:
    python3 render_ending_screen.py

Requires:
    - Pillow (PIL)
    - A source still: a real frame from the sermon video, NOT a designed
      thumbnail. Pick the sharpest available frame of a clear, expressive
      moment (see "Source still selection" below).
    - The Calvary logo, generated via the calvary-logo skill
      (`calvary-logo-roundel-transparent.png`) — never hand-recreate the logo.
    - House fonts: Anton (display) and Inter Tight (body/UI).

═══════════════════════════════════════════════════════════════════════════
DESIGN RULES LOCKED BY THIS TEMPLATE (do not drift without new sign-off)
═══════════════════════════════════════════════════════════════════════════

1. PORTRAIT — soft photographic blend, not a hard cutout.
   Hard background-removal (rembg etc.) was tried repeatedly and kept failing:
   lost arms, rectangular equipment patches left behind, narrow silhouettes
   that clipped his jacket/shoulders. The fix that actually worked is a
   *feathered photographic crop*: take a generous rectangular crop around him
   (keeping some real background), then blend its edges into the canvas
   background with a soft alpha falloff. No cutout, no edge artifacts.

   The single detail that matters most here: size the fully-opaque core
   LARGE relative to the blur radius, so his face and torso sit at a true
   flat 255-alpha plateau with NO blur bleed into the centre. A core that's
   too small relative to the blur under-brightens his face — this happened
   once and had to be fixed. Verify with a pixel check before rendering the
   full composite:
       alpha_at_his_face_center should read 255, not "roughly high".

2. TITLE — three-line stack, last line is the accent word/phrase.
   Two short lines in warm white (Anton), then the accent line larger, with
   a vertical gradient (bright red → deep red), a dark contrasting edge
   (stroke), and a short firm drop shadow for real depth. This gradient/
   stroke/shadow combination is the one piece of treatment that's been
   explicitly praised twice — do not simplify it back to flat colour.

3. LOGO — sits just above the title, inside the main composition.
   Not a separate top-of-canvas element. It's part of "the shot" — same
   visual group as the title block, not header furniture. Always generate
   via the calvary-logo skill's script (transparent roundel variant); never
   hand-composite the raw eagle asset (it has a red disc baked in — see that
   skill for why).

4. CTA — a real design element, not footer text.
   A solid red block with its own dedicated vertical space, comfortably
   clear of the bottom edge (~150-180px margin). Two lines:
     - "WATCH THE FULL VIDEO ON YOUTUBE" (or equivalent) — large, Anton, warm
       white, can wrap to two lines.
     - The channel-search line — this is NOT secondary. It's the actual next
       action, and needs to be large, warm white, bold, with a thin
       contrasting stroke — not small dark text on the red background. That
       was tried and was illegible at phone size.

5. PALETTE — near-black charcoal base, subtle burgundy glow behind the
   portrait, fine grain across the whole canvas. Keep the glow subtle: it
   should read as depth/mood, not colour the whole image warm/brown.

6. ALWAYS CHECK AT PHONE SIZE before calling a render finished. Resize the
   export to roughly 240×427 and view it — text that reads fine at full
   resolution can fail at the size it's actually going to be seen.

═══════════════════════════════════════════════════════════════════════════
SOURCE STILL SELECTION
═══════════════════════════════════════════════════════════════════════════

Before picking a frame, compare candidates on TWO axes, not just expression:

  - Sharpness: use a focus metric (Laplacian variance over the face region)
    to compare candidates objectively, not just by eye.
        cv2.Laplacian(face_crop, cv2.CV_64F).var()
    Higher is sharper. A frame that "looks fine" at a glance can score much
    lower than a nearby alternative.
  - Ease of background removal / blending: prefer a frame where he's
    positioned against simpler background (a plain wall or banner section)
    rather than in front of complex equipment (drum kits, cables, stands).
    This matters even for the feathered-blend approach — a simpler
    background blends more convincingly.

A frame that's both sharp AND simply-backgrounded beats one that's merely
sharp. Extract several candidates spanning different moments, screen them as
a contact sheet, then verify the top 2-3 individually at full resolution.
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import numpy as np

# ═══════════════════════════════════════════════════════════════════════
# CONFIG — change these per sermon. Nothing below this block should need
# to change for a routine new-sermon render.
# ═══════════════════════════════════════════════════════════════════════

CONFIG = {
    # Source still: a real frame from the sermon video (not a designed thumbnail)
    "source_still": "source_still.jpg",
    # Crop box (left, top, right, bottom) around him in the source still —
    # generous, chest-up, keeping some real background around the edges
    "portrait_crop": (155, 155, 580, 620),

    # Title: first two lines in warm white, LAST line is the gradient accent
    "title_lines": ["HE NEVER", "FAILS"],

    "speaker_name": "Bishop Henry Emmanuel",
    "speaker_label": "CALVARY HEPHZIBAH \u00b7 GUEST MINISTER",  # verify before use

    "cta_line_1": ["WATCH THE FULL VIDEO", "ON YOUTUBE"],
    "cta_line_2": "SEARCH: CALVARY HEPHZIBAH",

    "output_path": "ending_screen_output.jpg",

    # Font paths (house fonts, shouldn't need to change)
    "font_anton": "/home/claude/calvaryhephzibah/anniversary/overlays/fonts/anton-400.ttf",
    "font_inter_medium": "/home/claude/calvaryhephzibah/anniversary/overlays/fonts/inter-tight-500.ttf",
    "logo_path": "logo/calvary-logo-roundel-transparent.png",  # generate via calvary-logo skill first
}

# Palette (locked)
WARM_WHITE = (248, 242, 233)
RED_BRIGHT = (214, 58, 48)
RED_DEEP = (120, 24, 24)
W, H = 1080, 1920


def build_background(seed=11):
    """Charcoal base, subtle burgundy glow behind where the portrait sits, fine grain."""
    import random
    bg = Image.new("RGB", (W, H), (15, 14, 15))
    draw = ImageDraw.Draw(bg)
    for y in range(H):
        t = y / H
        base = 14 + 6 * (1 - abs(t - 0.4) * 1.3)
        base = max(9, min(21, base))
        draw.line([(0, y), (W, y)], fill=(int(base), int(base * 0.95), int(base * 0.97)))
    glow = Image.new("L", (W, H), 0)
    gd = ImageDraw.Draw(glow)
    gd.ellipse([W // 2 - 560, 120, W // 2 + 560, 1150], fill=42)
    glow = glow.filter(ImageFilter.GaussianBlur(180))
    burgundy = Image.new("RGB", (W, H), (120, 32, 30))
    bg = Image.composite(burgundy, bg, glow)
    random.seed(seed)
    grain = Image.new("L", (W, H))
    gpix = grain.load()
    for y in range(H):
        for x in range(W):
            gpix[x, y] = random.randint(112, 128)
    grain_rgba = Image.merge("RGBA", (grain, grain, grain, Image.new("L", (W, H), 7)))
    return Image.alpha_composite(bg.convert("RGBA"), grain_rgba).convert("RGB")


def build_feathered_portrait(source_path, crop_box):
    """
    Soft photographic blend -- NOT a hard cutout. See module docstring rule 1.
    Core must be large relative to blur radius so his face plateaus at true
    255 alpha; verify before trusting the render.
    """
    photo = Image.open(source_path).convert("RGB").crop(crop_box)
    w, h = photo.size

    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).ellipse([-w * 0.15, -h * 0.15, w * 1.15, h * 1.05], fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(65))
    mask_arr = np.array(mask).astype(np.float32)
    mask_arr[:8, :] = 0; mask_arr[-8:, :] = 0
    mask_arr[:, :8] = 0; mask_arr[:, -8:] = 0
    mask = Image.fromarray(mask_arr.astype("uint8")).filter(ImageFilter.GaussianBlur(6))

    mask_norm = np.array(mask).astype(np.float32) / 255.0
    photo_arr = np.array(photo).astype(np.float32)
    darkened = photo_arr * (0.25 + 0.75 * mask_norm[..., None])
    photo_blended = Image.fromarray(np.clip(darkened, 0, 255).astype("uint8"))

    rgba = photo_blended.convert("RGBA")
    rgba.putalpha(mask)

    # sanity check -- fail loudly rather than silently ship a dark face
    face_alpha = np.array(mask)[int(h * 0.35), int(w * 0.5)]
    if face_alpha < 250:
        print(f"WARNING: face-region alpha is {face_alpha}, not ~255 -- "
              f"his face/torso will look darkened. Increase core size or "
              f"reduce blur radius before rendering the final composite.")
    return rgba


def render(config=CONFIG):
    canvas = build_background().convert("RGBA")

    portrait = build_feathered_portrait(config["source_still"], config["portrait_crop"])
    target_w = 920
    scale = target_w / portrait.width
    port = portrait.resize((target_w, int(portrait.height * scale)), Image.LANCZOS)
    ppx = (W - port.width) // 2
    ppy = 130
    canvas.alpha_composite(port, (ppx, ppy))
    canvas_rgb = canvas.convert("RGB")

    # Logo -- inside the main shot, just above the title (rule 3)
    logo = Image.open(config["logo_path"]).convert("RGBA")
    logo_size = 92
    logo_small = logo.resize((logo_size, logo_size), Image.LANCZOS)
    logo_y = 800
    canvas_rgba = canvas_rgb.convert("RGBA")
    canvas_rgba.alpha_composite(logo_small, (W // 2 - logo_size // 2, logo_y))
    canvas_rgb = canvas_rgba.convert("RGB")
    draw = ImageDraw.Draw(canvas_rgb)

    # Title -- first line(s) warm white
    font_anton = config["font_anton"]
    line1_font = ImageFont.truetype(font_anton, 96)
    line1 = config["title_lines"][0]
    l1w = draw.textlength(line1, font=line1_font)
    l1_y = 915
    sh1 = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(sh1).text(((W - l1w) / 2 + 5, l1_y + 7), line1, font=line1_font, fill=(0, 0, 0, 180))
    sh1 = sh1.filter(ImageFilter.GaussianBlur(3))
    canvas_rgb = Image.alpha_composite(canvas_rgb.convert("RGBA"), sh1).convert("RGB")
    draw = ImageDraw.Draw(canvas_rgb)
    draw.text(((W - l1w) / 2, l1_y), line1, font=line1_font, fill=WARM_WHITE, stroke_width=3, stroke_fill=(10, 8, 8))

    # Accent line -- gradient + edge + shadow (rule 2, the praised treatment)
    fails_font = ImageFont.truetype(font_anton, 190)
    fails_text = config["title_lines"][-1]
    fw = draw.textlength(fails_text, font=fails_font)
    fx = (W - fw) / 2
    fy = 1025

    probe = Image.new("L", (W, H), 0)
    ImageDraw.Draw(probe).text((fx, fy), fails_text, font=fails_font, fill=255)
    bbox = probe.getbbox()

    shadow_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow_layer).text((fx + 8, fy + 11), fails_text, font=fails_font, fill=(0, 0, 0, 190))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(3))
    canvas_rgb = Image.alpha_composite(canvas_rgb.convert("RGBA"), shadow_layer).convert("RGB")

    edge_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(edge_layer).text((fx, fy), fails_text, font=fails_font, fill=(8, 6, 6, 255),
                                     stroke_width=6, stroke_fill=(8, 6, 6, 255))
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

    # Name + label
    font_inter_m = config["font_inter_medium"]
    name_font = ImageFont.truetype(font_inter_m, 38)
    name = config["speaker_name"]
    nw = draw.textlength(name, font=name_font)
    name_y = bbox[3] + 30
    draw.text(((W - nw) / 2, name_y), name, font=name_font, fill=(220, 214, 207))

    label_font = ImageFont.truetype(config["font_inter_medium"], 24)
    label = config["speaker_label"]
    lw = draw.textlength(label, font=label_font)
    draw.text(((W - lw) / 2, name_y + 56), label, font=label_font, fill=(190, 110, 95))

    # CTA block -- real design weight, not footer text (rule 4)
    cta_top, cta_bottom = 1470, 1740
    draw.rectangle([70, cta_top, W - 70, cta_bottom], fill=RED_BRIGHT)
    draw.rectangle([70, cta_top, W - 70, cta_top + 6], fill=(120, 24, 24))

    cta1_font = ImageFont.truetype(font_anton, 52)
    y = cta_top + 55
    for line in config["cta_line_1"]:
        lw2 = draw.textlength(line, font=cta1_font)
        draw.text(((W - lw2) / 2, y), line, font=cta1_font, fill=WARM_WHITE)
        y += 62

    cta2_font = ImageFont.truetype(font_anton, 42)
    cta2 = config["cta_line_2"]
    c2w = draw.textlength(cta2, font=cta2_font)
    draw.text(((W - c2w) / 2, cta_top + 198), cta2, font=cta2_font, fill=WARM_WHITE,
               stroke_width=2, stroke_fill=(120, 20, 18))

    canvas_rgb.save(config["output_path"], quality=96)
    print(f"Saved: {config['output_path']}")

    # Always produce the phone-size check alongside the full render (rule 6)
    phone_path = config["output_path"].replace(".jpg", "-phonesize.jpg")
    canvas_rgb.resize((240, 427)).save(phone_path, quality=92)
    print(f"Saved phone check: {phone_path}")


if __name__ == "__main__":
    render()

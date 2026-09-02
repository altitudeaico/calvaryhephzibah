"""
Shared portrait-blend logic for Calvary sermon ending-screen / cover templates.

Used by render_ending_screen.py, ig/render_ig_cover.py, and
ig/render_ig_ending_screen.py — all three MUST use this shared function
rather than their own copy, so a fix here fixes all three at once. This
module exists because of a real bug found across two rounds of feedback:
duplicated mask logic drifted, and the same edge-blending flaw shipped in
multiple places before being traced to its root cause.

THE CORE TECHNIQUE (soft photographic blend, not a hard cutout):
Background-removal models (rembg etc.) were tried repeatedly for this
speaker's footage and kept failing — lost arms, rectangular equipment
patches left behind, narrow silhouettes clipping his jacket. The reliable
alternative: take a generous rectangular crop with real background still in
it, then blend it into the canvas using two SEPARATE masks:

  1. `brightness_mask` — tight around just his face/torso. Everything
     outside this core gets genuinely darkened, even while still fully
     opaque. This is what keeps stage equipment subdued rather than
     exposed. Do NOT tie this to the same mask as alpha/transparency — that
     was tried and brightening his face also brightened the background.

  2. `alpha_mask` — controls the fade into the page background. Built from
     a smoothstep function of each pixel's elliptical distance from a
     centre point, NOT from a blurred shape. A blurred-ellipse mask can run
     out of room at the crop's own edges (no image data beyond the crop for
     the blur to fade into), leaving a harder edge on whichever side has
     the least margin — this shipped as an approved design before someone
     caught the straight top edge on a later review. The distance-based
     mask must have its `outer` threshold tuned so alpha genuinely reaches
     0 within the crop's own bounds — verify with the check at the bottom
     of `build_feathered_portrait`, don't assume it from the shape alone.
"""

from PIL import Image, ImageDraw, ImageFilter
import numpy as np


def build_feathered_portrait(
    source_path,
    crop_box,
    bright_core_box_frac=(0.15, 0.02, 0.85, 0.62),  # (l,t,r,b) as fraction of crop, face/torso only
    bright_blur=85,
    bright_floor=0.10,
    alpha_center_frac=(0.5, 0.42),   # (cx, cy) as fraction of crop
    alpha_radii_frac=(0.50, 0.46),   # (rx, ry) as fraction of crop
    alpha_inner=0.50,
    alpha_outer=0.88,
    alpha_blur=10,
):
    """
    Returns an RGBA image: a photographic crop with (a) the background
    darkened relative to his face/torso, and (b) a smooth, guaranteed-zero-
    at-the-edges alpha falloff for blending into a page background.

    Defaults are the values locked from the "He Never Fails" build after
    several corrected rounds — change only if a new source photo's
    proportions genuinely require it, and re-verify with the printed
    diagnostics before trusting the result.
    """
    photo = Image.open(source_path).convert("RGB").crop(crop_box)
    w, h = photo.size

    # --- Brightness mask: tight core, wide falloff ---
    l, t, r, b = bright_core_box_frac
    bright_core = Image.new("L", (w, h), 0)
    ImageDraw.Draw(bright_core).ellipse([w*l, h*t, w*r, h*b], fill=255)
    bright_mask = bright_core.filter(ImageFilter.GaussianBlur(bright_blur))
    bright_norm = np.array(bright_mask).astype(np.float32) / 255.0

    photo_arr = np.array(photo).astype(np.float32)
    darkened = photo_arr * (bright_floor + (1 - bright_floor) * bright_norm[..., None])
    photo_dark = np.clip(darkened, 0, 255).astype("uint8")

    # --- Alpha mask: distance-based falloff, guaranteed zero at crop edges ---
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    cx, cy = w * alpha_center_frac[0], h * alpha_center_frac[1]
    nx = (xx - cx) / (w * alpha_radii_frac[0])
    ny = (yy - cy) / (h * alpha_radii_frac[1])
    dist = np.sqrt(nx**2 + ny**2)
    tt = np.clip((dist - alpha_inner) / (alpha_outer - alpha_inner), 0, 1)
    alpha_norm = 1.0 - (tt * tt * (3 - 2 * tt))  # smoothstep
    alpha_mask = Image.fromarray((alpha_norm * 255).astype("uint8")).filter(
        ImageFilter.GaussianBlur(alpha_blur)
    )

    rgba = Image.fromarray(photo_dark).convert("RGBA")
    rgba.putalpha(alpha_mask)

    # --- Diagnostics: fail loudly, don't ship a silently-broken blend ---
    a = np.array(alpha_mask)
    edge_max = max(a[0, w // 2], a[-1, w // 2], a[h // 2, 0], a[h // 2, -1])
    if edge_max > 15:
        print(f"WARNING: alpha at crop edge midpoints peaks at {edge_max}, not ~0 -- "
              f"a straight boundary will likely be visible. Tighten alpha_outer.")
    face_bright = bright_floor + (1 - bright_floor) * bright_norm[int(h * 0.30), int(w * 0.5)]
    if face_bright < 0.70:
        print(f"WARNING: face-region brightness multiplier is {face_bright:.2f}, not close "
              f"to 1.0 -- his face/torso will look darkened. Shrink bright_core_box_frac "
              f"or reduce bright_blur.")

    return rgba

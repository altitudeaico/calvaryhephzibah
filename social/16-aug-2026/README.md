# Social pack — Sunday 16 August 2026

**Sermon:** Altars and the Believer's Victory · The Altars Series, part 3
**Preacher:** Dr Titi Sodipo (Guest Minister)
**Full sermon:** https://youtu.be/7IoC5ERT6tA

5 posts ready, 1 held back. Reel · carousel · reel · carousel · reel.

---

## 1. Get it into the repo

This session cannot push (the git-proxy blocker is still open). Unzip into your local clone
and push from there:

```bash
cd ~/Projects/calvaryhephzibah
git pull
unzip ~/Downloads/calvary-social-pack-16-aug-2026.zip
git add social/16-aug-2026 series/altars
git -c commit.gpgsign=false commit -m "16 Aug 2026: Add social pack — Altars and the Believer's Victory (Dr Titi Sodipo)"
git push origin main
```

Then confirm it actually landed, rather than trusting "committed":

```bash
git ls-remote origin refs/heads/main
```

Pages rebuilds in 30–60 seconds. The page is at:
`https://calvaryhephzibah.co.uk/social/16-aug-2026/`

It carries `noindex,nofollow` — it holds unpublished content and internal notes. Leave that
in place.

## 2. No Supabase SQL this week

Nothing new to run. The `social_posts` table (schema 55) already exists and the ALTARS series
images went in on schema 40. Ticking "Posted" on the page writes straight to Supabase.

## 3. What is in the pack

### Postable

| # | Format | Title | Invite |
|---|---|---|---|
| 1 | Reel · 64s | The charge against you was nailed there | Yes |
| 2 | Carousel · 9 | Faith is not denial | |
| 3 | Reel · 64s | Overwhelming victory — Romans 8:36-37 | |
| 4 | Carousel · 8 | Make allowance | |
| 5 | Reel · 83s | Fight from the victory, not for it | |

Invite rotation is one in five, on post 1. Guilt and a private list of wrongs is where
"come as you are" earns its place.

### Held back

**The flu testimony.** Not cut, deliberately. It resolves in healing, and as a
stranger-facing Reel it reads as "resist hard enough and the illness lifts." The audience
we are trying to reach includes people who have prayed exactly that and are still ill. It
is in `posts.json` with `captions: null` so the decision stays visible and reversible. If
you want it out, Stories or the members feed, not the public grid.

Also left out: the **evil altars** section. Strong teaching in the room, but patterns of
illness before exams and girls who cannot marry ask a sceptical newcomer to accept far too
much on turn one.

## 4. Posting

Follow `sermon-clip-captions/references/publishing.md` before any write to GHL. The traps
that bite:

- Location is always `ufTeOHywYxLPaG9TDWPG`. Never omit it.
- Post type lives in a nested block and the field is `type`, not `postType`. Wrong name
  returns 201 and is silently ignored.
- `scheduleDate` is **UTC**. Subtract an hour from BST or it lands early.
- Draft by default. Publish only when you say so for that specific post.

**Post 5 runs 83 seconds.** That clears Facebook's 90-second Reels cap with seven seconds
spare. Do not let anything re-trim or pad it. Instagram, TikTok and YouTube have no issue.

Known from last week and likely to recur: GHL cannot post image carousels to TikTok, and
TikTok rejects media from an unverified domain, so the reels may need posting there by
hand. Facebook page tokens were expired on 9 Aug — worth reconnecting the pages in Social
Planner before you start.

## 5. Where the footage came from, and what to fix

The three exports were **1920×1080 Zoom-room recordings** at roughly 2 Mbps, not vertical,
with the "Calvary Hephzibah F.G. Church" name label burned into the bottom-left. Each clip
was therefore cropped below the label, reframed to 9:16, upscaled to 1080×1920 and graded
with `Film_Look__1_.cube` before the normal finish.

That LUT inspects as a **creative-look** LUT (it lifts black to 0.089), correctly matched to
Rec709 footage. No log decode needed.

The Romans 8 clip needed an **animated crop**: the room camera is still settling for the
first eight seconds and then drifts steadily right, so a fixed crop loses her entirely. The
crop catches up over 8 seconds then pans at about 8.8 px/sec.

**The quality ceiling is real.** Cropped and upscaled Zoom footage is watchable but soft.
A camera closer to the lectern — the Tenveo PTZ, framed tight — fixes this at source and
would lift every clip from here on.

## 6. Audio

Voice arrived at **-36 to -37 LUFS**, the quietest batch so far. High-passed at 90 Hz,
compressed, then `loudnorm` to -14. Beds sit -9dB under, lifting 4.5 dB when the voice
stops so the closing carries. No sidechain ducking.

Beds are the levelled `felt-and-faith-a/b.mp3` from the 9 August week — the page links to
them in place rather than duplicating 6 MB. They are Kingdom-series beds, not
Altars-specific. Say if you want fresh Suno beds for the series and I will generate and
level a pair.

## 7. New files added to `series/altars/`

| File | What it is |
|---|---|
| `closing/a4-disarmed.json` | Closing spec for the Colossians 2 clip. `a1-enforcers` and `a2-overwhelming-victory` already existed and mapped onto the other two clips exactly. |
| `carousels/c6-faith-not-denial.json` | The jumbo jet carousel |
| `carousels/c7-make-allowance.json` | The Colossians 3:13 carousel |
| `episodes/endcard-a-16-aug.png` | Episode end-card screen |
| `episodes/endcard-b-16-aug.png` | Series end-card screen |

The end-card renderer expects a portrait with alpha, and only the flat
`preachers/titi-sodipo.jpg` is in the repo. I keyed the black background off it to build the
cutout. **Worth saving a proper transparent PNG of her portrait into `preachers/`** so the
next episode does not repeat that step.

## 8. Two things to confirm

- **Dr Titi Sodipo** — the auto-transcript renders it "Shodiko". The repo spelling is used
  throughout. Confirm it is right, since it is on every caption and both end cards.
- **The unclipped material.** All three of your clips came from the same five minutes of a
  fifty-minute message. If you can pull OpusClip exports of the **jumbo jet** section and
  **"whatsoever you do not resist, you are permitting"**, next week's pack gets a stronger
  spine than carousels alone can carry.

A corrected sermon extract sits in this folder as
`sermon-extract-16-aug-2026.md`, with a table of every transcript garble that was fixed.

# Weekly social packs

One folder per Sunday. Each is a self-contained preview page: every post
simulated as it will look, its caption per platform, and a tick box that
remembers what has gone out.

```
social/
  <dd-mmm-yyyy>/
    index.html      the preview page
    posts.json      the posts, captions, care flags
    clips/          compressed preview MP4s (540px, ~0.6MB each)
    carousel/       rendered slides, 1080x1350
    endcard-*.jpg   1080x1920 end card
    *.mp3           levelled music beds
```

Live at `calvaryhephzibah.co.uk/social/<week>/`

## Building next week's

1. Copy the most recent week's folder and rename it.
2. Replace `clips/`, `carousel/`, the end card and the beds.
3. Rewrite `posts.json`. That file is the whole content layer, the page
   reads it and needs no other edit.
4. Change `WEEK` in the script block of `index.html` to the new folder name.
   Posted status is keyed on it, so forgetting this makes the new week
   inherit last week's ticks.

Compress clips before committing. Raw OpusClip exports run 12 to 30 MB each
and this repo takes a new set weekly:

```
ffmpeg -i in.mp4 -vf scale=540:-2 -c:v libx264 -crf 30 -preset veryfast \
       -c:a aac -b:a 96k -movflags +faststart out.mp4
```

## posts.json

Each post takes `id`, `format` (`reel` or `carousel`), `title`, `rank`,
`invite`, `care`, `quote`, `onscreen`, and `captions` for the four platforms.
Reels also take `asset` and `duration`; carousels take `slug` and `slides`.

Two conventions worth keeping:

- **`captions: null` means do not post.** The card still renders so the
  decision is visible and reversible, but it shows no caption and does not
  count toward the total.
- **`care`** puts a red-bordered flag on the card. Use it for member-facing
  clips, anything involving an identifiable person, and tender subjects.
  Rank 99 sorts a post to the bottom.

Invite rotation is roughly one post in four, tracked by the `invite` flag.

## Posted status

Stored in Supabase `social_posts`, keyed on `(week, post_id)`, so state is
shared across devices and people. Run `control-room/schema/55_social_posts.sql`
once. Until then the page falls back to browser storage and says so.

## The pages are noindex

These carry unpublished content and internal notes. Every page keeps
`<meta name="robots" content="noindex,nofollow">`. Do not remove it to chase a
WhatsApp preview.

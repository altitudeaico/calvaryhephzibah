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

## Finishing the clips

OpusClip exports come out quiet. Measured on 9 Aug: **-29.3 LUFS**, where social
platforms target about -14. They also have no music and no end card. The
finishing pass does all three in one ffmpeg call per clip:

```
ffmpeg -i clip.mp4 -loop 1 -t 3 -i endcard.jpg -ss OFFSET -i bed.mp3 \
 -filter_complex "\
[0:v]scale=1080:1920,fps=25,setsar=1[v0];\
[1:v]scale=1080:1920,fps=25,setsar=1,format=yuv420p,fade=t=in:st=0:d=0.4[v1];\
[v0][v1]concat=n=2:v=1:a=0[v];\
[0:a]highpass=f=90,acompressor=threshold=-22dB:ratio=3.5:attack=8:release=180,\
loudnorm=I=-14:TP=-1.5:LRA=11,apad=pad_dur=3.2[a0];\
[2:a]volume=-15dB,afade=t=in:st=0:d=1.2,afade=t=out:st=FADEOUT:d=1.6[a1];\
[a0][a1]amix=inputs=2:duration=first:dropout_transition=0:normalize=0,\
atrim=0:TOTAL,alimiter=limit=0.97[a]" \
 -map "[v]" -map "[a]" -c:v libx264 -crf 21 -preset veryfast -pix_fmt yuv420p \
 -c:a aac -b:a 192k -ar 48000 -movflags +faststart out.mp4
```

`TOTAL` is clip duration plus 3, `FADEOUT` is `TOTAL - 1.6`, `OFFSET` varies per
clip so they do not all use the same passage of the bed.

Three things in there matter and should not be changed casually:

- **`normalize=0` on amix.** Without it ffmpeg halves both inputs and the voice
  ends up quieter than it started.
- **`volume=-15dB` on the bed.** The beds sit at -20.4 LUFS, so this puts them
  about 20 dB under a -14 LUFS voice. Felt, not heard.
- **No sidechain ducking.** The music holds one level throughout by design. A
  ducker makes it pump under the speech, which is exactly the wavering the beds
  were levelled to remove.

Alternate Bed A and Bed B across the set so a run of posts does not sound
identical. Both are levelled to the same median, so they can sit side by side.

**Finished full-quality clips are not committed.** At 4 to 9 MB each they add up
fast on a weekly repo. Only the 540px previews live here. Keep the finals in
Drive.

Compress previews before committing. Raw OpusClip exports run 12 to 30 MB each
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

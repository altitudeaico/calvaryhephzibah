# Music beds

Background music for clips, trailers and overlays. Everything in here is
either generated in-house (Suno) or owned outright. **Do not add licensed or
stock music to this folder** — the repo is public, so committing a licensed
track republishes it, which almost no licence permits. Licensed audio goes in
Supabase Storage or Drive, with only a pointer kept here.

## Beds

### `bed-beneath-the-same-sky.mp3`
| | |
|---|---|
| Source | Suno (generated 3 August 2026, id `30ab5728…`) |
| Supplied by | Bolaji Olatoye |
| Length | 118.5s · 48kHz stereo · 196kbps |
| Loudness | -13.54 LUFS · -0.14 dBTP · LRA 10.1 |
| **Has vocals** | **Yes** — see the map below |
| First used | ALTARS clip beds, "Family Altar", 2 August 2026 |

**Vocal map** — matters because a sung vocal under a preaching clip fights the
preacher. Measured by syllabic-rate modulation in the centre channel:

| Section | Content |
|---|---|
| 0:00 – 0:28 | **instrumental** |
| 0:28 – 1:04 | vocals |
| 1:04 – 1:08 | break |
| 1:08 – 1:28 | vocals |
| 1:28 – 1:44 | **instrumental** |
| 1:44 – end | vocals |

The 28-second instrumental intro is the usable window for speech beds. Longer
than that under a talking clip and you get two voices at once.

### `bed-beneath-the-same-sky-flat.mp3`
Derived from the above. The original swings 23dB between its quiet and loud
passages, which reads as the music "fluctuating" under speech even with no
ducking applied. This version is compressed and levelled to a 5.6dB spread at
-23 LUFS, so it can be dropped under a clip at a single static gain with no
envelope, no sidechain and no swell.

```
equalizer=f=400:t=q:w=1.1:g=-4,
acompressor=threshold=0.125:ratio=9:attack=80:release=500,
dynaudnorm=f=75:g=3:p=0.97:m=20:s=0,
acompressor=threshold=0.2:ratio=4:attack=50:release=300,
loudnorm=I=-23:TP=-3:LRA=2
```

Use this one for clip beds. Use the original only where the music is the
foreground and its dynamics are wanted.

The track is bass-heavy (48% of its energy below 200Hz), so under speech it
takes a dip around 400Hz to keep the low-mids clear of a female speaking voice.

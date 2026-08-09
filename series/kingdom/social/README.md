# Enter Into The Kingdom — social assets

Sunday 9 August 2026 · Rev Ifeayinchukwu Obi · guest minister

## What's here

| Path | What it is |
|---|---|
| `endcards/endcard-09-aug-2026.jpg` | 1080x1920 end card. Append 2.5 to 3 sec to the tail of every vertical clip. |
| `music/felt-and-faith-a.mp3` | Music bed A, 2:08, levelled |
| `music/felt-and-faith-b.mp3` | Music bed B, 2:08, levelled |
| `../carousels/*.json` | Carousel specs |
| `../out/*.png` | Rendered carousel slides, 1080x1350 |

Rebuild the end card with `python3 series/kingdom/render_endcard.py <out.jpg>`.

## The music beds

Source: two Suno generations of the same prompt, "Felt and Faith".

**Both have been levelled deliberately.** The raw generations wandered by
15.4 LU and 12.9 LU respectively, which under speech means the bed swells over
the preacher in one sentence and disappears in the next. They have been through
two stages of compression, a limiter, and a loudness normalise to a fixed
target.

| | Raw spread | Levelled spread | Median |
|---|---|---|---|
| Bed A | 15.4 LU | **3.7 LU** | -20.4 LUFS |
| Bed B | 12.9 LU | **2.9 LU** | -20.4 LUFS |

Both now sit at the same median, so they are **interchangeable across a set of
posts without the volume jumping** between clips. The intro ramp and outro fade
were trimmed off, so both start and end in the settled part of the track.

**Mixing under speech.** Bring the bed in around 18 to 22 dB below the
preacher's voice. It should be felt, not heard. If a viewer notices the music,
it is too loud. Do not add further compression; that work is done.

## Care flags on this set

- **Clip 7 (making a difference in church)** is member-facing. It talks about
  the worship leader and about the congregation carrying the Spirit. Lead any
  caption on the half that includes an outsider, and soften the in-group beat
  so a stranger is not told they are outside.
- **Clip 6 (Matthew 6:33)** is mostly the preacher asking someone to read aloud,
  and the audio ends on a buzzer. Weakest of the seven. Recommend not posting.

## Still unresolved

The preacher's name is spelled **Ifeayinchukwu** on the end card, the sermon
thumbnail and the run sheet. It has also appeared as **Ifeanyichukwu**
(21 June 2026). Confirm before this spreads further.

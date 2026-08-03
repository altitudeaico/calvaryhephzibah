# ALTARS — series assets

Visual identity for the ALTARS sermon series (Calvary Hephzibah Full Gospel Church).

Series line: *There are altars and there are altars.* — Pastor Shade Olatoye

## Contents

| File | What it is |
|---|---|
| `altars-master.png` | The locked object. Every other asset derives from this. |
| `altars-key-art-16x9.png` | Landscape title lockup |
| `altars-landscape-still.png` / `.mp4` | Landscape card, static and animated |
| `altars-series-card-9x16.png` / `.mp4` | Vertical / story card, static and animated |
| `altars-thumbnail-1280x720.jpg` | YouTube thumbnail |
| `plates/` | Google Flow start frames for the trailer scenes |
| `episodes/` | Per-week episode thumbnails built on the master plate |
| `family-altar-endcard-9x16.mp4` / `-endcard-a-9x16.png` | 4.6s two-screen clip tail for the 2 Aug episode: episode screen then series screen |
| `render_altars_endcard_9x16.py` | Builds both 9x16 end-card screens. The master plate is landscape, so it is laid in as a feathered full-width BAND rather than cropped to 9:16, which would bin the stone pile |
| `render_altars_short.py` + `shorts/*.json` | Builds 9x16 themed teaching shorts: type over the clean plates with a slow push, cross-faded, music bed, series end screen. Content is spec'd in JSON so a new one is a small file, not new code |
| `short-endcard-9x16.png` | End screen for the themed shorts. Credits the sermon as the SOURCE, because the words in those videos are the church's, not the preacher's |
| `render_altars_carousel.py` + `carousels/*.json` | 1080x1350 carousel slides. Blocks are measured from their ink boxes and the stack is centred as a unit, so slides of four words and slides of a full paragraph both sit right without a fixed grid |
| `render_altars_episode.py` | Builds an episode thumbnail: master plate + scrim, red series badge, Anton episode title, series line with the second *altars.* in red, preacher block, portrait right |

## Episodes

| Date | Episode | Preacher |
|---|---|---|
| 26 Jul 2026 | Altars | Dr Titi Sodipo |
| 2 Aug 2026 | Family Altar | Dr Titi Sodipo |

## A note on usable footage

Only three files in `plates/` are clean: `scene1-ember`, `scene2-master`,
`scene3-fire`. Everything else in this folder, including both animated cards,
has **SERMON SERIES burned into the frame** and cannot be used as background
for anything. If more b-roll is needed, it has to be generated.

## Not here yet

- **The 30s teaser trailer** — held back pending a confirmed series date and external-comms sign-off (Governance §11).
- **Episode key art** (state variants of the master: aged, meagre, collapsed, rubble). Episode thumbnails currently all use the master plate.
- **The date.**

Built with the `calvary-series-trailer` skill.

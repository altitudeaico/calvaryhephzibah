# Social reel tools (used from Sep 2026)

- build_closing.sh PREFIX d1 d2 d3 : animates cards/PREFIX1..3.png (2160x3840 upscales of ChatGPT 9:16 cards) into closing-PREFIX.mp4 with slow push-in + 0.5s crossfades.
- assemble.sh CLIP CLIPLEN CLOSING ENDCARD BED BEDOFFSET OUT : clip (voice lifted, highpass/comp/loudnorm -14) + closing + 3s end card, music bed at -6dB rising under closing, fade out.
- Beds: social/20-sep-2026/music-beds/hymn-in-motion-a.mp3 / -b.mp3 (alternate by day).

-- ============================================================
-- 63_song_lyrics_30aug2026.sql
-- ============================================================
-- Lyrics for "Beautiful One" (Tim Hughes), supplied by Bolaji,
-- formatted to the 2-line slide format. In-service display only
-- (CCLI-covered). One of three songs on the 30 August set that were
-- new to Calvary; "I Give Myself Away" and "I Surrender All to You"
-- still need lyrics -- not included in this file.
--
-- Loads into the persistent library and patches the 30 August plan.
-- Idempotent. Run in the Supabase SQL editor (project:
-- pfycvgbrsbecznkcikwt), any time after 61_setlist_30aug2026.sql.
-- ============================================================

insert into control_room_songs (title, slides, section_default, artist) values

('Beautiful One',
 '[
   {"line1":"Wonderful, so wonderful is Your unfailing love","line2":"Your cross has spoken mercy over me"},
   {"line1":"No eye has seen, no ear has heard","line2":"No heart could fully know"},
   {"line1":"How glorious, how beautiful You are","line2":""},

   {"line1":"Beautiful One, I love You","line2":"Beautiful One, I adore"},
   {"line1":"Beautiful One, my soul must sing","line2":""},

   {"line1":"Powerful, so powerful, Your glory fills the skies","line2":"Your mighty works displayed for all to see"},
   {"line1":"The beauty of Your Majesty awakes my heart to sing","line2":"How marvellous, how wonderful You are"},

   {"line1":"Beautiful One, I love You","line2":"Beautiful One, I adore"},
   {"line1":"Beautiful One, my soul must sing","line2":""},
   {"line1":"Beautiful One, I love You","line2":"Beautiful One, I adore"},
   {"line1":"Beautiful One, my soul must sing","line2":""}
 ]',
 'praise', 'Tim Hughes')

on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist,
      updated_at      = now();

-- --------------------------------------------------------------------
-- Patch 30 August plan item -- replace placeholder with real lyrics
-- --------------------------------------------------------------------

update control_room_plan_items i
set slides = s.slides
from control_room_songs s, control_room_plans p
where i.plan_id = p.id
  and p.service_date = '2026-08-30'
  and lower(i.title) = lower(s.title)
  and s.title = 'Beautiful One';

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- VERIFY -- which 30 August songs still need lyrics?
-- Expect: I Give Myself Away, I Surrender All to You (2 rows).
-- Beautiful One should no longer appear.
-- --------------------------------------------------------------------
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-30' and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

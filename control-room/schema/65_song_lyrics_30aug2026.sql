-- ============================================================
-- 65_song_lyrics_30aug2026.sql
-- ============================================================
-- Lyrics for "I Surrender All to You", supplied by Bolaji as a full
-- live-recording transcript with many repeats. Distilled to the real
-- Chorus/Vamp/Declaration structure for clean slides -- the
-- "Withholding nothing" and "I give you all of me" sections repeat
-- many more times live than encoded here; the stage card carries a
-- loop note for both.
--
-- Last of the three new songs on the 30 August set. After this file
-- runs, all five songs on the 30 August set list resolve real
-- lyrics -- none left on placeholder slides.
--
-- Loads into the persistent library and patches the 30 August plan.
-- Idempotent. Run in the Supabase SQL editor (project:
-- pfycvgbrsbecznkcikwt), any time after 61_setlist_30aug2026.sql.
-- ============================================================

insert into control_room_songs (title, slides, section_default, artist) values

('I Surrender All to You',
 '[
   {"line1":"I surrender all to you","line2":"Everything I give to you"},
   {"line1":"Withholding nothing","line2":"Withholding nothing"},

   {"line1":"Withholding nothing","line2":"Withholding nothing"},

   {"line1":"I give you all of me","line2":"I give you all of me"},
   {"line1":"King Jesus","line2":"My Savior"},
   {"line1":"Forever","line2":""},

   {"line1":"I give you all of me","line2":"I give you all of me"},
   {"line1":"King Jesus","line2":"My Savior"},
   {"line1":"Forever","line2":""},

   {"line1":"I give you all of me","line2":"I give you all of me"},

   {"line1":"I surrender all to you","line2":"Everything I give to you"},
   {"line1":"Withholding nothing","line2":"Withholding nothing"}
 ]',
 'worship', null)

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
  and s.title = 'I Surrender All to You';

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- VERIFY -- expect ZERO rows now. All five 30 August songs should
-- have real lyrics.
-- --------------------------------------------------------------------
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-30' and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

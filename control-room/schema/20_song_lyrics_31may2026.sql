-- ============================================================
-- 20_song_lyrics_31may2026.sql
-- ============================================================
-- Real lyrics for the 31 May 2026 set list, formatted for the 2-line
-- slide format used by control_room_plan_items.slides.
--
-- This batch: 10,000 Reasons (Bless the Lord) — Matt Redman.
-- (Lyrics supplied by the worship team; CCLI-covered, for in-service
-- slide display only.)
--
-- Still outstanding for 31 May after this file:
--     · Hallelujah (You Won the Victory)
--     · How Great Is Our God
--     · Give Thanks
--
-- This migration:
--   1. Upserts the song into control_room_songs (persistent library)
--      so it's available for every future Sunday.
--   2. Patches the matching item in control_room_plan_items for the
--      31 May plan, replacing placeholder slides with real lyrics.
--
-- Idempotent: safe to re-run. Library uses ON CONFLICT update; plan
-- items use targeted UPDATE on (plan_id, title).
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- ────────────────────────────────────────────────────────────────────
-- 1. SONG LIBRARY (control_room_songs) — persistent across weeks
-- ────────────────────────────────────────────────────────────────────

insert into control_room_songs (title, slides, section_default, artist) values

('10,000 Reasons',
 '[
   {"line1":"Bless the Lord, O my soul","line2":"O my soul"},
   {"line1":"Worship His holy name","line2":""},
   {"line1":"Sing like never before, O my soul","line2":"I''ll worship Your holy name"},

   {"line1":"The sun comes up,","line2":"it''s a new day dawning"},
   {"line1":"It''s time to sing Your song again","line2":""},
   {"line1":"Whatever may pass and whatever","line2":"lies before me"},
   {"line1":"Let me be singing","line2":"when the evening comes"},

   {"line1":"Bless the Lord, O my soul","line2":"O my soul"},
   {"line1":"Worship His holy name","line2":""},
   {"line1":"Sing like never before, O my soul","line2":"I''ll worship Your holy name"},

   {"line1":"You''re rich in love","line2":"and You''re slow to anger"},
   {"line1":"Your name is great","line2":"and Your heart is kind"},
   {"line1":"For all Your goodness","line2":"I will keep on singing"},
   {"line1":"10,000 reasons","line2":"for my heart to find"},

   {"line1":"Bless the Lord, O my soul","line2":"O my soul"},
   {"line1":"Worship His holy name","line2":""},
   {"line1":"Sing like never before, O my soul","line2":"I''ll worship Your holy name"},

   {"line1":"And on that day","line2":"when my strength is failing"},
   {"line1":"The end draws near","line2":"and my time has come"},
   {"line1":"Still my soul will sing","line2":"Your praise unending"},
   {"line1":"10,000 years","line2":"and then forevermore"},

   {"line1":"Bless the Lord, O my soul","line2":"O my soul"},
   {"line1":"Worship His holy name","line2":""},
   {"line1":"Sing like never before, O my soul","line2":"I''ll worship Your holy name"},

   {"line1":"O I''ll worship Your holy name","line2":"I will worship Your holy name"},
   {"line1":"Holy name","line2":""}
 ]',
 'worship', 'Matt Redman')

on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist,
      updated_at      = now();

-- ────────────────────────────────────────────────────────────────────
-- 2. Patch 31 May 2026 plan item — replace placeholder with real lyrics
-- ────────────────────────────────────────────────────────────────────

update control_room_plan_items pi
   set slides = s.slides
  from control_room_songs s
 where pi.plan_id = (select id from control_room_plans where service_date = '2026-05-31')
   and pi.kind = 'song'
   and pi.title = s.title;

-- ────────────────────────────────────────────────────────────────────
-- VERIFY
-- ────────────────────────────────────────────────────────────────────

-- The song in the library
select title, artist, section_default, jsonb_array_length(slides) as slides
  from control_room_songs
 where title = '10,000 Reasons';

-- 31 May plan items — which still need lyrics?
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides,
       case when i.slides::text like '%placeholder%' or i.slides::text like '%lyrics in library%'
            then '⚠ still needs lyrics' else '✓ real lyrics' end as state
  from control_room_plan_items i
  join control_room_plans p on p.id = i.plan_id
 where p.service_date = '2026-05-31'
   and i.kind = 'song'
 order by i.position;

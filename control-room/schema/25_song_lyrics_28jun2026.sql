-- ============================================================
-- 25_song_lyrics_28jun2026.sql
-- ============================================================
-- Real lyrics for the 28 June 2026 set list, formatted for the 2-line
-- slide format used by control_room_plan_items.slides.
-- (Lyrics supplied by the worship team; CCLI-covered, for in-service
-- slide display only.)
--
-- This batch (so far):
--     · Jesus at the Centre — Israel Houghton
--     · Awesome God, Mighty God
--     · Thank You Lord
--
-- STILL PENDING lyrics (placeholder until added here and re-run):
--     · Be Magnified — Lynn DeShazo
--   (Praise medley + Here I Am to Worship already resolve from prior
--    plans, so they are not in this file.)
--
-- This migration:
--   1. Upserts each song into control_room_songs (persistent library)
--      so it's available for every future Sunday.
--   2. Patches the matching item in control_room_plan_items for the
--      28 June plan, replacing placeholder slides with real lyrics.
--
-- Idempotent: safe to re-run. Library uses ON CONFLICT update; plan
-- items use targeted UPDATE on (plan_id, title).
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. SONG LIBRARY (control_room_songs) — persistent across weeks
-- --------------------------------------------------------------------

insert into control_room_songs (title, slides, section_default, artist) values

('Jesus at the Centre',
 '[
   {"line1":"Jesus at the center of it all","line2":"Jesus at the center of it all"},
   {"line1":"From beginning to the end","line2":"It will always be, it''s always been"},
   {"line1":"You, Jesus","line2":"Jesus"},

   {"line1":"Nothing else matters","line2":"Nothing in this world will do"},
   {"line1":"Jesus, You''re the center","line2":"And everything revolves around You"},
   {"line1":"Jesus, You","line2":""},

   {"line1":"Jesus, be the center of my life","line2":"Jesus, be the center of my life"},
   {"line1":"From beginning to the end","line2":"It will always be, it''s always been"},
   {"line1":"You, Jesus","line2":"Oh, Jesus"},

   {"line1":"From my heart to the Heavens","line2":"Jesus, be the center"},
   {"line1":"It''s all about You","line2":"Yes, it''s all about You"}
 ]',
 'worship', 'Israel Houghton'),

('Awesome God, Mighty God',
 '[
   {"line1":"Awesome God, Mighty God,","line2":"we give You praise"},
   {"line1":"Awesome God, we give You praise,","line2":"Mighty God"},

   {"line1":"You are high and lifted up,","line2":"Awesome God"},
   {"line1":"You are high and lifted up,","line2":"Mighty God"}
 ]',
 'offering', null),

('Thank You Lord',
 '[
   {"line1":"Thank You Lord, thank You Lord,","line2":"thank You Lord"},
   {"line1":"I just want to thank You Lord","line2":""}
 ]',
 'end', null)

on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist,
      updated_at      = now();

-- --------------------------------------------------------------------
-- 2. Patch 28 June 2026 plan — replace placeholders with real lyrics
-- --------------------------------------------------------------------

update control_room_plan_items pi
   set slides = s.slides
  from control_room_songs s
 where pi.plan_id = (select id from control_room_plans where service_date = '2026-06-28')
   and pi.kind = 'song'
   and pi.title = s.title;

-- --------------------------------------------------------------------
-- VERIFY
-- --------------------------------------------------------------------

-- The songs added to the library by this file
select title, artist, section_default, jsonb_array_length(slides) as slides
  from control_room_songs
 where title in ('Jesus at the Centre', 'Awesome God, Mighty God', 'Thank You Lord');

-- 28 June plan items — which still need lyrics?
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides,
       case when i.slides::text like '%to be added%' then 'needs lyrics' else 'real lyrics' end as state
  from control_room_plan_items i
  join control_room_plans p on p.id = i.plan_id
 where p.service_date = '2026-06-28'
   and i.kind = 'song'
 order by i.position;

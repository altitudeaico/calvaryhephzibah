-- ============================================================
-- 27_song_lyrics_05jul2026.sql
-- ============================================================
-- Real lyrics for the 5 July 2026 set, formatted for the 2-line
-- slide format used by control_room_plan_items.slides.
-- (Lyrics supplied by the worship team; CCLI-covered, for in-service
-- slide display only.)
--
-- This batch:
--     · King of Glory — Todd Dulaney (feat. Shana Wilson-Williams)
--       (verse/chorus attribution labels removed; worship arrangement)
--
-- STILL PENDING lyrics for the 5 Jul set (placeholder until added here
-- and re-run):
--     · Indescribable — Chris Tomlin
--     · You Deserve It (My Hallelujah) — J.J. Hairston
--     · We Lift Our Hands in the Sanctuary
--   (The four praise songs + My Jesus / Shout to the Lord already resolve
--    from the control_room_songs library, so they are not in this file.)
--
-- This migration:
--   1. Upserts King of Glory into control_room_songs (persistent library)
--      so it's available for every future Sunday.
--   2. Patches the matching item in control_room_plan_items for the
--      5 July plan, replacing the placeholder with real lyrics.
--
-- Idempotent: safe to re-run. Library uses ON CONFLICT update; plan
-- items use targeted UPDATE on (plan_id, title).
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. SONG LIBRARY (control_room_songs) — persistent across weeks
-- --------------------------------------------------------------------

insert into control_room_songs (title, slides, section_default, artist) values

('King of Glory',
 '[
   {"line1":"Yes, the world will bow down and say You are God","line2":"Every man will bow down and say You are King"},
   {"line1":"So let''s start right now","line2":"Why would we wait?"},

   {"line1":"King of Glory, fill this place","line2":"We just wanna be with You"},
   {"line1":"Just wanna be with You","line2":"King of Glory, fill this place"},
   {"line1":"Just wanna be with You","line2":"Just wanna be with You"},

   {"line1":"Yes, the world will bow down and say You are God","line2":"Every man will bow down and say You are King"},
   {"line1":"So let''s start right now","line2":"Why would we wait"},
   {"line1":"We can praise You now","line2":"In victory"},

   {"line1":"King of Glory, fill this place","line2":"We just wanna be with You"},
   {"line1":"Just wanna be with You","line2":"King of Glory, fill this place"},
   {"line1":"Just wanna be with You","line2":"Just wanna be with You"}
 ]',
 'worship', 'Todd Dulaney')

on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist,
      updated_at      = now();

-- --------------------------------------------------------------------
-- 2. Patch 5 July 2026 plan — replace placeholder with real lyrics
-- --------------------------------------------------------------------

update control_room_plan_items pi
   set slides = s.slides
  from control_room_songs s
 where pi.plan_id = (select id from control_room_plans where service_date = '2026-07-05')
   and pi.kind = 'song'
   and pi.title = s.title
   and pi.title = 'King of Glory';

-- --------------------------------------------------------------------
-- VERIFY
-- --------------------------------------------------------------------

-- The song added to the library by this file
select title, artist, section_default, jsonb_array_length(slides) as slides
  from control_room_songs
 where title = 'King of Glory';

-- 5 July plan items — which still need lyrics?
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides,
       case when i.slides::text like '%to be added%' then 'needs lyrics' else 'real lyrics' end as state
  from control_room_plan_items i
  join control_room_plans p on p.id = i.plan_id
 where p.service_date = '2026-07-05'
   and i.kind = 'song'
 order by i.position;

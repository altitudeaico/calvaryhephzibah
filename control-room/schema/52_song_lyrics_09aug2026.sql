-- ============================================================
-- 52_song_lyrics_09aug2026.sql
-- ============================================================
-- Closes the LAST placeholder left open by 50_setlist_09aug2026.sql.
--
--   . You Are Worthy (end of service, position 9)
--     Lyrics supplied by Bolaji Olatoye, 8 August 2026.
--     CCLI-covered, for in-service slide display only.
--
-- After this runs, all nine songs for 9 August have real slides.
--
-- SLIDE COUNT -- read this before Sunday:
--   The song is two couplets. They differ only in the last phrase:
--       "...Lord of lords, You are worthy."
--       "...Lord of lords, I worship You."
--   Seeded as TWO slides, exactly as supplied. It is normally sung
--   round more than once, so the operator loops back to slide 1
--   rather than advancing off the end. If Calvary sings a set number
--   of passes, say so and the repeats get written out in full (the
--   pattern used for "Bow Down and Worship Him" and "Lord We Proclaim
--   You Now"), so the operator advances instead of looping.
--
-- Divine pronoun capitalised: "I worship you" -> "I worship You",
-- house style across repo content.
--
-- This migration:
--   1. Upserts the song into control_room_songs (persistent library)
--      so it resolves automatically every future Sunday.
--   2. Patches the 9 August plan item, replacing the placeholder.
--
-- >> RUN AFTER 50_setlist_09aug2026.sql. If you ever re-run 50
-- >> (which recreates the plan), re-run 51 and 52 afterwards.
--
-- Idempotent: library uses ON CONFLICT update; the plan item update
-- is safe to re-run any number of times.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. SONG LIBRARY (control_room_songs) -- persistent across weeks
-- --------------------------------------------------------------------

insert into control_room_songs (title, slides, section_default, artist) values

('You Are Worthy',
 '[
   {"line1":"Worthy, You are worthy, King of kings","line2":"Lord of lords, You are worthy"},
   {"line1":"Worthy, You are worthy, King of kings","line2":"Lord of lords, I worship You"}
 ]',
 'end', null)

on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist;

-- --------------------------------------------------------------------
-- 2. PATCH THE 9 AUGUST PLAN ITEM
-- --------------------------------------------------------------------

update control_room_plan_items i
   set slides = (select s.slides from control_room_songs s
                  where s.title = 'You Are Worthy' limit 1)
  from control_room_plans p
 where p.id = i.plan_id
   and p.service_date = '2026-08-09'
   and lower(i.title) in ('you are worthy', 'worthy');

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 3. VERIFY
-- --------------------------------------------------------------------

-- The patched song: expect position 9, 2 slides, ok
select i.position, i.section, i.title,
       jsonb_array_length(i.slides) as slides,
       case when i.slides::text like '%to be added%' then 'PLACEHOLDER' else 'ok' end as status
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-09'
  and i.title = 'You Are Worthy';

-- Anything still on a placeholder for 9 August? EXPECT ZERO ROWS.
select i.position, i.section, i.title
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-09'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full set list with slide counts -- all nine should have slides
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-09'
  and i.kind = 'song'
order by i.position;

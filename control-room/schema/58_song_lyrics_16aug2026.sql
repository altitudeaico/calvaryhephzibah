-- ============================================================
-- 58_song_lyrics_16aug2026.sql
-- ============================================================
-- Closes the LAST placeholder left open by 56_setlist_16aug2026.sql.
--
--   . Let Praises Rise (worship, position 5)
--     Lyrics supplied by Bolaji Olatoye, 15 August 2026.
--     CCLI-covered, for in-service slide display only.
--
-- After this runs, all nine songs for 16 August have real slides.
--
-- SLIDE GROUPING -- read this before Sunday:
--   The verse runs in THREE-line phrases ("Let praises rise / From
--   the inside / From the inside of me"), which does not divide
--   evenly into two-line slides. Rather than pair lines straight
--   down the list -- which would strand "From the inside of me" on
--   the same slide as the NEXT phrase's opening line -- each phrase
--   is split across two slides and never bleeds into its neighbour.
--   That is why several slides carry a blank second line. It is
--   deliberate, not missing text.
--
-- OPENING SECTION:
--   The first three slides are the sung/spoken call-in ("Hallelujah
--   ... Lift up your hands"). Transcribed exactly as supplied. If the
--   team starts straight at the verse on the day, the operator opens
--   on slide 4 rather than slide 1.
--
-- AD-LIB:
--   Slide 10 carries "(Anybody want that)" as supplied. It is an
--   ad-lib, not a lyric the room sings. Leave it on screen or skip
--   it -- the operator's call -- but do not treat a missing response
--   as a cue error.
--
-- FLAG -- ARTIST UNKNOWN:
--   artist is seeded null. The song is new to Calvary and no
--   attribution was supplied; it is NOT guessed here. Fill it in when
--   someone confirms the writer, so the credit line on the stage page
--   can carry it.
--
-- Idempotent: re-running replaces the library entry and re-patches
-- the plan item for 2026-08-16.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt),
-- any time after 56_setlist_16aug2026.sql.
-- ============================================================

-- --------------------------------------------------------------------
-- 1. LIBRARY ENTRY (control_room_songs)
-- --------------------------------------------------------------------

insert into control_room_songs (title, slides, section_default, artist) values

('Let Praises Rise',
 '[
   {"line1":"Hallelujah","line2":"Come on, with a continuing of your hands"},
   {"line1":"Lift up your hands, open up your mouth","line2":""},
   {"line1":"God, we give You glory","line2":"We praise Your Name"},

   {"line1":"Let praises rise","line2":"From the inside"},
   {"line1":"From the inside of me","line2":""},
   {"line1":"May You delight","line2":"In the inside"},
   {"line1":"In the inside of me","line2":""},
   {"line1":"Come fill my life","line2":"From the inside"},
   {"line1":"From the inside of me","line2":""},
   {"line1":"Set me on fire","line2":"From the inside (Anybody want that)"},
   {"line1":"From the inside of me","line2":""},

   {"line1":"''Cause all I want","line2":"Is for You"},
   {"line1":"For You to be glorified","line2":"For You to be lifted high"},
   {"line1":"All I want","line2":"Is for You"},
   {"line1":"For You to be glorified","line2":"For You to be lifted high"}
 ]',
 'worship', null)

on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist;

-- --------------------------------------------------------------------
-- 2. PATCH THE 16 AUGUST PLAN ITEM
-- --------------------------------------------------------------------

update control_room_plan_items i
   set slides = (select s.slides from control_room_songs s
                  where s.title = 'Let Praises Rise' limit 1)
  from control_room_plans p
 where p.id = i.plan_id
   and p.service_date = '2026-08-16'
   and lower(i.title) in ('let praises rise', 'let praise rise');

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 3. VERIFY
-- --------------------------------------------------------------------

-- The patched song: expect position 5, 15 slides, ok
select i.position, i.section, i.title,
       jsonb_array_length(i.slides) as slides,
       case when i.slides::text like '%to be added%' then 'PLACEHOLDER' else 'ok' end as status
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-16'
  and i.title = 'Let Praises Rise';

-- Anything still on a placeholder for 16 August? EXPECT ZERO ROWS.
select i.position, i.section, i.title
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-16'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full set list with slide counts -- all nine should have slides
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-16'
  and i.kind = 'song'
order by i.position;

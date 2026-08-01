-- ============================================================
-- 46_song_lyrics_02aug2026.sql
-- ============================================================
-- Closes the one placeholder left open by 45_setlist_02aug2026.sql.
--
--   . Bow Down and Worship Him -- Bishop Paul S Morton Sr (worship)
--     Lyrics supplied by Bolaji Olatoye, 1 August 2026.
--     CCLI-covered, for in-service slide display only.
--
-- CANONICAL TITLE CHANGE: the set list was written as "Bow down and
-- worship", and 45 seeded the plan item as 'Bow Down and Worship'.
-- The song's real title is "Bow Down and Worship Him". This migration
-- renames the plan item to the canonical title as well as filling the
-- slides, so the song resolves automatically every future week.
--
-- The chorus is written out THREE times, matching how it is sung, so
-- the operator advances segment by segment rather than holding one
-- slide through the repeats (same pattern as "Yes Lord" on 26 July).
--
-- This migration:
--   1. Upserts the song into control_room_songs (persistent library)
--      so it is available for every future Sunday.
--   2. Patches the 2 August plan item -- both the title and the
--      slides -- replacing the placeholder.
--
-- >> RUN AFTER 45_setlist_02aug2026.sql. If you ever re-run 45
-- >> (which recreates the plan), re-run this file afterwards.
--
-- Idempotent: library uses ON CONFLICT update; the plan item update
-- matches either the old or the canonical title, so it is safe to
-- re-run any number of times.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. SONG LIBRARY (control_room_songs) -- persistent across weeks
-- --------------------------------------------------------------------

insert into control_room_songs (title, slides, section_default, artist) values

('Bow Down and Worship Him',
 '[
   {"line1":"Bow down and worship Him","line2":"Worship Him, oh worship Him"},
   {"line1":"Bow down and worship Him","line2":"Enter in, oh enter in"},
   {"line1":"Bow down and worship Him","line2":"Worship Him, oh worship Him"},
   {"line1":"Bow down and worship Him","line2":"Enter in, oh enter in"},
   {"line1":"Bow down and worship Him","line2":"Worship Him, oh worship Him"},
   {"line1":"Bow down and worship Him","line2":"Enter in, oh enter in"},
   {"line1":"Consuming fire, sweet perfume","line2":"His awesome presence fills this room"},
   {"line1":"This is holy ground","line2":"This is holy ground"},
   {"line1":"This is holy ground","line2":"So come and bow down"}
 ]',
 'worship', 'Bishop Paul S Morton Sr')

on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist;

-- --------------------------------------------------------------------
-- 2. PATCH THE 2 AUGUST PLAN ITEM (title + slides)
-- --------------------------------------------------------------------

update control_room_plan_items i
   set title  = 'Bow Down and Worship Him',
       slides = (select s.slides from control_room_songs s
                  where s.title = 'Bow Down and Worship Him' limit 1)
  from control_room_plans p
 where p.id = i.plan_id
   and p.service_date = '2026-08-02'
   and lower(i.title) in ('bow down and worship', 'bow down and worship him');

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 3. VERIFY
-- --------------------------------------------------------------------

-- The patched song: expect 'Bow Down and Worship Him', 9 slides, ok
select i.position, i.section, i.title,
       jsonb_array_length(i.slides) as slides,
       case when i.slides::text like '%to be added%' then 'PLACEHOLDER' else 'ok' end as status
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-02'
  and i.title = 'Bow Down and Worship Him';

-- Anything still on a placeholder for 2 August? EXPECT ZERO ROWS.
select i.position, i.section, i.title
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-02'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full set list with slide counts
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-02'
  and i.kind = 'song'
order by i.position;

-- ============================================================
-- 51_song_lyrics_09aug2026.sql
-- ============================================================
-- Closes ONE of the two placeholders left open by
-- 50_setlist_09aug2026.sql.
--
--   . Lord We Proclaim You Now (worship, medley song 1 of 3)
--     Also known as "Release Your Power" / "Let Your Presence Fall".
--     Lyrics supplied by Bolaji Olatoye, 8 August 2026.
--     CCLI-covered, for in-service slide display only.
--
-- >> STILL OUTSTANDING: "You Are Worthy" (position 9, end of
-- >> service) has no lyrics and remains a PLACEHOLDER after this
-- >> migration runs. The verify query below will still return that
-- >> one row. That is expected, not a failure.
--
-- SLIDE ORDER -- read this before Sunday:
--   The slides follow the order of the lyrics AS SUPPLIED, which is
--   the recorded version:
--       Verse . Chorus . Verse . Chorus . Chorus . Chorus . Tag . Tag
--
--   The arrangement agreed at the rehearsal on Friday 7 August runs
--   differently -- verse one SOLO, verse two with the band, THEN the
--   chorus up to four times, with no chorus between the verses:
--       Verse . Verse . Chorus x4
--
--   The operator will therefore need to SKIP slides 4-5 (the first
--   chorus) if the band goes straight from verse one into verse two.
--   Left in rather than removed, because the band may well sing it
--   the recorded way on the day. Do not re-sequence without asking.
--
-- The chorus is written out in full each time it repeats, matching
-- how it is sung, so the operator advances segment by segment rather
-- than holding one slide through the repeats (same pattern as
-- "Bow Down and Worship Him" on 2 August).
--
-- This migration:
--   1. Upserts the song into control_room_songs (persistent library)
--      so it resolves automatically every future Sunday.
--   2. Patches the 9 August plan item, replacing the placeholder.
--
-- >> RUN AFTER 50_setlist_09aug2026.sql. If you ever re-run 50
-- >> (which recreates the plan), re-run this file afterwards.
--
-- Idempotent: library uses ON CONFLICT update; the plan item update
-- is safe to re-run any number of times.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. SONG LIBRARY (control_room_songs) -- persistent across weeks
-- --------------------------------------------------------------------

insert into control_room_songs (title, slides, section_default, artist) values

('Lord We Proclaim You Now',
 '[
   {"line1":"Lord, we proclaim You now","line2":"Of Your mighty power"},
   {"line1":"And Your awesome majesty","line2":"Lord, come upon us now"},
   {"line1":"And release Your power","line2":"And let Your presence fall"},
   {"line1":"Oh, Lord","line2":"Oh, Lord"},
   {"line1":"Release Your power","line2":"And let Your presence fall"},
   {"line1":"Lord, we proclaim You now","line2":"Of Your mighty power"},
   {"line1":"And Your awesome majesty","line2":"Lord, come upon us now"},
   {"line1":"And release Your power","line2":"And let Your presence fall"},
   {"line1":"Oh, Lord","line2":"Oh, Lord"},
   {"line1":"Release Your power","line2":"And let Your presence fall"},
   {"line1":"Oh, Lord","line2":"Oh, Lord"},
   {"line1":"Release Your power","line2":"And let Your presence fall"},
   {"line1":"Oh, Lord","line2":"Oh, Lord"},
   {"line1":"Release Your power","line2":"And let Your presence fall"},
   {"line1":"Release Your power","line2":"And let Your presence fall"},
   {"line1":"Release Your power","line2":"And let Your presence fall"}
 ]',
 'worship', null)

on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist;

-- --------------------------------------------------------------------
-- 2. PATCH THE 9 AUGUST PLAN ITEM
-- --------------------------------------------------------------------

update control_room_plan_items i
   set slides = (select s.slides from control_room_songs s
                  where s.title = 'Lord We Proclaim You Now' limit 1)
  from control_room_plans p
 where p.id = i.plan_id
   and p.service_date = '2026-08-09'
   and lower(i.title) in ('lord we proclaim you now',
                          'lord we proclaim',
                          'release your power');

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 3. VERIFY
-- --------------------------------------------------------------------

-- The patched song: expect position 5, 16 slides, ok
select i.position, i.section, i.title,
       jsonb_array_length(i.slides) as slides,
       case when i.slides::text like '%to be added%' then 'PLACEHOLDER' else 'ok' end as status
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-09'
  and i.title = 'Lord We Proclaim You Now';

-- Anything still on a placeholder for 9 August?
-- EXPECT EXACTLY ONE ROW: You Are Worthy (position 9).
select i.position, i.section, i.title
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-09'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full set list with slide counts
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-09'
  and i.kind = 'song'
order by i.position;

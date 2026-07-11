-- ============================================================
-- 33_song_lyrics_12jul2026.sql
-- ============================================================
-- Lyrics for the "Reign Jesus" set slot -- these are the chorus of
-- "Elohim" by MOG Music (the "Reign, reign" refrain), supplied by
-- Bolaji. Kept under the set title "Reign Jesus" as published; rename
-- to "Elohim" on request. Citation markers and ad-libs stripped;
-- "Reign, reign" kept as single-line hold slides. In-service display
-- only (CCLI-covered).
--
-- Loads into the persistent library and patches the 12 July plan.
-- Idempotent. Run in the Supabase SQL editor (project:
-- pfycvgbrsbecznkcikwt), any time after 30_setlist_12jul2026.sql.
-- ============================================================

insert into control_room_songs (title, slides, section_default, artist) values
('Reign Jesus',
 '[
   {"line1":"You are God, Elohim","line2":"Ancient of Days"},
   {"line1":"Reign, reign","line2":""},
   {"line1":"There is none like You, Lord","line2":"Ancient of Days"},
   {"line1":"Reign, reign","line2":""}
 ]',
 'worship', 'MOG Music (Elohim)')
on conflict (title) do update
  set slides = excluded.slides,
      section_default = excluded.section_default,
      artist = excluded.artist;

update control_room_plan_items i
set slides = s.slides
from control_room_songs s, control_room_plans p
where i.plan_id = p.id
  and p.service_date = '2026-07-12'
  and lower(i.title) = lower(s.title)
  and s.title = 'Reign Jesus';

-- VERIFY -- which 12 July songs still need lyrics? (expect Oh Be Lifted only)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-12' and i.kind = 'song'
  and (i.slides::text like '%to be added%' or i.slides::text like '%plan]%')
order by i.position;

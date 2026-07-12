-- ============================================================
-- 34_song_lyrics_12jul2026.sql
-- ============================================================
-- Lyrics for "Oh Be Lifted" (worship chorus), supplied by Bolaji,
-- formatted to the 2-line slide format. In-service display only
-- (CCLI-covered). This is the last of the three new worship songs --
-- with this run, every song in the 12 July set has real lyrics.
--
-- Loads into the persistent library and patches the 12 July plan.
-- Idempotent. Run in the Supabase SQL editor (project:
-- pfycvgbrsbecznkcikwt), any time after 30_setlist_12jul2026.sql.
-- ============================================================

insert into control_room_songs (title, slides, section_default, artist) values
('Oh Be Lifted',
 '[
   {"line1":"Oh, be lifted","line2":"Above all other gods"},
   {"line1":"We lay our crowns","line2":"And worship You"},
   {"line1":"All glorious God","line2":"We praise Your name"},
   {"line1":"We lay our crowns","line2":"And worship You"}
 ]',
 'worship', null)
on conflict (title) do update
  set slides = excluded.slides,
      section_default = excluded.section_default;

update control_room_plan_items i
set slides = s.slides
from control_room_songs s, control_room_plans p
where i.plan_id = p.id
  and p.service_date = '2026-07-12'
  and lower(i.title) = lower(s.title)
  and s.title = 'Oh Be Lifted';

-- VERIFY -- which 12 July songs still need lyrics? (expect ZERO rows now)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-12' and i.kind = 'song'
  and (i.slides::text like '%to be added%' or i.slides::text like '%plan]%')
order by i.position;

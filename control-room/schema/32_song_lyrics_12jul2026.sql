-- ============================================================
-- 32_song_lyrics_12jul2026.sql
-- ============================================================
-- Real lyrics for "No Longer Slaves" (Bethel Music / Jonathan David
-- & Melissa Helser), supplied by Bolaji, formatted to the 2-line
-- slide format. Worship-leader ad-libs and spoken interjections
-- stripped; for in-service slide display only (CCLI-covered).
--
-- This clears the last of the three new worship songs that had no
-- lyrics. (Oh Be Lifted and Reign Jesus were the other two -- if you
-- want those on screen too, send the words.)
--
-- Loads into the persistent library and patches the 12 July plan.
-- Idempotent. Run in the Supabase SQL editor (project:
-- pfycvgbrsbecznkcikwt), any time after 30_setlist_12jul2026.sql.
-- ============================================================

insert into control_room_songs (title, slides, section_default, artist) values
('No Longer Slaves',
 '[
   {"line1":"I''m no longer a slave to fear","line2":"''Cause I am a child of God"},
   {"line1":"I''m no longer a slave to fear","line2":"For I am a child of God"},
   {"line1":"You unravel me with a melody","line2":"You surround me with a song"},
   {"line1":"Of deliverance from my enemies","line2":"To lure my fears away"},
   {"line1":"From my mother''s womb, You have chosen me","line2":"You have called me by my name"},
   {"line1":"And I''ve been born again to Your family","line2":"Your blood runs through my veins"},
   {"line1":"You split the sea, so I can walk right through it","line2":"My fears are drowned in perfect love"},
   {"line1":"You rescued me, so I can stand and sing","line2":"I am a child of God"},
   {"line1":"I am a child of God","line2":"I am a child of God"}
 ]',
 'worship', 'Bethel Music')
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
  and s.title = 'No Longer Slaves';

-- VERIFY -- which 12 July songs still need lyrics? (expect Oh Be Lifted, Reign Jesus)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-12' and i.kind = 'song'
  and (i.slides::text like '%to be added%' or i.slides::text like '%plan]%')
order by i.position;

-- ============================================================
-- 31_song_lyrics_12jul2026.sql
-- ============================================================
-- Real lyrics for five recurring songs in the 12 July 2026 set,
-- formatted for the 2-line slide format used by
-- control_room_plan_items.slides.
-- (Lyrics as already used on the live stage runthrough pages;
-- CCLI-covered, for in-service slide display only.)
--
-- This batch loads into the persistent library the songs that were
-- previously only on the stage pages (never in control_room_songs):
--     · Trading My Sorrows      (praise)
--     · Lord You Are Good       (praise)
--     · Friend of God           (praise)
--     · Every Praise            (praise)
--     · My Jesus (Shout to the Lord)  (end of service)
--
-- Already resolved from the library, so NOT repeated here:
--     · We Lift Our Hands in the Sanctuary  (offering)
--     · Hallelujah (You Won the Victory)    (worship)
--
-- Still pending real lyrics (new this week -- load when available):
--     · Oh Be Lifted · Reign Jesus · No Longer Slaves
--
-- This migration:
--   1. Upserts each song into control_room_songs (persistent library)
--      so it resolves for every future Sunday.
--   2. Patches the matching items in control_room_plan_items for the
--      12 July plan, replacing placeholders with real lyrics.
--
-- Idempotent: library uses ON CONFLICT update; plan items use a
-- targeted UPDATE on (plan_id, lower(title) = library title).
-- Run AFTER 30_setlist_12jul2026.sql, in the Supabase SQL editor
-- (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. SONG LIBRARY (control_room_songs) -- persistent across weeks
-- --------------------------------------------------------------------

insert into control_room_songs (title, slides, section_default, artist) values
('Trading My Sorrows',
 '[
   {"line1":"I''m trading my sorrows","line2":"I''m trading my shame"},
   {"line1":"I''m laying them down","line2":"for the joy of the Lord"},
   {"line1":"I''m trading my sickness","line2":"I''m trading my pain"},
   {"line1":"I''m laying them down","line2":"for the joy of the Lord"},
   {"line1":"Yes Lord, yes Lord","line2":"yes yes Lord"},
   {"line1":"Yes Lord, yes Lord","line2":"yes yes Lord"},
   {"line1":"Yes Lord, yes Lord","line2":"yes yes Lord, amen"},
   {"line1":"I am pressed but not crushed","line2":"persecuted not abandoned"},
   {"line1":"Struck down but not destroyed","line2":"I am blessed beyond the curse"},
   {"line1":"His promise will endure","line2":"his joy''s gonna be my strength"},
   {"line1":"Though sorrow may last for the night","line2":"his joy comes with the morning"}
 ]',
 'praise', 'Israel Houghton / Darrell Evans'),

('Lord You Are Good',
 '[
   {"line1":"Lord you are good","line2":"and your mercy endureth forever"},
   {"line1":"Lord you are good","line2":"and your mercy endureth forever"},
   {"line1":"People from every nation and tongue","line2":"from generation to generation"},
   {"line1":"We worship you","line2":"hallelujah, hallelujah"},
   {"line1":"We worship you","line2":"for who you are"},
   {"line1":"We worship you","line2":"hallelujah, hallelujah"},
   {"line1":"We worship you","line2":"for who you are"},
   {"line1":"You are good all the time","line2":"all the time you are good"},
   {"line1":"You are good all the time","line2":"all the time you are good"}
 ]',
 'praise', 'Israel Houghton'),

('Friend of God',
 '[
   {"line1":"Who am I that you are mindful of me","line2":"that you hear me when I call"},
   {"line1":"Is it true that you are thinking of me","line2":"how you love me, it''s amazing"},
   {"line1":"I am a friend of God","line2":"I am a friend of God"},
   {"line1":"I am a friend of God","line2":"he calls me friend"},
   {"line1":"I am a friend of God","line2":"I am a friend of God"},
   {"line1":"I am a friend of God","line2":"he calls me friend"},
   {"line1":"God Almighty, Lord of glory","line2":"you have called me friend"}
 ]',
 'praise', 'Israel Houghton'),

('Every Praise',
 '[
   {"line1":"Every praise is to our God","line2":"Every word of worship with one accord"},
   {"line1":"Every praise, every praise","line2":"Is to our God"},
   {"line1":"Sing hallelujah to our God","line2":"Glory hallelujah is due our God"},
   {"line1":"Every praise, every praise","line2":"Is to our God"},
   {"line1":"God my Saviour","line2":"God my Healer"},
   {"line1":"God my Deliverer","line2":"Yes He is, yes He is"},
   {"line1":"God my Saviour","line2":"God my Healer"},
   {"line1":"God my Deliverer","line2":"Yes He is, yes He is"},
   {"line1":"Every praise is to our God","line2":"Every word of worship with one accord"},
   {"line1":"Every praise, every praise","line2":"Is to our God"}
 ]',
 'praise', 'Hezekiah Walker'),

('My Jesus (Shout to the Lord)',
 '[
   {"line1":"My Jesus, my Saviour","line2":"Lord there is none like you"},
   {"line1":"All of my days I want to praise","line2":"the wonders of your mighty love"},
   {"line1":"My comfort, my shelter","line2":"tower of refuge and strength"},
   {"line1":"Let every breath, all that I am","line2":"never cease to worship you"},
   {"line1":"Shout to the Lord","line2":"all the earth let us sing"},
   {"line1":"Power and majesty","line2":"praise to the King"},
   {"line1":"Mountains bow down","line2":"and the seas will roar"},
   {"line1":"At the sound of your name","line2":""},
   {"line1":"I sing for joy","line2":"at the work of your hands"},
   {"line1":"Forever I''ll love you","line2":"forever I''ll stand"},
   {"line1":"Nothing compares to","line2":"the promise I have in you"}
 ]',
 'end', 'Darlene Zschech')
on conflict (title) do update
  set slides = excluded.slides,
      section_default = excluded.section_default,
      artist = excluded.artist;

-- --------------------------------------------------------------------
-- 2. PATCH the 12 July plan items with the real lyrics from the library
-- --------------------------------------------------------------------

update control_room_plan_items i
set slides = s.slides
from control_room_songs s,
     control_room_plans p
where i.plan_id = p.id
  and p.service_date = '2026-07-12'
  and lower(i.title) = lower(s.title)
  and s.title in (
    'Trading My Sorrows','Lord You Are Good','Friend of God',
    'Every Praise','My Jesus (Shout to the Lord)'
  );

-- --------------------------------------------------------------------
-- 3. VERIFY -- which 12 July songs still need lyrics? (expect the 3 new ones)
-- --------------------------------------------------------------------

select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-12'
  and i.kind = 'song'
  and (i.slides::text like '%to be added%' or i.slides::text like '%plan]%')
order by i.position;

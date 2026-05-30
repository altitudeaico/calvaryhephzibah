-- ============================================================
-- 20_song_lyrics_31may2026.sql
-- ============================================================
-- Real lyrics for the 31 May 2026 set list, formatted for the 2-line
-- slide format used by control_room_plan_items.slides.
--
-- This batch: 10,000 Reasons (Bless the Lord) — Matt Redman;
-- Hallelujah (You Won the Victory); and How Great Is Our God — Chris Tomlin.
-- (Lyrics supplied by the worship team; CCLI-covered, for in-service
-- slide display only. How Great's bridge is set to the lead lines only —
-- the parenthetical BV echoes are not projected.)
--
-- Still outstanding for 31 May after this file:
--     · Give Thanks
--
-- This migration:
--   1. Upserts the song into control_room_songs (persistent library)
--      so it's available for every future Sunday.
--   2. Patches the matching item in control_room_plan_items for the
--      31 May plan, replacing placeholder slides with real lyrics.
--
-- Idempotent: safe to re-run. Library uses ON CONFLICT update; plan
-- items use targeted UPDATE on (plan_id, title).
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- ────────────────────────────────────────────────────────────────────
-- 1. SONG LIBRARY (control_room_songs) — persistent across weeks
-- ────────────────────────────────────────────────────────────────────

insert into control_room_songs (title, slides, section_default, artist) values

('10,000 Reasons',
 '[
   {"line1":"Bless the Lord, O my soul","line2":"O my soul"},
   {"line1":"Worship His holy name","line2":""},
   {"line1":"Sing like never before, O my soul","line2":"I''ll worship Your holy name"},

   {"line1":"The sun comes up,","line2":"it''s a new day dawning"},
   {"line1":"It''s time to sing Your song again","line2":""},
   {"line1":"Whatever may pass and whatever","line2":"lies before me"},
   {"line1":"Let me be singing","line2":"when the evening comes"},

   {"line1":"Bless the Lord, O my soul","line2":"O my soul"},
   {"line1":"Worship His holy name","line2":""},
   {"line1":"Sing like never before, O my soul","line2":"I''ll worship Your holy name"},

   {"line1":"You''re rich in love","line2":"and You''re slow to anger"},
   {"line1":"Your name is great","line2":"and Your heart is kind"},
   {"line1":"For all Your goodness","line2":"I will keep on singing"},
   {"line1":"10,000 reasons","line2":"for my heart to find"},

   {"line1":"Bless the Lord, O my soul","line2":"O my soul"},
   {"line1":"Worship His holy name","line2":""},
   {"line1":"Sing like never before, O my soul","line2":"I''ll worship Your holy name"},

   {"line1":"And on that day","line2":"when my strength is failing"},
   {"line1":"The end draws near","line2":"and my time has come"},
   {"line1":"Still my soul will sing","line2":"Your praise unending"},
   {"line1":"10,000 years","line2":"and then forevermore"},

   {"line1":"Bless the Lord, O my soul","line2":"O my soul"},
   {"line1":"Worship His holy name","line2":""},
   {"line1":"Sing like never before, O my soul","line2":"I''ll worship Your holy name"},

   {"line1":"O I''ll worship Your holy name","line2":"I will worship Your holy name"},
   {"line1":"Holy name","line2":""}
 ]',
 'worship', 'Matt Redman'),

('Hallelujah (You Won the Victory)',
 '[
   {"line1":"Hallelujah,","line2":"You have won the victory"},
   {"line1":"Hallelujah,","line2":"You have won it all for me"},

   {"line1":"Death could not hold You down","line2":"You are the risen King"},
   {"line1":"Seated in majesty","line2":"You are the risen King"},

   {"line1":"By His stripes we are healed","line2":"By His nail-pierced hands we''re free"},
   {"line1":"By His blood we''re washed clean","line2":"Now we have the victory"},

   {"line1":"The power of sin is broken","line2":"Jesus overcame it all"},
   {"line1":"He has won our freedom","line2":"Jesus has won it all"},

   {"line1":"Our God is risen","line2":"He is alive"},
   {"line1":"He''s won the victory","line2":"He reigns on high"}
 ]',
 'worship', null),

('How Great Is Our God',
 '[
   {"line1":"The splendor of a King,","line2":"clothed in majesty"},
   {"line1":"Let all the earth rejoice","line2":"All the earth rejoice"},

   {"line1":"He wraps Himself in light","line2":"And darkness tries to hide"},
   {"line1":"And trembles at His voice","line2":"Trembles at His voice"},

   {"line1":"How great is our God, sing with me","line2":"How great is our God, and all will see"},
   {"line1":"How great,","line2":"how great is our God"},

   {"line1":"Age to age He stands","line2":"And time is in His hands"},
   {"line1":"Beginning and the end","line2":"Beginning and the end"},

   {"line1":"The Godhead, Three in One","line2":"Father, Spirit, Son"},
   {"line1":"The Lion and the Lamb","line2":"The Lion and the Lamb"},

   {"line1":"How great is our God, sing with me","line2":"How great is our God, and all will see"},
   {"line1":"How great,","line2":"how great is our God"},

   {"line1":"Name above all names","line2":"Worthy of our praise"},
   {"line1":"My heart will sing","line2":"How great is our God"},

   {"line1":"You''re the name above all names","line2":"You are worthy of our praise"},
   {"line1":"And my heart will sing","line2":"How great is our God"},

   {"line1":"How great is our God, sing with me","line2":"How great is our God, and all will see"},
   {"line1":"How great,","line2":"how great is our God"}
 ]',
 'worship', 'Chris Tomlin')

on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist,
      updated_at      = now();

-- ────────────────────────────────────────────────────────────────────
-- 2. Patch 31 May 2026 plan item — replace placeholder with real lyrics
-- ────────────────────────────────────────────────────────────────────

update control_room_plan_items pi
   set slides = s.slides
  from control_room_songs s
 where pi.plan_id = (select id from control_room_plans where service_date = '2026-05-31')
   and pi.kind = 'song'
   and pi.title = s.title;

-- ────────────────────────────────────────────────────────────────────
-- VERIFY
-- ────────────────────────────────────────────────────────────────────

-- The songs in the library
select title, artist, section_default, jsonb_array_length(slides) as slides
  from control_room_songs
 where title in ('10,000 Reasons', 'Hallelujah (You Won the Victory)', 'How Great Is Our God');

-- 31 May plan items — which still need lyrics?
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides,
       case when i.slides::text like '%placeholder%' or i.slides::text like '%lyrics in library%'
            then '⚠ still needs lyrics' else '✓ real lyrics' end as state
  from control_room_plan_items i
  join control_room_plans p on p.id = i.plan_id
 where p.service_date = '2026-05-31'
   and i.kind = 'song'
 order by i.position;

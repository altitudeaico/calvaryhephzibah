-- ============================================================
-- 27_song_lyrics_05jul2026.sql
-- ============================================================
-- Real lyrics for the 5 July 2026 set, formatted for the 2-line
-- slide format used by control_room_plan_items.slides.
-- (Lyrics supplied by the worship team; CCLI-covered, for in-service
-- slide display only.)
--
-- This batch (add songs here and re-run as they come in):
--     · King of Glory — Todd Dulaney (verse/chorus labels removed)
--     · Indescribable — Chris Tomlin / Laura Story
--     · You Deserve It (My Hallelujah) — J.J. Hairston
--     · We Lift Our Hands in the Sanctuary — Kurt Carr
--
-- ALL NINE songs in the 5 Jul set now have real lyrics — nothing pending.
--   (The four praise songs + My Jesus / Shout to the Lord already resolved
--    from the control_room_songs library, so they are not in this file.)
--
-- This migration:
--   1. Upserts each song into control_room_songs (persistent library)
--      so it's available for every future Sunday.
--   2. Patches the matching items in control_room_plan_items for the
--      5 July plan, replacing placeholders with real lyrics.
--
-- Idempotent: safe to re-run. Library uses ON CONFLICT update; plan
-- items use targeted UPDATE on (plan_id, title = library title).
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
 'worship', 'Todd Dulaney'),

('Indescribable',
 '[
   {"line1":"From the highest of heights to the depths of the sea","line2":"Creation''s revealing Your majesty"},
   {"line1":"From the colors of fall to the fragrance of spring","line2":"Every creature unique in the song that it sings"},
   {"line1":"All exclaiming","line2":""},

   {"line1":"Indescribable, uncontainable,","line2":"You placed the stars in the sky and You know them by name"},
   {"line1":"You are amazing God","line2":"All powerful, untameable,"},
   {"line1":"Awestruck we fall to our knees as we humbly proclaim","line2":"You are amazing God"},

   {"line1":"Who has told every lightning bolt where it should go","line2":"Or seen heavenly storehouses laden with snow"},
   {"line1":"Who imagined the sun and gives source to its light","line2":"Yet conceals it to bring us the coolness of night"},
   {"line1":"None can fathom","line2":""},

   {"line1":"Indescribable, uncontainable,","line2":"You placed the stars in the sky and You know them by name"},
   {"line1":"You are amazing God","line2":"All powerful, untameable,"},
   {"line1":"Awestruck we fall to our knees as we humbly proclaim","line2":"You are amazing God"},

   {"line1":"Indescribable, uncontainable,","line2":"You placed the stars in the sky and You know them by name"},
   {"line1":"You are amazing God","line2":"Incomparable, unchangeable"},
   {"line1":"You see the depths of my heart and You love me the same","line2":"You are amazing God"},
   {"line1":"You are amazing God","line2":""}
 ]',
 'worship', 'Chris Tomlin'),

('You Deserve It (My Hallelujah)',
 '[
   {"line1":"My hallelujah belongs to You","line2":"My hallelujah belongs to You"},
   {"line1":"My hallelujah belongs to You","line2":"My hallelujah belongs to You"},

   {"line1":"You deserve it, you deserve it","line2":"You deserve it, you deserve it"},

   {"line1":"All of the glory belongs to You","line2":"All of the glory belongs to You"},

   {"line1":"Hallelujah, hallelujah","line2":"Hallelujah, hallelujah"},
   {"line1":"All the glory, all the glory","line2":"And all the honor"},
   {"line1":"And all the praise","line2":""},

   {"line1":"You deserve it","line2":""}
 ]',
 'worship', 'J.J. Hairston'),

('We Lift Our Hands in the Sanctuary',
 '[
   {"line1":"We lift our hands in the sanctuary","line2":"We lift our hands to give You the glory"},
   {"line1":"We lift our hands to give You the praise","line2":"And we will praise You for the rest of our days"},
   {"line1":"Yes, we will praise You for the rest of our days","line2":""},

   {"line1":"We clap our hands in the sanctuary","line2":"We clap our hands to give You the glory"},
   {"line1":"We clap our hands to give You the praise","line2":"And we will praise You for the rest of our days"},
   {"line1":"Yes, we will praise You for the rest of our days","line2":""},

   {"line1":"We sing our song in the sanctuary","line2":"We sing our song to give You the glory"},
   {"line1":"We sing our song to give You the praise","line2":"And we will praise You for the rest of our days"},
   {"line1":"Yes, we will praise You for the rest of our days","line2":""},

   {"line1":"Jesus, we give You the praise","line2":"Emmanuel, we lift up Your name"},
   {"line1":"Heavenly Father, coming Messiah","line2":"And we will praise You for the rest of our days"},
   {"line1":"Yes, will praise You for the rest of our days","line2":""},

   {"line1":"Hallelujah in the sanctuary","line2":"Hallelujah we give You the glory"},
   {"line1":"Hallelujah we give You the praise","line2":"And we will praise You for the rest of our days"},
   {"line1":"Yes, we will praise You for the rest of our days","line2":""},

   {"line1":"Jesus, we give You the praise","line2":"Emmanuel, we lift up Your name"},
   {"line1":"Heavenly Father, coming Messiah","line2":"And we will praise You for the rest of our days"},
   {"line1":"Yes, will praise You for the rest of our days","line2":""},

   {"line1":"Yes! Yes, Lord for the rest of our days","line2":""},
   {"line1":"Hallelujah, hallelujah,","line2":"Hallelujah for the rest of our days"},
   {"line1":"And we will praise You for the rest of our days","line2":""}
 ]',
 'offering', 'Kurt Carr')

on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist,
      updated_at      = now();

-- --------------------------------------------------------------------
-- 2. Patch 5 July 2026 plan — replace placeholders with real lyrics
--    (patches every 5 Jul song that now has a library entry)
-- --------------------------------------------------------------------

update control_room_plan_items pi
   set slides = s.slides
  from control_room_songs s
 where pi.plan_id = (select id from control_room_plans where service_date = '2026-07-05')
   and pi.kind = 'song'
   and pi.title = s.title;

-- --------------------------------------------------------------------
-- VERIFY
-- --------------------------------------------------------------------

-- The songs added to the library by this file
select title, artist, section_default, jsonb_array_length(slides) as slides
  from control_room_songs
 where title in ('King of Glory', 'Indescribable', 'You Deserve It (My Hallelujah)', 'We Lift Our Hands in the Sanctuary');

-- 5 July plan items — which still need lyrics?
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides,
       case when i.slides::text like '%to be added%' then 'needs lyrics' else 'real lyrics' end as state
  from control_room_plan_items i
  join control_room_plans p on p.id = i.plan_id
 where p.service_date = '2026-07-05'
   and i.kind = 'song'
 order by i.position;

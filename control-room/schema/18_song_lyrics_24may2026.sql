-- ============================================================
-- 18_song_lyrics_24may2026.sql
-- ============================================================
-- Real song lyrics for the 24 May 2026 set list, formatted for the
-- 2-line slide format used by control_room_plan_items.slides.
--
-- This migration:
--   1. Upserts each song into control_room_songs (persistent library)
--      so it's available for every future Sunday.
--   2. Patches the matching item in control_room_plan_items for the
--      24 May plan, replacing placeholder slides with real lyrics.
--
-- Idempotent: safe to re-run. Library uses ON CONFLICT update; plan
-- items use targeted UPDATE on (plan_id, title).
-- ============================================================

-- ────────────────────────────────────────────────────────────────────
-- 1. SONG LIBRARY (control_room_songs) — persistent across weeks
-- ────────────────────────────────────────────────────────────────────

insert into control_room_songs (title, slides, section_default, artist) values

-- These Are the Days of Elijah
('These Are the Days of Elijah',
 '[
   {"line1":"These are the days of Elijah","line2":"Declaring the Word of the Lord"},
   {"line1":"And these are the days of Your servant Moses","line2":"Righteousness being restored"},
   {"line1":"And though these are days of great trials","line2":"Of famine and darkness and sword"},
   {"line1":"Still we are the voice in the desert crying","line2":"Prepare ye the way of the Lord!"},
   {"line1":"Behold He comes, riding on the clouds","line2":"Shining like the sun, at the trumpet call"},
   {"line1":"Lift your voice, it''s the year of Jubilee","line2":"And out of Zion''s hill salvation comes"},
   {"line1":"And these are the days of Ezekiel","line2":"The dry bones becoming as flesh"},
   {"line1":"And these are the days of Your servant David","line2":"Rebuilding a temple of praise"},
   {"line1":"And these are the days of the harvest","line2":"The fields are as white in the world"},
   {"line1":"And we are the laborers in Your vineyard","line2":"Declaring the Word of the Lord"},
   {"line1":"There''s no god like Jehovah","line2":"There''s no god like Jehovah"},
   {"line1":"There''s no god like Jehovah","line2":"There''s no god like Jehovah"}
 ]'::jsonb, 'praise', 'Robin Mark'),

-- Lord I Lift Your Name on High
('Lord I Lift Your Name on High',
 '[
   {"line1":"Lord, I lift Your name on high","line2":"Lord, I love to sing Your praises"},
   {"line1":"I''m so glad You''re in my life","line2":"I''m so glad You came to save us"},
   {"line1":"You came from heaven to earth","line2":"To show the way"},
   {"line1":"From the earth to the cross","line2":"My debt to pay"},
   {"line1":"From the cross to the grave","line2":"From the grave to the sky"},
   {"line1":"Lord, I lift Your name on high","line2":""}
 ]'::jsonb, 'praise', 'Rick Founds'),

-- Ancient of Days / Blessing and Honour
('Ancient of Days / Blessing and Honour',
 '[
   {"line1":"Blessing and honour, glory and power","line2":"Be unto the Ancient of Days"},
   {"line1":"From every nation, all of creation","line2":"Bow before the Ancient of Days"},
   {"line1":"Every tongue in Heaven and Earth","line2":"Shall declare your glory"},
   {"line1":"Every knee shall bow at your throne","line2":"In worship"},
   {"line1":"You will be exalted, O God","line2":"And your kingdom shall not pass away"},
   {"line1":"Blessing and honour, glory and power","line2":"Be unto the Ancient of Days"},
   {"line1":"From every nation, all of creation","line2":"Bow before the Ancient of Days"},
   {"line1":"Your kingdom shall reign over all the earth","line2":"Sing unto the Ancient of Days"},
   {"line1":"For none can compare to your matchless worth","line2":"Sing unto the Ancient of Days"},
   {"line1":"Every tongue in Heaven and Earth","line2":"Shall declare your glory"},
   {"line1":"Every knee shall bow at your throne","line2":"In worship"},
   {"line1":"You will be exalted, O God","line2":"And your kingdom shall not pass away"}
 ]'::jsonb, 'praise', 'Ron Kenoly'),

-- Holy Spirit You Are Welcome Here
('Holy Spirit You Are Welcome Here',
 '[
   {"line1":"There''s nothing worth more","line2":"That will ever come close"},
   {"line1":"Nothing can compare","line2":"You''re our living hope"},
   {"line1":"Your presence, Lord","line2":""},
   {"line1":"I''ve tasted and seen","line2":"Of the sweetest of love"},
   {"line1":"When my heart becomes free","line2":"And my shame is undone"},
   {"line1":"Your presence, Lord","line2":""},
   {"line1":"Holy Spirit, You are welcome here","line2":"Come flood this place and fill the atmosphere"},
   {"line1":"Your glory, God, is what our hearts long for","line2":"To be overcome by Your presence, Lord"},
   {"line1":"Your presence, Lord","line2":""},
   {"line1":"Let us become more aware of Your presence","line2":""},
   {"line1":"Let us experience the glory of Your goodness","line2":""}
 ]'::jsonb, 'worship', 'Jesus Culture'),

-- Atmosphere Shift
('Atmosphere Shift',
 '[
   {"line1":"There is only one name","line2":"There is only one name"},
   {"line1":"With the power to save","line2":"The power to save"},
   {"line1":"Our God He is champion","line2":"He reigns forevermore"},
   {"line1":"Forevermore","line2":""},
   {"line1":"Every knee will bow down","line2":"Every tongue will confess"},
   {"line1":"Jesus Christ You are Lord","line2":""},
   {"line1":"Atmosphere shift now","line2":"Chains be broken, break now"},
   {"line1":"Holy Spirit come down","line2":"Heaven open, heaven open"}
 ]'::jsonb, 'worship', 'Phil Thompson'),

-- Spirit Break Out
('Spirit Break Out',
 '[
   {"line1":"Our Father","line2":"All of Heaven roars Your name"},
   {"line1":"Sing louder","line2":"Let this place erupt with praise"},
   {"line1":"Can you hear it","line2":"A sound of Heaven touching earth"},
   {"line1":"A sound of Heaven touching earth","line2":""},
   {"line1":"Spirit break out","line2":"Break our walls down"},
   {"line1":"Spirit break out","line2":"Heaven come down, oh"},
   {"line1":"So King Jesus","line2":"You''re the name we''re lifting high"},
   {"line1":"Your glory","line2":"Shaking up the earth and sky"},
   {"line1":"Revival","line2":"We wanna see Your Kingdom here"},
   {"line1":"We wanna see Your Kingdom here","line2":""}
 ]'::jsonb, 'worship', 'William McDowell'),

-- Open the Eyes of My Heart, Lord
('Open the Eyes of My Heart, Lord',
 '[
   {"line1":"Open the eyes of my heart, Lord","line2":"Open the eyes of my heart"},
   {"line1":"I want to see You","line2":"I want to see You"},
   {"line1":"To see You high and lifted up","line2":"Shinin'' in the light of Your glory"},
   {"line1":"Pour out Your power and love","line2":"As we sing holy, holy, holy"},
   {"line1":"Holy, holy, holy","line2":"Holy, holy, holy"},
   {"line1":"I want to see You","line2":""}
 ]'::jsonb, 'offering', 'Paul Baloche'),

-- His Love Endures Forever (Chris Tomlin "Forever" — closing benediction stanza only)
('His Love Endures Forever',
 '[
   {"line1":"Sing praise, sing praise","line2":"Sing praise, sing praise"},
   {"line1":"Forever, God is faithful","line2":"Forever, God is strong"},
   {"line1":"Forever, God is with us","line2":"Forever"}
 ]'::jsonb, 'end', 'Chris Tomlin')

on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist,
      updated_at      = now();

-- ────────────────────────────────────────────────────────────────────
-- 2. Patch 24 May 2026 plan items — replace placeholders with real lyrics
-- ────────────────────────────────────────────────────────────────────
-- Strategy: update each plan_item by its title (per-plan-id, song-kind).
-- The slides JSONB is pulled from the library we just upserted, keeping
-- a single source of truth.

update control_room_plan_items pi
   set slides = s.slides
  from control_room_songs s
 where pi.plan_id = (select id from control_room_plans where service_date = '2026-05-24')
   and pi.kind = 'song'
   and pi.title = s.title;

-- ────────────────────────────────────────────────────────────────────
-- VERIFY
-- ────────────────────────────────────────────────────────────────────

-- All songs in the library, with slide counts
select title, artist, section_default, jsonb_array_length(slides) as slides
  from control_room_songs
 order by title;

-- 24 May plan items — confirm placeholders are gone
select i.position, i.kind, i.section, i.title, jsonb_array_length(i.slides) as slides,
       case when i.slides::text like '%placeholder%' then '⚠ STILL PLACEHOLDER' else '✓ real lyrics' end as state
  from control_room_plan_items i
  join control_room_plans p on p.id = i.plan_id
 where p.service_date = '2026-05-24'
   and i.kind = 'song'
 order by i.position;

-- Spot-check the first slide of each song to make sure the data looks right
select i.title, i.slides->0 as first_slide
  from control_room_plan_items i
  join control_room_plans p on p.id = i.plan_id
 where p.service_date = '2026-05-24'
   and i.kind = 'song'
 order by i.position;

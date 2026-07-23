-- ============================================================
-- 41_song_library_26jul2026.sql
-- ============================================================
-- Adds four songs to the persistent library (control_room_songs)
-- ahead of the 26 July 2026 set. Lyrics supplied by Bolaji Olatoye,
-- 23 July 2026, matching the stage runthrough page for that Sunday.
-- CCLI-covered, for in-service slide display only.
--
--   . Glory Be to the Lord               (praise)  -- Afro medley segment 5
--   . Higher, Every Day                  (praise)  -- Afro medley segment 6
--   . My Hands, My Feet, My Whole Body   (praise)  -- Afro medley segments 7 & 9
--   . I Could Sing of Your Love Forever  (worship) -- new arrangement
--
-- LIBRARY ONLY. No plan items are patched here, so this is safe to
-- run standalone and BEFORE the 26 July setlist migration
-- (42_setlist_26jul2026.sql). Running it first means the setlist
-- resolves these lyrics automatically from the library.
--
-- Idempotent: ON CONFLICT (title) updates slides, section and artist.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

insert into control_room_songs (title, slides, section_default, artist) values
('Glory Be to the Lord',
 '[
   {"line1":"Glory be to the Lord","line2":"Hallelujah"},
   {"line1":"Glory be to the Lord","line2":"Hallelujah"}
 ]',
 'praise', ''),

('Higher, Every Day',
 '[
   {"line1":"Higher, higher, every day","line2":"I lift my Jesus higher, every day"}
 ]',
 'praise', ''),

('My Hands, My Feet, My Whole Body',
 '[
   {"line1":"My hands, my feet, my whole body","line2":"All that I am will sing hallelujah to You"}
 ]',
 'praise', ''),

('I Could Sing of Your Love Forever',
 '[
   {"line1":"Over the mountains and the sea","line2":"Your river runs with love for me"},
   {"line1":"And I will open up my heart","line2":"And let the Healer set me free"},
   {"line1":"I''m happy to be in the truth","line2":"And I will daily lift my hands"},
   {"line1":"For I will always sing","line2":"Of when Your love came down"},
   {"line1":"I could sing of Your love forever","line2":"I could sing of Your love forever"},
   {"line1":"I could sing of Your love forever","line2":"I could sing of Your love forever"},
   {"line1":"Oh, I feel like dancing","line2":"It''s foolishness, I know"},
   {"line1":"But when the world has seen the light","line2":"They will dance with joy like we''re dancing now"}
 ]',
 'worship', 'Martin Smith (Delirious?)')
on conflict (title) do update
  set slides          = excluded.slides,
      section_default = excluded.section_default,
      artist          = excluded.artist;

notify pgrst, 'reload schema';

-- Verify
select title, section_default, artist, jsonb_array_length(slides::jsonb) as slide_count
from control_room_songs
where title in (
  'Glory Be to the Lord',
  'Higher, Every Day',
  'My Hands, My Feet, My Whole Body',
  'I Could Sing of Your Love Forever'
)
order by title;

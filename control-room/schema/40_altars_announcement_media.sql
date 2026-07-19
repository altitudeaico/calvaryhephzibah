-- ============================================================
-- 40_altars_announcement_media.sql
-- ============================================================
-- Register the ALTARS series assets in the Control Room as pushable
-- announcement images/videos, BY URL (no upload, no base64) — same pattern
-- as the sermon thumbnails. The files are already published to GitHub Pages
-- at /series/altars/, so control_room_images.data_url points straight at them
-- (storage_path null => mediaSrc() returns the URL as-is to the overlay).
--
-- Result: the operator opens the Control Room, and in the Images list there
-- are three ALTARS items ready to push full-screen — two stills and the 15s
-- animated card. Only the 16:9 landscape assets are registered (the overlay
-- screen is 16:9; the 9:16 story card is for social, not the stream).
--
-- Idempotent: re-running clears the prior ALTARS rows and re-seeds them.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- 1. Clear any previously registered ALTARS announcement media (clean re-seed)
delete from control_room_images
where category = 'announcement'
  and data_url like 'https://calvaryhfgc.github.io/calvaryhephzibah/series/altars/%';

-- 2. Register the three 16:9 assets by URL
insert into control_room_images (name, category, media_type, data_url, storage_path, width, height)
values
  ('ALTARS — title card',
   'announcement', 'image',
   'https://calvaryhfgc.github.io/calvaryhephzibah/series/altars/altars-landscape-still.png',
   null, 1920, 1080),
  ('ALTARS — key art',
   'announcement', 'image',
   'https://calvaryhfgc.github.io/calvaryhephzibah/series/altars/altars-key-art-16x9.png',
   null, 1539, 866),
  ('ALTARS — animated (15s)',
   'announcement', 'video',
   'https://calvaryhfgc.github.io/calvaryhephzibah/series/altars/altars-landscape-15s.mp4',
   null, 1920, 1080);

notify pgrst, 'reload schema';

-- 3. VERIFY — should list the three ALTARS rows
select name, category, media_type, width, height, data_url
from control_room_images
where data_url like '%/series/altars/%'
order by name;

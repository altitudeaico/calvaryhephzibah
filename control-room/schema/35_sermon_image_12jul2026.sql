-- ============================================================
-- 35_sermon_image_12jul2026.sql
-- ============================================================
-- Register the sermon thumbnail in the Control Room BY URL (no upload,
-- no base64) and attach it to the Sermon row in the order of service.
--
-- The thumbnail is already published to GitHub Pages, so we point
-- control_room_images.data_url straight at it. mediaSrc() in the
-- operator returns data_url as-is when there's no storage_path, so the
-- overlay receives the URL and displays it. The realtime payload stays
-- tiny (a short URL instead of a ~160KB base64 blob).
--
-- Result: the operator opens the Control Room and the Sermon item in
-- the running order already has the thumbnail attached with a
-- "Push image" button. Nothing to upload manually.
--
-- NOTE: the URL carries the ?v=3 cache-buster that matches the current
-- thumbnail. If the thumbnail is regenerated, bump the version here too.
--
-- Idempotent: re-running replaces the seeded row and re-links it.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt),
-- any time after 30_setlist_12jul2026.sql.
-- ============================================================

-- 1. Remove any prior seed of this date's sermon image (idempotent)
update control_room_plan_speakers s
  set image_id = null
  from control_room_plans p
  where s.plan_id = p.id
    and p.service_date = '2026-07-12'
    and s.image_id in (select id from control_room_images where name = 'Sermon — 12 Jul 2026');

delete from control_room_images where name = 'Sermon — 12 Jul 2026';

-- 2. Register the thumbnail by URL, and link it to the Sermon OOS row
with img as (
  insert into control_room_images (name, category, media_type, data_url, storage_path, width, height)
  values (
    'Sermon — 12 Jul 2026',
    'sermon',
    'image',
    'https://calvaryhfgc.github.io/calvaryhephzibah/sermon-thumbnail-12-jul-2026.jpg?v=3',
    null,
    1280, 720
  )
  returning id
)
update control_room_plan_speakers s
  set image_id = (select id from img)
  from control_room_plans p
  where s.plan_id = p.id
    and p.service_date = '2026-07-12'
    and s.role = 'Sermon';

-- 3. VERIFY -- the Sermon row should now show the attached image + its URL
select s.position, s.role, s.name, i.name as image_name, i.data_url
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
left join control_room_images i on i.id = s.image_id
where p.service_date = '2026-07-12' and s.role = 'Sermon';

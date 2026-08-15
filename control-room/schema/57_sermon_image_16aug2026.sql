-- ============================================================
-- 57_sermon_image_16aug2026.sql
-- ============================================================
-- Register the 16 August sermon thumbnail in the Control Room BY URL
-- (no upload, no base64) and attach it to the Sermon row in the
-- order of service.
--
-- >> HOST: the URL uses the CUSTOM DOMAIN, not calvaryhfgc.github.io.
-- >> The repo transferred to the altitudeaico account, so the old
-- >> owner's Pages host no longer serves it and any image registered
-- >> against it will fail to load in the overlay. Earlier weeks
-- >> (44_, 49_, 53_) still carry github.io URLs and are stale for the
-- >> same reason.
--
-- The thumbnail is already published to GitHub Pages, so
-- control_room_images.data_url points straight at it. mediaSrc() in
-- the operator returns data_url as-is when storage_path is null, so
-- the overlay receives the URL and displays it.
--
-- Result: the operator opens the Control Room and the Sermon item in
-- the running order already has the thumbnail attached with a
-- "Push image" button. Nothing to upload manually.
--
-- >> CACHE-BUSTER: the URL carries ?v=1 -- this is the FIRST render of
-- >> the 16 August thumbnail, so the version starts at 1 (last week's
-- >> ?v=4 counted revisions of a different file). The same ?v=1 is used
-- >> in media-briefing-16-aug-2026.html. If the thumbnail is
-- >> regenerated, bump the version HERE as well as in the run sheet,
-- >> or OBS will keep showing the cached older art.
--
-- Idempotent: re-running replaces the seeded row and re-links it.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt),
-- any time after 56_setlist_16aug2026.sql.
-- ============================================================

-- 1. Remove ALL previously URL-registered sermon thumbnails (previous weeks +
--    any prior seed of this date), so only this week's ever exists. The
--    plan_speakers.image_id FK is ON DELETE SET NULL, so old attachments clear
--    automatically. Manual / base64 uploads are NOT touched.
delete from control_room_images
where category = 'sermon'
  and storage_path is null
  and (data_url like 'https://calvaryhfgc.github.io/%sermon-thumbnail-%'
    or data_url like 'https://calvaryhephzibah.co.uk/%sermon-thumbnail-%');

-- 2. Register the thumbnail by URL, and link it to the Sermon OOS row
with img as (
  insert into control_room_images (name, category, media_type, data_url, storage_path, width, height)
  values (
    'Sermon — 16 Aug 2026 · Altars and the Believer''s Victory (ALTARS)',
    'sermon',
    'image',
    'https://calvaryhephzibah.co.uk/sermon-thumbnail-16-aug-2026.jpg?v=1',
    null,
    1280, 720
  )
  returning id
)
update control_room_plan_speakers s
  set image_id = (select id from img)
  from control_room_plans p
  where s.plan_id = p.id
    and p.service_date = '2026-08-16'
    and s.role = 'Sermon';

notify pgrst, 'reload schema';

-- 3. VERIFY -- the Sermon row should now show the attached image + its URL
select s.position, s.role, s.name, i.name as image_name, i.data_url
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
left join control_room_images i on i.id = s.image_id
where p.service_date = '2026-08-16' and s.role = 'Sermon';

-- Confirm exactly ONE URL-registered sermon thumbnail exists
select name, data_url, width, height, created_at
from control_room_images
where category = 'sermon'
  and storage_path is null
  and data_url like 'https://calvaryhfgc.github.io/%sermon-thumbnail-%'
order by created_at desc;

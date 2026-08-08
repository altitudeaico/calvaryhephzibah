-- ============================================================
-- 53_sermon_image_09aug2026.sql
-- ============================================================
-- Register the 9 August sermon thumbnail in the Control Room BY URL
-- (no upload, no base64) and attach it to the Sermon row in the
-- order of service.
--
--   Enter Into The Kingdom -- Rev Ifeayinchukwu Obi
--   1280x720, portrait cut-out on the obsidian plate.
--
-- The thumbnail is already published, so control_room_images.data_url
-- points straight at it. mediaSrc() in the operator returns data_url
-- as-is when storage_path is null, so the overlay receives the URL
-- and displays it.
--
-- Result: the operator opens the Control Room and the Sermon item in
-- the running order already has the thumbnail attached with a
-- "Push image" button. Nothing to upload manually.
--
-- >> HOST: deliberately still on calvaryhfgc.github.io, not the
-- >> calvaryhephzibah.co.uk custom domain. The OG tags on the run
-- >> sheet moved to the custom domain because social scrapers refuse
-- >> to follow the Pages redirect. OBS is a browser, follows the
-- >> redirect fine, and github.io is the host that has worked every
-- >> week so far. Not worth changing a live Sunday dependency in the
-- >> same week. Revisit after 9 August.
--
-- >> CACHE-BUSTER: the URL carries ?v=3, matching the current
-- >> thumbnail (rebuilt 8 August with Rev Obi's portrait composited).
-- >> If the thumbnail is regenerated again, bump the version HERE as
-- >> well as in the run sheet, or OBS will keep showing cached art.
--
-- Idempotent: re-running replaces the seeded row and re-links it.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt),
-- any time after 50_setlist_09aug2026.sql.
-- ============================================================

-- 1. Remove ALL previously URL-registered sermon thumbnails (previous weeks +
--    any prior seed of this date), so only this week's ever exists. Matches
--    BOTH hosts, so any older rows seeded against either domain are cleared.
--    The plan_speakers.image_id FK is ON DELETE SET NULL, so old attachments
--    clear automatically. Manual / base64 uploads are NOT touched.
delete from control_room_images
where category = 'sermon'
  and storage_path is null
  and (data_url like 'https://calvaryhfgc.github.io/%sermon-thumbnail-%'
       or data_url like 'https://calvaryhephzibah.co.uk/%sermon-thumbnail-%');

-- 2. Register the thumbnail by URL, and link it to the Sermon OOS row
with img as (
  insert into control_room_images (name, category, media_type, data_url, storage_path, width, height)
  values (
    'Sermon — 9 Aug 2026 · Enter Into The Kingdom (Rev Ifeayinchukwu Obi)',
    'sermon',
    'image',
    'https://calvaryhfgc.github.io/calvaryhephzibah/sermon-thumbnail-09-aug-2026.jpg?v=3',
    null,
    1280, 720
  )
  returning id
)
update control_room_plan_speakers s
  set image_id = (select id from img)
  from control_room_plans p
  where s.plan_id = p.id
    and p.service_date = '2026-08-09'
    and s.role = 'Sermon';

notify pgrst, 'reload schema';

-- 3. VERIFY -- the Sermon row should now show the attached image + its URL
select s.position, s.role, s.name, i.name as image_name, i.data_url
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
left join control_room_images i on i.id = s.image_id
where p.service_date = '2026-08-09' and s.role = 'Sermon';

-- Confirm exactly ONE URL-registered sermon thumbnail exists
select name, data_url, width, height, created_at
from control_room_images
where category = 'sermon'
  and storage_path is null
  and (data_url like 'https://calvaryhfgc.github.io/%sermon-thumbnail-%'
       or data_url like 'https://calvaryhephzibah.co.uk/%sermon-thumbnail-%')
order by created_at desc;

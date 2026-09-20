-- ============================================================
-- 72_sermon_image_20sep2026.sql
-- ============================================================
-- Register the 20 September sermon thumbnail in the Control Room BY
-- URL (no upload, no base64) and attach it to the Sermon row in the
-- order of service, so the operator gets a "Push image" button on
-- that row without uploading anything by hand.
--
-- >> HOST: the URL uses the CUSTOM DOMAIN, calvaryhephzibah.co.uk.
--
-- >> CACHE-BUSTER: ?v=3 -- this thumbnail went through three
-- >> distinct versions at the same filename before being registered
-- >> here (Claude's initial text-only render -> Claude's portrait
-- >> composite -> ChatGPT's final creative version with the Calvary
-- >> logo, the one actually used). v=3 matches the version now set
-- >> in media-briefing-20-sep-2026.html. If it's regenerated again,
-- >> bump BOTH places together or OBS will show cached art.
--
-- Idempotent: re-running replaces the seeded row and re-links it.
-- Run any time after 71_setlist_20sep2026.sql.
-- ============================================================

-- 1. Remove ALL previously URL-registered sermon thumbnails (previous weeks +
--    any prior seed of this date), so only this week's ever exists. The
--    plan_speakers.image_id FK is ON DELETE SET NULL, so old attachments clear
--    automatically. Manual / base64 uploads are NOT touched.
delete from control_room_images
where category = 'sermon'
  and storage_path is null
  and data_url like 'https://calvaryhephzibah.co.uk/%sermon-thumbnail-%';

-- 2. Register the thumbnail by URL, and link it to the Sermon OOS row
with img as (
  insert into control_room_images (name, category, media_type, data_url, storage_path, width, height)
  values (
    'Sermon — 20 Sep 2026 · Manifesting The Kingdom (Bishop Henry Emmanuel, Guest Minister)',
    'sermon',
    'image',
    'https://calvaryhephzibah.co.uk/sermon-thumbnail-20-sep-2026.jpg?v=3',
    null,
    1280, 720
  )
  returning id
)
update control_room_plan_speakers s
  set image_id = (select id from img)
  from control_room_plans p
  where s.plan_id = p.id
    and p.service_date = '2026-09-20'
    and s.role = 'Sermon';

notify pgrst, 'reload schema';

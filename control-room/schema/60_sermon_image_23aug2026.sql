-- ============================================================
-- 60_sermon_image_23aug2026.sql
-- ============================================================
-- Register the 23 August sermon thumbnail in the Control Room BY URL
-- (no upload, no base64) and attach it to the Sermon row in the
-- order of service, so the operator gets a "Push image" button on
-- that row without uploading anything by hand.
--
-- >> HOST: the URL uses the CUSTOM DOMAIN, calvaryhephzibah.co.uk.
-- >> NOT calvaryhfgc.github.io -- that account's Pages host does not
-- >> serve this repo (it transferred to altitudeaico), so anything
-- >> registered against it silently fails to load in the overlay.
-- >> This is the same dead host that was breaking every Control Room
-- >> OG preview until 23 Aug. Seeds 44_, 49_ and 53_ still carry it
-- >> and are stale for the same reason.
--
-- The thumbnail is already published to GitHub Pages, so
-- control_room_images.data_url points straight at it. mediaSrc() in
-- the operator returns data_url as-is when storage_path is null, so
-- the overlay receives the URL and displays it.
--
-- >> CACHE-BUSTER: ?v=2. The 23 August thumbnail was published once,
-- >> then RE-RENDERED the same morning (scrubbed lapel fixed, portrait
-- >> faded to the base, title/scripture gap opened up). The filename
-- >> did not change, so OBS may hold the first render in its browser
-- >> cache. v=2 forces it to refetch. If the art is regenerated again,
-- >> bump it here AND in media-briefing-23-aug-2026.html together.
-- >>
-- >> Note the run sheet's og:image deliberately carries NO query string
-- >> -- WhatsApp's scraper handles them badly. The cache-buster is for
-- >> OBS only, which is why it lives here and not in the OG tags.
--
-- PREREQUISITE, and it is a real one: control_room_plan_speakers had
-- RLS enabled with ZERO policies until 23 Aug, so every anon read
-- returned nothing and the operator's order of service was always
-- empty -- which also meant no Sermon row to hang an image off. That
-- is fixed (RLS disabled, anon granted, matching its sibling tables).
-- If the order of service ever goes blank again, check RLS FIRST.
--
-- Idempotent: re-running replaces the seeded row and re-links it.
-- Run any time after 59_setlist_23aug2026.sql.
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
    'Sermon — 23 Aug 2026 · Living Under The Rule Of The KING (Rev Ifeayinchukwu Obi)',
    'sermon',
    'image',
    'https://calvaryhephzibah.co.uk/sermon-thumbnail-23-aug-2026.jpg?v=2',
    null,
    1280, 720
  )
  returning id
)
update control_room_plan_speakers s
  set image_id = (select id from img)
  from control_room_plans p
  where s.plan_id = p.id
    and p.service_date = '2026-08-23'
    and s.role = 'Sermon';

notify pgrst, 'reload schema';

-- 3. VERIFY -- the Sermon row should now show the attached image + its URL
select s.position, s.role, s.name, i.name as image_name, i.data_url
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
left join control_room_images i on i.id = s.image_id
where p.service_date = '2026-08-23' and s.role = 'Sermon';

-- Confirm exactly ONE URL-registered sermon thumbnail exists, on the LIVE host.
-- Any row returned by the second query is pointing at the dead Pages host and
-- will not render in the overlay.
select name, data_url, width, height, created_at
from control_room_images
where category = 'sermon' and storage_path is null
order by created_at desc;

select name, data_url
from control_room_images
where data_url like 'https://calvaryhfgc.github.io/%';

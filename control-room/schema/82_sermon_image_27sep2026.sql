-- ============================================================
-- 82_sermon_image_27sep2026.sql
-- ============================================================
-- Register the 27 September sermon thumbnail in the Control Room BY
-- URL and attach it to the Sermon row in the order of service, so the
-- operator gets a "Push image" button on that row.
--
-- >> HOST: custom domain, calvaryhephzibah.co.uk.
-- >> CACHE-BUSTER: ?v=2 (ChatGPT final, replaced Claude placeholder v=1) matches media-briefing-27-sep-2026.html. If the
-- >> thumbnail is replaced (e.g. a ChatGPT creative version), bump BOTH.
--
-- Idempotent. Run any time after 81_setlist_27sep2026.sql.
-- ============================================================

delete from control_room_images
where category = 'sermon'
  and storage_path is null
  and data_url like 'https://calvaryhephzibah.co.uk/%sermon-thumbnail-%';

with img as (
  insert into control_room_images (name, category, media_type, data_url, storage_path, width, height)
  values (
    'Sermon — 27 Sep 2026 · Can Two Walk Together Except They Agree? (Bishop Henry Emmanuel, Guest Minister)',
    'sermon',
    'image',
    'https://calvaryhephzibah.co.uk/sermon-thumbnail-27-sep-2026.jpg?v=2',
    null,
    1280, 720
  )
  returning id
)
update control_room_plan_speakers s
  set image_id = (select id from img)
  from control_room_plans p
  where s.plan_id = p.id
    and p.service_date = '2026-09-27'
    and s.role = 'Sermon';

notify pgrst, 'reload schema';

-- Verify: expect one row, image attached to Sermon
select s.role, s.name, i.name as image, i.data_url
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
left join control_room_images i on i.id = s.image_id
where p.service_date = '2026-09-27' and s.role = 'Sermon';

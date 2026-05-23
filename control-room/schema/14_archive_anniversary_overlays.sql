-- ============================================================
-- 14_archive_anniversary_overlays.sql
-- ============================================================
-- Soft-archives the 40 anniversary broadcast overlay images now
-- that the 17 May 2026 anniversary service is in the past.
--
-- Strategy:
--   1. Add 'anniversary_archived' to the valid category constraint
--   2. UPDATE control_room_images SET category = 'anniversary_archived'
--      WHERE category = 'anniversary'
--
-- Effect:
--   - Records stay in the database (no data loss, fully recoverable)
--   - The PNG files themselves stay live on GitHub Pages
--   - The Control Room operator UI's default category filters won't
--     surface them anymore — they're out of the way
--   - To restore: UPDATE ... SET category = 'anniversary' WHERE
--     category = 'anniversary_archived'
--
-- Idempotent: safe to run multiple times.
-- ============================================================

-- 1. Expand the category constraint to allow the new value
do $$ begin
  if exists (select 1 from pg_constraint where conname = 'valid_image_category') then
    alter table control_room_images drop constraint valid_image_category;
  end if;
  alter table control_room_images
    add constraint valid_image_category
    check (category in (
      'offering',
      'communion',
      'sermon',
      'announcement',
      'general',
      'anniversary',
      'anniversary_archived'
    ));
end $$;

-- 2. Move all anniversary images to the archived category
update control_room_images
   set category = 'anniversary_archived'
 where category = 'anniversary';

-- 3. The partial unique index on (name) was scoped to category = 'anniversary'.
--    Recreate it under the new category so name-uniqueness still holds, in case
--    we ever bring anniversary content back or run the original seed again.
drop index if exists idx_images_anniversary_name;
create unique index if not exists idx_images_anniversary_archived_name
  on control_room_images(name)
  where category = 'anniversary_archived';

notify pgrst, 'reload schema';

-- ============================================================
-- VERIFY
-- ============================================================

-- Should show 40 rows under anniversary_archived, 0 under anniversary
select category, count(*) as total
from control_room_images
group by category
order by category;

-- ============================================================
-- 05_youtube_02aug2026.sql
-- ============================================================
-- Attach the published YouTube link to the 2 August 2026 sermon.
-- Run after 04_seed_02aug2026.sql.
-- Idempotent.
-- ============================================================

update sermons
   set youtube_url = 'https://youtu.be/LgxikILP0pI',
       updated_at  = now()
 where service_date = '2026-08-02'
   and title = 'Family Altar';

-- VERIFY
select service_date, title, preacher, youtube_url
from sermons where service_date = '2026-08-02';

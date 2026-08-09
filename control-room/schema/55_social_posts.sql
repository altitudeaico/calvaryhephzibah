-- ============================================================
-- 55_social_posts.sql - posted / not posted tracking
-- ============================================================
-- Backs the tick boxes on the weekly social preview pages at
--   calvaryhephzibah.co.uk/social/<week>/
--
-- One row per post per week. The page upserts on (week, post_id),
-- so ticking on a phone shows up on the laptop and vice versa,
-- and Scott sees the same state Bolaji does.
--
-- Deliberately NOT a Control Room table. It carries no service
-- data, just workflow state, so it lives on its own.
--
-- The page is read AND write from the browser with the public anon
-- key, so anon needs insert/update here. That is a considered
-- trade-off: the only thing anyone could do is tick a box on an
-- unlisted internal page. No personal data, no service content.
-- If that stops being acceptable, gate it behind bridge_users_v2
-- auth rather than making it read-only, or the page loses its point.
--
-- Idempotent. Run in the Supabase SQL editor (pfycvgbrsbecznkcikwt).
-- ============================================================

create table if not exists social_posts (
  id          uuid primary key default gen_random_uuid(),
  week        text not null,              -- '09-aug-2026'
  post_id     text not null,              -- 'reel-01', 'carousel-02'
  posted      boolean default false,
  posted_at   timestamptz,
  posted_by   text,                       -- optional, free text
  notes       text,
  updated_at  timestamptz default now(),
  unique (week, post_id)
);

create index if not exists social_posts_week_idx on social_posts (week);

-- keep updated_at honest
create or replace function social_posts_touch()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists social_posts_touch_trg on social_posts;
create trigger social_posts_touch_trg
  before update on social_posts
  for each row execute function social_posts_touch();

-- ---- access for the preview page (anon key) -------------------------
alter table social_posts disable row level security;
grant select, insert, update on social_posts to anon;

notify pgrst, 'reload schema';

-- ---- VERIFY ---------------------------------------------------------

-- Should return the empty table with the right columns
select column_name, data_type
from information_schema.columns
where table_name = 'social_posts'
order by ordinal_position;

-- This week's progress, once you have started ticking
select week,
       count(*)                        as tracked,
       count(*) filter (where posted)  as posted,
       max(posted_at)                  as last_posted
from social_posts
group by week
order by week desc;

-- Preacher library: reusable speaker records so repeat preachers don't need
-- re-uploading each week. A record = name + title + a hosted headshot (the JPG
-- lives in the repo at preachers/<slug>.jpg, served from GitHub Pages). Sermon
-- thumbnails, name banners, and the speaker overlay card all pull from here.
--
-- Run once in the Supabase SQL editor for project pfycvgbrsbecznkcikwt.

create table if not exists preachers (
  id          uuid primary key default gen_random_uuid(),
  slug        text unique not null,   -- e.g. 'ifeayinchukwu-obi'; used in the image filename
  name        text not null,          -- full name as shown on screen (incl. honorific)
  title       text,                   -- role, e.g. 'Guest Minister', 'Resident Pastor'
  image_url   text,                   -- GitHub Pages URL to the square headshot
  notes       text,
  last_seen   date,                   -- most recent time they preached
  created_at  timestamptz default now()
);

alter table preachers disable row level security;
grant select, insert, update, delete on preachers to anon;
notify pgrst, 'reload schema';

-- First record: Rev Ifeayinchukwu Obi (repeat guest minister — 21 Jun & 19 Jul 2026)
insert into preachers (slug, name, title, image_url, last_seen)
values (
  'ifeayinchukwu-obi',
  'Rev Ifeayinchukwu Obi',
  'Guest Minister',
  'https://calvaryhfgc.github.io/calvaryhephzibah/preachers/ifeayinchukwu-obi.jpg',
  '2026-07-19'
)
on conflict (slug) do update
  set name = excluded.name,
      title = excluded.title,
      image_url = excluded.image_url,
      last_seen = excluded.last_seen;

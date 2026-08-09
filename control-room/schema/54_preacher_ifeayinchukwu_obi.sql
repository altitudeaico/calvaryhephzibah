-- ============================================================
-- 54_preacher_ifeayinchukwu_obi.sql
-- ============================================================
-- Adds Rev Ifeayinchukwu Obi to the reusable preacher library so his
-- headshot never needs re-uploading. He has preached at Calvary at
-- least twice (21 June 2026 and 9 August 2026) and describes Calvary
-- as feeling like home.
--
-- Headshot: preachers/ifeayinchukwu-obi.jpg (800x800, green-foliage
-- background, cut out with the green key in cutout_portrait.py -- the
-- grey key destroys his suit).
--
-- >> NAME SPELLING UNRESOLVED. Spelled Ifeayinchukwu here to match the
-- >> 9 Aug order of service, run sheet and sermon thumbnail. It has
-- >> also appeared as Ifeanyichukwu (21 June 2026). Confirm with him
-- >> and correct everywhere at once if this is wrong.
--
-- Requires the preachers table from 39_preacher_library.sql.
-- Idempotent: ON CONFLICT (slug) updates.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

insert into preachers (slug, name, title, image_url, last_seen, notes)
values (
  'ifeayinchukwu-obi',
  'Rev Ifeayinchukwu Obi',
  'Guest Minister',
  'https://calvaryhfgc.github.io/calvaryhephzibah/preachers/ifeayinchukwu-obi.jpg',
  '2026-08-09',
  'Repeat guest minister, visiting from Nigeria. Preached "Enter Into The Kingdom: The Pathway To The Abundant Life" (9 August 2026). Preaches from the King James Version, works interactively with the congregation reading aloud, and keeps a close eye on the clock. Name spelling unconfirmed -- also recorded as Ifeanyichukwu on 21 June 2026.'
)
on conflict (slug) do update
  set name      = excluded.name,
      title     = excluded.title,
      image_url = excluded.image_url,
      last_seen = excluded.last_seen,
      notes     = excluded.notes;

notify pgrst, 'reload schema';

-- VERIFY
select slug, name, title, last_seen from preachers order by last_seen desc;

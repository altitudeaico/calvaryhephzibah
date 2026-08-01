-- ============================================================
-- 47_preacher_titi_sodipo.sql
-- ============================================================
-- Adds Dr Titi Sodipo to the reusable preacher library so her
-- headshot never needs re-uploading again. She has now preached at
-- Calvary at least three times (3 May, 26 July and 2 August 2026).
--
-- The headshot lives in the repo at preachers/titi-sodipo.jpg
-- (800x800, cut out from the green-screen portrait supplied by
-- Bolaji, 1 August 2026) and is served from GitHub Pages.
--
-- Requires the preachers table from 39_preacher_library.sql.
-- Idempotent: ON CONFLICT (slug) updates.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

insert into preachers (slug, name, title, image_url, last_seen, notes)
values (
  'titi-sodipo',
  'Dr Titi Sodipo',
  'Guest Minister',
  'https://calvaryhfgc.github.io/calvaryhephzibah/preachers/titi-sodipo.jpg',
  '2026-08-02',
  'Repeat guest minister. Preached "That I May Know Him and the Power of His Resurrection" (3 May 2026), "Altars" (26 July 2026) and "Family Altar" (2 August 2026).'
)
on conflict (slug) do update
  set name      = excluded.name,
      title     = excluded.title,
      image_url = excluded.image_url,
      last_seen = excluded.last_seen,
      notes     = excluded.notes;

notify pgrst, 'reload schema';

-- VERIFY
select slug, name, title, last_seen, image_url from preachers order by last_seen desc;

-- ============================================================
-- 19_setlist_31may2026.sql
-- ============================================================
-- Sunday 31st May 2026 — Pastor Shade Olatoye
--   Sermon: "David Encouraged Himself In The LORD" (1 Samuel 30:6)
--
-- Seeds the plan + order of service for the Control Room.
--
-- NOTE: songs, song lyrics, and the pre-sermon Bible reading
-- (reader + passage) are NOT in this file — they are pending the
-- worship team set list and the confirmed reading. They follow in a
-- separate migration (20_song_lyrics_31may2026.sql /
-- 21_scripture_31may2026.sql) once confirmed, mirroring the 24 May
-- sequence (13 -> 17 -> 18).
--
-- Until then, the Control Room falls back to the briefing parser for
-- 2026-05-31 (briefings.json -> media-briefing-31-may-2026.html).
--
-- Idempotent: re-running replaces the plan, items, and speakers for
-- 2026-05-31 cleanly.
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- ────────────────────────────────────────────────────────────────────
-- 1. PLAN
-- ────────────────────────────────────────────────────────────────────

delete from control_room_plans where service_date = '2026-05-31';

insert into control_room_plans (service_date, notes)
values ('2026-05-31', 'David Encouraged Himself In The LORD (Pastor Shade Olatoye · 1 Samuel 30:6) — set list & reading pending');

-- ────────────────────────────────────────────────────────────────────
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- ────────────────────────────────────────────────────────────────────

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-05-31');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading', 'Pastor Kayode Ogungbenro', null),
  (2,  'Opening Prayer',          'Sister Petty',             null),
  (3,  'Worship',                 null,                       'Worship Team'),
  (4,  'Communion',               'Pastor Gbenga Adebanjo',   null),
  (5,  'Announcements',           'Pastor Kayode Ogungbenro', null),
  (6,  'Thanksgiving',            'Pastor Gbenga Adebanjo',   null),
  (7,  'Bible Reading',           null,                       'Reader & passage TBC'),
  (8,  'Sermon',                  'Pastor Shade Olatoye',     'David Encouraged Himself In The LORD · 1 Samuel 30:6'),
  (9,  'Closing Prayer',          'Sister Folake Okunubi',    null),
  (10, 'Benediction',             'Sister Yinka Osipitan',    null)
) as v(position, role, name, notes)
where p.service_date = '2026-05-31';

-- ────────────────────────────────────────────────────────────────────
-- 3. VERIFY
-- ────────────────────────────────────────────────────────────────────

select p.service_date, p.notes,
       count(distinct s.id) as speakers
from control_room_plans p
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-05-31'
group by p.service_date, p.notes;

select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-05-31'
order by s.position;

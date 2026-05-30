-- ============================================================
-- 19_setlist_31may2026.sql
-- ============================================================
-- Sunday 31st May 2026 — Pastor Shade Olatoye
--   Sermon: "David Encouraged Himself In The LORD" (1 Samuel 30:6)
--
-- Seeds the full plan for the Control Room: plan + song set list +
-- order of service.
--
-- SET LIST
--   Praise  (Key of B):  Days of Elijah · Lord I Lift Your Name on High ·
--                        Ancient of Days / Blessing and Honour
--   Worship (Key of D):  10,000 Reasons · Hallelujah (You Won the Victory) ·
--                        How Great Is Our God
--   Offering:            Uncle Caster — piano single (INSTRUMENTAL, no lyrics)
--   End of Service:      Give Thanks
--
-- LYRICS: each song's slides are pulled from the control_room_songs
-- library by title where they exist (Days of Elijah, Lord I Lift Your
-- Name on High, Ancient of Days are already in the library). Songs not
-- yet in the library get placeholder slides and still need real lyrics
-- loaded (see 20_song_lyrics_31may2026.sql — to follow):
--     · 10,000 Reasons
--     · Hallelujah (You Won the Victory)
--     · How Great Is Our God
--     · Give Thanks
-- The offering item is instrumental — it intentionally has no slides.
--
-- The pre-sermon Bible reading (reader + passage) is still TBC and is
-- not cued here.
--
-- Idempotent: re-running replaces the plan, items, and speakers for
-- 2026-05-31 cleanly. Re-run after loading lyrics to refresh.
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- ────────────────────────────────────────────────────────────────────
-- 1. PLAN + SONG SET LIST (control_room_plan_items)
-- ────────────────────────────────────────────────────────────────────

delete from control_room_plans where service_date = '2026-05-31';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-05-31',
    'David Encouraged Himself In The LORD (Pastor Shade Olatoye · 1 Samuel 30:6) — Praise Key of B, Worship Key of D')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  -- pull real lyrics from the library if present, else fall back
  coalesce(
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title)),
    v.fallback::jsonb
  )
from (values

  -- ── PRAISE (Key of B) ─────────────────────────────────────────
  (1, 'song', 'These Are the Days of Elijah', 'praise',
    '[{"line1":"[lyrics in library]","line2":"[re-run after lyrics load]"}]'),
  (2, 'song', 'Lord I Lift Your Name on High', 'praise',
    '[{"line1":"[lyrics in library]","line2":"[re-run after lyrics load]"}]'),
  (3, 'song', 'Ancient of Days / Blessing and Honour', 'praise',
    '[{"line1":"[lyrics in library]","line2":"[re-run after lyrics load]"}]'),

  -- ── WORSHIP (Key of D) ────────────────────────────────────────
  (4, 'song', '10,000 Reasons', 'worship',
    '[{"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 3]","line2":"[replace with real lyrics]"}]'),
  (5, 'song', 'Hallelujah (You Won the Victory)', 'worship',
    '[{"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 3]","line2":"[replace with real lyrics]"}]'),
  (6, 'song', 'How Great Is Our God', 'worship',
    '[{"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 3]","line2":"[replace with real lyrics]"}]'),

  -- ── OFFERING ──────────────────────────────────────────────────
  -- Instrumental piano — no lyrics to display. Empty slides on purpose.
  (7, 'song', 'Uncle Caster — Piano Single (instrumental)', 'offering',
    '[]'),

  -- ── END OF SERVICE ────────────────────────────────────────────
  (8, 'song', 'Give Thanks', 'end',
    '[{"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"}]')

) as v(position, kind, title, section, fallback);

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
  (3,  'Worship',                 null,                       'Worship Team · Praise Key of B, Worship Key of D'),
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
       count(distinct i.id)              as songs,
       sum(jsonb_array_length(i.slides)) as total_slides,
       count(distinct s.id)              as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-05-31'
group by p.service_date, p.notes;

-- Which songs still need real lyrics (any slide still a placeholder)?
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-05-31'
  and (i.slides::text like '%placeholder%' or i.slides::text like '%lyrics in library%')
order by i.position;

-- Order of service
select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-05-31'
order by s.position;

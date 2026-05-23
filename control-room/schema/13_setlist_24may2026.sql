-- Sunday 24th May 2026 — Pentecost Sunday
-- Set list + order of service for Control Room
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt)
--
-- Idempotent: re-running this script will replace the plan, items, and speakers
-- for 2026-05-24 cleanly.

-- ────────────────────────────────────────────────────────────────────
-- 1. PLAN + SONGS (control_room_plan_items)
-- ────────────────────────────────────────────────────────────────────

-- Clear any existing plan for this date
delete from control_room_plans where service_date = '2026-05-24';

-- Create the plan and seed song items in one go
with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-05-24', 'Pentecost Sunday — Keep Going: The Harvest Is Coming (Bishop Bayo Yusuf · Galatians 6:9)')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  position, kind, title, section, slides::jsonb
from (values

  -- ── PRAISE MEDLEY ─────────────────────────────────────────────
  (1, 'song', 'These Are the Days of Elijah', 'praise',
    '[
      {"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 3]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 4]","line2":"[replace with real lyrics]"}
    ]'),

  (2, 'song', 'Lord I Lift Your Name on High', 'praise',
    '[
      {"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 3]","line2":"[replace with real lyrics]"}
    ]'),

  (3, 'song', 'Ancient of Days / Blessing and Honour', 'praise',
    '[
      {"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 3]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 4]","line2":"[replace with real lyrics]"}
    ]'),

  -- ── WORSHIP ──────────────────────────────────────────────────
  (4, 'song', 'Holy Spirit You Are Welcome Here', 'worship',
    '[
      {"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 3]","line2":"[replace with real lyrics]"}
    ]'),

  (5, 'song', 'Atmosphere Shift', 'worship',
    '[
      {"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 3]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 4]","line2":"[replace with real lyrics]"}
    ]'),

  (6, 'song', 'Spirit Break Out', 'worship',
    '[
      {"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 3]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 4]","line2":"[replace with real lyrics]"}
    ]'),

  -- ── OFFERING ─────────────────────────────────────────────────
  (7, 'song', 'Open the Eyes of My Heart, Lord', 'offering',
    '[
      {"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 3]","line2":"[replace with real lyrics]"}
    ]'),

  -- ── END OF SERVICE ───────────────────────────────────────────
  (8, 'song', 'His Love Endures Forever', 'end',
    '[
      {"line1":"[placeholder slide 1]","line2":"[replace with real lyrics]"},
      {"line1":"[placeholder slide 2]","line2":"[replace with real lyrics]"}
    ]')

) as v(position, kind, title, section, slides);

-- ────────────────────────────────────────────────────────────────────
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- ────────────────────────────────────────────────────────────────────

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-05-24');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1, 'Welcome & Opening Scripture', 'Pastor Shade Olatoye',     'Holy Spirit scripture — reference TBC'),
  (2, 'Opening Prayer',              null,                       'TBC'),
  (3, 'Worship',                     null,                       'Worship Team · Uncle Caster leading'),
  (4, 'Communion',                   null,                       'TBC'),
  (5, 'Announcements',               'Pastor Kayode Ogungbenro', null),
  (6, 'Bible Reading',               null,                       'Galatians 6:9 · Reader TBC'),
  (7, 'Sermon',                      'Bishop Bayo Yusuf',            'Keep Going: The Harvest Is Coming'),
  (8, 'Closing Prayer',              null,                       'TBC'),
  (9, 'Benediction',                 null,                       'TBC')
) as v(position, role, name, notes)
where p.service_date = '2026-05-24';

-- ────────────────────────────────────────────────────────────────────
-- 3. VERIFY
-- ────────────────────────────────────────────────────────────────────

-- Plan summary
select
  p.service_date,
  p.notes,
  count(distinct i.id)                     as songs,
  sum(jsonb_array_length(i.slides))        as total_slides,
  count(distinct s.id)                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id    = p.id
left join control_room_plan_speakers s on s.plan_id    = p.id
where p.service_date = '2026-05-24'
group by p.service_date, p.notes;

-- Order of service
select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-05-24'
order by s.position;

-- Song set list
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slide_count
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-05-24'
order by i.position;

-- ============================================================
-- 23_setlist_21jun2026.sql
-- ============================================================
-- Sunday 21st June 2026 — FATHER'S DAY
--   Sermon: "The Father's Heart" (Rev Ifeayin Obi · Guest Minister)
--   Pre-sermon reading: Ephesians 3:14-21 (Emmanuel Ariyibi)
--
-- Seeds the full plan for the Control Room: plan + song set list +
-- order of service + the pre-sermon scripture reading.
--
-- ⚠ SET LIST IS A PLACEHOLDER — carried forward unchanged from
--   14 Jun (= 7 Jun = 31 May). No Father's Day set was supplied at
--   seed time. CONFIRM the set with Bolaji before Sunday; if it
--   changes, edit the values block below and re-run this file.
--   Carried-forward set, same order, same keys:
--     Praise  (Key of B):  These Are the Days of Elijah ·
--                          Lord I Lift Your Name on High ·
--                          Ancient of Days / Blessing and Honour
--     Worship (Key of D):  10,000 Reasons ·
--                          Hallelujah (You Won the Victory) ·
--                          How Great Is Our God
--     Offering:            Open the Eyes of My Heart, Lord
--     End of Service:      Give Thanks
--
-- LYRICS: each song's real slides are copied from the most recent
-- resolved plan — 14 Jun first, then 7 Jun, then 31 May, then the
-- persistent song library (control_room_songs), then a placeholder.
-- Run 22_setlist_14jun2026.sql (and 21_) first and all eight songs
-- carry real lyrics, so this file alone fully cues the service.
--
-- ORDER OF SERVICE: 10 items. Father's Day Presentations (Pastor
-- Kayode) sits between Communion and Announcements as a service
-- moment — it lives in plan_speakers only (no slides of its own).
--
-- SCRIPTURE: Ephesians 3:14-21 is a single contiguous range, cued as
-- one scripture item (position 98) via cr_add_scripture_to_plan() —
-- the helper created in 16_scripture_in_plan.sql.
--
-- Idempotent: re-running replaces the plan, items, and speakers for
-- 2026-06-21 cleanly, then re-cues the scripture.
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- ────────────────────────────────────────────────────────────────────
-- 1. PLAN + SONG SET LIST (control_room_plan_items)
-- ────────────────────────────────────────────────────────────────────

delete from control_room_plans where service_date = '2026-06-21';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-06-21',
    'Father''s Day — The Father''s Heart (Rev Ifeayin Obi · Guest Minister) — set carried forward from last week (PLACEHOLDER, confirm): Praise Key of B, Worship Key of D')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  -- prefer 14 Jun's exact resolved slides, then 7 Jun, then 31 May, then the library, then a placeholder
  coalesce(
    (select i1.slides
       from control_room_plan_items i1
       join control_room_plans p1 on p1.id = i1.plan_id
      where p1.service_date = '2026-06-14'
        and lower(i1.title) = lower(v.title)
      limit 1),
    (select i2.slides
       from control_room_plan_items i2
       join control_room_plans p2 on p2.id = i2.plan_id
      where p2.service_date = '2026-06-07'
        and lower(i2.title) = lower(v.title)
      limit 1),
    (select i3.slides
       from control_room_plan_items i3
       join control_room_plans p3 on p3.id = i3.plan_id
      where p3.service_date = '2026-05-31'
        and lower(i3.title) = lower(v.title)
      limit 1),
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- ── PRAISE (Key of B) ─────────────────────────────────────────
  (1, 'song', 'These Are the Days of Elijah', 'praise',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 14 Jun plan]"}]'),
  (2, 'song', 'Lord I Lift Your Name on High', 'praise',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 14 Jun plan]"}]'),
  (3, 'song', 'Ancient of Days / Blessing and Honour', 'praise',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 14 Jun plan]"}]'),

  -- ── WORSHIP (Key of D) ────────────────────────────────────────
  (4, 'song', '10,000 Reasons', 'worship',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 14 Jun plan]"}]'),
  (5, 'song', 'Hallelujah (You Won the Victory)', 'worship',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 14 Jun plan]"}]'),
  (6, 'song', 'How Great Is Our God', 'worship',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 14 Jun plan]"}]'),

  -- ── OFFERING ──────────────────────────────────────────────────
  (7, 'song', 'Open the Eyes of My Heart, Lord', 'offering',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 14 Jun plan]"}]'),

  -- ── END OF SERVICE ────────────────────────────────────────────
  (8, 'song', 'Give Thanks', 'end',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 14 Jun plan]"}]')

) as v(position, kind, title, section, fallback);

-- ────────────────────────────────────────────────────────────────────
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- ────────────────────────────────────────────────────────────────────

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-06-21');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading',     'Pastor Shade Olatoye',     null),
  (2,  'Opening Prayer',              'Sister Kemi Awolesi',      null),
  (3,  'Worship',                     null,                       'Worship Team · Praise Key of B, Worship Key of D'),
  (4,  'Communion',                   'Pastor Shade Olatoye',     null),
  (5,  'Father''s Day Presentations', 'Pastor Kayode Ogungbenro', 'Father''s Day moment'),
  (6,  'Announcements',               'Pastor Gbenga Adebanjo',   null),
  (7,  'Bible Reading',               'Emmanuel Ariyibi',         'Ephesians 3:14-21'),
  (8,  'Sermon',                      'Rev Ifeayin Obi',          'The Father''s Heart · Guest Minister'),
  (9,  'Closing Prayer',              'Dr Caster Martins',        null),
  (10, 'Benediction',                 'Mummy Oso',                null)
) as v(position, role, name, notes)
where p.service_date = '2026-06-21';

-- ────────────────────────────────────────────────────────────────────
-- 3. SCRIPTURE — Ephesians 3:14-21 (pre-sermon reading)
-- Position 98 sits after the 8 song items so it doesn't collide.
-- ────────────────────────────────────────────────────────────────────

select cr_add_scripture_to_plan(
  p_service_date => '2026-06-21'::date,
  p_position     => 98,
  p_book         => 'Ephesians',
  p_chapter      => 3,
  p_verse_start  => 14,
  p_verse_end    => 21,
  p_section      => 'reading',
  p_version      => 'KJV'
) as ephesians_3_14_21_item_id;

-- ────────────────────────────────────────────────────────────────────
-- 4. VERIFY
-- ────────────────────────────────────────────────────────────────────

-- Plan summary
select p.service_date, p.notes,
       count(distinct i.id) filter (where i.kind = 'song')      as songs,
       count(distinct i.id) filter (where i.kind = 'scripture') as scriptures,
       sum(jsonb_array_length(i.slides))                        as total_slides,
       count(distinct s.id)                                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-06-21'
group by p.service_date, p.notes;

-- Any song still on a placeholder? (should return 0 rows once 14 Jun plan is loaded)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-06-21'
  and i.kind = 'song'
  and i.slides::text like '%from last week%'
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-06-21'
order by i.position;

-- Order of service speakers
select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-06-21'
order by s.position;

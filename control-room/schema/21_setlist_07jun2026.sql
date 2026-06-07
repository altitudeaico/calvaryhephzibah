-- ============================================================
-- 21_setlist_07jun2026.sql
-- ============================================================
-- Sunday 7th June 2026 — Bishop Henry Emmanuel (Guest Minister)
--   Sermon: "The Divine Key"
--   Pre-sermon reading: Acts 2:1-4, 40-41 (Sister Petty)
--
-- Seeds the full plan for the Control Room: plan + song set list +
-- order of service + the pre-sermon scripture reading.
--
-- SET LIST — IDENTICAL to last week (31 May), same order, same keys:
--   Praise  (Key of B):  These Are the Days of Elijah ·
--                        Lord I Lift Your Name on High ·
--                        Ancient of Days / Blessing and Honour
--   Worship (Key of D):  10,000 Reasons ·
--                        Hallelujah (You Won the Victory) ·
--                        How Great Is Our God
--   Offering:            Open the Eyes of My Heart, Lord
--   End of Service:      Give Thanks
--
-- LYRICS: because the set matches 31 May, each song's real slides are
-- copied straight from last week's plan (control_room_plan_items for
-- 2026-05-31). If that plan is missing, it falls back to the persistent
-- song library (control_room_songs), then to a placeholder. After 31
-- May's migrations 19 + 20 all eight songs carry real lyrics, so this
-- file alone fully cues the service — no separate lyrics file needed.
--
-- SCRIPTURE: Acts 2:1-4 and Acts 2:40-41 are cued as two scripture
-- items (positions 98, 99) via cr_add_scripture_to_plan() — the helper
-- created in 16_scripture_in_plan.sql. They render verse-by-verse like
-- the ad-hoc Bible search; the overlay needs no changes. Two items
-- because the reading is a split range (1-4 then 40-41).
--
-- Idempotent: re-running replaces the plan, items, and speakers for
-- 2026-06-07 cleanly, then re-cues the scripture.
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- ────────────────────────────────────────────────────────────────────
-- 1. PLAN + SONG SET LIST (control_room_plan_items)
-- ────────────────────────────────────────────────────────────────────

delete from control_room_plans where service_date = '2026-06-07';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-06-07',
    'The Divine Key (Bishop Henry Emmanuel · Guest Minister) — set as last week: Praise Key of B, Worship Key of D')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  -- prefer last week's exact resolved slides, then the library, then a placeholder
  coalesce(
    (select i2.slides
       from control_room_plan_items i2
       join control_room_plans p2 on p2.id = i2.plan_id
      where p2.service_date = '2026-05-31'
        and lower(i2.title) = lower(v.title)
      limit 1),
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- ── PRAISE (Key of B) ─────────────────────────────────────────
  (1, 'song', 'These Are the Days of Elijah', 'praise',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 31 May plan]"}]'),
  (2, 'song', 'Lord I Lift Your Name on High', 'praise',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 31 May plan]"}]'),
  (3, 'song', 'Ancient of Days / Blessing and Honour', 'praise',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 31 May plan]"}]'),

  -- ── WORSHIP (Key of D) ────────────────────────────────────────
  (4, 'song', '10,000 Reasons', 'worship',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 31 May plan]"}]'),
  (5, 'song', 'Hallelujah (You Won the Victory)', 'worship',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 31 May plan]"}]'),
  (6, 'song', 'How Great Is Our God', 'worship',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 31 May plan]"}]'),

  -- ── OFFERING ──────────────────────────────────────────────────
  (7, 'song', 'Open the Eyes of My Heart, Lord', 'offering',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 31 May plan]"}]'),

  -- ── END OF SERVICE ────────────────────────────────────────────
  (8, 'song', 'Give Thanks', 'end',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 31 May plan]"}]')

) as v(position, kind, title, section, fallback);

-- ────────────────────────────────────────────────────────────────────
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- ────────────────────────────────────────────────────────────────────

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-06-07');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1, 'Welcome & Bible Reading', 'Pastor Shade Olatoye',     null),
  (2, 'Opening Prayer',          'Sister Lisa',              null),
  (3, 'Worship',                 null,                       'Worship Team · Praise Key of B, Worship Key of D'),
  (4, 'Communion',               'Pastor Shade Olatoye',     null),
  (5, 'Announcements',           'Pastor Kayode Ogungbenro', null),
  (6, 'Bible Reading',           'Sister Petty',             'Acts 2:1-4, 40-41'),
  (7, 'Sermon',                  'Bishop Henry Emmanuel',    'The Divine Key · Guest Minister'),
  (8, 'Closing Prayer',          'Pastor Gbenga Adebanjo',   null),
  (9, 'Benediction',             'Sister Bukky Olowolagba',  null)
) as v(position, role, name, notes)
where p.service_date = '2026-06-07';

-- ────────────────────────────────────────────────────────────────────
-- 3. SCRIPTURE — Acts 2:1-4 and 2:40-41 (pre-sermon reading)
-- Positions 98/99 sit after the 8 song items so they don't collide.
-- ────────────────────────────────────────────────────────────────────

select cr_add_scripture_to_plan(
  p_service_date => '2026-06-07'::date,
  p_position     => 98,
  p_book         => 'Acts',
  p_chapter      => 2,
  p_verse_start  => 1,
  p_verse_end    => 4,
  p_section      => 'reading',
  p_version      => 'KJV'
) as acts_2_1_4_item_id;

select cr_add_scripture_to_plan(
  p_service_date => '2026-06-07'::date,
  p_position     => 99,
  p_book         => 'Acts',
  p_chapter      => 2,
  p_verse_start  => 40,
  p_verse_end    => 41,
  p_section      => 'reading',
  p_version      => 'KJV'
) as acts_2_40_41_item_id;

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
where p.service_date = '2026-06-07'
group by p.service_date, p.notes;

-- Any song still on a placeholder? (should return 0 rows)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-06-07'
  and i.kind = 'song'
  and i.slides::text like '%from last week%'
order by i.position;

-- Full running order: songs + scripture + speakers
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-06-07'
order by i.position;

select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-06-07'
order by s.position;

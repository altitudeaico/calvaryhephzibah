-- ============================================================
-- 22_setlist_14jun2026.sql
-- ============================================================
-- Sunday 14th June 2026 — Bishop Henry Emmanuel (Guest Minister)
--   Sermon: "Agreeing With GOD In Prayer"
--   Pre-sermon reading: Isaiah 55:1-13 (Pastor Kemi Ogungbenro)
--
-- Seeds the full plan for the Control Room: plan + song set list +
-- order of service + the pre-sermon scripture reading.
--
-- SET LIST — IDENTICAL to last week (7 Jun), same order, same keys:
--   Praise  (Key of B):  These Are the Days of Elijah ·
--                        Lord I Lift Your Name on High ·
--                        Ancient of Days / Blessing and Honour
--   Worship (Key of D):  10,000 Reasons ·
--                        Hallelujah (You Won the Victory) ·
--                        How Great Is Our God
--   Offering:            Open the Eyes of My Heart, Lord
--   End of Service:      Give Thanks
--
-- LYRICS: because the set matches 7 Jun (which itself matched 31 May),
-- each song's real slides are copied from last week's resolved plan
-- (control_room_plan_items for 2026-06-07), falling back to 2026-05-31,
-- then the persistent song library (control_room_songs), then a
-- placeholder. Run 21_setlist_07jun2026.sql first and all eight songs
-- carry real lyrics, so this file alone fully cues the service — no
-- separate lyrics file needed.
--
-- SCRIPTURE: Isaiah 55:1-13 is a single contiguous range, cued as one
-- scripture item (position 98) via cr_add_scripture_to_plan() — the
-- helper created in 16_scripture_in_plan.sql. It renders verse-by-verse
-- like the ad-hoc Bible search; the overlay needs no changes.
--
-- Idempotent: re-running replaces the plan, items, and speakers for
-- 2026-06-14 cleanly, then re-cues the scripture.
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- ────────────────────────────────────────────────────────────────────
-- 1. PLAN + SONG SET LIST (control_room_plan_items)
-- ────────────────────────────────────────────────────────────────────

delete from control_room_plans where service_date = '2026-06-14';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-06-14',
    'Agreeing With GOD In Prayer (Bishop Henry Emmanuel · Guest Minister) — set as last week: Praise Key of B, Worship Key of D')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  -- prefer last week's exact resolved slides, then 31 May, then the library, then a placeholder
  coalesce(
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
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 7 Jun plan]"}]'),
  (2, 'song', 'Lord I Lift Your Name on High', 'praise',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 7 Jun plan]"}]'),
  (3, 'song', 'Ancient of Days / Blessing and Honour', 'praise',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 7 Jun plan]"}]'),

  -- ── WORSHIP (Key of D) ────────────────────────────────────────
  (4, 'song', '10,000 Reasons', 'worship',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 7 Jun plan]"}]'),
  (5, 'song', 'Hallelujah (You Won the Victory)', 'worship',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 7 Jun plan]"}]'),
  (6, 'song', 'How Great Is Our God', 'worship',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 7 Jun plan]"}]'),

  -- ── OFFERING ──────────────────────────────────────────────────
  (7, 'song', 'Open the Eyes of My Heart, Lord', 'offering',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 7 Jun plan]"}]'),

  -- ── END OF SERVICE ────────────────────────────────────────────
  (8, 'song', 'Give Thanks', 'end',
    '[{"line1":"[lyrics from last week]","line2":"[re-run after loading 7 Jun plan]"}]')

) as v(position, kind, title, section, fallback);

-- ────────────────────────────────────────────────────────────────────
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- Closing Prayer & Benediction are TBC at time of seeding.
-- ────────────────────────────────────────────────────────────────────

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-06-14');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1, 'Welcome & Bible Reading', 'Pastor Shade Olatoye',     null),
  (2, 'Opening Prayer',          'Sister Petty',             null),
  (3, 'Worship',                 null,                       'Worship Team · Praise Key of B, Worship Key of D'),
  (4, 'Communion',               'Pastor Shade Olatoye',     null),
  (5, 'Announcements',           'Pastor Kayode Ogungbenro', null),
  (6, 'Bible Reading',           'Pastor Kemi Ogungbenro',   'Isaiah 55:1-13'),
  (7, 'Sermon',                  'Bishop Henry Emmanuel',    'Agreeing With GOD In Prayer · Guest Minister'),
  (8, 'Closing Prayer',          'TBC',                      null),
  (9, 'Benediction',             'TBC',                      null)
) as v(position, role, name, notes)
where p.service_date = '2026-06-14';

-- ────────────────────────────────────────────────────────────────────
-- 3. SCRIPTURE — Isaiah 55:1-13 (pre-sermon reading)
-- Position 98 sits after the 8 song items so it doesn't collide.
-- ────────────────────────────────────────────────────────────────────

select cr_add_scripture_to_plan(
  p_service_date => '2026-06-14'::date,
  p_position     => 98,
  p_book         => 'Isaiah',
  p_chapter      => 55,
  p_verse_start  => 1,
  p_verse_end    => 13,
  p_section      => 'reading',
  p_version      => 'KJV'
) as isaiah_55_1_13_item_id;

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
where p.service_date = '2026-06-14'
group by p.service_date, p.notes;

-- Any song still on a placeholder? (should return 0 rows)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-06-14'
  and i.kind = 'song'
  and i.slides::text like '%from last week%'
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-06-14'
order by i.position;

-- Order of service speakers
select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-06-14'
order by s.position;

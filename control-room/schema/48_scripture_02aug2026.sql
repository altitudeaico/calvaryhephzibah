-- ============================================================
-- 48_scripture_02aug2026.sql
-- ============================================================
-- Closes the last open item on the 2 August plan: the pre-sermon
-- Bible reading, confirmed by Bolaji on 1 August 2026.
--
--   Reader: Dr Caster Martins
--   1) Genesis 18:18-19
--   2) Galatians 4:19
--
-- Both are cued as scripture items so the operator can push them
-- verse by verse from the Control Room. Positions 98 and 99 sit
-- after the eight song items (positions 1-8), matching the house
-- convention from 16_scripture_in_plan.sql.
--
-- Version is KJV, already seeded in control_room_bible by
-- 02_seed_kjv.sql, so no verse inserts are needed here.
--
-- Also clears the FLAG on the Bible Reading speaker row (position 7)
-- and refreshes the plan notes, so nothing on 2 August is left
-- marked as outstanding except the opening prayer.
--
-- >> RUN AFTER 45_setlist_02aug2026.sql (and 46). If you ever re-run
-- >> 45, which recreates the plan, re-run 46 and 48 afterwards.
--
-- Idempotent: cr_add_scripture_to_plan() deletes any existing
-- scripture item at the same position before inserting.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. THE READINGS
-- --------------------------------------------------------------------

-- Genesis 18:18-19 -- Abraham commanding his household after him.
-- The Old Testament ground for the family altar.
select cr_add_scripture_to_plan(
  p_service_date => '2026-08-02'::date,
  p_position     => 98,
  p_book         => 'Genesis',
  p_chapter      => 18,
  p_verse_start  => 18,
  p_verse_end    => 19,
  p_section      => 'reading',
  p_version      => 'KJV'
);

-- Galatians 4:19 -- travailing in birth again until Christ be formed in you.
select cr_add_scripture_to_plan(
  p_service_date => '2026-08-02'::date,
  p_position     => 99,
  p_book         => 'Galatians',
  p_chapter      => 4,
  p_verse_start  => 19,
  p_verse_end    => 19,
  p_section      => 'reading',
  p_version      => 'KJV'
);

-- --------------------------------------------------------------------
-- 2. CLEAR THE FLAG ON THE BIBLE READING SPEAKER ROW
-- --------------------------------------------------------------------

update control_room_plan_speakers s
   set notes = 'Genesis 18:18-19 · Galatians 4:19 (KJV)'
  from control_room_plans p
 where p.id = s.plan_id
   and p.service_date = '2026-08-02'
   and s.position = 7;

-- --------------------------------------------------------------------
-- 3. REFRESH PLAN NOTES
-- --------------------------------------------------------------------

update control_room_plans
   set notes = 'Family Altar (Dr Titi Sodipo, guest minister) -- ALTARS series. Eight discrete songs, no medley and no backing track; all eight have real lyrics. Pre-sermon reading Genesis 18:18-19 and Galatians 4:19 (KJV), read by Dr Caster Martins. Opening prayer still unassigned. Keys set at soundcheck.'
 where service_date = '2026-08-02';

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 4. VERIFY
-- --------------------------------------------------------------------

-- The two readings: expect 2 rows with slides > 0
select i.position, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-02'
  and i.kind = 'scripture'
order by i.position;

-- Eyeball the actual verse text that will push to screen
select i.title, s.value ->> 'line1' as line1, s.value ->> 'line2' as line2
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
cross join lateral jsonb_array_elements(i.slides) as s(value)
where p.service_date = '2026-08-02'
  and i.kind = 'scripture'
order by i.position;

-- Anything on the plan still flagged? Expect ONE row: opening prayer.
select s.position, s.role, coalesce(s.name, '--') as name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-08-02'
  and s.notes like 'FLAG:%'
order by s.position;

-- Full running order
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-02'
order by i.position;

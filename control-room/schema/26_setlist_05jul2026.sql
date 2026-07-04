-- ============================================================
-- 26_setlist_05jul2026.sql
-- ============================================================
-- Sunday 5th July 2026
--   Sermon: "Prayer Postures and War the Room"
--           (Pastor Shade Olatoye · General Overseer)
--   Pre-sermon reading: PASSAGE TBC (Noah Femi-Ade · KJV)
--
-- Seeds the full plan for the Control Room: plan + song set list +
-- order of service. Scripture is NOT cued yet -- the reading passage
-- has not been confirmed (see part 3 below).
--
-- SET LIST (PROVISIONAL -- NOT yet confirmed by the worship team):
--   Carried forward from Sunday 28 June so lyrics resolve cleanly.
--   Confirm or replace before Sunday, then re-run this file.
--     Praise   (Key of B): These Are the Days of Elijah ·
--                          Lord I Lift Your Name on High ·
--                          Ancient of Days / Blessing and Honour
--     Worship  (Key TBC):  Here I Am to Worship ·
--                          Be Magnified ·
--                          Jesus at the Centre
--     Offering (Key TBC):  Awesome God, Mighty God
--     End      (Key TBC):  Thank You Lord
--
-- LYRICS resolution (coalesce, first hit wins):
--     28 Jun -> 21 Jun -> 14 Jun -> song library -> placeholder.
--   Every song above resolves to REAL slides:
--     * Praise (x3) + Here I Am to Worship resolve from the 28 Jun plan.
--     * Be Magnified, Jesus at the Centre, Awesome God (Mighty God) and
--       Thank You Lord were saved to control_room_songs by
--       25_song_lyrics_28jun2026.sql, so they resolve from the library.
--   No placeholders expected -- the verify query at the end should
--   return zero rows.
--
-- ORDER OF SERVICE: 11 items. Two announcement moments this week --
-- Social Media and Online Giving -- both live in plan_speakers only
-- (no slides of their own). Closing Prayer is Brother Ernest.
-- Benediction is TBC.
--
-- SCRIPTURE: the pre-sermon reading passage is NOT confirmed. The
-- cr_add_scripture_to_plan() calls are left commented below -- fill in
-- the book/chapter/verses once Pastor Shade confirms, uncomment, and
-- re-run this file.
--
-- Idempotent: re-running replaces the plan, items, and speakers for
-- 2026-07-05 cleanly.
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN + SONG SET LIST (control_room_plan_items)
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-07-05';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-07-05',
    'Prayer Postures and War the Room (Pastor Shade Olatoye · General Overseer) — PROVISIONAL set carried from 28 Jun, confirm with worship team; Praise Key of B, rest keys TBC')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  -- 28 Jun -> 21 Jun -> 14 Jun -> song library -> placeholder
  coalesce(
    (select i1.slides from control_room_plan_items i1
       join control_room_plans p1 on p1.id = i1.plan_id
      where p1.service_date = '2026-06-28' and lower(i1.title) = lower(v.title) limit 1),
    (select i2.slides from control_room_plan_items i2
       join control_room_plans p2 on p2.id = i2.plan_id
      where p2.service_date = '2026-06-21' and lower(i2.title) = lower(v.title) limit 1),
    (select i3.slides from control_room_plan_items i3
       join control_room_plans p3 on p3.id = i3.plan_id
      where p3.service_date = '2026-06-14' and lower(i3.title) = lower(v.title) limit 1),
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- PRAISE (Key of B) -- resolves from 28 Jun
  (1, 'song', 'These Are the Days of Elijah', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"These Are the Days of Elijah"}]'),
  (2, 'song', 'Lord I Lift Your Name on High', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Lord I Lift Your Name on High"}]'),
  (3, 'song', 'Ancient of Days / Blessing and Honour', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Ancient of Days / Blessing and Honour"}]'),

  -- WORSHIP (Key TBC)
  (4, 'song', 'Here I Am to Worship', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Here I Am to Worship"}]'),
  (5, 'song', 'Be Magnified', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Be Magnified"}]'),
  (6, 'song', 'Jesus at the Centre', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Jesus at the Centre"}]'),

  -- OFFERING (Key TBC)
  (7, 'song', 'Awesome God, Mighty God', 'offering',
    '[{"line1":"[lyrics to be added]","line2":"Awesome God, Mighty God"}]'),

  -- END OF SERVICE (Key TBC)
  (8, 'song', 'Thank You Lord', 'end',
    '[{"line1":"[lyrics to be added]","line2":"Thank You Lord"}]')

) as v(position, kind, title, section, fallback);

-- --------------------------------------------------------------------
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- --------------------------------------------------------------------

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-07-05');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading',   'Pastor Shade Olatoye',   null),
  (2,  'Opening Prayer',            'Pastor Kemi Ogungbenro', null),
  (3,  'Worship',                   null,                     'Worship Team · PROVISIONAL set (carried from 28 Jun) · Praise Key of B, rest TBC'),
  (4,  'Communion',                 'Pastor Gbenga Adebanjo', null),
  (5,  'Announcements',             'Pastor Gbenga Adebanjo', null),
  (6,  'Social Media Announcement', 'Media Team',             'Slide / QR on screen'),
  (7,  'Online Giving Announcement','TBC',                    'Giving slide on screen · lead + content to confirm'),
  (8,  'Bible Reading',             'Noah Femi-Ade',          'Passage TBC'),
  (9,  'Sermon',                    'Pastor Shade Olatoye',   'Prayer Postures and War the Room · General Overseer'),
  (10, 'Closing Prayer',            'Brother Ernest',         null),
  (11, 'Benediction',               'TBC',                    null)
) as v(position, role, name, notes)
where p.service_date = '2026-07-05';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE -- pre-sermon reading (Noah Femi-Ade · KJV)
-- PASSAGE NOT YET CONFIRMED. Once Pastor Shade confirms the reading,
-- fill in book/chapter/verses, uncomment, and re-run. Positions start
-- at 98 so they don't collide with song positions. KJV is already
-- seeded in control_room_bible, so no verse inserts are needed.
-- --------------------------------------------------------------------

-- select cr_add_scripture_to_plan(
--   p_service_date => '2026-07-05'::date,
--   p_position     => 98,
--   p_book         => '<Book>',
--   p_chapter      => <chapter>,
--   p_verse_start  => <start>,
--   p_verse_end    => <end>,
--   p_section      => 'reading',
--   p_version      => 'KJV'
-- ) as reading_item_id;

-- --------------------------------------------------------------------
-- 4. VERIFY
-- --------------------------------------------------------------------

-- Plan summary
select p.service_date, p.notes,
       count(distinct i.id) filter (where i.kind = 'song')      as songs,
       count(distinct i.id) filter (where i.kind = 'scripture') as scriptures,
       sum(jsonb_array_length(i.slides))                        as total_slides,
       count(distinct s.id)                                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-07-05'
group by p.service_date, p.notes;

-- Which songs still need lyrics added? (should be ZERO rows)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-05'
  and i.kind = 'song'
  and (i.slides::text like '%to be added%' or i.slides::text like '%plan]%')
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-05'
order by i.position;

-- Order of service speakers
select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-07-05'
order by s.position;

-- ============================================================
-- 30_setlist_12jul2026.sql
-- ============================================================
-- Sunday 12th July 2026
--   Sermon: "I Will Not Be Ungrateful To You LORD"
--           (Pastor Kayode Ogungbenro)
--   Pre-sermon reading: PASSAGE TBC (Sister Petty Femi-Ade · KJV)
--   Also today: Birthday Thanksgiving (praise & dance, cutting of
--   the cake, prayers for the celebrant & family) led by Pastor
--   Shade Olatoye.
--
-- Seeds the plan for the Control Room: plan + order of service.
--
-- WORSHIP SET: NOT YET CONFIRMED. The worship team had not finalised
-- this Sunday's songs when this plan was seeded, so NO song items are
-- inserted here on purpose (nothing is carried over from last week).
-- When the set lands, add a section-4 song-items block (copy the
-- coalesce pattern from 26_setlist_05jul2026.sql) and re-run this file.
--
-- SCRIPTURE: the pre-sermon reading passage is NOT confirmed. The
-- cr_add_scripture_to_plan() call is left commented below -- fill in
-- book/chapter/verses once confirmed, uncomment, re-run.
--
-- Idempotent: re-running replaces the plan and speakers for
-- 2026-07-12 cleanly.
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN (control_room_plans)
--    No song items yet -- worship set to be confirmed (see header).
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-07-12';

insert into control_room_plans (service_date, notes)
values ('2026-07-12',
  'I Will Not Be Ungrateful To You LORD (Pastor Kayode Ogungbenro). Birthday Thanksgiving today (praise & dance, cake, prayers) led by Pastor Shade. WORSHIP SET TBC -- no songs seeded yet; add song items and re-run once the team confirms.');

-- --------------------------------------------------------------------
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- --------------------------------------------------------------------

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-07-12');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading',   'Pastor Shade Olatoye',    null),
  (2,  'Opening Prayer',            'Tinu Ibitoye',            null),
  (3,  'Worship',                   null,                      'Worship Team · set TBC, keys at soundcheck'),
  (4,  'Communion',                 'Pastor Shade Olatoye',    null),
  (5,  'Media Awareness',           'Pastor Gbenga Adebanjo',  'Awareness slide on screen'),
  (6,  'Announcements',             'Pastor Gbenga Adebanjo',  null),
  (7,  'Bible Reading',             'Sister Petty Femi-Ade',   'Passage TBC'),
  (8,  'Sermon',                    'Pastor Kayode Ogungbenro','I Will Not Be Ungrateful To You LORD'),
  (9,  'Birthday Thanksgiving',     'Pastor Shade Olatoye',    'Praise & dance · cutting of the cake · prayers for the celebrant & family'),
  (10, 'Closing Prayer & Benediction','Brother Ernest Omoregie',null),
  (11, 'Photographs',              'Pastor Kayode Ogungbenro','Take-away reminder: don''t leave without your own')
) as v(position, role, name, notes)
where p.service_date = '2026-07-12';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE -- pre-sermon reading (Sister Petty Femi-Ade · KJV)
-- PASSAGE NOT YET CONFIRMED. Once confirmed, fill in book/chapter/
-- verses, uncomment, and re-run. Position 98 so it doesn't collide
-- with song positions. KJV is already seeded in control_room_bible.
-- --------------------------------------------------------------------

-- select cr_add_scripture_to_plan(
--   p_service_date => '2026-07-12'::date,
--   p_position     => 98,
--   p_book         => '<Book>',
--   p_chapter      => <chapter>,
--   p_verse_start  => <start>,
--   p_verse_end    => <end>,
--   p_section      => 'reading',
--   p_version      => 'KJV'
-- ) as reading_item_id;

-- --------------------------------------------------------------------
-- 4. SONG SET LIST -- NOT SEEDED (worship set TBC).
-- When the team confirms songs, paste a block like this (canonical
-- titles so lyrics resolve from prior plans / control_room_songs),
-- then re-run this whole file:
--
-- with plan as (select id from control_room_plans where service_date='2026-07-12')
-- insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
-- select (select id from plan), v.position, v.kind, v.title, v.section,
--   coalesce(
--     (select s.slides from control_room_songs s where lower(s.title)=lower(v.title) limit 1),
--     v.fallback::jsonb)
-- from (values
--   (1,'song','<Praise song>','praise','[{"line1":"[lyrics to be added]","line2":"<Title>"}]')
--   -- ...more rows...
-- ) as v(position,kind,title,section,fallback);
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- 5. VERIFY
-- --------------------------------------------------------------------

-- Plan summary (expect 0 songs until the set is seeded)
select p.service_date, p.notes,
       count(distinct i.id) filter (where i.kind = 'song')      as songs,
       count(distinct i.id) filter (where i.kind = 'scripture') as scriptures,
       coalesce(sum(jsonb_array_length(i.slides)), 0)           as total_slides,
       count(distinct s.id)                                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-07-12'
group by p.service_date, p.notes;

-- Which songs still need lyrics added? (none seeded yet -- expect 0 rows)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-12'
  and i.kind = 'song'
  and (i.slides::text like '%to be added%' or i.slides::text like '%plan]%')
order by i.position;

-- Order of service speakers
select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-07-12'
order by s.position;

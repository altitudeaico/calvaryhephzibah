-- ============================================================
-- 36_setlist_19jul2026.sql
-- ============================================================
-- Sunday 19th July 2026
--   Sermon: "True GOD, True Hope: Why The Nicene Creed"
--           (Rev Ifeayinchukwu Obi -- GUEST MINISTER)
--   Pre-sermon reading: John 1:1-14 (Reader TBC - KJV)
--
-- Seeds the full plan for the Control Room: plan + song set list +
-- order of service + scripture.
--
-- SET LIST (confirmed by Bolaji):
--     Praise   : These Are the Days of Elijah ·
--                Lord I Lift Your Name on High ·
--                Ancient of Days / Blessing and Honour
--     Worship  : Here I Am to Worship · Be Magnified ·
--                Jesus at the Centre
--     Offering : Awesome God, Mighty God
--     End      : Thank You Lord
--   Keys are set at soundcheck (none confirmed in advance).
--
-- LYRICS resolution (coalesce, first hit wins) -- ALL EIGHT SONGS
-- ALREADY HAVE REAL LYRICS, so NO placeholders and NO companion
-- lyrics file is needed this week:
--   Resolve from control_room_songs (persistent library):
--       These Are the Days of Elijah, Lord I Lift Your Name on High,
--       Ancient of Days / Blessing and Honour, Jesus at the Centre,
--       Awesome God Mighty God, Thank You Lord.
--   Resolve from the 2026-06-28 plan (real lyrics live there, never
--   promoted to the library):
--       Here I Am to Worship, Be Magnified.
--
--   Bolaji wrote the set as: "These are the days" -> canonical
--   "These Are the Days of Elijah"; "Lord I Lift" -> "Lord I Lift
--   Your Name on High"; "Ancient of Days" -> "Ancient of Days /
--   Blessing and Honour" (the canonical Calvary anthem title);
--   "Thank you lord x3..." -> "Thank You Lord". Titles are spelled
--   canonically here so lyrics resolve.
--
-- ORDER OF SERVICE: Welcome & Bible Reading, Opening Prayer, Worship,
-- Communion, Media Awareness + Announcements, pre-sermon reading,
-- sermon, closing prayer, benediction. Speaker-only items live in
-- plan_speakers.
--
-- SCRIPTURE: pre-sermon reading John 1:1-14 (KJV) IS confirmed and is
-- seeded below via cr_add_scripture_to_plan(). Reader name still TBC
-- (does not affect the Control Room cue).
--
-- Idempotent: re-running replaces the plan, items, speakers, and
-- scripture for 2026-07-19 cleanly.
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN + SONG SET LIST (control_room_plan_items)
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-07-19';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-07-19',
    'True GOD, True Hope: Why The Nicene Creed (Rev Ifeayinchukwu Obi, guest minister). Pre-sermon reading John 1:1-14 (KJV). All eight songs have real lyrics (library + 28 Jun plan); keys set at soundcheck.')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  coalesce(
    -- persistent library (resolves 6 of the 8)
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    -- 28 Jun plan carries real lyrics for Here I Am to Worship + Be Magnified
    (select i1.slides from control_room_plan_items i1
       join control_room_plans p1 on p1.id = i1.plan_id
      where p1.service_date = '2026-06-28' and lower(i1.title) = lower(v.title) limit 1),
    -- backstops (recent plans), then placeholder
    (select i2.slides from control_room_plan_items i2
       join control_room_plans p2 on p2.id = i2.plan_id
      where p2.service_date = '2026-07-12' and lower(i2.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- PRAISE
  (1, 'song', 'These Are the Days of Elijah', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"These Are the Days of Elijah"}]'),
  (2, 'song', 'Lord I Lift Your Name on High', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Lord I Lift Your Name on High"}]'),
  (3, 'song', 'Ancient of Days / Blessing and Honour', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Ancient of Days / Blessing and Honour"}]'),

  -- WORSHIP
  (4, 'song', 'Here I Am to Worship', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Here I Am to Worship"}]'),
  (5, 'song', 'Be Magnified', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Be Magnified"}]'),
  (6, 'song', 'Jesus at the Centre', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Jesus at the Centre"}]'),

  -- OFFERING
  (7, 'song', 'Awesome God, Mighty God', 'offering',
    '[{"line1":"[lyrics to be added]","line2":"Awesome God, Mighty God"}]'),

  -- END OF SERVICE
  (8, 'song', 'Thank You Lord', 'end',
    '[{"line1":"[lyrics to be added]","line2":"Thank You Lord"}]')

) as v(position, kind, title, section, fallback);

-- --------------------------------------------------------------------
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- --------------------------------------------------------------------

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-07-19');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading',   'Pastor Gbenga Adebanjo',   null),
  (2,  'Opening Prayer',            'Sister Yinka Osipitan',    null),
  (3,  'Worship',                   null,                       'Worship Team · keys set at soundcheck'),
  (4,  'Communion',                 'Pastor Gbenga Adebanjo',   null),
  (5,  'Media Awareness',           'Pastor Gbenga Adebanjo',   'Slide / QR on screen'),
  (6,  'Announcements',             'Pastor Kayode Ogungbenro', null),
  (7,  'Bible Reading',             null,                       'John 1:1-14 · KJV · reader TBC'),
  (8,  'Sermon',                    'Rev Ifeayinchukwu Obi',    'Guest Minister · True GOD, True Hope: Why The Nicene Creed'),
  (9,  'Closing Prayer',            'Pastor Kemi Ogungbenro',   null),
  (10, 'Benediction',               'Sister Petty',             null)
) as v(position, role, name, notes)
where p.service_date = '2026-07-19';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE -- pre-sermon reading John 1:1-14 (KJV)
-- Position 98 so it doesn't collide with song positions. KJV is already
-- seeded in control_room_bible, so no verse inserts are needed.
-- --------------------------------------------------------------------

select cr_add_scripture_to_plan(
  p_service_date => '2026-07-19'::date,
  p_position     => 98,
  p_book         => 'John',
  p_chapter      => 1,
  p_verse_start  => 1,
  p_verse_end    => 14,
  p_section      => 'reading',
  p_version      => 'KJV'
) as reading_item_id;

-- --------------------------------------------------------------------
-- 4. VERIFY
-- --------------------------------------------------------------------

-- Plan summary
select p.service_date, p.notes,
       count(distinct i.id) filter (where i.kind = 'song')      as songs,
       count(distinct i.id) filter (where i.kind = 'scripture') as scriptures,
       coalesce(sum(jsonb_array_length(i.slides)), 0)           as total_slides,
       count(distinct s.id)                                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-07-19'
group by p.service_date, p.notes;

-- Which songs still need lyrics? (expect ZERO rows this week)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-19'
  and i.kind = 'song'
  and (i.slides::text like '%to be added%' or i.slides::text like '%plan]%')
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-19'
order by i.position;

-- Order of service speakers
select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-07-19'
order by s.position;

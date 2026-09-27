-- ============================================================
-- 81_setlist_27sep2026.sql
-- ============================================================
-- Sunday 27th September 2026
--   Sermon: "Can Two Walk Together Except They Agree?"
--   Preacher: Bishop Henry Emmanuel (Guest Minister)
--   Pre-sermon Bible Reading: Sister Tash Campbell
--     Daniel 5:10-12 · Acts 11:25-26 (KJV, already in control_room_bible)
--
-- Seeds the plan + order of service + scripture for the Control Room.
-- Idempotent: re-running replaces the plan, speakers and scripture
-- for 2026-09-27 cleanly.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
--
-- SET LIST -- identical to 20 Sep 2026 (confirmed "same as the
-- previous week"). Canonical titles copied exactly from 71:
--     Praise   : These Are the Days of Elijah / Lord I Lift Your Name
--                on High / Open the Eyes of My Heart, Lord
--     Worship  : I Will Worship / Heart of Worship / Jesus at the Centre
--     Offering : Give Thanks to the Lord
--     End      : Thank You Lord (Don Moen)
-- KEYS: all TBC, set at the Sunday soundcheck.
--
-- FLAG: Offering was not itemised in the order of service as sent.
-- Added back at position 9 (usual post-sermon slot). No leader named.
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN (control_room_plans) + song set list
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-09-27';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-09-27',
    'Can Two Walk Together Except They Agree? (Bishop Henry Emmanuel, Guest Minister). Same set as 20 Sep 2026, song for song; all 8 resolve from last week''s plan. ALL KEYS TBC, set at the Sunday soundcheck. Scripture: Daniel 5:10-12 and Acts 11:25-26 (KJV), read by Sister Tash Campbell. Offering not itemised in the order of service as sent; added back in its usual post-sermon slot since the worship set includes an Offering song; no offering leader named.')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  coalesce(
    -- most recent prior plan with the same title
    (select i2.slides
     from control_room_plan_items i2
     join control_room_plans p2 on p2.id = i2.plan_id
     where lower(i2.title) = lower(v.title) and i2.kind = 'song'
       and p2.service_date < '2026-09-27'
     order by p2.service_date desc
     limit 1),
    -- persistent library
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    -- explicit fallback -- placeholder only, should never be hit
    v.fallback::jsonb
  )
from (values

  (1, 'song', 'These Are the Days of Elijah', 'praise',
    '[{"line1": "[lyrics to be added]", "line2": "These Are the Days of Elijah"}]'),

  (2, 'song', 'Lord I Lift Your Name on High', 'praise',
    '[{"line1": "[lyrics to be added]", "line2": "Lord I Lift Your Name on High"}]'),

  (3, 'song', 'Open the Eyes of My Heart, Lord', 'praise',
    '[{"line1": "[lyrics to be added]", "line2": "Open the Eyes of My Heart, Lord"}]'),

  (4, 'song', 'I Will Worship', 'worship',
    '[{"line1": "[lyrics to be added]", "line2": "I Will Worship"}]'),

  (5, 'song', 'Heart of Worship', 'worship',
    '[{"line1": "[lyrics to be added]", "line2": "Heart of Worship"}]'),

  (6, 'song', 'Jesus at the Centre', 'worship',
    '[{"line1": "[lyrics to be added]", "line2": "Jesus at the Centre"}]'),

  (7, 'song', 'Give Thanks to the Lord', 'offering',
    '[{"line1": "[lyrics to be added]", "line2": "Give Thanks to the Lord"}]'),

  (8, 'song', 'Thank You Lord (Don Moen)', 'end',
    '[{"line1": "[lyrics to be added]", "line2": "Thank You Lord (Don Moen)"}]')

) as v(position, kind, title, section, fallback);

-- --------------------------------------------------------------------
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- --------------------------------------------------------------------

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-09-27');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading', 'Ps Gbenga Adebanjo',       null),
  (2,  'Opening Prayer',          'Sister Petty',             null),
  (3,  'Worship',                 null,                       'Worship Team · same set as 20 Sep · all keys TBC, set at soundcheck'),
  (4,  'Communion',               'Ps Kayode Ogungbenro',     null),
  (5,  'Media Awareness',         'Pastor Gbenga Adebanjo',   null),
  (6,  'Announcements',           'Pastor Kayode Ogungbenro', null),
  (7,  'Bible Reading',           'Sister Tash Campbell',     'Daniel 5:10-12 · Acts 11:25-26 (KJV)'),
  (8,  'Sermon',                  'Bishop Henry Emmanuel',    'Can Two Walk Together Except They Agree? · Guest Minister'),
  (9,  'Offering',                null,                       'Give Thanks to the Lord · FLAG: not itemised in the order as sent, added back in usual slot · no offering leader named'),
  (10, 'Closing Prayer',          'Brother Ernest',           null),
  (11, 'Benediction',             'Ps Funke Adebanjo',        null)
) as v(position, role, name, notes)
where p.service_date = '2026-09-27';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE (cr_add_scripture_to_plan)
-- --------------------------------------------------------------------
select cr_add_scripture_to_plan(
  p_service_date => '2026-09-27'::date, p_position => 98,
  p_book => 'Daniel', p_chapter => 5, p_verse_start => 10, p_verse_end => 12,
  p_section => 'reading', p_version => 'KJV');

select cr_add_scripture_to_plan(
  p_service_date => '2026-09-27'::date, p_position => 99,
  p_book => 'Acts', p_chapter => 11, p_verse_start => 25, p_verse_end => 26,
  p_section => 'reading', p_version => 'KJV');

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 4. VERIFY
-- --------------------------------------------------------------------

-- Plan summary. Expect: songs = 8, scriptures = 2, speakers = 11.
select p.service_date, p.notes,
       count(distinct i.id) filter (where i.kind = 'song')      as songs,
       count(distinct i.id) filter (where i.kind = 'scripture') as scriptures,
       coalesce(sum(jsonb_array_length(i.slides)), 0)           as total_slides,
       count(distinct s.id)                                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-09-27'
group by p.service_date, p.notes;

-- Which songs still need lyrics? Expect NONE -- all 8 resolve from
-- last week's plan.
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-09-27'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-09-27'
order by i.position;

-- Order of service speakers, with anything still needing input
select s.position, s.role, coalesce(s.name, '--') as name,
       case when s.notes like 'FLAG:%' or s.notes like '%FLAG:%' then 'NEEDS INPUT' else '' end as flag,
       s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-09-27'
order by s.position;

-- ============================================================
-- 59_setlist_23aug2026.sql
-- ============================================================
-- Sunday 23rd August 2026
--   Sermon: "Living Under The Rule Of The KING: Entering,
--            Experiencing and Manifesting The Kingdom Of GOD"
--            (Rev Ifeayinchukwu Obi -- GUEST MINISTER)
--   Pre-sermon reading: John 3:3-7 (KJV) -- READER NOT NAMED
--
-- Seeds the plan + order of service + scripture for the Control
-- Room. Idempotent: re-running replaces the plan, speakers and
-- scripture for 2026-08-23 cleanly.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
--
-- ------------------------------------------------------------
-- >> NO SONGS SEEDED THIS WEEK <<
-- ------------------------------------------------------------
-- The worship set was NOT supplied with the order of service.
-- Nothing has been invented: this file seeds ZERO song rows, so
-- the plan carries the running order and the scripture only.
--
-- When the set arrives, add a follow-up file
--   60_setlist_songs_23aug2026.sql
-- that inserts the song rows into control_room_plan_items against
-- this same plan, using the usual coalesce resolution chain:
--
--   coalesce(
--     (select s.slides from control_room_songs s
--       where lower(s.title) = lower(v.title) limit 1),
--     (select i.slides from control_room_plan_items i
--        join control_room_plans p on p.id = i.plan_id
--       where p.service_date = '2026-08-16'
--         and lower(i.title) = lower(v.title) limit 1),
--     v.fallback::jsonb
--   )
--
-- Titles must be canonical -- resolution matches on lower(title).
-- Grep prior setlist SQL for the exact string a song is stored
-- under before typing a new one.
--
-- ------------------------------------------------------------
-- FLAGS
-- ------------------------------------------------------------
-- 1. WORSHIP SET -- missing entirely (see above). This also
--    blocks the stage runthrough page and its OG card, which are
--    pure song content. Neither was built for 23 Aug.
--
-- 2. BIBLE READING -- John 3:3-7 given with NO reader named.
--    Seeded with name = null. Fill in before Sunday.
--
-- 3. MEDIA AWARENESS -- listed on the order of service with no
--    leader named. Seeded with name = null. On 16 Aug this slot
--    was Pastor Kayode Ogungbenro; do not assume it is him again.
--
-- 4. PREACHER NAME SPELLING -- spelled "Ifeayinchukwu" as given,
--    which matches all 30 existing occurrences across the repo
--    (9 Aug briefing, thumbnail, 54_preacher_ifeayinchukwu_obi.sql,
--    portrait filename). It has also appeared as "Ifeanyichukwu"
--    (21 June 2026). Still unresolved -- confirm with Rev Obi.
--    If it changes, it changes in every published asset at once.
--
-- 5. CONTINUITY -- this is the second Sunday in Rev Obi's kingdom
--    thread: 9 Aug was "Enter Into The Kingdom -- The Pathway To
--    The Abundant Life". Not formally badged as a series.
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN (control_room_plans) -- no song items this week
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-08-23';

insert into control_room_plans (service_date, notes)
values ('2026-08-23',
  'Living Under The Rule Of The KING: Entering, Experiencing and Manifesting The Kingdom Of GOD (Rev Ifeayinchukwu Obi, guest minister). Reading John 3:3-7 KJV. NO WORSHIP SET SUPPLIED -- zero song items seeded; add them via 60_setlist_songs_23aug2026.sql once the set is confirmed. Bible reader and Media Awareness leader both unnamed on the order of service.');

-- --------------------------------------------------------------------
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- --------------------------------------------------------------------

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-08-23');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading',  'Pastor Shade Olatoye',  null),
  (2,  'Opening Prayer',           'Sister Lisa',           null),
  (3,  'Worship',                  null,                    'FLAG: Worship Team -- set list not supplied, all keys TBC'),
  (4,  'Communion',                'Pastor Shade Olatoye',  null),
  (5,  'Media Awareness',          null,                    'FLAG: no leader named on the order of service'),
  (6,  'Announcements',            'Brother Ernest',        null),
  (7,  'Bible Reading',            null,                    'FLAG: no reader named -- John 3:3-7 · KJV'),
  (8,  'Sermon',                   'Rev Ifeayinchukwu Obi', 'Guest Minister · Living Under The Rule Of The KING: Entering, Experiencing and Manifesting The Kingdom Of GOD'),
  (9,  'Closing Prayer',           'Sister Petty',          null),
  (10, 'Benediction',              'Deacon Femi Osipitan',  null)
) as v(position, role, name, notes)
where p.service_date = '2026-08-23';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE (cr_add_scripture_to_plan)
-- --------------------------------------------------------------------

-- John 3:3-7 -- the new birth. "Except a man be born again, he cannot
-- see the kingdom of God" is the hinge the whole sermon title turns on:
-- entering the kingdom is a birth, not an achievement.
select cr_add_scripture_to_plan(
  p_service_date => '2026-08-23'::date,
  p_position     => 98,
  p_book         => 'John',
  p_chapter      => 3,
  p_verse_start  => 3,
  p_verse_end    => 7,
  p_section      => 'reading',
  p_version      => 'KJV'
);

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 4. VERIFY
-- --------------------------------------------------------------------

-- Plan summary. Expect: songs = 0, scriptures = 1, speakers = 10.
select p.service_date, p.notes,
       count(distinct i.id) filter (where i.kind = 'song')      as songs,
       count(distinct i.id) filter (where i.kind = 'scripture') as scriptures,
       coalesce(sum(jsonb_array_length(i.slides)), 0)           as total_slides,
       count(distinct s.id)                                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-08-23'
group by p.service_date, p.notes;

-- Which songs still need lyrics?
-- Expect ZERO rows -- because there are no songs at all yet, not
-- because everything resolved. Do not read an empty result as "done".
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-23'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-23'
order by i.position;

-- Order of service speakers, with anything still needing input
select s.position, s.role, coalesce(s.name, '--') as name,
       case when s.notes like 'FLAG:%' then 'NEEDS INPUT' else '' end as flag,
       s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-08-23'
order by s.position;

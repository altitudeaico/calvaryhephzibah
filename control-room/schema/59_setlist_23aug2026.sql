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
-- SET LIST -- NINE songs, supplied late by Bolaji Adebanjo on
-- 23 August: "we're keeping to the same set from last week". It is
-- the 16 August set unchanged, same order, same sections.
--     Praise   : Trading My Sorrows .
--                Lord You Are Good .
--                Friend of God .
--                Every Praise
--     Worship  : Let Praises Rise .
--                Spirit Break Out .
--                How Great Is Our God
--     Offering : Higher, Every Day
--     End      : You Are Worthy
--
-- KEYS ARE ALL "TBC" again -- none were given, same as 16 August.
-- Set at the Sunday soundcheck. Deliberate state, not missing data.
--
-- TITLE CANONICALISATION (so lyrics resolve on lower(title)):
--   "Higher higher everyday"              -> 'Higher, Every Day'
--   "Worthy, king of kings lord of lords" -> 'You Are Worthy'
--   These are the same two corrections made on 16 August. Do not
--   seed the verbatim strings -- resolution matches on lower(title)
--   and would miss.
--
-- LYRICS: all nine should resolve real slides. Eight come from
-- control_room_songs; "Let Praises Rise" was new to Calvary on
-- 16 August and its lyrics were added by 58_song_lyrics_16aug2026.sql,
-- so it resolves from the library too now. The 2026-08-16 plan is
-- kept as a backstop in the coalesce chain regardless. If the verify
-- query at the bottom returns ANY row, 58_ has not been run in this
-- database -- run it, then re-run this file.
--
-- ------------------------------------------------------------
-- FLAGS
-- ------------------------------------------------------------
-- 1. "EVERY PRAISE" WAS GIVEN WITH A QUESTION MARK -- again. It
--    carried the same question mark on 16 August and was never
--    resolved either way. Seeded IN at position 4: a song that gets
--    dropped costs nothing, a song that is missing cannot be pushed
--    to the screen. CONFIRM WITH THE WORSHIP TEAM. If it is out,
--    delete the position-4 row and re-run; positions do not need
--    renumbering for the Control Room to work.
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

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-08-23',
    'Living Under The Rule Of The KING: Entering, Experiencing and Manifesting The Kingdom Of GOD (Rev Ifeayinchukwu Obi, guest minister). Nine discrete songs, no medley -- the 16 August set repeated unchanged, confirmed late by Bolaji Adebanjo. ALL KEYS TBC, set at the Sunday soundcheck. Every Praise carries a question mark for the second week running and is seeded in pending confirmation. Reading: John 3:3-7 KJV. Bible reader and Media Awareness leader both unnamed on the order of service.')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  coalesce(
    -- persistent library (should resolve all nine)
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    -- backstops: the two most recent plans, same set list
    (select i1.slides from control_room_plan_items i1
       join control_room_plans p1 on p1.id = i1.plan_id
      where p1.service_date = '2026-08-16' and lower(i1.title) = lower(v.title) limit 1),
    (select i2.slides from control_room_plan_items i2
       join control_room_plans p2 on p2.id = i2.plan_id
      where p2.service_date = '2026-08-09' and lower(i2.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- PRAISE -- key TBC
  (1, 'song', 'Trading My Sorrows', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Trading My Sorrows"}]'),
  (2, 'song', 'Lord You Are Good', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Lord You Are Good"}]'),
  (3, 'song', 'Friend of God', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Friend of God"}]'),
  -- FLAG: given with a question mark for the SECOND week. Seeded in -- confirm.
  (4, 'song', 'Every Praise', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Every Praise"}]'),

  -- WORSHIP -- key TBC, three discrete songs (no medley)
  -- Lyrics added 15 Aug by 58_song_lyrics_16aug2026.sql; resolves from library.
  (5, 'song', 'Let Praises Rise', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Let Praises Rise"}]'),
  (6, 'song', 'Spirit Break Out', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Spirit Break Out"}]'),
  (7, 'song', 'How Great Is Our God', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"How Great Is Our God"}]'),

  -- OFFERING -- key TBC
  (8, 'song', 'Higher, Every Day', 'offering',
    '[{"line1":"[lyrics to be added]","line2":"Higher, Every Day"}]'),

  -- END OF SERVICE -- key TBC
  (9, 'song', 'You Are Worthy', 'end',
    '[{"line1":"[lyrics to be added]","line2":"You Are Worthy"}]')

) as v(position, kind, title, section, fallback);

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
  (3,  'Worship',                  null,                    'Worship Team · nine songs, 16 Aug set repeated · all keys TBC, set at soundcheck'),
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

-- Plan summary. Expect: songs = 9, scriptures = 1, speakers = 10.
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
-- Expect ZERO rows. Any row here means the library lookup missed --
-- almost always because 58_song_lyrics_16aug2026.sql has not been run
-- in this database, or because a title was typed non-canonically.
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

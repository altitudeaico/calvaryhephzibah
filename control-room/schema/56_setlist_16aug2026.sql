-- ============================================================
-- 56_setlist_16aug2026.sql
-- ============================================================
-- Sunday 16th August 2026
--   THE ALTARS SERIES -- part 3 of 3
--   Sermon: "Altars and the Believer's Victory"
--           (Dr Titi Sodipo)
--   Pre-sermon reading: Sister Lisa -- Ephesians 6:10-18 (KJV)
--
-- Seeds the full plan for the Control Room: plan + song set list +
-- order of service + the scripture reading.
--
-- SERIES CONTEXT -- this is episode 3:
--     1. "Altars"       -- 26 July 2026
--     2. "Family Altar" -- 2 August 2026
--     3. "Altars and the Believer's Victory" -- THIS ONE
--
-- SET LIST -- NINE songs. KEYS ARE ALL "TBC": none were agreed in
-- advance this week, so they get set at the Sunday soundcheck. That
-- is a correct, deliberate state -- not missing data.
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
-- No medley this week -- unlike 9 August, the three worship songs
-- are discrete. Nothing runs together unless the team calls it on
-- the day.
--
-- TITLE CANONICALISATION (so lyrics resolve on lower(title)):
--   "Higher higher everyday"              -> 'Higher, Every Day'
--   "Worthy, king of kings lord of lords" -> 'You Are Worthy'
--
-- LYRICS resolution (coalesce, first hit wins):
--   EIGHT of the nine resolve from control_room_songs:
--       Trading My Sorrows, Lord You Are Good, Friend of God,
--       Every Praise, Spirit Break Out, How Great Is Our God,
--       Higher, Every Day, You Are Worthy.
--   (Spirit Break Out was seeded by 18_song_lyrics_24may2026.sql;
--    How Great Is Our God by 20_song_lyrics_31may2026.sql;
--    You Are Worthy by 52_song_lyrics_09aug2026.sql.)
--
--   >> ONE SONG HAS NO LYRICS ANYWHERE:
--   >>   "Let Praises Rise" (worship, position 5)
--   >> This song is NEW to Calvary -- it appears in no prior plan and
--   >> in no library entry. It is seeded with a PLACEHOLDER slide so
--   >> the plan is complete and the verify query flags it. Nothing
--   >> usable will push to the screen for this song until the lyrics
--   >> are supplied and added via a 58_song_lyrics_16aug2026.sql
--   >> upsert.
--
-- FLAG -- "EVERY PRAISE" WAS GIVEN WITH A QUESTION MARK:
--   The order of service listed it as uncertain. It is seeded IN, at
--   position 4, because a song that is dropped costs nothing but a
--   song that is missing cannot be pushed to the screen. CONFIRM
--   WITH THE WORSHIP TEAM before Sunday. If it is out, delete the
--   position-4 row and re-run; positions do not need renumbering for
--   the Control Room to work.
--
-- FLAG -- NO GUEST-MINISTER LABEL THIS WEEK:
--   Dr Titi Sodipo was seeded as "guest minister" for 2 August
--   (45_setlist_02aug2026.sql). She is deliberately NOT labelled a
--   guest minister here. Do not re-add the badge.
--
-- Idempotent: re-running replaces the plan, items, speakers and
-- scripture for 2026-08-16 cleanly.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN + SONG SET LIST (control_room_plan_items)
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-08-16';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-08-16',
    'Altars and the Believer''s Victory (Dr Titi Sodipo) -- The Altars Series, part 3 of 3. Nine discrete songs, no medley. ALL KEYS TBC: none agreed in advance, set at the Sunday soundcheck. Eight of nine resolve real lyrics from the library; Let Praises Rise is a PLACEHOLDER pending lyrics -- it is new to Calvary. Every Praise was given with a question mark and is seeded in pending confirmation. Reading: Ephesians 6:10-18 KJV, read by Sister Lisa.')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  coalesce(
    -- persistent library (resolves 8 of the 9)
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    -- backstops: the two most recent plans
    (select i1.slides from control_room_plan_items i1
       join control_room_plans p1 on p1.id = i1.plan_id
      where p1.service_date = '2026-08-09' and lower(i1.title) = lower(v.title) limit 1),
    (select i2.slides from control_room_plan_items i2
       join control_room_plans p2 on p2.id = i2.plan_id
      where p2.service_date = '2026-08-02' and lower(i2.title) = lower(v.title) limit 1),
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
  -- FLAG: given with a question mark. Seeded in -- confirm.
  (4, 'song', 'Every Praise', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Every Praise"}]'),

  -- WORSHIP -- key TBC, three discrete songs (no medley this week)
  -- New to Calvary. NOTHING to resolve from -- expect PLACEHOLDER.
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
  where plan_id in (select id from control_room_plans where service_date = '2026-08-16');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading',   'Pastor Kayode Ogungbenro', null),
  (2,  'Opening Prayer',            'Sister Petty',             null),
  (3,  'Worship',                   null,                       'Worship Team · all keys TBC, set at soundcheck'),
  (4,  'Communion',                 'Pastor Kayode Ogungbenro', null),
  (5,  'Media Awareness',           'Pastor Kayode Ogungbenro', 'Slide / QR on screen'),
  (6,  'Announcements',             'Pastor Kayode Ogungbenro', null),
  (7,  'Bible Reading',             'Sister Lisa',              'Ephesians 6:10-18 · KJV'),
  (8,  'Sermon',                    'Dr Titi Sodipo',           'The Altars Series part 3 · Altars and the Believer''s Victory'),
  (9,  'Closing Prayer',            'Sister Petty',             null),
  (10, 'Benediction',               'Pastor Funke Adebanjo',    null)
) as v(position, role, name, notes)
where p.service_date = '2026-08-16';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE (cr_add_scripture_to_plan)
-- --------------------------------------------------------------------

-- Ephesians 6:10-18 -- the whole armour of God. The warfare passage
-- the sermon is built on: "we wrestle not against flesh and blood".
-- Nine verses, so this is the longest single reading of the series.
select cr_add_scripture_to_plan(
  p_service_date => '2026-08-16'::date,
  p_position     => 98,
  p_book         => 'Ephesians',
  p_chapter      => 6,
  p_verse_start  => 10,
  p_verse_end    => 18,
  p_section      => 'reading',
  p_version      => 'KJV'
);

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 4. VERIFY
-- --------------------------------------------------------------------

-- Plan summary
select p.service_date, p.notes,
       count(distinct i.id) filter (where i.kind = 'song')      as songs,
       count(distinct i.id) filter (where i.kind = 'scripture') as scriptures,
       -- sum() is NOT distinct-guarded, so the speakers join below fans it
       -- out: with 10 speakers it reports 10x the real slide count. Kept
       -- as a sub-select so the number is actually true.
       (select coalesce(sum(jsonb_array_length(i2.slides)), 0)
          from control_room_plan_items i2 where i2.plan_id = p.id) as total_slides,
       count(distinct s.id)                                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-08-16'
group by p.service_date, p.notes;

-- Which songs still need lyrics?
-- Expect EXACTLY ONE row: Let Praises Rise (position 5).
-- If you see more than one, a library title has drifted -- check the
-- canonicalisation notes at the top of this file.
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-16'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-16'
order by i.position;

-- Order of service speakers, with anything still needing input
select s.position, s.role, coalesce(s.name, '--') as name,
       case when s.notes like 'FLAG:%' then 'NEEDS INPUT' else '' end as flag,
       s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-08-16'
order by s.position;

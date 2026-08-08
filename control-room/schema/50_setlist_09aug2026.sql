-- ============================================================
-- 50_setlist_09aug2026.sql
-- ============================================================
-- Sunday 9th August 2026
--   Sermon: "Enter Into The Kingdom" -- The Pathway To The
--           Abundant Life (Rev Ifeayinchukwu Obi -- GUEST MINISTER)
--   Pre-sermon reading: Sister Petty -- Matthew 13:44-45 + John 10:10
--
-- Seeds the full plan for the Control Room: plan + song set list +
-- order of service + both scripture readings.
--
-- SET LIST -- agreed at the worship team rehearsal on Friday
-- 7 August 2026 (see worship-recap-07-aug-2026). Keys were settled
-- on the night, so they are NOT "TBC" this week:
--     Praise (Key of B)   : Trading My Sorrows .
--                           Lord You Are Good .
--                           Friend of God .
--                           Every Praise
--     Worship (Key of Ab) : Lord We Proclaim You Now .
--                           Reign Jesus .
--                           Bow Down and Worship Him
--                           >> these three run as ONE MEDLEY with no
--                           >> stop between them
--     Offering (Key of Ab): Higher, Every Day
--     End (Key of Ab)     : You Are Worthy
--
-- TITLE CANONICALISATION (so lyrics resolve on lower(title)):
--   "Reign Jesus Reign"        -> 'Reign Jesus'
--   "Bow Down and Worship"     -> 'Bow Down and Worship Him'
--   "Higher Higher" / "every day I live for Jesus"
--                              -> 'Higher, Every Day'
--
-- LYRICS resolution (coalesce, first hit wins):
--   SEVEN of the nine resolve from control_room_songs:
--       Trading My Sorrows, Lord You Are Good, Friend of God,
--       Every Praise, Reign Jesus, Bow Down and Worship Him,
--       Higher, Every Day.
--
--   >> TWO SONGS HAVE NO LYRICS ANYWHERE:
--   >>   1. "Lord We Proclaim You Now"  (also known as "Release Your
--   >>      Power" / "Let Your Presence Fall")
--   >>   2. "You Are Worthy"            ("King of kings, Lord of
--   >>      lords, You are worthy")
--   >> Both are seeded with PLACEHOLDER slides so the plan is
--   >> complete and the verify query flags them. Nothing usable will
--   >> push to the screen for these two until the lyrics are supplied
--   >> and added via a 51_song_lyrics_09aug2026.sql upsert.
--
-- FLAG -- SCRIPTURE REFERENCE CORRECTED:
--   The order of service gave the first reading as "Matthew
--   23:44-45". Matthew 23 ends at verse 39, so that reference does
--   not exist. Matthew 13:44-45 is the kingdom parables (hidden
--   treasure, pearl of great price), which is what the sermon title
--   is built on. Seeded here as Matthew 13:44-45. CONFIRM WITH
--   REV OBI before Sunday; if he meant something else, re-run
--   cr_add_scripture_to_plan() at position 98 with the right refs.
--
-- FLAG -- PREACHER NAME SPELLING:
--   Spelled "Ifeayinchukwu" as given in the order of service. It has
--   also appeared as "Ifeanyichukwu" (21 June 2026). Confirm before
--   this goes anywhere public.
--
-- Idempotent: re-running replaces the plan, items, speakers and
-- scripture for 2026-08-09 cleanly.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN + SONG SET LIST (control_room_plan_items)
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-08-09';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-08-09',
    'Enter Into The Kingdom (Rev Ifeayinchukwu Obi, guest minister). Nine songs; the three worship songs run as one medley with no stop. Keys agreed at the 7 Aug rehearsal: praise in B, worship/offering/end in Ab. Seven of nine resolve real lyrics from the library; Lord We Proclaim You Now and You Are Worthy are PLACEHOLDERS pending lyrics. First reading corrected from Matthew 23:44-45 (does not exist) to Matthew 13:44-45 -- confirm with the preacher.')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  coalesce(
    -- persistent library (resolves 7 of the 9)
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    -- backstops: the two most recent plans
    (select i1.slides from control_room_plan_items i1
       join control_room_plans p1 on p1.id = i1.plan_id
      where p1.service_date = '2026-08-02' and lower(i1.title) = lower(v.title) limit 1),
    (select i2.slides from control_room_plan_items i2
       join control_room_plans p2 on p2.id = i2.plan_id
      where p2.service_date = '2026-07-26' and lower(i2.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- PRAISE -- Key of B
  (1, 'song', 'Trading My Sorrows', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Trading My Sorrows"}]'),
  (2, 'song', 'Lord You Are Good', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Lord You Are Good"}]'),
  (3, 'song', 'Friend of God', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Friend of God"}]'),
  (4, 'song', 'Every Praise', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Every Praise"}]'),

  -- WORSHIP MEDLEY -- Key of Ab, all three run together
  -- New to the set. NOTHING to resolve from -- expect PLACEHOLDER.
  (5, 'song', 'Lord We Proclaim You Now', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Lord We Proclaim You Now"}]'),
  (6, 'song', 'Reign Jesus', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Reign Jesus"}]'),
  (7, 'song', 'Bow Down and Worship Him', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Bow Down and Worship Him"}]'),

  -- OFFERING -- Key of Ab
  (8, 'song', 'Higher, Every Day', 'offering',
    '[{"line1":"[lyrics to be added]","line2":"Higher, Every Day"}]'),

  -- END OF SERVICE -- Key of Ab
  -- New to the set. NOTHING to resolve from -- expect PLACEHOLDER.
  (9, 'song', 'You Are Worthy', 'end',
    '[{"line1":"[lyrics to be added]","line2":"You Are Worthy"}]')

) as v(position, kind, title, section, fallback);

-- --------------------------------------------------------------------
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- --------------------------------------------------------------------

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-08-09');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading',   'Pastor Kayode Ogungbenro', null),
  (2,  'Opening Prayer',            'Sister Lisa Richardson',   null),
  (3,  'Worship',                   null,                       'Worship Team · praise in B, worship medley / offering / end in Ab'),
  (4,  'Communion',                 'Pastor Kayode Ogungbenro', null),
  (5,  'Media Awareness',           'Pastor Kayode Ogungbenro', 'Slide / QR on screen'),
  (6,  'Announcements',             'Pastor Kayode Ogungbenro', null),
  (7,  'Bible Reading',             'Sister Petty',             'Matthew 13:44-45 · John 10:10 · KJV'),
  (8,  'Sermon',                    'Rev Ifeayinchukwu Obi',    'Guest Minister · Enter Into The Kingdom: The Pathway To The Abundant Life'),
  (9,  'Closing Prayer',            'Sister Petty',             null),
  (10, 'Benediction',               'Pastor Funke Adebanjo',    null)
) as v(position, role, name, notes)
where p.service_date = '2026-08-09';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE (cr_add_scripture_to_plan)
-- --------------------------------------------------------------------

-- Matthew 13:44-45 -- the kingdom parables: treasure hid in a field,
-- and the merchant seeking goodly pearls. The "enter into" of the
-- sermon title: what a man will sell to get in.
select cr_add_scripture_to_plan(
  p_service_date => '2026-08-09'::date,
  p_position     => 98,
  p_book         => 'Matthew',
  p_chapter      => 13,
  p_verse_start  => 44,
  p_verse_end    => 45,
  p_section      => 'reading',
  p_version      => 'KJV'
);

-- John 10:10 -- life, and life more abundantly. The second half of
-- the sermon title.
select cr_add_scripture_to_plan(
  p_service_date => '2026-08-09'::date,
  p_position     => 99,
  p_book         => 'John',
  p_chapter      => 10,
  p_verse_start  => 10,
  p_verse_end    => 10,
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
       coalesce(sum(jsonb_array_length(i.slides)), 0)           as total_slides,
       count(distinct s.id)                                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-08-09'
group by p.service_date, p.notes;

-- Which songs still need lyrics?
-- Expect EXACTLY TWO rows: Lord We Proclaim You Now, You Are Worthy.
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-09'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-09'
order by i.position;

-- Order of service speakers, with anything still needing input
select s.position, s.role, coalesce(s.name, '--') as name,
       case when s.notes like 'FLAG:%' then 'NEEDS INPUT' else '' end as flag,
       s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-08-09'
order by s.position;

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
-- Seeds the full plan for the Control Room: plan + song set list +
-- order of service.
--
-- SET LIST (confirmed by Bolaji):
--     Praise   (Key of E): Trading My Sorrows · Lord You Are Good ·
--                          Friend of God · Every Praise
--     Worship  (keys at soundcheck):
--                          Oh Be Lifted · Reign Jesus ·
--                          Hallelujah (You Won the Victory) · No Longer Slaves
--     Offering (kept short): We Lift Our Hands in the Sanctuary
--     End      : My Jesus (Shout to the Lord)
--
-- LYRICS resolution (coalesce, first hit wins): library -> placeholder.
--   Resolve now from control_room_songs:
--       We Lift Our Hands in the Sanctuary, Hallelujah (You Won the Victory).
--   Resolve after running 31_song_lyrics_12jul2026.sql (which loads them
--   into the library and patches this plan):
--       Trading My Sorrows, Lord You Are Good, Friend of God, Every Praise,
--       My Jesus (Shout to the Lord).
--   Placeholder until lyrics are loaded (new songs, no lyrics anywhere yet):
--       Oh Be Lifted, Reign Jesus, No Longer Slaves.
--
--   Bolaji wrote the set as: "In the sanctuary" -> canonical
--   "We Lift Our Hands in the Sanctuary"; "Shout to the Lord" ->
--   "My Jesus (Shout to the Lord)"; "Hallelujah" -> "Hallelujah (You
--   Won the Victory)" (the recurring Calvary anthem). Titles are
--   spelled canonically here so lyrics resolve.
--
-- ORDER OF SERVICE: Social Media Announcement + Announcements (Pastor Gbenga),
-- then reading, sermon, Birthday Thanksgiving, closing & benediction
-- (Brother Ernest Omoregie), photographs. Speaker-only items live in
-- plan_speakers.
--
-- SCRIPTURE: the pre-sermon reading passage is NOT confirmed. The
-- cr_add_scripture_to_plan() call is left commented below.
--
-- Idempotent: re-running replaces the plan, items, and speakers for
-- 2026-07-12 cleanly. Run this FIRST, then 31_song_lyrics_12jul2026.sql.
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN + SONG SET LIST (control_room_plan_items)
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-07-12';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-07-12',
    'I Will Not Be Ungrateful To You LORD (Pastor Kayode Ogungbenro). Birthday Thanksgiving today (praise & dance, cake, prayers) led by Pastor Shade. Praise Key of E (lyrics loaded); worship keys at soundcheck; Oh Be Lifted / Reign Jesus / No Longer Slaves need lyrics loaded.')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  coalesce(
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- PRAISE (Key of E)
  (1, 'song', 'Trading My Sorrows', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Trading My Sorrows"}]'),
  (2, 'song', 'Lord You Are Good', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Lord You Are Good"}]'),
  (3, 'song', 'Friend of God', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Friend of God"}]'),
  (4, 'song', 'Every Praise', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Every Praise"}]'),

  -- WORSHIP (keys at soundcheck)
  (5, 'song', 'Oh Be Lifted', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Oh Be Lifted"}]'),
  (6, 'song', 'Reign Jesus', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Reign Jesus"}]'),
  (7, 'song', 'Hallelujah (You Won the Victory)', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Hallelujah (You Won the Victory)"}]'),
  (8, 'song', 'No Longer Slaves', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"No Longer Slaves"}]'),

  -- OFFERING (kept short)
  (9, 'song', 'We Lift Our Hands in the Sanctuary', 'offering',
    '[{"line1":"[lyrics to be added]","line2":"We Lift Our Hands in the Sanctuary"}]'),

  -- END OF SERVICE
  (10, 'song', 'My Jesus (Shout to the Lord)', 'end',
    '[{"line1":"[lyrics to be added]","line2":"My Jesus (Shout to the Lord)"}]')

) as v(position, kind, title, section, fallback);

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
  (3,  'Worship',                   null,                      'Worship Team · Praise Key of E; worship keys at soundcheck'),
  (4,  'Communion',                 'Pastor Shade Olatoye',    null),
  (5,  'Social Media Announcement',   'Pastor Gbenga Adebanjo',  'Slide / QR on screen'),
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
where p.service_date = '2026-07-12'
group by p.service_date, p.notes;

-- Which songs still need lyrics? (before 31: expect 8; after 31: expect the 3 new)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-12'
  and i.kind = 'song'
  and (i.slides::text like '%to be added%' or i.slides::text like '%plan]%')
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-12'
order by i.position;

-- Order of service speakers
select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-07-12'
order by s.position;

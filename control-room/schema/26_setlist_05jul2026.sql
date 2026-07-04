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
-- SET LIST (CONFIRMED at the Tue 3 Jul virtual rehearsal):
--     Praise   (Key of E, 4 choruses back-to-back):
--                          Trading My Sorrows ·
--                          Lord You Are Good ·
--                          Friend of God ·
--                          Every Praise
--     Worship  (6/8, keys set at soundcheck):
--                          King of Glory ·
--                          Indescribable ·
--                          You Deserve It (My Hallelujah)
--     Offering (Key TBC, kept short):
--                          We Lift Our Hands in the Sanctuary
--     End      (Key TBC):  My Jesus (Shout to the Lord)
--
-- This is a fresh set -- NONE of these nine songs have lyrics in the
-- Control Room yet, so they seed as honest placeholders and the verify
-- query at the end will flag every one. Load the lyrics next (Lyric
-- Formatter, or a 27_song_lyrics_05jul2026.sql upsert into
-- control_room_songs) and re-run this file so they resolve.
--
-- LYRICS resolution (coalesce, first hit wins):
--     song library (control_room_songs) -> placeholder.
--   Kept minimal on purpose -- there are no recent plans to pull these
--   specific songs from. Anything already sitting in the library (e.g.
--   a canonical "My Jesus (Shout to the Lord)") will resolve; the rest
--   placeholder until lyrics are loaded.
--
-- ORDER OF SERVICE: 11 items. Two announcement moments -- Social Media
-- and Online Giving -- live in plan_speakers only (no slides). Closing
-- Prayer is Brother Ernest. Benediction is TBC.
--
-- SCRIPTURE: the pre-sermon reading passage is NOT confirmed. The
-- cr_add_scripture_to_plan() call is left commented below -- fill in
-- book/chapter/verses once Pastor Shade confirms, uncomment, re-run.
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
    'Prayer Postures and War the Room (Pastor Shade Olatoye · General Overseer) — CONFIRMED set (Tue 3 Jul rehearsal): Praise Key of E; Worship 6/8, keys at soundcheck; new songs, load lyrics')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  -- song library -> placeholder (fresh set, nothing recent to pull from)
  coalesce(
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- PRAISE (Key of E) -- four choruses, back-to-back
  (1, 'song', 'Trading My Sorrows', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Trading My Sorrows"}]'),
  (2, 'song', 'Lord You Are Good', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Lord You Are Good"}]'),
  (3, 'song', 'Friend of God', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Friend of God"}]'),
  (4, 'song', 'Every Praise', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Every Praise"}]'),

  -- WORSHIP (6/8, key set at soundcheck)
  (5, 'song', 'King of Glory', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"King of Glory"}]'),
  (6, 'song', 'Indescribable', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Indescribable"}]'),
  (7, 'song', 'You Deserve It (My Hallelujah)', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"You Deserve It (My Hallelujah)"}]'),

  -- OFFERING (Key TBC) -- kept short, no intro
  (8, 'song', 'We Lift Our Hands in the Sanctuary', 'offering',
    '[{"line1":"[lyrics to be added]","line2":"We Lift Our Hands in the Sanctuary"}]'),

  -- END OF SERVICE (Key TBC)
  (9, 'song', 'My Jesus (Shout to the Lord)', 'end',
    '[{"line1":"[lyrics to be added]","line2":"My Jesus (Shout to the Lord)"}]')

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
  (3,  'Worship',                   null,                     'Worship Team · Praise Key of E; Worship 6/8, keys at soundcheck'),
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
-- fill in book/chapter/verses, uncomment, and re-run. Position 98 so it
-- doesn't collide with song positions. KJV is already seeded in
-- control_room_bible, so no verse inserts are needed.
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

-- Which songs still need lyrics added? (fresh set -- expect all 9 until loaded)
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

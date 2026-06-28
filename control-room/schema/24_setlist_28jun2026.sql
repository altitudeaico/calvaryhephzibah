-- ============================================================
-- 24_setlist_28jun2026.sql
-- ============================================================
-- Sunday 28th June 2026
--   Sermon: "The Posture of the Heart, in Prayer"
--           (Apostle Sarah Bunjo · Guest Minister)
--   Pre-sermon reading: James 4:8 · Jeremiah 17:9-10 · Proverbs 4:23
--                       (Emmanuel Ariyibi · KJV)
--
-- Seeds the full plan for the Control Room: plan + song set list +
-- order of service + the three pre-sermon scripture passages.
--
-- SET LIST (confirmed by Bolaji):
--     Praise   (Key of B): These Are the Days of Elijah ·
--                          Lord I Lift Your Name on High ·
--                          Ancient of Days / Blessing and Honour
--     Worship  (Key TBC):  Here I Am to Worship ·
--                          Be Magnified ·
--                          Jesus at the Centre
--     Offering (Key TBC):  Awesome God, Mighty God
--     End      (Key TBC):  Thank You Lord
--
--   Praise is the same three songs as recent weeks. Worship, Offering
--   and End of Service are a NEW set this week.
--
-- LYRICS resolution (coalesce, first hit wins):
--     21 Jun -> 14 Jun -> 7 Jun -> 19 Apr -> song library -> placeholder.
--   * Praise (x3) resolve from the 21 Jun plan -- real slides.
--   * "Here I Am to Worship" resolves from the 19 Apr plan (03_setlist).
--   * "Be Magnified", "Jesus at the Centre", "Awesome God, Mighty God"
--     and "Thank You Lord" are NOT yet in the Control Room -- they seed
--     as a placeholder slide. Add their lyrics (Lyric Formatter / a
--     song_lyrics upsert into control_room_songs) and re-run this file.
--
-- ORDER OF SERVICE: 10 items. Thanksgiving (Pastor Gbenga) sits
-- between Communion and Announcements as a service moment -- it lives
-- in plan_speakers only (no slides of its own). Benediction is TBC.
--
-- SCRIPTURE: three separate passages, each cued as its own scripture
-- item (positions 98, 99, 100) via cr_add_scripture_to_plan() -- the
-- helper created in 16_scripture_in_plan.sql. All KJV, already seeded
-- in control_room_bible, so no verse inserts are needed.
--
-- Idempotent: re-running replaces the plan, items, and speakers for
-- 2026-06-28 cleanly, then re-cues the three scripture passages.
-- Run in Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN + SONG SET LIST (control_room_plan_items)
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-06-28';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-06-28',
    'The Posture of the Heart, in Prayer (Apostle Sarah Bunjo · Guest Minister) — Praise Key of B; new Worship/Offering/End set, keys TBC')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  -- 21 Jun -> 14 Jun -> 7 Jun -> 19 Apr -> song library -> placeholder
  coalesce(
    (select i1.slides from control_room_plan_items i1
       join control_room_plans p1 on p1.id = i1.plan_id
      where p1.service_date = '2026-06-21' and lower(i1.title) = lower(v.title) limit 1),
    (select i2.slides from control_room_plan_items i2
       join control_room_plans p2 on p2.id = i2.plan_id
      where p2.service_date = '2026-06-14' and lower(i2.title) = lower(v.title) limit 1),
    (select i3.slides from control_room_plan_items i3
       join control_room_plans p3 on p3.id = i3.plan_id
      where p3.service_date = '2026-06-07' and lower(i3.title) = lower(v.title) limit 1),
    (select i4.slides from control_room_plan_items i4
       join control_room_plans p4 on p4.id = i4.plan_id
      where p4.service_date = '2026-04-19' and lower(i4.title) = lower(v.title) limit 1),
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- PRAISE (Key of B) -- resolves from 21 Jun
  (1, 'song', 'These Are the Days of Elijah', 'praise',
    '[{"line1":"[lyrics from recent plan]","line2":"[re-run after loading 21 Jun]"}]'),
  (2, 'song', 'Lord I Lift Your Name on High', 'praise',
    '[{"line1":"[lyrics from recent plan]","line2":"[re-run after loading 21 Jun]"}]'),
  (3, 'song', 'Ancient of Days / Blessing and Honour', 'praise',
    '[{"line1":"[lyrics from recent plan]","line2":"[re-run after loading 21 Jun]"}]'),

  -- WORSHIP (Key TBC) -- new this week
  (4, 'song', 'Here I Am to Worship', 'worship',
    '[{"line1":"[lyrics from 19 Apr plan]","line2":"[re-run after loading 03_setlist]"}]'),
  (5, 'song', 'Be Magnified', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Be Magnified"}]'),
  (6, 'song', 'Jesus at the Centre', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Jesus at the Centre"}]'),

  -- OFFERING (Key TBC) -- new this week
  (7, 'song', 'Awesome God, Mighty God', 'offering',
    '[{"line1":"[lyrics to be added]","line2":"Awesome God, Mighty God"}]'),

  -- END OF SERVICE (Key TBC) -- new this week
  (8, 'song', 'Thank You Lord', 'end',
    '[{"line1":"[lyrics to be added]","line2":"Thank You Lord"}]')

) as v(position, kind, title, section, fallback);

-- --------------------------------------------------------------------
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- --------------------------------------------------------------------

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-06-28');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading', 'Pastor Gbenga Adebanjo', null),
  (2,  'Opening Prayer',          'Sister Lisa',            null),
  (3,  'Worship',                 null,                     'Worship Team · Praise Key of B, Worship/Offering/End keys TBC'),
  (4,  'Communion',               'Pastor Shade Olatoye',   null),
  (5,  'Thanksgiving',            'Pastor Gbenga Adebanjo', null),
  (6,  'Announcements',           'Pastor Gbenga Adebanjo', null),
  (7,  'Bible Reading',           'Emmanuel Ariyibi',       'James 4:8 · Jeremiah 17:9-10 · Proverbs 4:23'),
  (8,  'Sermon',                  'Apostle Sarah Bunjo',    'The Posture of the Heart, in Prayer · Guest Minister'),
  (9,  'Closing Prayer',          'Sister Petty',           null),
  (10, 'Benediction',             'TBC',                    null)
) as v(position, role, name, notes)
where p.service_date = '2026-06-28';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE -- three pre-sermon passages (Emmanuel Ariyibi · KJV)
-- Positions 98-100 sit after the 8 song items so they don't collide,
-- and cue in reading order: James -> Jeremiah -> Proverbs.
-- --------------------------------------------------------------------

select cr_add_scripture_to_plan(
  p_service_date => '2026-06-28'::date,
  p_position     => 98,
  p_book         => 'James',
  p_chapter      => 4,
  p_verse_start  => 8,
  p_verse_end    => 8,
  p_section      => 'reading',
  p_version      => 'KJV'
) as james_4_8_item_id;

select cr_add_scripture_to_plan(
  p_service_date => '2026-06-28'::date,
  p_position     => 99,
  p_book         => 'Jeremiah',
  p_chapter      => 17,
  p_verse_start  => 9,
  p_verse_end    => 10,
  p_section      => 'reading',
  p_version      => 'KJV'
) as jeremiah_17_9_10_item_id;

select cr_add_scripture_to_plan(
  p_service_date => '2026-06-28'::date,
  p_position     => 100,
  p_book         => 'Proverbs',
  p_chapter      => 4,
  p_verse_start  => 23,
  p_verse_end    => 23,
  p_section      => 'reading',
  p_version      => 'KJV'
) as proverbs_4_23_item_id;

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
where p.service_date = '2026-06-28'
group by p.service_date, p.notes;

-- Which songs still need lyrics added? (placeholder / cross-plan slides)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-06-28'
  and i.kind = 'song'
  and (i.slides::text like '%to be added%' or i.slides::text like '%plan]%')
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-06-28'
order by i.position;

-- Order of service speakers
select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-06-28'
order by s.position;

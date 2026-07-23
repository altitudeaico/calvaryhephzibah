-- ============================================================
-- 42_setlist_26jul2026.sql
-- ============================================================
-- Sunday 26th July 2026 -- SONG SET LIST ONLY.
--
-- Order of service, speakers, sermon and scripture are NOT seeded
-- here because they were not settled at the time of writing. They
-- arrive in a follow-up patch migration (43_orderofservice_26jul2026).
--
-- >> IMPORTANT: this file deletes and recreates the 2026-07-26 plan,
-- >> which cascades to items and speakers. If you re-run this AFTER
-- >> running the order-of-service patch, re-run that patch too.
--
-- SET (confirmed by Bolaji with Bolaji Adebanjo, 23 July 2026):
--   Afro Praise Medley, new arrangement over a backing track
--   (111-112 BPM to confirm), seeded as six separate items so the
--   operator can advance segment by segment:
--       We Lift Our Hands . Yes Lord . Blessing and Honour .
--       Glory Be to the Lord . Higher, Every Day . My Hands, My Feet
--   Then: Days of Elijah / Lord I Lift (click track loop, 105 BPM
--   percussion, no kick), Open the Eyes of My Heart (Caribbean loop).
--   Worship: I Could Sing of Your Love Forever (new arrangement),
--   My Jesus (Shout to the Lord).
--   Offering and end of service are placeholders, not yet chosen.
--
--   Trading My Sorrows was dropped from the set. Its "Yes Lord"
--   refrain lives on inside the medley and is seeded inline below,
--   since there is no standalone library entry for it.
--
-- LYRICS: every song except Yes Lord and the two placeholders
-- resolves from control_room_songs. RUN 41_song_library_26jul2026.sql
-- FIRST or four of them will fall back to placeholders.
--
-- Keys are set at soundcheck, none confirmed in advance.
-- Idempotent. Run in the Supabase SQL editor
-- (project: pfycvgbrsbecznkcikwt).
-- ============================================================

delete from control_room_plans where service_date = '2026-07-26';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-07-26',
    'Songs only. Afro Praise Medley (new arrangement, backing track 111-112 BPM TBC) seeded as six segments. Offering and end of service not yet chosen. Order of service, sermon and scripture to follow in a patch migration. Keys set at soundcheck.')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  coalesce(
    -- persistent library resolves everything except Yes Lord + placeholders
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    -- backstop: most recent plans
    (select i1.slides from control_room_plan_items i1
       join control_room_plans p1 on p1.id = i1.plan_id
      where p1.service_date = '2026-07-19' and lower(i1.title) = lower(v.title) limit 1),
    (select i2.slides from control_room_plan_items i2
       join control_room_plans p2 on p2.id = i2.plan_id
      where p2.service_date = '2026-07-12' and lower(i2.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- Afro medley segment 2
  (1, 'song', 'We Lift Our Hands in the Sanctuary', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"We Lift Our Hands in the Sanctuary"}]'),

  -- Afro medley segment 3 -- inline, not a library song
  (2, 'song', 'Yes Lord', 'praise',
    '[{"line1":"Yes Lord, yes Lord","line2":"yes yes Lord"},{"line1":"Yes Lord, yes Lord","line2":"yes yes Lord"},{"line1":"Yes Lord, yes Lord","line2":"yes yes Lord, amen"}]'),

  -- Afro medley segment 4
  (3, 'song', 'Ancient of Days / Blessing and Honour', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Ancient of Days / Blessing and Honour"}]'),

  -- Afro medley segment 5 -- call and response x2
  (4, 'song', 'Glory Be to the Lord', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Glory Be to the Lord"}]'),

  -- Afro medley segment 6 -- once through
  (5, 'song', 'Higher, Every Day', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Higher, Every Day"}]'),

  -- Afro medley segments 7 & 9, with the break between
  (6, 'song', 'My Hands, My Feet, My Whole Body', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"My Hands, My Feet, My Whole Body"}]'),

  -- Second medley, into Lord I Lift
  (7, 'song', 'These Are the Days of Elijah', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"These Are the Days of Elijah"}]'),

  -- Percussion loop 105 BPM, no kick
  (8, 'song', 'Lord I Lift Your Name on High', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Lord I Lift Your Name on High"}]'),

  -- Caribbean-feel loop
  (9, 'song', 'Open the Eyes of My Heart, Lord', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Open the Eyes of My Heart, Lord"}]'),

  -- New arrangement, bass 5 2 4 1
  (10, 'song', 'I Could Sing of Your Love Forever', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"I Could Sing of Your Love Forever"}]'),

  (11, 'song', 'My Jesus (Shout to the Lord)', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"My Jesus (Shout to the Lord)"}]'),

  -- Placeholder
  (12, 'song', 'Offering song TBC', 'offering',
    '[{"line1":"[song not chosen yet]","line2":"Offering"}]'),

  -- Placeholder
  (13, 'song', 'End of service song TBC', 'end',
    '[{"line1":"[song not chosen yet]","line2":"End of Service"}]')

) as v(position, kind, title, section, fallback);

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- Verify: anything still showing a placeholder needs attention
-- --------------------------------------------------------------------

select i.position, i.section, i.title,
       jsonb_array_length(i.slides) as slides,
       case when i.slides::text like '%lyrics to be added%'
             or i.slides::text like '%not chosen yet%'
            then 'PLACEHOLDER' else 'ok' end as status
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-07-26'
order by i.position;

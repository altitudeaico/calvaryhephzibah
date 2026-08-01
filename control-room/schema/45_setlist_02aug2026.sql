-- ============================================================
-- 45_setlist_02aug2026.sql
-- ============================================================
-- Sunday 2nd August 2026
--   Sermon: "Family Altar" (Dr Titi Sodipo -- GUEST MINISTER)
--   Pre-sermon reading: reader Dr Caster Martins, PASSAGE NOT GIVEN
--
-- Seeds the full plan for the Control Room: plan + song set list +
-- order of service. No scripture item is seeded because no passage
-- has been given (see the FLAG note below).
--
-- SET LIST (as given by Bolaji, 1 August 2026) -- eight DISCRETE
-- songs, no medley and no backing track this week:
--     Praise   : These Are the Days of Elijah .
--                Lord I Lift Your Name on High .
--                Open the Eyes of My Heart, Lord
--     Worship  : I Could Sing of Your Love Forever .
--                My Jesus (Shout to the Lord) .
--                Bow Down and Worship
--     Offering : Glory Be to the Lord
--     End      : Thank You Lord
--   Keys are set at soundcheck (none confirmed in advance).
--
-- LYRICS resolution (coalesce, first hit wins):
--   SEVEN of the eight resolve from control_room_songs (persistent
--   library), so no companion lyrics file is needed for them:
--       These Are the Days of Elijah, Lord I Lift Your Name on High,
--       Open the Eyes of My Heart Lord, I Could Sing of Your Love
--       Forever, My Jesus (Shout to the Lord), Glory Be to the Lord,
--       Thank You Lord.
--
--   >> ONE SONG HAS NO LYRICS ANYWHERE: "Bow Down and Worship".
--   >> It is new to the set, has no library entry and appears in no
--   >> prior plan. It is seeded with a PLACEHOLDER slide so the plan
--   >> is complete and the verify query flags it. Nothing usable will
--   >> push to the screen for this song until the lyrics are supplied
--   >> and added via a 46_song_lyrics_02aug2026.sql upsert.
--
--   Bolaji wrote the set as: "These are the days" -> canonical
--   "These Are the Days of Elijah"; "Open the eyes of my heart" ->
--   "Open the Eyes of My Heart, Lord"; "Shout to the lord" ->
--   "My Jesus (Shout to the Lord)"; "Glory be to the Lord" and
--   "Thankyou Lord" -> "Glory Be to the Lord" / "Thank You Lord".
--   Titles are spelled canonically here so lyrics resolve.
--
-- ORDER OF SERVICE: seeded into control_room_plan_speakers.
--   TWO ITEMS FLAGGED AS INCOMPLETE:
--     . Opening Prayer -- no name given in the order of service.
--     . Bible Reading  -- reader given (Dr Caster Martins) but NO
--       passage. When the passage lands, add it with
--       cr_add_scripture_to_plan() (see 36_setlist_19jul2026.sql for
--       the call shape) at position 98.
--
-- ASSUMPTION FLAGGED: the order of service says "Dr Martin" for the
-- Bible reading. Seeded as "Dr Caster Martins", who has read at
-- Calvary before. Correct it here if that is the wrong person.
--
-- Idempotent: re-running replaces the plan, items and speakers for
-- 2026-08-02 cleanly.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN + SONG SET LIST (control_room_plan_items)
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-08-02';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-08-02',
    'Family Altar (Dr Titi Sodipo, guest minister). Eight discrete songs, no medley and no backing track. Seven of eight resolve real lyrics from the library; Bow Down and Worship is a PLACEHOLDER pending lyrics. Bible reading passage still TBC (reader Dr Caster Martins). Opening prayer unassigned. Keys set at soundcheck.')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  coalesce(
    -- persistent library (resolves 7 of the 8)
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    -- backstops: the two most recent plans
    (select i1.slides from control_room_plan_items i1
       join control_room_plans p1 on p1.id = i1.plan_id
      where p1.service_date = '2026-07-26' and lower(i1.title) = lower(v.title) limit 1),
    (select i2.slides from control_room_plan_items i2
       join control_room_plans p2 on p2.id = i2.plan_id
      where p2.service_date = '2026-07-19' and lower(i2.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- PRAISE
  (1, 'song', 'These Are the Days of Elijah', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"These Are the Days of Elijah"}]'),
  (2, 'song', 'Lord I Lift Your Name on High', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Lord I Lift Your Name on High"}]'),
  (3, 'song', 'Open the Eyes of My Heart, Lord', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Open the Eyes of My Heart, Lord"}]'),

  -- WORSHIP
  (4, 'song', 'I Could Sing of Your Love Forever', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"I Could Sing of Your Love Forever"}]'),
  (5, 'song', 'My Jesus (Shout to the Lord)', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"My Jesus (Shout to the Lord)"}]'),

  -- New song this week. NOTHING to resolve from -- expect PLACEHOLDER.
  (6, 'song', 'Bow Down and Worship', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Bow Down and Worship"}]'),

  -- OFFERING
  (7, 'song', 'Glory Be to the Lord', 'offering',
    '[{"line1":"[lyrics to be added]","line2":"Glory Be to the Lord"}]'),

  -- END OF SERVICE
  (8, 'song', 'Thank You Lord', 'end',
    '[{"line1":"[lyrics to be added]","line2":"Thank You Lord"}]')

) as v(position, kind, title, section, fallback);

-- --------------------------------------------------------------------
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- --------------------------------------------------------------------

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-08-02');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading',   'Pastor Shade Olatoye',     null),
  (2,  'Opening Prayer',            null,                       'FLAG: no name given'),
  (3,  'Worship',                   null,                       'Worship Team · eight discrete songs, no medley · keys set at soundcheck'),
  (4,  'Communion',                 'Pastor Kayode Ogungbenro', null),
  (5,  'Media Awareness',           'Brother Bolaji Olatoye',   'Slide / QR on screen'),
  (6,  'Announcements',             'Pastor Kayode Ogungbenro', null),
  (7,  'Bible Reading',             'Dr Caster Martins',        'FLAG: passage TBC · name given as "Dr Martin", read as Dr Caster Martins'),
  (8,  'Sermon',                    'Dr Titi Sodipo',           'Guest Minister · Family Altar'),
  (9,  'Closing Prayer',            'Deacon Labi Sokoya',       null),
  (10, 'Benediction',               'Mummy Oso',                null)
) as v(position, role, name, notes)
where p.service_date = '2026-08-02';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE -- NOT SEEDED
-- No passage was given for the pre-sermon reading. When it lands, run:
--
--   select cr_add_scripture_to_plan(
--     p_service_date => '2026-08-02'::date,
--     p_position     => 98,
--     p_book         => '<Book>',
--     p_chapter      => <n>,
--     p_verse_start  => <n>,
--     p_verse_end    => <n>,
--     p_section      => 'reading',
--     p_version      => 'KJV'
--   );
--
-- KJV is already seeded in control_room_bible, so no verse inserts
-- are needed. Then clear the FLAG on speaker position 7.
-- --------------------------------------------------------------------

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
where p.service_date = '2026-08-02'
group by p.service_date, p.notes;

-- Which songs still need lyrics? (expect EXACTLY ONE row: Bow Down and Worship)
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-02'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-02'
order by i.position;

-- Order of service speakers, with anything still needing input
select s.position, s.role, coalesce(s.name, '--') as name,
       case when s.notes like 'FLAG:%' then 'NEEDS INPUT' else '' end as flag,
       s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-08-02'
order by s.position;

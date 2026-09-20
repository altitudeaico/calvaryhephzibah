-- ============================================================
-- 71_setlist_20sep2026.sql
-- ============================================================
-- Sunday 20th September 2026
--   Sermon: "Manifesting The Kingdom"
--   Preacher: Bishop Henry Emmanuel (Guest Minister)
--   Pre-sermon Bible Reading: Sister Petty -- NO PASSAGE NAMED,
--                              scripture is TBC, confirm before Sunday
--
-- Seeds the plan + order of service for the Control Room.
-- Idempotent: re-running replaces the plan, speakers and scripture
-- for 2026-09-20 cleanly.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
--
-- SET LIST -- new Praise set this week, Worship/Offering/End
-- carried over unchanged from last Sunday (13 Sep 2026):
--     Praise   : These Are the Days of Elijah (Robin Mark)
--                Lord I Lift Your Name on High (Rick Founds)
--                Open the Eyes of My Heart, Lord (Paul Baloche)
--     Worship  : I Will Worship (actual title "You're Worthy of My
--                  Praise", David Ruis)
--                Heart of Worship
--                Jesus at the Centre
--     Offering : Give Thanks to the Lord
--     End      : Thank You Lord (Don Moen)
--
-- KEYS ARE ALL "TBC" -- none given. Set at the Sunday soundcheck.
--
-- LYRICS SOURCING -- all 8 songs already exist in control_room_songs
-- (the persistent library) or in the 2026-09-13 plan, so the coalesce
-- chain below resolves every song without any new lyrics being
-- entered here. Canonical titles used exactly as stored:
--   "These Are the Days of Elijah", "Lord I Lift Your Name on High",
--   "Open the Eyes of My Heart, Lord" -- confirmed in control_room_songs.
--   "I Will Worship", "Heart of Worship", "Jesus at the Centre",
--   "Give Thanks to the Lord", "Thank You Lord (Don Moen)" --
--   confirmed in the 2026-09-13 plan.
--
-- ------------------------------------------------------------
-- FLAGS
-- ------------------------------------------------------------
-- 1. OFFERING ITEM -- not listed in the order of service as sent.
--    Added back into the order of service (speakers table,
--    position 9) in its usual post-sermon slot, since the confirmed
--    worship set includes an Offering song. No offering leader was
--    named. Confirm if this is wrong.
--
-- 2. SCRIPTURE -- NO PASSAGE was given for the pre-sermon Bible
--    Reading (Sister Petty). No cr_add_scripture_to_plan() call is
--    included below -- add one once the reference is confirmed.
--
-- 3. PREACHER -- Bishop Henry Emmanuel is treated as a Guest
--    Minister (not on the standing leadership list). Confirm if
--    this attribution is wrong.
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN (control_room_plans) + song set list
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-09-20';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-09-20',
    'Manifesting The Kingdom (Bishop Henry Emmanuel, Guest Minister). New Praise set this week (Days of Elijah, Lord I Lift Your Name on High, Open the Eyes of My Heart) -- all resolve from the song library. Worship, Offering and End of Service carry over unchanged from last Sunday (13 Sep 2026). ALL KEYS TBC, set at the Sunday soundcheck. Scripture for the pre-sermon Bible Reading (Sister Petty) was not named in the order as sent -- TBC, needs confirming. Offering was not itemised in the order of service as sent -- added back in its usual post-sermon slot since the worship set includes an Offering song; no offering leader named.')
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
       and p2.service_date < '2026-09-20'
     order by p2.service_date desc
     limit 1),
    -- persistent library
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    -- explicit fallback -- placeholder only, should never be hit given
    -- all 8 songs are already confirmed present above
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
  where plan_id in (select id from control_room_plans where service_date = '2026-09-20');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading', 'Ps Shade Olatoye',         null),
  (2,  'Opening Prayer',          'Mummy Oso',                null),
  (3,  'Worship',                 null,                       'Worship Team · new Praise set · all keys TBC, set at soundcheck'),
  (4,  'Communion',               'Ps Gbenga Adebanjo',       null),
  (5,  'Media Awareness',         'Pastor Gbenga Adebanjo',   null),
  (6,  'Announcements',           'Pastor Kayode Ogungbenro', null),
  (7,  'Bible Reading',           'Sister Petty',             'FLAG: no passage named in the order as sent — scripture TBC'),
  (8,  'Sermon',                  'Bishop Henry Emmanuel',    'Manifesting The Kingdom · Guest Minister'),
  (9,  'Offering',                null,                       'Give Thanks to the Lord · FLAG: not itemised in the order as sent, added back in usual slot · no offering leader named'),
  (10, 'Closing Prayer',          'Brother Ernest',           null),
  (11, 'Benediction',             'Deacon Femi Osipitan',     null)
) as v(position, role, name, notes)
where p.service_date = '2026-09-20';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE (cr_add_scripture_to_plan)
-- --------------------------------------------------------------------
-- None seeded -- no passage was given for the Bible Reading (Sister
-- Petty). Add a cr_add_scripture_to_plan(...) call here once
-- confirmed, e.g.:
--
-- select cr_add_scripture_to_plan(
--   p_service_date => '2026-09-20'::date,
--   p_position     => 98,
--   p_book         => '<Book>',
--   p_chapter      => <chapter>,
--   p_verse_start  => <verse>,
--   p_verse_end    => <verse>,
--   p_section      => 'reading',
--   p_version      => 'KJV'
-- );

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 4. VERIFY
-- --------------------------------------------------------------------

-- Plan summary. Expect: songs = 8, scriptures = 0 (TBC), speakers = 11.
select p.service_date, p.notes,
       count(distinct i.id) filter (where i.kind = 'song')      as songs,
       count(distinct i.id) filter (where i.kind = 'scripture') as scriptures,
       coalesce(sum(jsonb_array_length(i.slides)), 0)           as total_slides,
       count(distinct s.id)                                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-09-20'
group by p.service_date, p.notes;

-- Which songs still need lyrics? Expect NONE -- all 8 should resolve
-- from the library or last week's plan.
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-09-20'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-09-20'
order by i.position;

-- Order of service speakers, with anything still needing input
select s.position, s.role, coalesce(s.name, '--') as name,
       case when s.notes like 'FLAG:%' or s.notes like '%FLAG:%' then 'NEEDS INPUT' else '' end as flag,
       s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-09-20'
order by s.position;

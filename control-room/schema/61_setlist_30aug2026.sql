-- ============================================================
-- 61_setlist_30aug2026.sql
-- ============================================================
-- Sunday 30th August 2026
--   Sermon: "He Never Fails" (Bishop Henry Emmanuel -- last preached
--            7 & 14 Jun 2026, both times badged Guest Minister --
--            carried forward here, confirm if that's changed)
--   Pre-sermon reading: Isaiah 46:8-13 (KJV) -- Sister Tash Campbell
--   Also: Mummy Awolesi's Birthday Celebration (Thanksgiving Offering
--         + Grand Entry of the Celebrant + reception programme) folded
--         into the same service.
--
-- Seeds the plan + order of service + scripture for the Control
-- Room. Idempotent: re-running replaces the plan, speakers and
-- scripture for 2026-08-30 cleanly.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
--
-- CORRECTION HISTORY -- Bolaji first sent an order of service on
-- 29 Aug that turned out to be last week's (23 Aug, already
-- published) with only the songs genuinely new. He resent the
-- correct order of service for 30 Aug on the same day, which is what
-- this file seeds. If a `30aug2026` plan already exists from an
-- earlier attempt, this delete-then-insert replaces it cleanly.
--
-- SET LIST -- FIVE songs confirmed, Offering and End of Service
-- still open:
--     Praise   : Beautiful One .
--                Open the Eyes of My Heart, Lord
--     Worship  : I Give Myself Away .
--                I Surrender All to You .
--                Jesus at the Centre
--     Offering : NOT YET GIVEN -- the Thanksgiving Offering segment
--                is being led by Guest Artists, assisted by the
--                Worship Team, but no song title has been supplied.
--     End      : NOT YET GIVEN
--
-- KEYS ARE ALL "TBC" -- none were given. Set at the Sunday
-- soundcheck. Deliberate state, not missing data.
--
-- TITLE CANONICALISATION (so lyrics resolve on lower(title)):
--   "Open the eyes of my heart lord" -> 'Open the Eyes of My Heart, Lord'
--     (matches the comma-form used since 24 May 2026 -- do not seed
--     without the comma or it will miss the existing library entry)
--   "Jesus at the center" -> 'Jesus at the Centre'
--     (matches the British-spelling form used since 28 Jun 2026)
--   "Beautiful One", "I Give Myself Away", "I Surrender All to You"
--     have no prior entries in this repo -- first time at Calvary,
--     or at least first time logged here. Seeded as given.
--
-- LYRICS: "Open the Eyes of My Heart, Lord" and "Jesus at the Centre"
-- should resolve real slides from control_room_songs (both have
-- multiple prior plans). The other three are new -- placeholder
-- slides seeded below; if the verify query flags them, they need
-- either lyrics from Bolaji or a check of whether they're already in
-- the library under a slightly different title.
--
-- ------------------------------------------------------------
-- FLAGS
-- ------------------------------------------------------------
-- 1. THIRD PRAISE SONG -- Bolaji's note: "more than one praise
--    (African to be precise)" while also saying P&W is shorter than
--    usual this week. Only two Praise titles were actually given.
--    Read as: a third, African-style praise number may still be
--    confirmed. NOT seeded -- do not guess a title. Add it when named.
--
-- 2. OFFERING SONG -- no title given. The slot itself is real (see
--    speakers row 6, "Mummy Awolesi's Birthday -- Thanksgiving
--    Offering", Guest Artists leading). No song item seeded for it.
--
-- 3. END OF SERVICE SONG -- no title given at all this week.
--
-- 4. BIBLE READER (Welcome slot) -- Pastor Shade Olatoye is named for
--    "Welcome & Bible Reading" as one combined item, consistent with
--    the template's usual pairing. This is separate from the
--    pre-sermon reading (Isaiah 46:8-13, Sister Tash Campbell).
--
-- 5. NO BENEDICTION GIVEN -- the order of service as sent ends with
--    Vote of Thanks then Closing Prayer (Pastor Kayode Ogungbenro).
--    Seeded without a benediction row. Confirm with Pastor Shade
--    whether one should be added.
--
-- 6. GUEST MINISTER BADGE -- Bishop Henry Emmanuel was badged "Guest
--    Minister" on both his prior visits (7 & 14 Jun 2026). Carried
--    forward here on the same assumption; not restated in this
--    message, so confirm if his status has changed.
--
-- 7. BIRTHDAY PROGRAMME -- Cutting of the Cake / Toast / Speeches /
--    More Photos / Vote of Thanks are seeded as their own speaker
--    rows (positions 12-16) with no name, since none were given --
--    these are usually run by an MC/family on the day. Fill in if
--    Bolaji supplies who's running each.
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN (control_room_plans) + song set list
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-08-30';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-08-30',
    'He Never Fails (Bishop Henry Emmanuel, guest minister -- carried forward from his June visits). Also Mummy Awolesi''s Birthday Celebration: Thanksgiving Offering + Grand Entry of the Celebrant + reception programme, folded into the same service. Five songs confirmed (two Praise, three Worship); Offering and End of Service songs NOT YET GIVEN -- Thanksgiving Offering led by Guest Artists, assisted by Worship Team. Possible third (African-style) Praise song still to come per Bolaji. ALL KEYS TBC, set at the Sunday soundcheck. No Benediction given on the order of service as sent.')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  coalesce(
    -- persistent library first (should resolve the two recurring songs)
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    v.fallback::jsonb
  )
from (values

  -- PRAISE -- key TBC. Third (African-style) song may still be added -- not seeded.
  (1, 'song', 'Beautiful One', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Beautiful One"}]'),
  (2, 'song', 'Open the Eyes of My Heart, Lord', 'praise',
    '[{"line1":"[lyrics to be added]","line2":"Open the Eyes of My Heart, Lord"}]'),

  -- WORSHIP -- key TBC
  (3, 'song', 'I Give Myself Away', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"I Give Myself Away"}]'),
  (4, 'song', 'I Surrender All to You', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"I Surrender All to You"}]'),
  (5, 'song', 'Jesus at the Centre', 'worship',
    '[{"line1":"[lyrics to be added]","line2":"Jesus at the Centre"}]')

  -- OFFERING and END OF SERVICE: no titles given yet -- deliberately
  -- not seeded. Add via a follow-up patch once Bolaji supplies them.

) as v(position, kind, title, section, fallback);

-- --------------------------------------------------------------------
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- --------------------------------------------------------------------

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-08-30');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading',        'Pastor Shade Olatoye',   null),
  (2,  'Opening Prayer',                 'Sister Petty',           null),
  (3,  'Worship',                        null,                     'Worship Team · shorter than usual this week · all keys TBC, set at soundcheck'),
  (4,  'Communion',                      'Pastor Gbenga Adebanjo', null),
  (5,  'Media Awareness',                'Pastor Gbenga Adebanjo', null),
  (6,  'Mummy Awolesi''s Birthday — Thanksgiving Offering', 'Pastor Shade Olatoye', 'Guest Artists leading, assisted by Worship Team · FLAG: no offering song title given'),
  (7,  'Announcements',                  'Pastor Kayode Ogungbenro', null),
  (8,  'Bible Reading',                  'Sister Tash Campbell',   'Isaiah 46:8-13 · KJV'),
  (9,  'Sermon',                         'Bishop Henry Emmanuel',  'Guest Minister · He Never Fails'),
  (10, 'Prayer',                         'Deaconess Janet Oviri',  null),
  (11, 'Grand Entry of the Celebrant',   null,                     'Mrs Augustina Adekemi Awolesi · Guest Artists & Worship Team'),
  (12, 'Cutting of the Cake',            null,                     null),
  (13, 'Toast',                          null,                     null),
  (14, 'Speeches',                       null,                     null),
  (15, 'More Photos',                    null,                     null),
  (16, 'Vote of Thanks',                 null,                     null),
  (17, 'Closing Prayer',                 'Pastor Kayode Ogungbenro', 'FLAG: no Benediction given on the order of service as sent')
) as v(position, role, name, notes)
where p.service_date = '2026-08-30';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE (cr_add_scripture_to_plan)
-- --------------------------------------------------------------------

-- Isaiah 46:8-13 -- "I am God, and there is none like me... My counsel
-- shall stand" — the backbone of "He Never Fails".
select cr_add_scripture_to_plan(
  p_service_date => '2026-08-30'::date,
  p_position     => 98,
  p_book         => 'Isaiah',
  p_chapter      => 46,
  p_verse_start  => 8,
  p_verse_end    => 13,
  p_section      => 'reading',
  p_version      => 'KJV'
);

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 4. VERIFY
-- --------------------------------------------------------------------

-- Plan summary. Expect: songs = 5, scriptures = 1, speakers = 17.
select p.service_date, p.notes,
       count(distinct i.id) filter (where i.kind = 'song')      as songs,
       count(distinct i.id) filter (where i.kind = 'scripture') as scriptures,
       coalesce(sum(jsonb_array_length(i.slides)), 0)           as total_slides,
       count(distinct s.id)                                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-08-30'
group by p.service_date, p.notes;

-- Which songs still need lyrics? "Open the Eyes of My Heart, Lord"
-- and "Jesus at the Centre" should resolve from the library and NOT
-- appear here. "Beautiful One", "I Give Myself Away" and "I Surrender
-- All to You" are expected to appear -- they're new.
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-30'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-08-30'
order by i.position;

-- Order of service speakers, with anything still needing input
select s.position, s.role, coalesce(s.name, '--') as name,
       case when s.notes like 'FLAG:%' or s.notes like '%FLAG:%' then 'NEEDS INPUT' else '' end as flag,
       s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-08-30'
order by s.position;

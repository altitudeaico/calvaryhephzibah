-- ============================================================
-- 69_setlist_13sep2026.sql
-- ============================================================
-- Sunday 13th September 2026
--   Sermon: "Resisting and Overcoming Temptation"
--   Preacher: Pastor Gbenga Adebanjo
--   Pre-sermon reading: Matthew 6:13, 1 Corinthians 10:13,
--                        James 1:3-16 (KJV) -- Brother Emmanuel Ariyibi
--
-- Seeds the plan + order of service + scripture for the Control
-- Room. Idempotent: re-running replaces the plan, speakers and
-- scripture for 2026-09-13 cleanly.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
--
-- SET LIST -- confirmed identical to last Sunday (6 Sep 2026) by
-- Bolaji Adebanjo. All 8 slots reuse last week's lyrics verbatim,
-- pulled directly from the live 2026-09-06 plan (note: that week's
-- setlist SQL was never committed to this repo -- seeded straight
-- into Supabase with no file, so this is the first time it's on
-- record here):
--     Praise   : Give Thanks to the Lord (Chris Tomlin's "Forever")
--                Let It Rise
--                You Reign (William Murphy)
--     Worship  : I Will Worship (actual title "You're Worthy of My
--                  Praise", David Ruis)
--                Heart of Worship
--                Jesus at the Centre
--     Offering : Give Thanks to the Lord (same song as Praise)
--     End      : Thank You Lord (Don Moen)
--
-- KEYS ARE ALL "TBC" -- none given. Set at the Sunday soundcheck.
--
-- TITLE CANONICALISATION (so lyrics resolve on lower(title)):
--   Canonical forms carried over unchanged from 6 Sep: "You Reign
--   (William Murphy)" and "Thank You Lord (Don Moen)" keep their
--   artist-qualified form; do not seed without it or the coalesce
--   chain below will miss last week's plan row.
--
-- COALESCE CHAIN -- checks the most recent prior plan with a
-- matching title first (catches "You Reign (William Murphy)" etc,
-- which aren't yet in the persistent control_room_songs library --
-- only "Heart of Worship", "Jesus at the Centre" and "Let It Rise"
-- are), then the library, then an explicit fallback carrying the
-- same verbatim lyrics as a safety net.
--
-- ------------------------------------------------------------
-- FLAGS
-- ------------------------------------------------------------
-- 1. OFFERING ITEM -- Pastor Shade's order of service as sent did
--    not list an Offering step. Added back into the order of
--    service (speakers table, position 9) in its usual post-sermon
--    slot, since the confirmed worship set includes an Offering
--    song. No offering leader was named. Confirm if this is wrong.
--
-- 2. READER -- Brother Emmanuel Ariyibi reads all three passages
--    (Matthew 6:13, 1 Corinthians 10:13, James 1:3-16) as one
--    combined Bible Reading slot, per the order as sent.
--
-- 3. JAMES 1:3-16 -- a long block (14 verses). Seeded as one
--    scripture call; pace it across several slides in the Control
--    Room rather than pushing it as a single slide.
-- ============================================================

-- --------------------------------------------------------------------
-- 1. PLAN (control_room_plans) + song set list
-- --------------------------------------------------------------------

delete from control_room_plans where service_date = '2026-09-13';

with new_plan as (
  insert into control_room_plans (service_date, notes)
  values ('2026-09-13',
    'Resisting and Overcoming Temptation (Pastor Gbenga Adebanjo). Same worship set as last Sunday (6 Sep 2026), confirmed by Bolaji Adebanjo -- all 8 songs reuse last week''s lyrics verbatim. ALL KEYS TBC, set at the Sunday soundcheck. Offering was not itemised in the order of service as sent -- added back in its usual post-sermon slot since the worship set includes an Offering song; no offering leader named. Bible Reading (Matthew 6:13, 1 Corinthians 10:13, James 1:3-16) read by Brother Emmanuel Ariyibi as one combined slot.')
  returning id
)
insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
select
  (select id from new_plan),
  v.position, v.kind, v.title, v.section,
  coalesce(
    -- most recent prior plan with the same title (catches last week's
    -- exact lyrics, including songs not yet in the persistent library)
    (select i2.slides
     from control_room_plan_items i2
     join control_room_plans p2 on p2.id = i2.plan_id
     where lower(i2.title) = lower(v.title) and i2.kind = 'song'
       and p2.service_date < '2026-09-13'
     order by p2.service_date desc
     limit 1),
    -- persistent library
    (select s.slides from control_room_songs s where lower(s.title) = lower(v.title) limit 1),
    -- explicit fallback -- same verbatim lyrics as a safety net
    v.fallback::jsonb
  )
from (values

  (1, 'song', 'Give Thanks to the Lord', 'praise',
    '[{"line1": "Give thanks to the Lord,", "line2": "our God and King"}, {"line1": "His love endures forever", "line2": ""}, {"line1": "For He is good,", "line2": "He is above all things"}, {"line1": "His love endures forever", "line2": ""}, {"line1": "Sing praise, sing praise", "line2": ""}, {"line1": "With a mighty hand", "line2": "and an outstretched arm"}, {"line1": "His love endures forever", "line2": ""}, {"line1": "For the life that''s been reborn", "line2": ""}, {"line1": "His love endures forever", "line2": ""}, {"line1": "Sing praise, sing praise,", "line2": "sing praise, sing praise"}, {"line1": "Forever God is faithful,", "line2": "forever God is strong"}, {"line1": "Forever God is with us,", "line2": "forever"}, {"line1": "Forever God is faithful,", "line2": "forever God is strong"}, {"line1": "Forever God is with us,", "line2": "forever, forever"}, {"line1": "From the rising", "line2": "to the setting sun"}, {"line1": "His love endures forever", "line2": ""}, {"line1": "By the grace of God,", "line2": "we will carry on"}, {"line1": "His love endures forever", "line2": ""}, {"line1": "Sing praise, sing praise,", "line2": "sing praise, sing praise"}]'),

  (2, 'song', 'Let It Rise', 'praise',
    '[{"line1": "Let the glory of the Lord rise among us", "line2": "Let the glory of the Lord rise among us"}, {"line1": "Let the praises of our King rise among us", "line2": "Let it rise"}, {"line1": "Oh, let it rise", "line2": ""}, {"line1": "Let the songs of the Lord rise among us", "line2": "Let the songs of the Lord rise among us"}, {"line1": "Let the joy of our King rise among us", "line2": "Let it rise"}, {"line1": "Oh, let it rise", "line2": ""}]'),

  (3, 'song', 'You Reign (William Murphy)', 'praise',
    '[{"line1": "My God reigns", "line2": "Our God reigns"}, {"line1": "Lord You reign above every name", "line2": "My God reigns"}, {"line1": "Our God reigns", "line2": "Lord You reign above every name"}, {"line1": "With power and majesty", "line2": "Dominion authority"}, {"line1": "You reign", "line2": "With power and majesty"}, {"line1": "Dominion authority", "line2": "You reign"}, {"line1": "Over my circumstance", "line2": "Given me another chance"}, {"line1": "You reign", "line2": "You reign"}, {"line1": "You still reign", "line2": ""}, {"line1": "Over my circumstance", "line2": "Given me another chance"}, {"line1": "You reign", "line2": "You reign"}, {"line1": "You still reign", "line2": ""}]'),

  (4, 'song', 'I Will Worship', 'worship',
    '[{"line1": "I will worship (I will worship)", "line2": "With all of my heart (with all of my heart)"}, {"line1": "I will praise You (I will praise You)", "line2": "With all of my strength (with all of my strength)"}, {"line1": "I will seek You (I will seek You)", "line2": "All of my days (all of my days)"}, {"line1": "I will follow (I will follow)", "line2": "All of Your ways (all Your ways)"}, {"line1": "I will give You all my worship", "line2": "I will give You all my praise"}, {"line1": "You alone I long to worship", "line2": "You alone are worthy of my praise"}, {"line1": "I will bow down (I will bow down)", "line2": "Hail You as King (hail You as King)"}, {"line1": "I will serve You (I will serve You)", "line2": "Give You everything (give You everything)"}, {"line1": "I will lift up (I will lift up)", "line2": "My eyes to Your throne (my eyes to Your throne)"}, {"line1": "I will trust You (I will trust You)", "line2": "Trust You alone (trust in You alone)"}, {"line1": "I will give You all my worship", "line2": "I will give You all my praise"}, {"line1": "You alone I long to worship", "line2": "You alone are worthy of my praise"}, {"line1": "I will give You all my worship", "line2": "I will give You all my praise"}, {"line1": "You alone I long to worship", "line2": "You alone are worthy of my praise"}, {"line1": "I will give You all my worship", "line2": "I will give You all my praise"}, {"line1": "You alone I long to worship", "line2": "You alone are worthy of my praise"}, {"line1": "You alone are worthy of my praise", "line2": "You alone are worthy of my praise"}]'),

  (5, 'song', 'Heart of Worship', 'worship',
    '[{"line1": "When the music fades", "line2": "All is stripped away"}, {"line1": "And I simply come", "line2": "Longin'' just to bring"}, {"line1": "Something that''s of worth", "line2": "That will bless Your heart"}, {"line1": "I''ll bring You more than a song", "line2": "For a song in itself"}, {"line1": "Is not what You have required", "line2": "You search much deeper within"}, {"line1": "Through the ways things appear", "line2": "You''re looking into my heart"}, {"line1": "I''m comin'' back to the heart of worship", "line2": "And it''s all about You"}, {"line1": "It''s all about You, Jesus", "line2": "I''m sorry, Lord, for the thing I''ve made it"}, {"line1": "When it''s all about You", "line2": "It''s all about You, Jesus"}, {"line1": "King of endless worth", "line2": "No one could express"}, {"line1": "How much You deserve?", "line2": "Though I''m weak and poor"}, {"line1": "All I have is Yours", "line2": "Every single breath"}, {"line1": "I''ll bring You more than a song", "line2": "For a song in itself"}, {"line1": "Is not what You have required", "line2": "You search much deeper within"}, {"line1": "Through the way things appear", "line2": "You''re looking into my heart, yeah"}, {"line1": "I''m comin'' back to the heart of worship", "line2": "And it''s all about You"}, {"line1": "It''s all about You, Jesus", "line2": "I''m sorry, Lord, for the thing I''ve made it"}, {"line1": "When it''s all about You", "line2": "It''s all about You, Jesus"}, {"line1": "I''m comin'' back to the heart of worship", "line2": "''Cause it''s all about You"}, {"line1": "It''s all about You, Jesus", "line2": "I''m sorry, Lord, for the thing I''ve made it"}, {"line1": "''Cause it''s all about You", "line2": "It''s all about You, Jesus, yeah"}, {"line1": "All about You", "line2": "I''ll bring You more than a song"}, {"line1": "I''ll bring You more than a song, more than a song", "line2": "I''ll bring You more than a song"}, {"line1": "I''ll bring You more than a song (than a song)", "line2": "You''re looking into my heart"}, {"line1": "You''re looking into my heart", "line2": "You''re looking into my heart"}, {"line1": "Into my heart", "line2": "I''ll bring You more than a song"}, {"line1": "I''ll bring You more than a song, yeah, yeah", "line2": "I''ll bring You more than a song"}, {"line1": "I''ll bring You more than a song", "line2": ""}]'),

  (6, 'song', 'Jesus at the Centre', 'worship',
    '[{"line1": "Jesus at the center of it all", "line2": "Jesus at the center of it all"}, {"line1": "From beginning to the end", "line2": "It will always be, it''s always been"}, {"line1": "You, Jesus", "line2": "Jesus"}, {"line1": "Nothing else matters", "line2": "Nothing in this world will do"}, {"line1": "Jesus, You''re the center", "line2": "And everything revolves around You"}, {"line1": "Jesus, You", "line2": ""}, {"line1": "Jesus, be the center of my life", "line2": "Jesus, be the center of my life"}, {"line1": "From beginning to the end", "line2": "It will always be, it''s always been"}, {"line1": "You, Jesus", "line2": "Oh, Jesus"}, {"line1": "From my heart to the Heavens", "line2": "Jesus, be the center"}, {"line1": "It''s all about You", "line2": "Yes, it''s all about You"}]'),

  (7, 'song', 'Give Thanks to the Lord', 'offering',
    '[{"line1": "Give thanks to the Lord,", "line2": "our God and King"}, {"line1": "His love endures forever", "line2": ""}, {"line1": "For He is good,", "line2": "He is above all things"}, {"line1": "His love endures forever", "line2": ""}, {"line1": "Sing praise, sing praise", "line2": ""}, {"line1": "With a mighty hand", "line2": "and an outstretched arm"}, {"line1": "His love endures forever", "line2": ""}, {"line1": "For the life that''s been reborn", "line2": ""}, {"line1": "His love endures forever", "line2": ""}, {"line1": "Sing praise, sing praise,", "line2": "sing praise, sing praise"}, {"line1": "Forever God is faithful,", "line2": "forever God is strong"}, {"line1": "Forever God is with us,", "line2": "forever"}, {"line1": "Forever God is faithful,", "line2": "forever God is strong"}, {"line1": "Forever God is with us,", "line2": "forever, forever"}, {"line1": "From the rising", "line2": "to the setting sun"}, {"line1": "His love endures forever", "line2": ""}, {"line1": "By the grace of God,", "line2": "we will carry on"}, {"line1": "His love endures forever", "line2": ""}, {"line1": "Sing praise, sing praise,", "line2": "sing praise, sing praise"}]'),

  (8, 'song', 'Thank You Lord (Don Moen)', 'end',
    '[{"line1": "Thank You Lord, thank You Lord,", "line2": "thank You Lord"}, {"line1": "I just want to thank You Lord", "line2": ""}]')

) as v(position, kind, title, section, fallback);

-- --------------------------------------------------------------------
-- 2. ORDER OF SERVICE (control_room_plan_speakers)
-- --------------------------------------------------------------------

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-09-13');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading', 'Pastor Kayode Ogungbenro', null),
  (2,  'Opening Prayer',          'Sister Lisa',              null),
  (3,  'Worship',                 null,                       'Worship Team · same set as last Sunday · all keys TBC, set at soundcheck'),
  (4,  'Communion',               'Pastor Gbenga Adebanjo',   null),
  (5,  'Media Awareness',         'Pastor Gbenga Adebanjo',   null),
  (6,  'Announcements',           'Pastor Kayode Ogungbenro', null),
  (7,  'Bible Reading',           'Brother Emmanuel Ariyibi', 'Matthew 6:13 · 1 Corinthians 10:13 · James 1:3-16 · KJV'),
  (8,  'Sermon',                  'Pastor Gbenga Adebanjo',   'Resisting and Overcoming Temptation'),
  (9,  'Offering',                null,                       'Give Thanks to the Lord · FLAG: not itemised in the order as sent, added back in usual slot · no offering leader named'),
  (10, 'Closing Prayer',          'Mummy Akintunde',          null),
  (11, 'Benediction',             'Sister Tinu',              null)
) as v(position, role, name, notes)
where p.service_date = '2026-09-13';

-- --------------------------------------------------------------------
-- 3. SCRIPTURE (cr_add_scripture_to_plan)
-- --------------------------------------------------------------------

select cr_add_scripture_to_plan(
  p_service_date => '2026-09-13'::date,
  p_position     => 98,
  p_book         => 'Matthew',
  p_chapter      => 6,
  p_verse_start  => 13,
  p_verse_end    => 13,
  p_section      => 'reading',
  p_version      => 'KJV'
);

select cr_add_scripture_to_plan(
  p_service_date => '2026-09-13'::date,
  p_position     => 99,
  p_book         => '1 Corinthians',
  p_chapter      => 10,
  p_verse_start  => 13,
  p_verse_end    => 13,
  p_section      => 'reading',
  p_version      => 'KJV'
);

select cr_add_scripture_to_plan(
  p_service_date => '2026-09-13'::date,
  p_position     => 100,
  p_book         => 'James',
  p_chapter      => 1,
  p_verse_start  => 3,
  p_verse_end    => 16,
  p_section      => 'reading',
  p_version      => 'KJV'
);

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 4. VERIFY
-- --------------------------------------------------------------------

-- Plan summary. Expect: songs = 8, scriptures = 1 (3-passage entry
-- may report as one or three rows depending on the helper), speakers = 11.
select p.service_date, p.notes,
       count(distinct i.id) filter (where i.kind = 'song')      as songs,
       count(distinct i.id) filter (where i.kind = 'scripture') as scriptures,
       coalesce(sum(jsonb_array_length(i.slides)), 0)           as total_slides,
       count(distinct s.id)                                     as speakers
from control_room_plans p
left join control_room_plan_items i    on i.plan_id = p.id
left join control_room_plan_speakers s on s.plan_id = p.id
where p.service_date = '2026-09-13'
group by p.service_date, p.notes;

-- Which songs still need lyrics? Expect NONE -- all 8 should resolve
-- from last week's plan.
select i.position, i.section, i.title, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-09-13'
  and i.kind = 'song'
  and i.slides::text like '%to be added%'
order by i.position;

-- Full running order: songs + scripture
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
from control_room_plan_items i
join control_room_plans p on p.id = i.plan_id
where p.service_date = '2026-09-13'
order by i.position;

-- Order of service speakers, with anything still needing input
select s.position, s.role, coalesce(s.name, '--') as name,
       case when s.notes like 'FLAG:%' or s.notes like '%FLAG:%' then 'NEEDS INPUT' else '' end as flag,
       s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-09-13'
order by s.position;

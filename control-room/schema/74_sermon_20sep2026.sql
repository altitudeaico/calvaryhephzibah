-- ============================================================
-- 74_sermon_20sep2026.sql
-- ============================================================
-- Pulled from the Zoom transcript of the 20 Sep 2026 service
-- (Calvary_Hephzibah_..._transcript_2026-09-20_12_14_18.txt).
-- Populates the sermon library (sermons, sermon_points,
-- sermon_scriptures, sermon_tags/sermon_tag_map,
-- sermon_teaching_threads) and, since the transcript also confirms
-- the scripture that was left TBC in 71_setlist_20sep2026.sql,
-- resolves that flag in the Control Room and cos_services too.
--
-- Confirmed from the transcript: Sister Petty's pre-sermon Bible
-- Reading was Romans 8:14-19 and Acts 10:36-38 (KJV).
--
-- Idempotent: re-running replaces the sermon and its children cleanly.
-- ============================================================

-- --------------------------------------------------------------------
-- 1. SERMON
-- --------------------------------------------------------------------

delete from sermons where service_date = '2026-09-20';

insert into sermons (
    service_date, title, preacher, is_guest, occasion, series,
    anchor_scripture, thesis, summary
  ) values (
    '2026-09-20',
    'Manifesting The Kingdom',
    'Bishop Henry Emmanuel',
    true,
    null,
    null,
    'Romans 8:14-19, Acts 10:36-38, John 1:12, 1 Timothy 4:8',
    'The kingdom of God moves from salvation to formation to manifestation -- and manifestation is not automatic. It comes through staying connected to God like Jesus did, being saturated in the Word, staying actively engaged in the church and with the poor, and ultimately living not for self but for the King.',
    'Continuing the church''s ongoing teaching on the kingdom of God -- salvation is the entrance, formation is the process -- Bishop Henry Emmanuel''s message pushes the arc to its third stage: manifestation. Opening from John 1:12 and the morning''s two Bible readings (Romans 8:14-19, on being led by the Spirit as sons of God, and Acts 10:36-38, on Jesus going about doing good because God was with Him), he argues the world is in enough confusion and turmoil that it is waiting to see the power of God worked out through believers, not just professed by them.

He builds the message around four connected requirements for manifestation. First, connection with God: Jesus rose early to pray (Mark 1:35) and repeatedly said He could do nothing of Himself, only what He observed the Father doing (John 5:19) -- illustrated with an extended personal testimony about a teenage intercessor in Uganda/Kenya who, after seeing a specific healing in a vision during prayer, was able to recognise and minister to that exact person on the street the next day. Second, saturation in the Word: 2 Timothy 2:15 (''study to shew thyself approved'') and Joshua 1:8 (meditating on the word day and night) are paired with 1 Timothy 4:8 -- ''godliness is profitable unto all things'' -- and Philippians 4:8, framed as discipleship that never really finishes; he includes his own admission that decades into ministry he is still ''in the making.'' Third, active engagement: drawing on Hebrews 10:25 against neglecting church gathering, and Matthew 25 and James 1 on caring for the poor as evidence of true religion, he warns that a gift or calling left unused while someone stays away from church becomes a burden rather than a blessing. Fourth, living for the King rather than for self: from Jesus''s high-priestly prayer in John 17:17-19, he argues the Word is what sanctifies, not the borrowed testimony of others -- with a pointed aside that many marriages fail because couples lean on other people''s stories instead of scripture for direction.

He closes with an altar call, inviting anyone who needs to rededicate their life to stand and be prayed for, framing the moment as a renewal of strength, commitment and dedication needed to keep ''exercising unto godliness.'''
  );

-- --------------------------------------------------------------------
-- 2. POINTS
-- --------------------------------------------------------------------

insert into sermon_points (sermon_id, position, heading, detail, scriptures)
select (select id from sermons where service_date = '2026-09-20'), v.position, v.heading, v.detail, v.scriptures
from (values
  (1, 'The progression: salvation, formation, manifestation',
      'Opens by locating the message as the next stage after entering the kingdom (salvation) and being formed in it -- manifestation is when the kingdom''s power becomes visible through believers, and the world is watching because it is in turmoil and wants to see it.',
      ARRAY['John 1:12', 'Romans 8:14-19']),
  (2, 'Connection with God: Jesus''s early mornings',
      'Jesus rose early to pray and repeatedly said He could do nothing of Himself, only what He saw the Father doing. Illustrated with a long personal testimony about a teenage intercessor whose prayer visions let her recognise and minister to a specific healed man on the street the next day.',
      ARRAY['Mark 1:35', 'John 5:19']),
  (3, 'Saturated with the Word: discipleship never finishes',
      'Study to show yourself approved (2 Timothy 2:15) and meditate day and night (Joshua 1:8) are paired with ''godliness is profitable unto all things'' (1 Timothy 4:8) and Philippians 4:8. A personal admission: decades into ministry, he is still ''in the making.''',
      ARRAY['2 Timothy 2:15', 'Joshua 1:8', '1 Timothy 4:8', 'Philippians 4:8']),
  (4, 'Actively engaged: church and the poor',
      'A gift or calling left dormant while someone stops gathering with the church becomes a burden, not a blessing (Hebrews 10:25). Caring for the poor and imprisoned (Matthew 25) and James 1''s ''true religion'' are named as marks of manifestation in action.',
      ARRAY['Hebrews 10:25', 'Matthew 25', 'James 1']),
  (5, 'Living for the King, not for self',
      'From Jesus''s prayer in John 17:17-19, sanctification comes through the Word, not other people''s testimonies -- applied pointedly to marriages that lean on borrowed stories instead of scripture.',
      ARRAY['John 17:17-19']),
  (6, 'Altar call: rededication',
      'Closes by inviting anyone needing to rededicate their life to stand for prayer, framed as a renewal of strength, commitment and dedication to keep ''exercising unto godliness.''',
      ARRAY['none cited directly'])
) as v(position, heading, detail, scriptures);

-- --------------------------------------------------------------------
-- 3. SCRIPTURES
-- --------------------------------------------------------------------

insert into sermon_scriptures (sermon_id, reference, book, chapter, verse_start, verse_end, role)
select (select id from sermons where service_date = '2026-09-20'), v.reference, v.book, v.chapter, v.verse_start, v.verse_end, v.role
from (values
  ('Romans 8:14-19',   'Romans',        8,  14, 19, 'anchor'),
  ('Acts 10:36-38',    'Acts',          10, 36, 38, 'supporting'),
  ('John 1:12',        'John',          1,  12, 12, 'supporting'),
  ('Mark 1:35',        'Mark',          1,  35, 35, 'supporting'),
  ('John 5:19',        'John',          5,  19, 19, 'supporting'),
  ('2 Timothy 2:15',   '2 Timothy',     2,  15, 15, 'supporting'),
  ('Joshua 1:8',       'Joshua',        1,  8,  8,  'supporting'),
  ('1 Timothy 4:8',    '1 Timothy',     4,  8,  8,  'supporting'),
  ('Philippians 4:8',  'Philippians',   4,  8,  8,  'supporting'),
  ('Hebrews 10:25',    'Hebrews',       10, 25, 25, 'supporting'),
  ('Matthew 25',       'Matthew',       25, null, null, 'supporting'),
  ('James 1',          'James',         1,  null, null, 'supporting'),
  ('John 17:17-19',    'John',          17, 17, 19, 'supporting')
) as v(reference, book, chapter, verse_start, verse_end, role);

-- --------------------------------------------------------------------
-- 4. TAGS
-- --------------------------------------------------------------------

insert into sermon_tags (name)
select v.name from (values
  ('kingdom of god'), ('manifestation'), ('prayer'), ('discipleship'),
  ('word of god'), ('service to others'), ('guest minister'), ('altar call')
) as v(name)
on conflict (name) do nothing;

insert into sermon_tag_map (sermon_id, tag_id)
select (select id from sermons where service_date = '2026-09-20'), t.id
from sermon_tags t
where t.name in ('kingdom of god', 'manifestation', 'prayer', 'discipleship',
                  'word of god', 'service to others', 'guest minister', 'altar call');

-- --------------------------------------------------------------------
-- 5. TEACHING THREADS (clip-worthy moments)
-- --------------------------------------------------------------------

insert into sermon_teaching_threads (sermon_id, name, summary)
select (select id from sermons where service_date = '2026-09-20'), v.name, v.summary
from (values
  ('The Vision Prayer',
   'A striking personal testimony: a teenage intercessor sees a specific person''s healing in a prayer vision, then recognises and ministers to that exact person on the street the next day -- a vivid picture of doing only what you ''observe the Father doing.'''),
  ('Still In The Making',
   'A disarming admission from decades into ministry: ''my memory is growing, I''m still in the making'' -- discipleship never graduates, even for the preacher.'),
  ('A Gift Left Unused Becomes a Burden',
   'God doesn''t take back a calling from someone who stops gathering with the church -- but the unused gift becomes a burden rather than a blessing. A sharp challenge on church attendance.'),
  ('Borrowed Testimony vs. the Word',
   'A pointed aside on why marriages fail: couples lean on other people''s stories and advice instead of scripture -- ''the truth will set you free, not testimony.''')
) as v(name, summary);

-- --------------------------------------------------------------------
-- 6. RESOLVE THE SCRIPTURE-TBC FLAG (Control Room + cos_services)
-- --------------------------------------------------------------------

select cr_add_scripture_to_plan(
  p_service_date => '2026-09-20'::date,
  p_position     => 98,
  p_book         => 'Romans',
  p_chapter      => 8,
  p_verse_start  => 14,
  p_verse_end    => 19,
  p_section      => 'reading',
  p_version      => 'KJV'
);

select cr_add_scripture_to_plan(
  p_service_date => '2026-09-20'::date,
  p_position     => 99,
  p_book         => 'Acts',
  p_chapter      => 10,
  p_verse_start  => 36,
  p_verse_end    => 38,
  p_section      => 'reading',
  p_version      => 'KJV'
);

update control_room_plan_speakers s
set notes = 'Romans 8:14-19 · Acts 10:36-38 (KJV) — confirmed from the service transcript'
from control_room_plans p
where s.plan_id = p.id
  and p.service_date = '2026-09-20'
  and s.role = 'Bible Reading';

update cos_services
set scripture = 'Romans 8:14-19 · Acts 10:36-38',
    notes = notes || E'\n\nUPDATE 20 Sep (post-service): scripture confirmed from the transcript (Romans 8:14-19, Acts 10:36-38, KJV) — flag resolved. Full sermon (points, scriptures, tags, clip-worthy threads) logged in the sermon library. Offering leader still not named.'
where service_date = '2026-09-20';

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 7. VERIFY
-- --------------------------------------------------------------------

select s.title, s.preacher, s.is_guest, s.anchor_scripture,
       (select count(*) from sermon_points p where p.sermon_id = s.id) as points,
       (select count(*) from sermon_scriptures ss where ss.sermon_id = s.id) as scriptures,
       (select count(*) from sermon_tag_map tm where tm.sermon_id = s.id) as tags,
       (select count(*) from sermon_teaching_threads tt where tt.sermon_id = s.id) as threads
from sermons s
where s.service_date = '2026-09-20';

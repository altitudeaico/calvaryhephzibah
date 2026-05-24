-- ============================================================
-- 17_sermon_24may2026_passages.sql
-- ============================================================
-- For Sunday 24 May 2026: Bishop Bayo Yusuf — "Doing Good Has A Pay Day"
--
-- The preacher has provided one main passage + six supporting passages
-- across four translations (NIV, NCV, CEV, KJV). Only KJV is currently
-- seeded in control_room_bible. This migration:
--
--   1. Inserts the specific verses needed for today's sermon in their
--      requested translations (NIV / NCV / CEV).
--   2. Cues all 7 passages onto the 24 May plan with section = 'sermon'
--      so they group separately from the worship songs in the set list.
--
-- Idempotent: safe to re-run. Existing sermon section is cleared each
-- time so the cue list reflects the latest call.
-- ============================================================

-- ────────────────────────────────────────────────────────────────────
-- 1. Insert today's verses in requested translations
-- ────────────────────────────────────────────────────────────────────
-- ON CONFLICT (version, book, chapter, verse) means re-running is safe.

insert into control_room_bible (version, book, book_num, chapter, verse, text) values
  -- Galatians 6:9 NIV (main passage)
  ('NIV', 'Galatians', 48, 6, 9,
   'Let us not become weary in doing good, for at the proper time we will reap a harvest if we do not give up.'),

  -- Romans 7:19 NIV
  ('NIV', 'Romans', 45, 7, 19,
   'For I do not do the good I want to do, but the evil I do not want to do—this I keep on doing.'),

  -- Romans 7:21-25 NCV
  ('NCV', 'Romans', 45, 7, 21,
   'So I have learned this rule: When I want to do good, evil is there with me.'),
  ('NCV', 'Romans', 45, 7, 22,
   'In my mind, I am happy with God''s law.'),
  ('NCV', 'Romans', 45, 7, 23,
   'But I see another law working in my body, which makes war against the law that my mind accepts. That other law working in my body is the law of sin, and it makes me its prisoner.'),
  ('NCV', 'Romans', 45, 7, 24,
   'What a miserable man I am! Who will save me from this body that brings me death?'),
  ('NCV', 'Romans', 45, 7, 25,
   'I thank God for saving me through Jesus Christ our Lord!'),

  -- Acts 2:1-4 NIV
  ('NIV', 'Acts', 44, 2, 1,
   'When the day of Pentecost came, they were all together in one place.'),
  ('NIV', 'Acts', 44, 2, 2,
   'Suddenly a sound like the blowing of a violent wind came from heaven and filled the whole house where they were sitting.'),
  ('NIV', 'Acts', 44, 2, 3,
   'They saw what seemed to be tongues of fire that separated and came to rest on each of them.'),
  ('NIV', 'Acts', 44, 2, 4,
   'All of them were filled with the Holy Spirit and began to speak in other tongues as the Spirit enabled them.'),

  -- 1 Corinthians 15:45-46 CEV
  ('CEV', '1 Corinthians', 46, 15, 45,
   'The first man was named Adam, and the Scriptures tell us that he was a living person. But Jesus, who may be called the last Adam, is a life-giving spirit.'),
  ('CEV', '1 Corinthians', 46, 15, 46,
   'We see that the one with a spiritual body did not come first. He came after the one who had a physical body.'),

  -- Colossians 3:1-4 NIV
  ('NIV', 'Colossians', 51, 3, 1,
   'Since, then, you have been raised with Christ, set your hearts on things above, where Christ is, seated at the right hand of God.'),
  ('NIV', 'Colossians', 51, 3, 2,
   'Set your minds on things above, not on earthly things.'),
  ('NIV', 'Colossians', 51, 3, 3,
   'For you died, and your life is now hidden with Christ in God.'),
  ('NIV', 'Colossians', 51, 3, 4,
   'When Christ, who is your life, appears, then you also will appear with him in glory.')

on conflict (version, book, chapter, verse) do update
  set text = excluded.text;

-- Note: Psalm 51:17 KJV is already in the database from the original KJV seed.

-- ────────────────────────────────────────────────────────────────────
-- 2. Clear any existing sermon-section items so re-running is clean
-- ────────────────────────────────────────────────────────────────────
delete from control_room_plan_items
 where plan_id = (select id from control_room_plans where service_date = '2026-05-24')
   and section = 'sermon';

-- Also remove the old KJV Galatians 6:9 cue from yesterday (was at position 99,
-- section 'reading'). It's superseded by the NIV main passage in the sermon group.
delete from control_room_plan_items
 where plan_id = (select id from control_room_plans where service_date = '2026-05-24')
   and kind = 'scripture'
   and section = 'reading';

-- ────────────────────────────────────────────────────────────────────
-- 3. Cue the sermon passages — section='sermon', in preaching order
-- ────────────────────────────────────────────────────────────────────
-- Positions 100+ keeps them well clear of any song positions (1-8).

-- Main passage: Galatians 6:9 NIV
select cr_add_scripture_to_plan(
  p_service_date => '2026-05-24'::date,
  p_position     => 100,
  p_book         => 'Galatians',
  p_chapter      => 6,
  p_verse_start  => 9,
  p_verse_end    => 9,
  p_section      => 'sermon',
  p_version      => 'NIV'
);

-- 1. Romans 7:19 NIV
select cr_add_scripture_to_plan('2026-05-24'::date, 101, 'Romans',        7,  19, 19, 'sermon', 'NIV');

-- 2. Romans 7:21-25 NCV
select cr_add_scripture_to_plan('2026-05-24'::date, 102, 'Romans',        7,  21, 25, 'sermon', 'NCV');

-- 3. Acts 2:1-4 NIV
select cr_add_scripture_to_plan('2026-05-24'::date, 103, 'Acts',          2,  1,  4,  'sermon', 'NIV');

-- 4. Psalm 51:17 KJV
select cr_add_scripture_to_plan('2026-05-24'::date, 104, 'Psalms',        51, 17, 17, 'sermon', 'KJV');

-- 5. 1 Corinthians 15:45-46 CEV
select cr_add_scripture_to_plan('2026-05-24'::date, 105, '1 Corinthians', 15, 45, 46, 'sermon', 'CEV');

-- 6. Colossians 3:1-4 NIV
select cr_add_scripture_to_plan('2026-05-24'::date, 106, 'Colossians',    3,  1,  4,  'sermon', 'NIV');

-- ────────────────────────────────────────────────────────────────────
-- VERIFY
-- ────────────────────────────────────────────────────────────────────

-- All items in the 24 May plan, grouped by section
select i.position, i.kind, i.section, i.title, jsonb_array_length(i.slides) as slides
  from control_room_plan_items i
  join control_room_plans p on p.id = i.plan_id
 where p.service_date = '2026-05-24'
 order by i.position;

-- Spot-check: how do the sermon scripture slides look?
select i.title, i.section, jsonb_pretty(i.slides->0) as first_slide
  from control_room_plan_items i
  join control_room_plans p on p.id = i.plan_id
 where p.service_date = '2026-05-24'
   and i.section = 'sermon'
 order by i.position;

-- Quick translation count
select version, count(*) as verses
  from control_room_bible
 group by version
 order by version;

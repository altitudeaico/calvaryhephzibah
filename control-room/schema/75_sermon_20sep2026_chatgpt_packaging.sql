-- ============================================================
-- 75_sermon_20sep2026_chatgpt_packaging.sql
-- ============================================================
-- ChatGPT's theme check, study guide and week-packaging pass on
-- "Manifesting The Kingdom" (Bishop Henry Emmanuel, 20 Sep 2026),
-- stored against the sermon already logged in 74_sermon_20sep2026.sql.
--
-- 1. Sharpens sermons.thesis + adds the editorial architecture to notes
-- 2. Study guide -> content_items (content_type = 'study'), one
--    row per teaching point (points 1-5; the altar call is response,
--    not a study point)
-- 3. Campaign packaging -> content_items (content_type = 'caption_only')
-- 4. Refined clip angles -> content_items (content_type = 'caption_only'),
--    linked to the existing sermon_teaching_threads by id
--
-- NOTE: no sermon_clips rows here -- those get created once the raw
-- sermon video is actually cut in OpusClip. This is pre-production.
--
-- Idempotent: re-running replaces everything this file owns for this
-- sermon (matched on sermon_id + content_type).
-- ============================================================

-- --------------------------------------------------------------------
-- 1. THESIS + EDITORIAL ARCHITECTURE
-- --------------------------------------------------------------------

update sermons
set thesis = 'God does not only save us. He forms us so that His Kingdom can be seen through us. That formation happens as we stay connected to God, grow in His Word, serve others and learn to live for the King rather than ourselves.',
    notes = 'ChatGPT theme-check (20 Sep 2026): centre of gravity is formation, not a dramatic "manifestation" event -- title kept (it is Bishop Henry''s own language) but thesis sharpened. Romans 8:19 ("creation is waiting to see what God has been forming") given as the emotional centre. Editorial architecture for site/study/campaign use:
THE JOURNEY -- Salvation -> Formation -> Manifestation
HOW GOD FORMS US -- Connection -> The Word -> Active Service
WHAT IT PRODUCES -- A life lived for the King
THE RESPONSE -- Rededication (point 6 / the altar call is the response to points 1-5, not a sixth teaching point)
Campaign line: "Saved doesn''t mean finished."'
where service_date = '2026-09-20';

-- --------------------------------------------------------------------
-- 2. STUDY GUIDE
-- --------------------------------------------------------------------

delete from content_items
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'study';

insert into content_items (sermon_id, content_type, hook, core_message, scripture, study_angle, application_question, editorial_status, created_by)
select
  (select id from sermons where service_date = '2026-09-20'),
  'study', v.hook, v.core_message, v.scripture, v.study_angle, v.application_question, 'draft', 'chatgpt'
from (values
  ('Salvation → Formation → Manifestation',
   'Receiving Christ gives us a new identity as children of God. But becoming part of God''s family is the beginning, not the end. God continues shaping His children so that their lives increasingly reveal Him.',
   'John 1:12; Romans 8:14-19',
   'Big idea: God''s work in us does not stop when we are saved.',
   'What has changed in you since you first believed? Where can you see God still shaping you? If somebody only saw how you lived this week, what would they learn about the God you follow?'),
  ('Stay connected to God',
   'Jesus ministered publicly from a life that was deeply connected to His Father privately. Prayer was not an emergency measure. It was part of His way of life.',
   'Mark 1:35; John 5:19',
   'Connection is the first requirement for formation.',
   'What does your connection with God look like when nobody else sees it? Is prayer mainly something you turn to when you need something? What could you change this week to make deliberate time with God?'),
  ('Stay in the Word',
   'There is no point at which a Christian graduates from discipleship. God''s Word continues teaching, correcting and reshaping the way we think and live.',
   '2 Timothy 2:15; Joshua 1:8; 1 Timothy 4:8; Philippians 4:8',
   'Discipleship never finishes -- not even for the preacher.',
   'Are you still deliberately learning, or are you living mainly on what you already know? What has been shaping your thinking recently? Is there something you know from Scripture that you now need to put into practice?'),
  ('Don''t just attend. Engage.',
   'Following Jesus is not only about what happens between you and God privately. It changes how you participate in His church and how you respond to people in need.',
   'Hebrews 10:25; Matthew 25; James 1',
   'Formation shows up in participation, not just private devotion.',
   'Are you mainly attending church, or contributing to it? Who around you could practically experience God''s love through you? Where could you serve rather than simply observe?'),
  ('Live for the King',
   'Jesus sends His people into the world with purpose. Our gifts, opportunities and lives are not ultimately given simply for ourselves.',
   'John 17:17-19',
   'The destination of formation: a life lived for the King, not for self.',
   'What has God placed in your hands that you may not be using? Where has comfort become more important than obedience? What would living for the King change about one decision you are making right now?')
) as v(hook, core_message, scripture, study_angle, application_question);

-- --------------------------------------------------------------------
-- 3. CAMPAIGN PACKAGING
-- --------------------------------------------------------------------

delete from content_items
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'caption_only';

insert into content_items (sermon_id, content_type, hook, core_message, cta, editorial_status, created_by, notes)
values
  (
    (select id from sermons where service_date = '2026-09-20'),
    'caption_only',
    'You weren''t only saved to believe differently. You were saved to live differently.',
    'Hero hook for the week -- the entry line for the sermon post / preview page.',
    null, 'draft', 'chatgpt', 'Campaign theme for the week: "Saved doesn''t mean finished."'
  ),
  (
    (select id from sermons where service_date = '2026-09-20'),
    'caption_only',
    'What does it actually look like for God''s Kingdom to show up in an ordinary life?',
    'Bishop Henry Emmanuel takes us beyond simply receiving Christ to the lifelong process of being formed by Him. Through prayer, God''s Word, serving others and learning to live for the King rather than ourselves, God changes us so that what He is doing inside us becomes visible through how we live.',
    'Manifesting The Kingdom | Bishop Henry Emmanuel', 'draft', 'chatgpt', 'Primary sermon description, for the briefing/preview page and post copy.'
  ),
  (
    (select id from sermons where service_date = '2026-09-20'),
    'caption_only',
    'Still in the making.',
    'Editorial pull-quote theme (not a direct Bishop Henry quotation unless verified against the recording) -- bridges into "Saved doesn''t mean finished."',
    null, 'draft', 'chatgpt', 'Strongest single social line identified from the sermon.'
  ),
  (
    (select id from sermons where service_date = '2026-09-20'),
    'caption_only',
    'WHO IS YOUR LIFE FOR?',
    'You can believe in God, know Scripture and go to church. But eventually the question becomes simpler: who is your life actually for? Jesus didn''t call us to build a life entirely around ourselves. He calls us to follow Him, serve people and use what He has put in our hands. The Kingdom becomes visible when following the King changes how we live.',
    'Watch the full message: Manifesting The Kingdom with Bishop Henry Emmanuel. Search YouTube for Calvary Hephzibah.',
    'draft', 'chatgpt', 'Closing post for the week -- ties the four-clip campaign (Prayer -> Growth -> Word -> Gifts -> Purpose) together.'
  );

-- --------------------------------------------------------------------
-- 4. REFINED CLIP ANGLES (linked to the existing teaching threads)
-- --------------------------------------------------------------------
-- Shares content_type = 'caption_only' with section 3 (the schema's
-- check constraint has no dedicated value for planning-stage clip
-- angles) -- distinguished instead by teaching_thread_id being set.
-- No separate delete here: section 3's delete already cleared this
-- sermon's 'caption_only' rows before either insert ran.

insert into content_items (sermon_id, teaching_thread_id, content_type, hook, core_message, editorial_status, created_by)
select
  (select id from sermons where service_date = '2026-09-20'),
  tt.id, 'caption_only', v.angle, v.note, 'draft', 'chatgpt'
from sermon_teaching_threads tt
join (values
  ('The Vision Prayer',                    'What can happen when somebody learns to genuinely seek God?', 'Story-led clip -- let the testimony carry it rather than over-explaining it.'),
  ('Still In The Making',                  'Saved doesn''t mean finished.', 'Bishop admitting he is still growing makes the broader teaching accessible rather than preachy.'),
  ('Borrowed Testimony vs. the Word',      'You can''t build your whole faith on somebody else''s experience.', 'The Word / disciple-development unit of the campaign.'),
  ('A Gift Left Unused Becomes a Burden',  'What are you doing with what God gave you?', 'Moves the audience from formation towards action and service.')
) as v(thread_name, angle, note) on tt.name = v.thread_name
where tt.sermon_id = (select id from sermons where service_date = '2026-09-20');

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- 5. VERIFY
-- --------------------------------------------------------------------

select content_type, count(*) from content_items
where sermon_id = (select id from sermons where service_date = '2026-09-20')
group by content_type order by content_type;

select thesis from sermons where service_date = '2026-09-20';

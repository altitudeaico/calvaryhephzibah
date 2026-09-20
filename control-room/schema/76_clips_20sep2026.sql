-- ============================================================
-- 76_clips_20sep2026.sql
-- ============================================================
-- Bolaji's top 6 picks from the OpusClip run on the 20 Sep 2026
-- sermon (project P3092011qmuK, YouTube https://youtu.be/B9JiC_NZjK4).
-- Logs each as a real sermon_clips row (replacing the earlier
-- planning-stage 'caption_only' clip_angle stubs from
-- 75_sermon_20sep2026_chatgpt_packaging.sql for the ones that made
-- the cut) plus a content_items 'clip' row carrying the transcript.
--
-- TRANSCRIPTS: matched against the full service transcript by content
-- (there is no ASR step in this environment), not independently
-- re-verified against each exported clip's exact trim boundaries.
-- Close to the real cut but may run a few seconds either side.
--
-- CARE FLAG: "You Are Kings" leans on the "ye are gods" reading of
-- Psalm 82 / John 10:34 -- contested even within Christian circles.
-- Bolaji selected it anyway with this flag noted; kept care_flag=true
-- so it's visible in any future review.
--
-- Idempotent: re-running replaces these 6 clips' rows cleanly.
-- ============================================================

delete from content_items
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id in (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20')
      and rank in (3, 4, 5, 6, 8, 9)
  );

delete from sermon_clips
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and rank in (3, 4, 5, 6, 8, 9);

with new_clips as (
  insert into sermon_clips (sermon_id, rank, hook, theme, timestamp_hint, platforms, status, care_flag, care_note)
  select
    (select id from sermons where service_date = '2026-09-20'),
    v.rank, v.hook, v.theme, v.timestamp_hint, v.platforms, 'candidate', v.care_flag, v.care_note
  from (values
    (3, 'God''s Expectation: Experience Reality & Divine Omen', 'The Vision Prayer testimony',
     'opusclip:9miaYzo15g (project P3092011qmuK, 63s, score 97)',
     ARRAY['instagram','tiktok','youtube_shorts','facebook'], false, null),
    (4, 'Manifesting God''s Kingdom: Letting His Power Work Through Us', 'Defining "manifesting the kingdom" -- letting God''s rule, values and power work through us',
     'opusclip:mAj055fsiO (project P3092011qmuK, 42s, score 96)',
     ARRAY['instagram','tiktok','youtube_shorts','facebook'], false, null),
    (9, 'You Are Kings: Understanding Jesus''s Divine Message', '"We are small kings / small gods" -- Psalm 82 / John 10:34 framing',
     'opusclip:aMh1KxkUGb (project P3092011qmuK, 31s, score 92)',
     ARRAY['instagram','tiktok','youtube_shorts','facebook'], true,
     'Theologically contested framing ("ye are gods") outside full sermon context -- flagged to Bolaji before selection, he chose to include it anyway. Consider whether it needs framing text/caption context before posting.'),
    (8, 'The Secret to Bringing God''s Glory Down!', 'Waiting on God -- the "one song" secret to His glory manifesting',
     'opusclip:F15c461vG7 (project P3092011qmuK, 29s, score 93)',
     ARRAY['instagram','tiktok','youtube_shorts','facebook'], false, null),
    (6, 'Spiritual vs. Physical Exercise: Which is More Profitable?', '1 Timothy 4:8 -- godliness as something you exercise, same as the body',
     'opusclip:KtTqpCeaIk (project P3092011qmuK, 49s, score 95)',
     ARRAY['instagram','tiktok','youtube_shorts','facebook'], false, null),
    (5, 'Holy Ghost Power: Overcoming Challenges with Faith', 'Leaning on the Holy Ghost; a 46-year walk with Christ since 1980',
     'opusclip:pgYjJ9EgGR (project P3092011qmuK, 36s, score 96)',
     ARRAY['instagram','tiktok','youtube_shorts','facebook'], false, null)
  ) as v(rank, hook, theme, timestamp_hint, platforms, care_flag, care_note)
  returning id, rank
)
insert into content_items (sermon_id, teaching_thread_id, source_clip_id, content_type, hook, core_message, notes, editorial_status, created_by)
select
  (select id from sermons where service_date = '2026-09-20'),
  v.thread_id, nc.id, 'clip', v.hook, v.core_message, v.transcript, 'draft', 'claude'
from new_clips nc
join (values
  (3, null::uuid,
   'God''s Expectation: Experience Reality & Divine Omen',
   'Don''t give up on your path -- creation is waiting for the manifestation of God''s sons; we must reach a higher level for God to manifest through us.',
   'TRANSCRIPT (matched from full service transcript, ~11:55:37-11:56:49): "There was this 15-year-old lady. He was into intercession. This lady could pray for 48 hours non-stop. And they''re only drinking water. 15-year-old Jesus Grabber. And then most of the witches in Uganda and Kenya, they came to bow to Jesus under her feet. Now, why I''m giving this testimony is this. In the course of her prayer, she will be taken to heaven, and she will observe a man on the street among many people that was being healed by Jesus. So when she comes back. The following day, when she finished praying all her prayer, she would go to the street. She would be looking at other people, both the blinder and the creeper and whatever thing, but the moment she observed or noticed the one that was healed. In heaven, she will walk there straight, and then she will say, you are healed. Do you get that principle? So that''s why Jesus said, he said, the work that I do. is the one that I see the Father do. So, it''s not everybody that came to Jesus that Jesus healed. And there was a time he healed everybody"'),
  (4, null::uuid,
   'Manifesting God''s Kingdom: Letting His Power Work Through Us',
   'What manifesting the kingdom of God really means: letting God''s rules, values and power work through our lives to change the world around us.',
   'TRANSCRIPT (matched from full service transcript, ~11:44:49-11:45:42): "Now, let''s now go. When we say manifesting, uh. the kingdom of God, what do we really mean. This is simply. Letting God rule. Values and power. Through our life. That is, when we allow the Gospel, Gospel rules its values and principles. power work through our life to change the world around us. We are lying. God''s rules, and His power, and His value. to root through us and change the world around us. And that''s why we read in that Romans chapter 8 that the whole creation is waiting. for the manifestations of the sons of God. The question is, who are the sons of God?" (NOTE: "We are lying" as transcribed -- likely "We are relying" mis-heard/mis-transcribed; left verbatim rather than corrected.)'),
  (9, null::uuid,
   'You Are Kings: Understanding Jesus''s Divine Message',
   'We are the kings, the lords, the "small gods" -- entitled to what Jesus possesses because His kingdom is within us.',
   'TRANSCRIPT (matched from full service transcript, ~11:49:19-11:49:57): "Why? A small king is coming. Not the king who, not the little king, a small king, and that is you and I. Why is Jesus King of kings? Who are the kings? Jesus said, Have you not heard? Has it not been said to you that ye are kings? And that you are God''s? Why is Jesus king of kings? We are the kings. We are the Lords. Are you listening to me? So, Jesus is our Lord. He is our King. We are the… we are the small gods. We are the small lords. We are the small kings."'),
  (8, null::uuid,
   'The Secret to Bringing God''s Glory Down!',
   'The secret to God''s glory showing up isn''t a technique -- it''s waiting, and giving Him one song to sing.',
   'TRANSCRIPT (matched from full service transcript, ~11:41:18-11:41:48): "On two or three occasions, there are these couple that came to me at different occasions. They say, Brother Henry. What happened? I said, what happened? How do you normally… what do you normally do to bring the glory of God down? I said, I did not see the glory. They said, we saw it. The glory came down. I said, what''s your secret? They said, what''s your secret? The only thing I know is that I wait. To make sure you give me one song to sing. Hallelujah. Praise the Lord, everybody. The Lord is good. Nothing you do to go that is waste. He will reward you."'),
  (6, null::uuid,
   'Spiritual vs. Physical Exercise: Which is More Profitable?',
   'We''ll pour hours and money into gym discipline but resist the idea that godliness needs the same constant exercise -- yet 1 Timothy 4:8 says it profits more.',
   'TRANSCRIPT (matched from full service transcript, ~11:58:56-12:00:08 -- this passage runs a bit longer than the 49s clip, exact trim not independently verified): "Verse 8. Paul was writing to Timothy, encouraging him, as a minister of God, as a pastor, what would help him to manifest the kingdom. Look at what it says here. Look at verse 8. It will take understanding of the Spirit to grab it, and you''re going to grab it in Jesus'' name. He said. For bodily exercise profited little. Now… Let''s stop there for a moment. How do you exercise your body? You go to a gym. I want you to look at how much you spend in gym. to get yourself to ride, to, to, to, to, to be fit. How much? You know it. Not just the money. What about the hours? You know what and what you do to put yourself right when it comes to physical exercises. But look at what he says here. He now puts it side by side with spiritual exercises. Look at what he says. He says. But godliness is profitable unto all things. In other words, godliness also needs some degree of exercises. Hello! Godliness! You need to exercise it!"'),
  (5, null::uuid,
   'Holy Ghost Power: Overcoming Challenges with Faith',
   'Challenges become nothing when we give in to the Holy Ghost -- a testimony from 46 years walking with Christ since 1980.',
   'TRANSCRIPT (matched from full service transcript, ~12:02:19-12:02:55): "We are made to be joint heirs with God. If somebody''s listening to me, I''m talking of manifestation. Okay, let''s continue. I''m talking of manifesting the kingdom. The challenges that we have, they are nothing when we give in to the Holy Ghost. Without the Holy Spirit, we can''t do nothing. Look, you look, I am not what I am today within one week. I gave my life to Christ 1980. 1980 and now. How many years?"')
) as v(rank, thread_id, hook, core_message, transcript) on v.rank = nc.rank;

-- Link "The Vision Prayer" teaching thread to its clip (rank 3)
update content_items
set teaching_thread_id = (
  select tt.id from sermon_teaching_threads tt
  join sermons s on s.id = tt.sermon_id
  where s.service_date = '2026-09-20' and tt.name = 'The Vision Prayer'
)
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 3
  );

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- VERIFY
-- --------------------------------------------------------------------

select sc.rank, sc.hook, sc.care_flag, ci.id is not null as has_transcript
from sermon_clips sc
left join content_items ci on ci.source_clip_id = sc.id and ci.content_type = 'clip'
where sc.sermon_id = (select id from sermons where service_date = '2026-09-20')
  and sc.rank in (3,4,5,6,8,9)
order by sc.rank;

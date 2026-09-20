-- ============================================================
-- 78_chatgpt_creative_pass_20sep2026.sql
-- ============================================================
-- ChatGPT's creative pass on the 10 stills: winner selection per
-- clip, 3 end cards, 3 carousels, and an explicit publishing
-- caveat on the "You Are Kings" clip.
--
-- Idempotent: re-running replaces the end_card/carousel rows and
-- reapplies the still-selection notes cleanly.
-- ============================================================

-- --------------------------------------------------------------------
-- 1. STILL SELECTION (which frame wins per clip)
-- --------------------------------------------------------------------

update content_items set notes = notes || ' SELECTED (ChatGPT, 20 Sep): more open expression, story-led.'
where id = '4f8282a8-ade7-4f1b-9db6-b1517a9b8812'; -- 01 vision-prayer-a (beats 02)

update content_items set notes = notes || ' NOT SELECTED vs 01 -- less open expression.'
where id = 'f20d67f6-e404-473f-93cb-972cb348e092'; -- 02 vision-prayer-b

update content_items set notes = notes || ' SELECTED (ChatGPT, 20 Sep): face/eye-line/mic visible, beats 03''s downward transitional frame.'
where id = '5ec0a01e-5143-418f-b15b-7b9a8e34970e'; -- 04 manifesting-kingdom-b (beats 03)

update content_items set notes = notes || ' NOT SELECTED vs 04 -- downward-looking transitional frame.'
where id = '4bf357c2-c7eb-4416-918f-227495b6d633'; -- 03 manifesting-kingdom-a

update content_items set notes = notes || ' SELECTED (ChatGPT, 20 Sep): open-hand gesture visually communicates the exercise/teaching point, beats 07.'
where id = '332c9af4-2d9d-4a12-a40b-da1a497b7cae'; -- 08 spiritual-exercise-b (beats 07)

update content_items set notes = notes || ' NOT SELECTED vs 08 -- weaker gesture.'
where id = '6cc415b6-b6eb-4871-b3be-ffab9327f5ef'; -- 07 spiritual-exercise-a

update content_items set notes = notes || ' SELECTED (ChatGPT, 20 Sep): more declarative and alive than 06.'
where id = '3d363ab1-c97a-443e-895c-b04f7058dafc'; -- 05 holy-ghost-power-a (beats 06)

update content_items set notes = notes || ' NOT SELECTED vs 05.'
where id = '6df2c96c-0973-4b5b-9509-e244252abe8b'; -- 06 holy-ghost-power-b

update content_items set notes = notes || ' SELECTED -- only candidate for this clip. Treat as source material only: PUBLISHING CAVEAT -- do not post as a standalone quote card ("You Are Kings"/"small gods"). Must be framed inside a carousel that establishes context first -- see the "You Are Kings" carousel in this same batch. Verify exact transcript immediately before/after this section before writing any final caption.'
where id = '5dca1824-f415-43db-b5e5-f1483275a870'; -- 10 you-are-kings

-- --------------------------------------------------------------------
-- 2. END CARDS
-- --------------------------------------------------------------------

delete from content_items
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'end_card';

insert into content_items (sermon_id, source_clip_id, content_type, hook, core_message, notes, editorial_status, created_by)
select
  (select id from sermons where service_date = '2026-09-20'), sc.id, 'end_card', v.hook, v.core_message, v.notes, 'draft', 'chatgpt'
from (values
  (6, 'TRAIN YOUR FAITH TOO.',
      'Setup (Instrument Serif italic): "You train your body." Payoff (Anton): "TRAIN YOUR FAITH TOO." Small copy: "1 TIMOTHY 4:8".',
      'ChatGPT: "probably the cleanest end card of the six -- instantly understandable, scripturally anchored, very shareable."'),
  (8, 'WAIT ON GOD.',
      'Setup (Instrument Serif italic): "It''s not another technique." Payoff (Anton): "WAIT ON GOD." Small supporting line: "His presence isn''t something we manufacture."',
      'ChatGPT: raw still is relatively ordinary, the end card gives the clip its landing.'),
  (5, 'YOU''RE NOT FACING IT ALONE.',
      'Setup (Instrument Serif italic): "The challenge may be real." Payoff (Anton): "YOU''RE NOT FACING IT ALONE." Small supporting line: "Yield to the Holy Spirit."',
      'ChatGPT: deliberately avoids repeating "Holy Ghost Power" on the card -- translates into language outside church culture can follow immediately.')
) as v(clip_rank, hook, core_message, notes)
join sermon_clips sc on sc.rank = v.clip_rank
  and sc.sermon_id = (select id from sermons where service_date = '2026-09-20');

-- --------------------------------------------------------------------
-- 3. CAROUSELS
-- --------------------------------------------------------------------

delete from content_items
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'carousel';

insert into content_items (sermon_id, source_clip_id, content_type, hook, core_message, notes, editorial_status, created_by)
select
  (select id from sermons where service_date = '2026-09-20'), sc.id, 'carousel', v.hook, v.core_message, v.notes, 'draft', 'chatgpt'
from (values
  (3, 'DON''T GIVE UP YET.',
      'Slide 1 -- eyebrow "A STORY ABOUT PRAYER"; big type "DON''T / GIVE UP / YET." (still 01, cut out, obsidian field, red accent). Slide 2 -- "A 15-year-old prayed. Saw someone in a vision. Then met that person the next day." Closer: "Stay close enough to God to hear Him."',
      'ChatGPT: deliberately doesn''t tell the whole testimony in the graphic -- makes people curious rather than fully informed, so they watch the clip.'),
  (4, 'WHAT DOES IT MEAN TO MANIFEST GOD''S KINGDOM?',
      '4-slide teaching carousel. Slide 1: "WHAT DOES IT MEAN TO / MANIFEST GOD''S KINGDOM?" Slide 2: "It isn''t just something you say." Slide 3: "It''s allowing God''s rule, values and power to shape the way you live." Slide 4: "THE KINGDOM BECOMES VISIBLE THROUGH YOU."',
      'ChatGPT: best candidate for the week''s teaching carousel -- answers the question the sermon title itself raises. Ties into the week''s campaign line "Saved doesn''t mean finished."'),
  (9, 'WHAT DOES IT MEAN TO REPRESENT THE KING?',
      'Framed carousel, NOT a standalone quote card. Slide 1: "WHAT DOES IT MEAN / TO REPRESENT / THE KING?" -- then the video/quote. Final slide: "We belong to the King. Our lives should reflect His rule." Small scripture line: "JOHN 10:34 • PSALM 82".',
      'ChatGPT PUBLISHING CAVEAT: do not publish still 10 as a standalone "YOU ARE KINGS" / "WE ARE SMALL GODS" quote card. Psalm 82:6 and John 10:34 carry genuine interpretive complexity -- a short clip alone can read as teaching believers are literally divine. The frame must establish context (representing the King''s rule) BEFORE the contentious line, and the caption must explicitly locate it inside Bishop Henry''s wider point about representing God''s Kingdom, never isolate "small gods" as the standalone social proposition. ChatGPT also flagged: verify the exact transcript immediately before/after this section before writing the final caption -- context matters more than usual here.')
) as v(clip_rank, hook, core_message, notes)
join sermon_clips sc on sc.rank = v.clip_rank
  and sc.sermon_id = (select id from sermons where service_date = '2026-09-20');

-- --------------------------------------------------------------------
-- 4. UPDATE THE CARE NOTE ON THE SOURCE CLIP ITSELF
-- --------------------------------------------------------------------

update sermon_clips
set care_note = care_note || ' ChatGPT creative review (20 Sep): confirmed this needs a framing carousel, not a standalone quote card -- see content_items (content_type=carousel) for the required treatment. Do not post the raw still or a bare quote graphic.'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and rank = 9;

-- --------------------------------------------------------------------
-- 5. WEEK'S VISUAL RHYTHM (record ChatGPT's format-per-clip plan)
-- --------------------------------------------------------------------

update sermons
set notes = notes || E'\n\n---\nCHATGPT CREATIVE PASS (20 Sep 2026): format-per-clip plan -- Story (God''s Expectation, carousel) -> Definition (Manifesting God''s Kingdom, carousel) -> Carefully framed theology (You Are Kings, carousel only, publishing caveat) -> Presence (God''s Glory, reel + end card) -> Practice (Spiritual Exercise, carousel + end card) -> Power (Holy Ghost Power, reel + end card). Overarching campaign line stays "SAVED DOESN''T MEAN FINISHED." Still winners recorded on each content_items (still) row. 3 end cards + 3 carousels logged, all editorial_status=draft pending Bolaji sign-off.'
where service_date = '2026-09-20';

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- VERIFY
-- --------------------------------------------------------------------

select content_type, count(*) from content_items
where sermon_id = (select id from sermons where service_date = '2026-09-20')
group by content_type order by content_type;

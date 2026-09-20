-- ============================================================
-- 77_stills_and_status_20sep2026.sql
-- ============================================================
-- 1. Logs the 10 raw stills pulled from the 6 selected clips as
--    content_items (content_type = 'still'), linked to their source
--    clip and pushed to GitHub at sermon-library/stills-import/20-sep-2026/
-- 2. Records the current unit-creation status (Claude side + ChatGPT
--    side) against the sermon, so it's visible outside this chat.
--
-- Idempotent: re-running replaces the stills and the status note.
-- ============================================================

delete from content_items
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'still';

insert into content_items (sermon_id, source_clip_id, content_type, hook, notes, source_still, asset_status, editorial_status, created_by)
select
  (select id from sermons where service_date = '2026-09-20'),
  sc.id, 'still', v.hook, v.notes,
  'https://raw.githubusercontent.com/altitudeaico/calvaryhephzibah/main/sermon-library/stills-import/20-sep-2026/' || v.filename,
  'ready', 'draft', 'claude'
from (values
  ('sermon-01-vision-prayer-a.jpg', 3, 'The Vision Prayer — frame A (~15s)', 'Raw frame grab, OpusClip auto-caption baked in ("YOU ASK THEM") — needs Calvary caption style if used, not a finished asset.'),
  ('sermon-02-vision-prayer-b.jpg', 3, 'The Vision Prayer — frame B (~45s)', 'Raw frame grab.'),
  ('sermon-03-manifesting-kingdom-a.jpg', 4, 'Manifesting God''s Kingdom — frame A (~12s)', 'Raw frame grab.'),
  ('sermon-04-manifesting-kingdom-b.jpg', 4, 'Manifesting God''s Kingdom — frame B (~30s)', 'Raw frame grab.'),
  ('sermon-05-holy-ghost-power-a.jpg', 5, 'Holy Ghost Power — frame A (~12s)', 'Raw frame grab.'),
  ('sermon-06-holy-ghost-power-b.jpg', 5, 'Holy Ghost Power — frame B (~25s)', 'Raw frame grab.'),
  ('sermon-07-spiritual-exercise-a.jpg', 6, 'Spiritual vs. Physical Exercise — frame A (~15s)', 'Raw frame grab.'),
  ('sermon-08-spiritual-exercise-b.jpg', 6, 'Spiritual vs. Physical Exercise — frame B (~35s)', 'Raw frame grab.'),
  ('sermon-09-gods-glory.jpg', 8, 'The Secret to Bringing God''s Glory Down — frame (~15s)', 'Raw frame grab, OpusClip auto-caption baked in.'),
  ('sermon-10-you-are-kings.jpg', 9, 'You Are Kings — frame (~15s)', 'Raw frame grab. Source clip is care-flagged (sermon_clips.care_flag) -- same theological caveat applies to this still if used standalone.')
) as v(filename, clip_rank, hook, notes)
join sermon_clips sc on sc.rank = v.clip_rank
  and sc.sermon_id = (select id from sermons where service_date = '2026-09-20');

update sermons
set notes = notes || E'\n\n---\nUNIT CREATION STATUS (20 Sep 2026, post-clip-selection):\nCLAUDE SIDE: 6 clips selected from 32 OpusClip candidates, logged as real sermon_clips rows with transcripts (content_items, content_type=clip). 10 raw stills pulled from those 6 HD exports via ffmpeg and pushed to sermon-library/stills-import/20-sep-2026/ (content_items, content_type=still). NO units finished yet -- no voice lift, music bed, closing sequence, or end card built on any clip; sermon_clips.status is "candidate" on all 6, not "scheduled_ghl". Nothing posted.\nCHATGPT SIDE: delivered the final sermon thumbnail (live, Calvary logo + photo composite) and a theme-check/study-guide/campaign-packaging pass (content_items, content_type=study and caption_only, editorial_status=draft, created_by=chatgpt) -- all still awaiting Bolaji sign-off. Stills are now available for ChatGPT''s next pass (carousel covers / end cards) once units are built.\nNEXT STEP: pick which of the 6 clips become Units (per calvary-social-pack: finished clip -> still -> carousel -> preview page -> GHL schedule), starting the pipeline in order.'
where service_date = '2026-09-20';

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- VERIFY
-- --------------------------------------------------------------------

select content_type, count(*) from content_items
where sermon_id = (select id from sermons where service_date = '2026-09-20')
group by content_type order by content_type;

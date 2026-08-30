-- ============================================================
-- 67_send_still_to_github.sql
-- ============================================================
-- Adds the two bookkeeping columns "Send to GitHub" needs, and
-- documents the Edge Function that does the actual work (Edge
-- Functions are deployed via the Supabase MCP connector directly,
-- not via SQL -- this file is a record, not something to re-run
-- the function from).
--
-- WHY THIS EXISTS: Sunday Stills' full archive lives in Supabase
-- Storage (control-room-media bucket) -- unlimited, fine for bulk,
-- but Claude sessions can't reach supabase.co directly (network
-- host_not_allowed in the sandbox used on 30 Aug 2026 -- worth
-- re-checking if a future session finds this note stale). GitHub
-- IS reachable (raw.githubusercontent.com is allowlisted), so for
-- the small number of stills actually picked for social content
-- each week, a one-click button pushes just that one image into
-- the repo, where a future Claude session doing content work can
-- reach it directly.
--
-- SECURITY -- why this needs a server-side function at all: the
-- GitHub token needs write access to the whole repo. Putting it in
-- stills.html would expose it to anyone opening browser dev tools.
-- The token lives ONLY as a Supabase Edge Function secret, read at
-- runtime, server-side, never sent to the browser.
--
-- Edge Function: send-still-to-github (deployed, ACTIVE as of 30
-- Aug 2026, id 13a06515-32f0-42be-8fc6-07a8eae8a727).
--   - Input: { still_id: uuid }
--   - Downloads the image from Storage server-side (service role key,
--     auto-provided by the platform -- not a manually-set secret)
--   - Commits it to altitudeaico/calvaryhephzibah at
--     social/{DD-mon-YYYY}/stills/{filename} (matches the existing
--     social/DD-mon-YYYY/ folder convention already used elsewhere)
--   - Updates control_room_stills.github_path + sent_to_github_at
--     on success
--
-- ONE-TIME MANUAL SETUP (no MCP tool exists to do this step --
-- confirmed by search, only project/DB management tools are
-- available, no secrets-management tool):
--   Supabase dashboard -> Project Settings -> Edge Functions ->
--   send-still-to-github -> Secrets -> add GITHUB_TOKEN, a
--   fine-grained PAT scoped to altitudeaico/calvaryhephzibah,
--   Contents: Read and write. Until this is set, the function
--   returns a clear error explaining exactly this, rather than
--   failing silently.
-- ============================================================

alter table control_room_stills
  add column if not exists github_path text,
  add column if not exists sent_to_github_at timestamptz;

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- VERIFY
-- --------------------------------------------------------------------
select column_name, data_type
from information_schema.columns
where table_name = 'control_room_stills'
order by ordinal_position;

-- Which stills have been sent to GitHub so far?
select service_date, file_name, github_path, sent_to_github_at
from control_room_stills
where github_path is not null
order by sent_to_github_at desc;

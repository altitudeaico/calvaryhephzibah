-- ============================================================
-- 68_content_studio.sql
-- ============================================================
-- Content Studio: carousel builder + AI-assisted caption drafting,
-- built directly on top of Sunday Stills. Answers the question "can
-- this only be done via Claude chats?" with no — this is a real
-- standalone tool, no chat required for day-to-day use.
--
-- Two pieces, deliberately split by how they're solved:
--   - Carousel building (arranging images, adding text, exporting
--     slides) is mechanical rendering -- done entirely client-side
--     in the browser via <canvas>, no backend needed at all.
--   - Caption drafting needs real language judgment (matching the
--     sermon-clip-captions skill's rules) -- routed through a
--     server-side Edge Function that calls the Anthropic API
--     directly, so the app has a genuine "smart button" rather than
--     needing a separate Claude chat.
--
-- UI: control-room/content-studio.html (PIN-gated, same shared PIN).
-- Linked from the footer as "Content Studio". Pulls its image picker
-- from control_room_stills (see 66_create_control_room_stills.sql
-- and 67_send_still_to_github.sql).
--
-- Edge Function: draft-caption (deployed, ACTIVE as of 30 Aug 2026,
-- id abbc5066-9913-4980-ad2e-0da7e136ec5e). Same security reasoning
-- as send-still-to-github: the Anthropic API key can't live in the
-- page's own code, so it's read server-side from a secret at
-- runtime instead.
--
-- ONE-TIME MANUAL SETUP (no MCP tool exists to do this -- confirmed,
-- same as the GitHub token before it):
--   Supabase dashboard -> Project Settings -> Edge Functions ->
--   draft-caption -> Secrets -> add ANTHROPIC_API_KEY.
--   Until this is set, the button returns a clear error explaining
--   exactly that, rather than failing silently.
--
-- KNOWN RISK, NOT YET VERIFIED IN A REAL BROWSER: exporting slides
-- draws Supabase Storage images onto a <canvas>, which requires the
-- images to be served with permissive CORS headers or the browser
-- blocks the export as a "tainted canvas" security measure. Public
-- Supabase Storage buckets normally serve with these headers by
-- default, but this was written and tested from a sandbox with no
-- real browser -- if Export fails with a security/tainted-canvas
-- error, that's the exact symptom to look for.
-- ============================================================

create table if not exists content_studio_projects (
  id uuid primary key default gen_random_uuid(),
  service_date date not null,
  title text,
  slides jsonb not null default '[]'::jsonb,   -- [{ still_id, storage_path, headline, subtext }]
  sermon_notes text,
  caption_draft text,
  caption_final text,
  status text not null default 'draft',         -- draft | ready | exported
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists content_studio_projects_date_idx
  on content_studio_projects (service_date desc, updated_at desc);

alter table content_studio_projects disable row level security;
grant select, insert, update, delete on content_studio_projects to anon;

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- VERIFY
-- --------------------------------------------------------------------
select column_name, data_type
from information_schema.columns
where table_name = 'content_studio_projects'
order by ordinal_position;

select id, service_date, title, status, jsonb_array_length(slides) as slide_count, created_at
from content_studio_projects
order by created_at desc;

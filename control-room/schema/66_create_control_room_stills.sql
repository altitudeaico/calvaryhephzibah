-- ============================================================
-- 66_create_control_room_stills.sql
-- ============================================================
-- Sunday Stills: lets the media team upload good-quality OBS
-- screenshots per service, stored in Supabase and browsable by
-- date, so the social team can draw from them later for content.
--
-- This has ALREADY BEEN APPLIED directly via the Supabase MCP
-- connector (confirmed working on this project as of 30 Aug 2026 --
-- see git-and-naming.md history if that note is still accurate).
-- This file exists so the schema is documented in the repo history
-- alongside every other control-room table, in case it ever needs
-- to be re-applied to a fresh project.
--
-- Reuses the existing `control-room-media` Storage bucket (already
-- created for other media, already has full anon insert/select/
-- update/delete policies -- confirmed present, no new bucket or
-- policy needed). New rows land under storage path
-- `stills/{service_date}/{timestamp}-{filename}`.
--
-- UI: control-room/stills.html (PIN-gated, same shared PIN as the
-- rest of Control Room). Linked from the footer as "Sunday Stills".
-- ============================================================

create table if not exists control_room_stills (
  id uuid primary key default gen_random_uuid(),
  service_date date not null,
  storage_path text not null,
  file_name text,
  width integer,
  height integer,
  size_bytes integer,
  caption text,
  tags text[],
  uploaded_by text,
  created_at timestamptz not null default now()
);

create index if not exists control_room_stills_service_date_idx
  on control_room_stills (service_date desc, created_at desc);

alter table control_room_stills disable row level security;
grant select, insert, update, delete on control_room_stills to anon;

alter publication supabase_realtime add table control_room_stills;
alter table control_room_stills replica identity full;

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- VERIFY
-- --------------------------------------------------------------------
select column_name, data_type
from information_schema.columns
where table_name = 'control_room_stills'
order by ordinal_position;

-- Confirm the storage bucket + policies this table depends on already exist
select id, name, public, file_size_limit, allowed_mime_types
from storage.buckets where id = 'control-room-media';

select policyname, cmd from pg_policies
where schemaname = 'storage' and tablename = 'objects'
  and qual like '%control-room-media%' or with_check like '%control-room-media%';

-- DRAFT FOR REVIEW -- NOT YET APPLIED to the live database.
-- These are the 15 tables Supabase flagged as fully exposed (RLS disabled,
-- readable and writable by anyone with the anon key). Enabling RLS alone
-- BLOCKS ALL ACCESS until policies exist -- so each table below gets a
-- starting policy, not just the ALTER TABLE line, to avoid breaking Control
-- Room live on a Sunday.
--
-- The read/write split below is a reasonable guess based on what each table
-- appears to be for, not a confirmed decision. Review before applying,
-- especially the Control Room tables, since those run live during service.

-- Bible text and song library: safe to leave publicly readable (no write risk
-- from congregation-facing surfaces), writes restricted to staff.
alter table public.control_room_bible enable row level security;
create policy "control_room_bible: public read" on public.control_room_bible for select using (true);

alter table public.control_room_songs enable row level security;
create policy "control_room_songs: public read" on public.control_room_songs for select using (true);
create policy "control_room_songs: staff write" on public.control_room_songs for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin','media'])
);

-- Live production state: read can stay open (the public overlay needs it),
-- writes should be restricted to signed-in operators only.
alter table public.control_room_live enable row level security;
create policy "control_room_live: public read" on public.control_room_live for select using (true);
create policy "control_room_live: staff write" on public.control_room_live for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin','media'])
);

alter table public.control_room_display enable row level security;
create policy "control_room_display: public read" on public.control_room_display for select using (true);
create policy "control_room_display: staff write" on public.control_room_display for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin','media'])
);

-- Service planning data: staff-only in both directions, no reason for this
-- to be publicly readable.
alter table public.control_room_plans enable row level security;
alter table public.control_room_plan_items enable row level security;
alter table public.control_room_plan_speakers enable row level security;
alter table public.control_room_announcements enable row level security;
alter table public.control_room_backdrops enable row level security;
create policy "control_room_plans: staff only" on public.control_room_plans for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin','media'])
);
create policy "control_room_plan_items: staff only" on public.control_room_plan_items for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin','media'])
);
create policy "control_room_plan_speakers: staff only" on public.control_room_plan_speakers for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin','media'])
);
create policy "control_room_announcements: staff only" on public.control_room_announcements for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin','media'])
);
create policy "control_room_backdrops: staff only" on public.control_room_backdrops for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin','media'])
);

-- control_room_users: this table becomes redundant once auth migrates to
-- profiles (Phase 1/2). Lock it to staff-only for now rather than design
-- policy for a table we intend to retire.
alter table public.control_room_users enable row level security;
create policy "control_room_users: staff only" on public.control_room_users for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin'])
);

-- Stills, social capability tracking, content studio: internal production
-- tools, staff-only.
alter table public.control_room_stills enable row level security;
alter table public.control_room_images enable row level security;
alter table public.control_room_people enable row level security;
alter table public.social_capability enable row level security;
alter table public.content_studio_projects enable row level security;
create policy "control_room_stills: staff only" on public.control_room_stills for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin','media'])
);
create policy "control_room_images: staff only" on public.control_room_images for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin','media'])
);
create policy "control_room_people: staff only" on public.control_room_people for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin'])
);
create policy "social_capability: staff only" on public.social_capability for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin'])
);
create policy "content_studio_projects: staff only" on public.content_studio_projects for all using (
  exists (select 1 from public.profiles p where p.id = auth.uid() and p.roles && array['staff','admin','media'])
);

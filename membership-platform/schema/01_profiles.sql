-- Calvary Portal: unified identity table, linked to Supabase Auth (auth.users)
-- Applied to project pfycvgbrsbecznkcikwt on 2 Sep 2026.
-- Replaces the pattern of separate PIN tables per system (bridge_users, bridge_users_v2,
-- control_room_users) with one profile per real account, with roles driving access.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  phone text,
  ghl_contact_id text,
  roles text[] not null default '{}',
  joined_at timestamptz not null default now(),
  last_synced_at timestamptz
);

comment on table public.profiles is 'Calvary Portal unified identity. One row per auth.users account. roles drives access to My Church / Team areas (e.g. {}, {volunteer,media}, {staff,admin}).';

alter table public.profiles enable row level security;

create policy "profiles: read own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: update own"
  on public.profiles for update
  using (auth.uid() = id);

create policy "profiles: admin read all"
  on public.profiles for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and 'admin' = any(p.roles)
    )
  );

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

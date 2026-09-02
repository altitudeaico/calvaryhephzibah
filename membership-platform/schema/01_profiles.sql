-- Calvary Portal: unified identity table, linked to Supabase Auth (auth.users)
-- Applied to project pfycvgbrsbecznkcikwt on 2 Sep 2026, revised same day
-- after a real security gap was found and fixed (see below).
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

-- FIXED 2 Sep 2026: originally had no WITH CHECK clause, relying on
-- Postgres's implicit "reuse USING as WITH CHECK" default for UPDATE
-- policies. Verified with real tokens that the implicit default DID
-- block a self-role-escalation attempt in practice, but an explicit
-- WITH CHECK is added anyway so this doesn't depend on an implicit
-- default -- explicit is safer than implicit for a security boundary.
create policy "profiles: update own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- FIXED 2 Sep 2026: the original version of this policy queried
-- public.profiles from within its own policy on public.profiles, which
-- caused genuine infinite recursion (error 42P17), discovered when
-- actually testing it, not by inspection. Fixed with a SECURITY DEFINER
-- helper function that bypasses RLS for just this one internal check --
-- the standard Supabase pattern for "is this user an admin" checks.
create or replace function public.is_admin(uid uuid)
returns boolean
language sql
security definer set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles where id = uid and 'admin' = any(roles)
  );
$$;

create policy "profiles: admin read all"
  on public.profiles for select
  using (public.is_admin(auth.uid()));

-- ADDED 2 Sep 2026: defense-in-depth against self-role-escalation. Even
-- with the explicit WITH CHECK above, a trigger provides a second,
-- independent layer that doesn't depend on RLS policy wording at all --
-- it hard-blocks any change to `roles` unless the actor is the service
-- role (trusted server-side code only, e.g. a future admin panel).
create or replace function public.prevent_self_role_change()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if auth.role() = 'service_role' then
    return new;
  end if;
  if new.roles is distinct from old.roles then
    raise exception 'roles cannot be changed by the account holder. Contact an administrator.';
  end if;
  return new;
end;
$$;

create trigger prevent_self_role_change_trigger
  before update on public.profiles
  for each row execute function public.prevent_self_role_change();

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

-- VERIFIED 2 Sep 2026 with real test accounts and real tokens (not just
-- policy inspection), then cleaned up -- no test data left behind:
--   - Signed-out request (anon key, no user token): returns [] empty, sees nothing.
--   - User B reading User A's profile by id: returns [] empty.
--   - User A attempting to PATCH their own roles to ['admin']: blocked,
--     "roles cannot be changed by the account holder."
--   - User A legitimately updating their own full_name: succeeds normally.
-- NOT yet tested: a genuine 'volunteer' role only unlocking exactly its
-- assigned Team sections (the client-side check in team.html is correct
-- by inspection, but this is UI-level filtering, not an additional
-- Postgres-level boundary, since the underlying staff tools -- Bridge,
-- Control Room, Rehearsal Studio -- have not been migrated onto this
-- profiles/roles system yet and still enforce access their own way).

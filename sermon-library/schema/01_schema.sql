-- ============================================================
-- 01_schema.sql — Sermon Library / Bible-study knowledge base
-- ============================================================
-- The data spine for a searchable sermon-notes + Bible-study app.
-- Lives in the same Supabase project as the Control Room
-- (pfycvgbrsbecznkcikwt). A GitHub Pages page reads it with the
-- anon key (like the Control Room), so anon gets READ access to
-- sermon content; writes happen here in the SQL editor.
--
-- Idempotent — safe to re-run. Run first, then the seed files.
--
-- PRIVACY: this data is readable by anyone with the public anon key,
-- so treat everything here as effectively public. Keep sensitive
-- specifics (names of individuals needing consent, minor-related
-- notes) OUT of these tables — use the boolean care_flag + a neutral
-- care_note only. Truly private notes need a later auth phase.
-- ============================================================

create extension if not exists pgcrypto;   -- gen_random_uuid()

-- ---- SERMONS -------------------------------------------------------
create table if not exists sermons (
  id              uuid primary key default gen_random_uuid(),
  service_date    date not null,
  title           text not null,           -- public/caption title
  preacher        text,
  is_guest        boolean default false,
  occasion        text,                     -- e.g. "Deacon Sokoya's 60th thanksgiving"
  series          text,                     -- optional teaching series
  anchor_scripture text,                    -- e.g. "Psalm 103:2"
  thesis          text,                     -- one-line big idea
  summary         text,                     -- short paragraph
  full_text       text,                     -- cleaned sermon-only transcript
  youtube_url     text,
  notes           text,                     -- production/context notes (e.g. power-cut gap)
  created_at      timestamptz default now(),
  updated_at      timestamptz default now(),
  unique (service_date, title)
);

-- full-text search over the sermon
alter table sermons add column if not exists search_tsv tsvector
  generated always as (
    to_tsvector('english',
      coalesce(title,'') || ' ' || coalesce(preacher,'') || ' ' ||
      coalesce(occasion,'') || ' ' || coalesce(thesis,'') || ' ' ||
      coalesce(summary,'') || ' ' || coalesce(full_text,''))
  ) stored;
create index if not exists sermons_search_idx on sermons using gin (search_tsv);
create index if not exists sermons_date_idx   on sermons (service_date desc);

-- ---- POINTS (structured outline) -----------------------------------
create table if not exists sermon_points (
  id          uuid primary key default gen_random_uuid(),
  sermon_id   uuid references sermons(id) on delete cascade,
  position    int not null,
  heading     text not null,
  detail      text,
  scriptures  text[] default '{}',          -- refs cited under this point
  unique (sermon_id, position)
);
create index if not exists sermon_points_sermon_idx on sermon_points (sermon_id);

-- ---- SCRIPTURES (normalised refs) ----------------------------------
create table if not exists sermon_scriptures (
  id           uuid primary key default gen_random_uuid(),
  sermon_id    uuid references sermons(id) on delete cascade,
  reference    text not null,               -- "Habakkuk 3:17"
  book         text,
  chapter      int,
  verse_start  int,
  verse_end    int,
  role         text default 'supporting'    -- 'anchor' | 'supporting'
);
create index if not exists sermon_scriptures_sermon_idx on sermon_scriptures (sermon_id);
create index if not exists sermon_scriptures_book_idx   on sermon_scriptures (book, chapter);

-- ---- CLIPS (social clip candidates + pipeline status) --------------
create table if not exists sermon_clips (
  id             uuid primary key default gen_random_uuid(),
  sermon_id      uuid references sermons(id) on delete cascade,
  rank           int,
  hook           text not null,
  theme          text,
  timestamp_hint text,                       -- "~11:49"
  platforms      text[] default '{}',        -- {'reel','tiktok','short','carousel'}
  status         text default 'to_caption',  -- to_caption | captioned | posted
  care_flag      boolean default false,      -- true = confirm consent before publishing
  care_note      text,                       -- NEUTRAL wording only (see privacy note above)
  posted_url     text,
  created_at     timestamptz default now(),
  updated_at     timestamptz default now()
);
create index if not exists sermon_clips_sermon_idx on sermon_clips (sermon_id);
create index if not exists sermon_clips_status_idx on sermon_clips (status);

-- ---- TAGS (themes) -------------------------------------------------
create table if not exists sermon_tags (
  id    uuid primary key default gen_random_uuid(),
  name  text unique not null
);
create table if not exists sermon_tag_map (
  sermon_id uuid references sermons(id) on delete cascade,
  tag_id    uuid references sermon_tags(id) on delete cascade,
  primary key (sermon_id, tag_id)
);

-- ---- READ ACCESS for the GitHub Pages reader (anon key) ------------
alter table sermons           enable row level security;
alter table sermon_points     enable row level security;
alter table sermon_scriptures enable row level security;
alter table sermon_clips      enable row level security;
alter table sermon_tags       enable row level security;
alter table sermon_tag_map    enable row level security;

do $$
declare t text;
begin
  foreach t in array array['sermons','sermon_points','sermon_scriptures','sermon_clips','sermon_tags','sermon_tag_map']
  loop
    execute format('drop policy if exists anon_read on %I;', t);
    execute format('create policy anon_read on %I for select to anon using (true);', t);
    execute format('grant select on %I to anon;', t);
  end loop;
end $$;

-- Writes are done here in the SQL editor (service role bypasses RLS).
-- A future authenticated write path (team login) can add insert/update
-- policies for the 'authenticated' role.

-- ---- Full-text search helper (used by the reader page) -------------
create or replace function search_sermons(q text)
returns setof sermons
language sql stable
as $$
  select *
  from sermons
  where q is null or q = '' or search_tsv @@ websearch_to_tsquery('english', q)
  order by
    case when q is null or q = '' then 0
         else ts_rank(search_tsv, websearch_to_tsquery('english', q)) end desc,
    service_date desc;
$$;
grant execute on function search_sermons(text) to anon;

-- ============================================================
-- PHASE 2 (later, not now): semantic search for the "app".
--   create extension vector;
--   alter table sermons add column embedding vector(1536);
--   -- populate embeddings from full_text via an edge function / batch,
--   -- then order by embedding <=> query_embedding for meaning-based search.
-- ============================================================

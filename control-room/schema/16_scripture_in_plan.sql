-- ============================================================
-- 16_scripture_in_plan.sql
-- ============================================================
-- Adds scripture readings as cueable items in a service plan.
--
-- Pattern: a row in control_room_plan_items with kind='scripture'
-- holds a passage broken into one-or-more slides, each shaped like
-- the ad-hoc Bible search produces:
--   {
--     "verses":    [{"n": 9, "text": "Let us not..."}],
--     "rangeLabel":"v.9",
--     "reference": "Galatians 6:9",
--     "book":      "Galatians",
--     "chapter":   6,
--     "version":   "KJV"
--   }
--
-- The operator UI pushes these via mode='verse' — identical payload
-- shape to the ad-hoc Bible search, so the overlay needs no changes.
--
-- Idempotent: safe to re-run.
-- ============================================================

-- ────────────────────────────────────────────────────────────────────
-- Helper: pack a range of verses into slides matching the JS
-- packVersesIntoSlides() logic (pair short consecutive verses).
-- ────────────────────────────────────────────────────────────────────
create or replace function cr_pack_verses_to_slides(
  p_book        text,
  p_chapter     integer,
  p_verse_start integer,
  p_verse_end   integer,
  p_version     text default 'KJV'
)
returns jsonb
language plpgsql
as $$
declare
  PAIR_THRESHOLD constant integer := 110;
  v_resolved_book text;
  v_verses        jsonb;
  v_slides        jsonb := '[]'::jsonb;
  v_arr_len       integer;
  i               integer := 0;
  cur_n           integer;
  cur_text        text;
  next_n          integer;
  next_text       text;
  combined_len    integer;
  reference_label text;
begin
  -- Resolve book name (case-insensitive prefix match — same as JS uses ilike)
  select book into v_resolved_book
    from control_room_bible
   where version = p_version
     and book ilike p_book || '%'
   order by book_num
   limit 1;

  if v_resolved_book is null then
    raise exception 'cr_pack_verses_to_slides: book not found: %', p_book;
  end if;

  -- Pull the verses as a JSONB array of {n, text}
  select jsonb_agg(jsonb_build_object('n', verse, 'text', text) order by verse)
    into v_verses
    from control_room_bible
   where version = p_version
     and book = v_resolved_book
     and chapter = p_chapter
     and verse between p_verse_start and p_verse_end;

  if v_verses is null or jsonb_array_length(v_verses) = 0 then
    raise exception 'cr_pack_verses_to_slides: no verses found for % %:%-%',
      v_resolved_book, p_chapter, p_verse_start, p_verse_end;
  end if;

  v_arr_len := jsonb_array_length(v_verses);

  -- Pack verses into slides, mirroring packVersesIntoSlides() in index.html
  while i < v_arr_len loop
    cur_n    := (v_verses->i->>'n')::int;
    cur_text := v_verses->i->>'text';

    if i + 1 < v_arr_len then
      next_n    := (v_verses->(i+1)->>'n')::int;
      next_text := v_verses->(i+1)->>'text';
      combined_len := length(cur_text) + length(next_text);
    else
      next_n := null;
      next_text := null;
      combined_len := length(cur_text);
    end if;

    if next_n is not null
       and combined_len <= PAIR_THRESHOLD * 2
       and length(cur_text) < PAIR_THRESHOLD then
      -- Pair this verse with the next
      v_slides := v_slides || jsonb_build_array(jsonb_build_object(
        'verses',     jsonb_build_array(
                        jsonb_build_object('n', cur_n,  'text', cur_text),
                        jsonb_build_object('n', next_n, 'text', next_text)
                      ),
        'rangeLabel', 'v.' || cur_n || '-' || next_n,
        'reference',  v_resolved_book || ' ' || p_chapter || ':' || cur_n || '-' || next_n,
        'book',       v_resolved_book,
        'chapter',    p_chapter,
        'version',    p_version
      ));
      i := i + 2;
    else
      -- Single-verse slide
      v_slides := v_slides || jsonb_build_array(jsonb_build_object(
        'verses',     jsonb_build_array(
                        jsonb_build_object('n', cur_n, 'text', cur_text)
                      ),
        'rangeLabel', 'v.' || cur_n,
        'reference',  v_resolved_book || ' ' || p_chapter || ':' || cur_n,
        'book',       v_resolved_book,
        'chapter',    p_chapter,
        'version',    p_version
      ));
      i := i + 1;
    end if;
  end loop;

  return v_slides;
end;
$$;

-- ────────────────────────────────────────────────────────────────────
-- Helper: add a scripture item to a plan
-- ────────────────────────────────────────────────────────────────────
create or replace function cr_add_scripture_to_plan(
  p_service_date date,
  p_position     integer,
  p_book         text,
  p_chapter      integer,
  p_verse_start  integer,
  p_verse_end    integer default null,
  p_section      text default 'reading',
  p_version      text default 'KJV'
)
returns uuid
language plpgsql
as $$
declare
  v_plan_id      uuid;
  v_slides       jsonb;
  v_title        text;
  v_item_id      uuid;
  v_verse_end    integer;
begin
  v_verse_end := coalesce(p_verse_end, p_verse_start);

  -- Find the plan
  select id into v_plan_id
    from control_room_plans
   where service_date = p_service_date
   limit 1;

  if v_plan_id is null then
    raise exception 'cr_add_scripture_to_plan: no plan for service_date %', p_service_date;
  end if;

  -- Build the slides
  v_slides := cr_pack_verses_to_slides(p_book, p_chapter, p_verse_start, v_verse_end, p_version);

  -- Title for display in the set list
  if v_verse_end = p_verse_start then
    v_title := '📖 ' || initcap(p_book) || ' ' || p_chapter || ':' || p_verse_start;
  else
    v_title := '📖 ' || initcap(p_book) || ' ' || p_chapter || ':' || p_verse_start || '-' || v_verse_end;
  end if;

  -- Remove any existing scripture item at this position (idempotent re-runs)
  delete from control_room_plan_items
   where plan_id = v_plan_id
     and position = p_position
     and kind = 'scripture';

  -- Insert the new scripture item
  insert into control_room_plan_items (plan_id, position, kind, title, section, slides)
  values (v_plan_id, p_position, 'scripture', v_title, p_section, v_slides)
  returning id into v_item_id;

  return v_item_id;
end;
$$;

-- ────────────────────────────────────────────────────────────────────
-- APPLY: Cue Galatians 6:9 for Sunday 24 May 2026 (pre-sermon reading)
-- Position 99 — chosen to sit AFTER the 8 song items (positions 1-8)
-- so it doesn't conflict, but the operator can still pull it up.
-- ────────────────────────────────────────────────────────────────────
select cr_add_scripture_to_plan(
  p_service_date => '2026-05-24'::date,
  p_position     => 99,
  p_book         => 'Galatians',
  p_chapter      => 6,
  p_verse_start  => 9,
  p_verse_end    => 9,
  p_section      => 'reading',
  p_version      => 'KJV'
) as scripture_item_id;

-- ────────────────────────────────────────────────────────────────────
-- VERIFY
-- ────────────────────────────────────────────────────────────────────

-- All items in the 24 May plan (songs + scripture)
select i.position, i.kind, i.title, i.section, jsonb_array_length(i.slides) as slides
  from control_room_plan_items i
  join control_room_plans p on p.id = i.plan_id
 where p.service_date = '2026-05-24'
 order by i.position;

-- Inspect the scripture slide payload to confirm it looks right
select i.title, jsonb_pretty(i.slides) as slides
  from control_room_plan_items i
  join control_room_plans p on p.id = i.plan_id
 where p.service_date = '2026-05-24'
   and i.kind = 'scripture';

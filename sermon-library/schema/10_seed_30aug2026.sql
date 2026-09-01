-- ============================================================
-- 10_seed_30aug2026.sql - Sunday 30 August 2026 sermon
-- "He Never Fails" (Bishop Henry Emmanuel)
-- Same service as Mummy Awolesi's Birthday Celebration.
-- Run after 01_schema.sql.
--
-- SOURCE: TurboScribe transcript + full MP4 video recording supplied
-- by Bolaji, 1 September 2026. Full ~21 minute sermon, complete.
--
-- THIS HAS ALREADY BEEN APPLIED directly via the Supabase MCP
-- connector. This file exists so the seed is documented in the repo
-- history alongside every other sermon-library entry, in case it
-- ever needs to be re-applied to a fresh project. See the `notes`
-- column on the sermon row (applied version) for the full set of
-- transcript-quality and OpusClip-correction flags -- summarised
-- briefly here:
--
--   - full_text is a cleaned paraphrase/condensation, not a verbatim
--     transcript. The original TurboScribe .txt/.srt are the source
--     of record for verbatim wording.
--   - CARE FLAG: the opening family-reunion illustration is
--     ambiguous between a real story and a hypothetical teaching
--     device. Do not caption or clip it as if it's a real, named
--     family without checking with Bishop Emmanuel first.
--   - OpusClip generated 27 candidate clips from this video. Two
--     corrections worth knowing: "Isaiah's message: rejoice even in
--     agony" is actually the Paul/Philippians passage, not Isaiah.
--     "Nigeria's Angelic Gift" first looked like an unrelated
--     OpusClip hallucination but is actually a real illustration in
--     this sermon (the angel-gift testimony) -- reinstated after
--     reading the full transcript rather than excluded.
--   - Stills: 6 frames extracted from the source video and added to
--     Sunday Stills (control_room_stills, service_date 2026-08-30,
--     file_name sermon-01 through sermon-06).
--
-- Idempotent: deletes before inserting. Supabase project:
-- pfycvgbrsbecznkcikwt
-- ============================================================

-- See control-room commit history / Supabase project for the full
-- applied SQL (sermon row with complete full_text and notes, 12
-- sermon_points, 8 sermon_scriptures, 6 sermon_clips, 8 tags).
-- Reproduced in full here would duplicate a large text block that's
-- already the source of truth in the live database -- this stub
-- documents WHAT was applied and WHY; query the live tables for the
-- actual content.

-- ---- VERIFY ---------------------------------------------------
-- Expect: 1 sermon, 12 points, 8 scriptures, 6 clips, 8 tags.
select s.service_date, s.title, s.preacher, s.is_guest, s.anchor_scripture,
       length(s.full_text)                                                    as body_chars,
       (select count(*) from sermon_points     p where p.sermon_id = s.id)    as points,
       (select count(*) from sermon_scriptures c where c.sermon_id = s.id)    as scriptures,
       (select count(*) from sermon_clips      k where k.sermon_id = s.id)    as clips,
       (select count(*) from sermon_tag_map    m where m.sermon_id = s.id)    as tags
from sermons s
where s.service_date = '2026-08-30';

-- Care-flagged clips to resolve before any public use
select rank, care_flag, status, theme, hook, care_note
from sermon_clips
where sermon_id = (select id from sermons where service_date = '2026-08-30' and title = 'He Never Fails')
order by care_flag desc, rank;

-- Full-text search should now reach this sermon
select service_date, title, preacher from search_sermons('rejoice expectation proverbs');

-- Free positioning for on-screen text (lyrics/verses).
-- Adds an optional custom position + continuous scale on top of the existing
-- top/middle/bottom + small/medium/large presets. When custom_pos is false the
-- overlay uses the presets exactly as before (fully backward compatible).
--
-- pos_x / pos_y: the CENTRE of the text block as a fraction of the 1920x1080
--   frame (0.5, 0.5 = dead centre; default 0.5, 0.82 ~ lower third).
-- scale: continuous size multiplier for the whole block (1.0 = as-is).
--
-- Run once in the Supabase SQL editor for project pfycvgbrsbecznkcikwt.

alter table control_room_display
  add column if not exists custom_pos boolean not null default false,
  add column if not exists pos_x numeric not null default 0.5,
  add column if not exists pos_y numeric not null default 0.82,
  add column if not exists scale numeric not null default 1.0;

grant select, insert, update on control_room_display to anon;
notify pgrst, 'reload schema';

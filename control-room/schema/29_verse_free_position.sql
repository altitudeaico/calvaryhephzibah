-- Independent free positioning for Bible verses.
-- Mirrors the lyric free-position columns (28) but for the verse stage, so
-- scripture can be placed and sized independently of song lyrics. When
-- verse_custom_pos is false the verse stage uses the top/middle/bottom +
-- small/medium/large presets exactly as before (fully backward compatible).
--
-- Run once in the Supabase SQL editor for project pfycvgbrsbecznkcikwt.

alter table control_room_display
  add column if not exists verse_custom_pos boolean not null default false,
  add column if not exists verse_pos_x numeric not null default 0.5,
  add column if not exists verse_pos_y numeric not null default 0.82,
  add column if not exists verse_scale numeric not null default 1.0;

grant select, insert, update on control_room_display to anon;
notify pgrst, 'reload schema';

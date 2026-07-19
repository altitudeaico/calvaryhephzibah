-- Giving block: a persistent top-right offering / info card on the overlay,
-- independent of mode (coexists with lyrics/verses like the lower third).
-- Payload shape: { show: bool, title: text, lines: [ {name?,label?,value} | text ] }
--
-- Run once in the Supabase SQL editor for project pfycvgbrsbecznkcikwt.

alter table control_room_live
  add column if not exists giving jsonb not null default '{"show":false}'::jsonb;

grant select, insert, update on control_room_live to anon;
notify pgrst, 'reload schema';

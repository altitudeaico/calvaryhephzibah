-- ============================================================
-- 43_orderofservice_26jul2026.sql
-- ============================================================
-- Sunday 26th July 2026 -- ORDER OF SERVICE + SERMON patch.
--
-- Adds the running order, the guest preacher and the sermon on top
-- of the songs already seeded by 42_setlist_26jul2026.sql. Kept as a
-- separate migration so the set list is never disturbed by an order
-- change, and vice versa.
--
-- >> RUN AFTER 42_setlist_26jul2026.sql. This patch only touches
-- >> control_room_plan_speakers and the scripture item; it does NOT
-- >> recreate the plan, so the songs survive. If you ever re-run 42
-- >> (which DOES recreate the plan), re-run this file afterwards.
--
-- Source: order-of-service notes from Pastor Shade, 24 July 2026.
--
-- TWO ITEMS DELIBERATELY LEFT AS PLACEHOLDERS (flagged by Pastor
-- Shade as not yet settled), to be closed in a follow-up patch:
--   . Bible Reading  -- no passage, no reader given. Seeded as a
--     speaker row reading "Reading + reader TBC" rather than a real
--     scripture item, because the passage is unknown. When it lands,
--     add it with cr_add_scripture_to_plan() (see 42/36 for the call)
--     and delete the placeholder speaker row at position 8.
--   . Graduation Presentations -- new segment this week, no lead
--     name and no slide detail. Seeded so the media team can see it
--     is coming and cover it; add the lead + any slide when known.
--
-- Guest preacher: Dr Titi Sodipo. Sermon: "Altars".
-- Idempotent: replaces all speaker rows for 2026-07-26 on each run.
-- Run in the Supabase SQL editor (project: pfycvgbrsbecznkcikwt).
-- ============================================================

-- Guard: the plan must already exist (42 creates it).
do $$
begin
  if not exists (select 1 from control_room_plans where service_date = '2026-07-26') then
    raise exception 'No plan for 2026-07-26. Run 42_setlist_26jul2026.sql first.';
  end if;
end $$;

-- --------------------------------------------------------------------
-- ORDER OF SERVICE (control_room_plan_speakers)
-- --------------------------------------------------------------------

delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-07-26');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1,  'Welcome & Bible Reading',   'Pastor Gbenga Adebanjo',   null),
  (2,  'Opening Prayer',            'Sister Yinka Osipitan',    null),
  (3,  'Worship',                   null,                       'Worship Team · Afro medley backing track 125 BPM · keys set at soundcheck'),
  (4,  'Communion',                 'Pastor Shade Olatoye',     null),
  (5,  'Media Awareness',           'Pastor Gbenga Adebanjo',   'Slide / QR on screen'),
  (6,  'Announcements',             'Pastor Kayode Ogungbenro', null),
  (7,  'Graduation Presentations',  null,                       'FLAG: lead + slide TBC · people to the front, camera to follow'),
  (8,  'Bible Reading',             null,                       'FLAG: passage + reader TBC'),
  (9,  'Sermon',                    'Dr Titi Sodipo',           'Guest Minister · Altars'),
  (10, 'Closing Prayer',            'Pastor Kemi Ogungbenro',   null),
  (11, 'Benediction',               'Sister Petty',             null)
) as v(position, role, name, notes)
where p.service_date = '2026-07-26';

-- --------------------------------------------------------------------
-- Plan note: refresh the summary now the order is known
-- --------------------------------------------------------------------

update control_room_plans
   set notes = 'Guest preacher Dr Titi Sodipo, sermon "Altars". Graduation Presentations segment this week. '
               'Afro medley on a 125 BPM backing track. Bible reading passage + reader still TBC, and the '
               'graduation lead + slide still TBC (both flagged). Offering and end-of-service songs not yet chosen.'
 where service_date = '2026-07-26';

notify pgrst, 'reload schema';

-- --------------------------------------------------------------------
-- VERIFY
-- --------------------------------------------------------------------

select s.position, s.role, coalesce(s.name, '--') as name,
       case when s.notes like 'FLAG:%' then 'NEEDS INPUT' else '' end as flag
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-07-26'
order by s.position;

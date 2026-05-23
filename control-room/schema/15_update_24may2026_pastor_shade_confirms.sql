-- ============================================================
-- 15_update_24may2026_pastor_shade_confirms.sql
-- ============================================================
-- Updates the Sunday 24 May 2026 plan with confirmations from
-- Pastor Shade's message:
--   - Sermon title: "Doing Good Has A Pay Day" (replaces working title)
--   - Order of service names filled in (was mostly TBC)
--
-- Idempotent: safe to re-run. Re-applies the latest names + title.
-- ============================================================

-- 1. Update the plan notes with the confirmed sermon title
update control_room_plans
   set notes = 'Pentecost Sunday — Doing Good Has A Pay Day (Bishop Bayo Yusuf · Galatians 6:9)'
 where service_date = '2026-05-24';

-- 2. Refresh the order of service with confirmed names
delete from control_room_plan_speakers
  where plan_id in (select id from control_room_plans where service_date = '2026-05-24');

insert into control_room_plan_speakers (plan_id, position, role, name, notes)
select p.id, v.position, v.role, v.name, v.notes
from control_room_plans p,
(values
  (1, 'Welcome & Bible Reading',  'Pastor Shade Olatoye',     null),
  (2, 'Opening Prayer',           'Sister Lisa',              null),
  (3, 'Worship',                  null,                       'Worship Team · Uncle Caster leading'),
  (4, 'Communion',                'Pastor Shade Olatoye',     null),
  (5, 'Announcements',            'Pastor Kayode Ogungbenro', null),
  (6, 'Bible Reading',            null,                       'Galatians 6:9 · Reader TBC'),
  (7, 'Sermon',                   'Bishop Bayo Yusuf',        'Doing Good Has A Pay Day'),
  (8, 'Closing Prayer',           'Sister Petty',             null),
  (9, 'Benediction',              'Mummy Oso',                null)
) as v(position, role, name, notes)
where p.service_date = '2026-05-24';

-- ============================================================
-- VERIFY
-- ============================================================

select p.service_date, p.notes
from control_room_plans p
where p.service_date = '2026-05-24';

select s.position, s.role, s.name, s.notes
from control_room_plan_speakers s
join control_room_plans p on p.id = s.plan_id
where p.service_date = '2026-05-24'
order by s.position;

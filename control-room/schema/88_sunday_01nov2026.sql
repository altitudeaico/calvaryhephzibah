-- ============================================================
-- 88_sunday_01nov2026.sql
-- Sunday 1 November 2026 · Outpouring of the Holy Spirit · Dr Bidemi Nwator
-- Idempotent when run in the SQL editor: deletes anything for 2026-11-01 first, then re-inserts.
--
-- SONGS: same set as 25 Oct (confirmed 31 Oct). Omemma still a placeholder. Keys TBC.
-- SCRIPTURE: reader Sister Tash Campbell, KJV, positions 100-101. Sent as "Joel 2:38-39, Joel 7".
--   Pastor Shade confirmed 31 Oct that the second is John 7:37-39. The first is loaded as Joel 2:28-29
--   (Joel 2 ends at v32), not yet confirmed.
-- FLAGS: offering not itemised, no leader named; Sister Lisa surname not given;
--   thumbnail is the ChatGPT final (v=2, from preachers/bidemi-nwator.jpg).
-- ============================================================

-- clear any previous seed for this date
delete from control_room_plan_items    where plan_id in (select id from control_room_plans where service_date = '2026-11-01');
delete from control_room_plan_speakers where plan_id in (select id from control_room_plans where service_date = '2026-11-01');
delete from control_room_plans         where service_date = '2026-11-01';
delete from control_room_images        where category = 'sermon' and data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-01-nov-2026.jpg%';
delete from cos_services               where service_date = '2026-11-01';

-- plan
insert into control_room_plans (service_date, notes) values ('2026-11-01',
 'Outpouring of the Holy Spirit (Dr Bidemi Nwator). Same set as 25 Oct; Omemma placeholder; keys TBC. Reading by Sister Tash Campbell: Joel 2:28-29 (to confirm), John 7:37-39 (KJV). Offering not itemised.');

-- songs
with p as (select id from control_room_plans where service_date = '2026-11-01'),
s(pos, title, section) as (values
  (1,'This Is the Day','praise'),
  (2,'Come and Let Us Sing','praise'),
  (3,'I Know Who I Am','praise'),
  (4,'Omemma','praise'),
  (5,'Wide as the Sky','worship'),
  (6,'Way Maker','worship'),
  (7,'Your Presence Is Heaven','worship'),
  (8,'Come and Let Us Sing','offering'),
  (9,'Way Maker','end'))
insert into control_room_plan_items (plan_id, position, kind, title, slides, section)
select p.id, s.pos, 'song', s.title,
       coalesce((select cs.slides from control_room_songs cs where lower(cs.title) = lower(s.title) limit 1),
                jsonb_build_array(jsonb_build_object('line1','[lyrics to be added]','line2', s.title))),
       s.section
from p, s;

-- sermon image (ChatGPT final, v=2)
insert into control_room_images (name, category, data_url, width, height, media_type)
values ('Sermon · 1 Nov 2026 · Outpouring of the Holy Spirit (Dr Bidemi Nwator)', 'sermon',
        'https://calvaryhephzibah.co.uk/sermon-thumbnail-01-nov-2026.jpg?v=2', 1280, 720, 'image');

-- speakers
with p as (select id from control_room_plans where service_date = '2026-11-01'),
img as (select id from control_room_images where data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-01-nov-2026.jpg%' limit 1),
sp(pos, role, name, notes) as (values
  (1,'Welcome & Bible Reading','Pastor Kayode Ogungbenro',null),
  (2,'Opening Prayer','Pastor Funke Adebanjo',null),
  (3,'Worship',null,'Worship Team · same set as 25 Oct · Omemma lyrics pending · all keys TBC'),
  (4,'Communion','Pastor Shade Olatoye',null),
  (5,'Media Awareness','Pastor Gbenga Adebanjo',null),
  (6,'Announcements','Pastor Kayode Ogungbenro',null),
  (7,'Bible Reading','Sister Tash Campbell','Joel 2:28-29 (to confirm) · John 7:37-39 (confirmed) · KJV'),
  (8,'Sermon','Dr Bidemi Nwator','Outpouring of the Holy Spirit'),
  (9,'Offering',null,'Come and Let Us Sing · FLAG: not itemised in the order as sent, added in usual slot · no offering leader named'),
  (10,'Closing Prayer','Sister Petty',null),
  (11,'Benediction','Sister Lisa',null))
insert into control_room_plan_speakers (plan_id, position, role, name, notes, image_id)
select p.id, sp.pos, sp.role, sp.name, sp.notes, case when sp.role = 'Sermon' then (select id from img) end
from p, sp;

-- Bible reading (KJV)
select cr_add_scripture_to_plan(
  p_service_date => '2026-11-01'::date, p_position => 100,
  p_book => 'Joel', p_chapter => 2, p_verse_start => 28, p_verse_end => 29,
  p_section => 'reading', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-11-01'::date, p_position => 101,
  p_book => 'John', p_chapter => 7, p_verse_start => 37, p_verse_end => 39,
  p_section => 'reading', p_version => 'KJV');

-- Calvary OS service record
insert into cos_services (service_date, badge, preacher, sermon_title, sermon_subtitle, scripture, worship_leader,
                          order_of_service, songs, band, notes, thumbnail_url)
values ('2026-11-01', 'Sunday Service', 'Dr Bidemi Nwator', 'Outpouring of the Holy Spirit', null,
 'Joel 2:28-29 (to confirm); John 7:37-39', null,
 '[{"n": 1, "item": "Welcome & Bible Reading", "type": "normal", "assigned": "Pastor Kayode Ogungbenro"}, {"n": 2, "item": "Opening Prayer", "type": "normal", "assigned": "Pastor Funke Adebanjo"}, {"n": 3, "item": "Worship", "type": "normal", "assigned": "Worship Team"}, {"n": 4, "item": "Communion", "type": "normal", "assigned": "Pastor Shade Olatoye"}, {"n": 5, "item": "Media Awareness", "type": "normal", "assigned": "Pastor Gbenga Adebanjo"}, {"n": 6, "item": "Announcements", "type": "normal", "assigned": "Pastor Kayode Ogungbenro"}, {"n": 7, "item": "Bible Reading", "type": "highlight", "assigned": "Sister Tash Campbell", "notes": "Joel 2:28-29 (to confirm) · John 7:37-39"}, {"n": 8, "item": "Sermon · Outpouring of the Holy Spirit", "type": "sermon", "assigned": "Dr Bidemi Nwator"}, {"n": 9, "item": "Offering · Come and Let Us Sing", "type": "highlight", "assigned": null, "notes": "No offering leader named"}, {"n": 10, "item": "Closing Prayer", "type": "normal", "assigned": "Sister Petty"}, {"n": 11, "item": "Benediction", "type": "normal", "assigned": "Sister Lisa"}]'::jsonb, '[{"title": "This Is the Day (Fred Hammond)", "lyrics": null, "section": "Praise"}, {"title": "Come and Let Us Sing (Israel Houghton)", "lyrics": null, "section": "Praise"}, {"title": "I Know Who I Am (Sinach) OR Omemma (Chandler Moore)", "lyrics": null, "section": "Praise"}, {"title": "Wide as the Sky (Isabel Davis)", "lyrics": null, "section": "Worship"}, {"title": "Way Maker (Sinach)", "lyrics": null, "section": "Worship"}, {"title": "Your Presence Is Heaven (Israel Houghton)", "lyrics": null, "section": "Worship"}, {"title": "Come and Let Us Sing", "lyrics": null, "section": "Offering"}, {"title": "Way Maker", "lyrics": null, "section": "End of Service"}]'::jsonb, '[]'::jsonb,
 'Same set as 25 Oct; Omemma placeholder, keys TBC. Reading sent as Joel 2:38-39 and Joel 7; John 7:37-39 confirmed, Joel loaded as 2:28-29 (to confirm). Offering leader not named. Thumbnail is the ChatGPT final (v=2).',
 'https://calvaryhephzibah.co.uk/sermon-thumbnail-01-nov-2026.jpg?v=2');

notify pgrst, 'reload schema';

-- VERIFY
select (select count(*) from control_room_plan_items i join control_room_plans p on p.id=i.plan_id where p.service_date='2026-11-01' and kind='song') songs,
       (select count(*) from control_room_plan_items i join control_room_plans p on p.id=i.plan_id where p.service_date='2026-11-01' and kind<>'song') scripture,
       (select count(*) from control_room_plan_speakers s join control_room_plans p on p.id=s.plan_id where p.service_date='2026-11-01') speakers;
select i.title from control_room_plan_items i join control_room_plans p on p.id=i.plan_id
 where p.service_date='2026-11-01' and i.slides::text like '%to be added%';

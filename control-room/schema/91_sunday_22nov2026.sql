-- ============================================================
-- 91_sunday_22nov2026.sql
-- Sunday 22 November 2026 · Shut the Door (Keep the Devil Out) · Dr Robert Abdullahi Johnson
-- Idempotent when run in the SQL editor: deletes anything for 2026-11-22 first, then re-inserts.
--
-- SONGS: same set as 15 Nov 2026 (seed 90); canonical titles unchanged, all eight resolve from prior plans. Keys TBC.
-- SCRIPTURE: reader Brother Ernest (read as Brother Ernest Omoregie), KJV, positions 100-103:
--   Luke 11:14-28, James 4:7-8, Romans 12:1-2, 2 Corinthians 5:17-21.
-- FLAGS: offering not itemised, no leader named (Give Thanks to the Lord is the offering song);
--   benediction TBD; "Pastor Gbenga" read as Pastor Gbenga Adebanjo; Welcome Bible reading has no passage;
--   thumbnail is the ChatGPT final (v=2).
-- ============================================================

-- clear any previous seed for this date
delete from control_room_plan_items    where plan_id in (select id from control_room_plans where service_date = '2026-11-22');
delete from control_room_plan_speakers where plan_id in (select id from control_room_plans where service_date = '2026-11-22');
delete from control_room_plans         where service_date = '2026-11-22';
delete from control_room_images        where category = 'sermon' and data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-22-nov-2026.jpg%';
delete from cos_services               where service_date = '2026-11-22';

-- plan
insert into control_room_plans (service_date, notes) values ('2026-11-22',
 'Shut the Door (Keep the Devil Out) (Dr Robert Abdullahi Johnson). Same set as 15 Nov; all 8 resolve from prior plans; keys TBC. Reading by Brother Ernest: Luke 11:14-28, James 4:7-8, Romans 12:1-2, 2 Corinthians 5:17-21 (KJV). Offering not itemised; benediction TBD.');

-- songs
with p as (select id from control_room_plans where service_date = '2026-11-22'),
s(pos, title, section) as (values
  (1,'These Are the Days of Elijah','praise'),
  (2,'Lord I Lift Your Name on High','praise'),
  (3,'Open the Eyes of My Heart, Lord','praise'),
  (4,'I Will Worship','worship'),
  (5,'Heart of Worship','worship'),
  (6,'Jesus at the Centre','worship'),
  (7,'Give Thanks to the Lord','offering'),
  (8,'Thank You Lord (Don Moen)','end'))
insert into control_room_plan_items (plan_id, position, kind, title, slides, section)
select p.id, s.pos, 'song', s.title,
       coalesce(
         (select i2.slides from control_room_plan_items i2
            join control_room_plans p2 on p2.id = i2.plan_id
           where lower(i2.title) = lower(s.title) and i2.kind = 'song'
             and p2.service_date < '2026-11-22'
             and i2.slides::text not like '%to be added%'
           order by p2.service_date desc limit 1),
         (select cs.slides from control_room_songs cs where lower(cs.title) = lower(s.title) limit 1),
         jsonb_build_array(jsonb_build_object('line1','[lyrics to be added]','line2', s.title))),
       s.section
from p, s;

-- sermon image (ChatGPT final, v=2)
insert into control_room_images (name, category, data_url, width, height, media_type)
values ('Sermon · 22 Nov 2026 · Shut the Door (Keep the Devil Out) (Dr Robert Abdullahi Johnson)', 'sermon',
        'https://calvaryhephzibah.co.uk/sermon-thumbnail-22-nov-2026.jpg?v=2', 1280, 720, 'image');

-- speakers
with p as (select id from control_room_plans where service_date = '2026-11-22'),
img as (select id from control_room_images where data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-22-nov-2026.jpg%' limit 1),
sp(pos, role, name, notes) as (values
  (1,'Welcome & Bible Reading','Pastor Gbenga Adebanjo','Sent as "Pastor Gbenga" · no passage given'),
  (2,'Opening Prayer','Deacon Femi Osipitan',null),
  (3,'Worship',null,'Worship Team · same set as 15 Nov · all keys TBC'),
  (4,'Communion','Pastor Shade Olatoye',null),
  (5,'Media Awareness','Pastor Gbenga Adebanjo','Sent as "Pastor Gbenga"'),
  (6,'Announcements','Pastor Kayode Ogungbenro',null),
  (7,'Bible Reading','Brother Ernest Omoregie','Sent as "Brother Ernest" · Luke 11:14-28, James 4:7-8, Romans 12:1-2, 2 Corinthians 5:17-21 · KJV'),
  (8,'Sermon','Dr Robert Abdullahi Johnson','Shut the Door (Keep the Devil Out) · Guest Minister · Revival Sunday with Grace Tours Global'),
  (9,'Offering',null,'Give Thanks to the Lord · FLAG: not itemised in the order as sent, added in usual slot · no offering leader named'),
  (10,'Closing Prayer','Sis Yinka Osipitan',null),
  (11,'Benediction',null,'TBD · no name sent'))
insert into control_room_plan_speakers (plan_id, position, role, name, notes, image_id)
select p.id, sp.pos, sp.role, sp.name, sp.notes, case when sp.role = 'Sermon' then (select id from img) end
from p, sp;

-- Bible reading (KJV)
select cr_add_scripture_to_plan(p_service_date => '2026-11-22'::date, p_position => 100,
  p_book => 'Luke', p_chapter => 11, p_verse_start => 14, p_verse_end => 28, p_section => 'reading', p_version => 'KJV');
select cr_add_scripture_to_plan(p_service_date => '2026-11-22'::date, p_position => 101,
  p_book => 'James', p_chapter => 4, p_verse_start => 7, p_verse_end => 8, p_section => 'reading', p_version => 'KJV');
select cr_add_scripture_to_plan(p_service_date => '2026-11-22'::date, p_position => 102,
  p_book => 'Romans', p_chapter => 12, p_verse_start => 1, p_verse_end => 2, p_section => 'reading', p_version => 'KJV');
select cr_add_scripture_to_plan(p_service_date => '2026-11-22'::date, p_position => 103,
  p_book => '2 Corinthians', p_chapter => 5, p_verse_start => 17, p_verse_end => 21, p_section => 'reading', p_version => 'KJV');

-- Calvary OS service record
insert into cos_services (service_date, badge, preacher, sermon_title, sermon_subtitle, scripture, worship_leader,
                          order_of_service, songs, band, notes, thumbnail_url)
values ('2026-11-22', 'Revival Sunday', 'Dr Robert Abdullahi Johnson', 'Shut the Door (Keep the Devil Out)', null,
 'Luke 11:14-28; James 4:7-8; Romans 12:1-2; 2 Corinthians 5:17-21', null,
 '[{"n": 1, "item": "Welcome & Bible Reading", "type": "normal", "assigned": "Pastor Gbenga Adebanjo"}, {"n": 2, "item": "Opening Prayer", "type": "normal", "assigned": "Deacon Femi Osipitan"}, {"n": 3, "item": "Worship", "type": "normal", "assigned": "Worship Team"}, {"n": 4, "item": "Communion", "type": "normal", "assigned": "Pastor Shade Olatoye"}, {"n": 5, "item": "Media Awareness", "type": "normal", "assigned": "Pastor Gbenga Adebanjo"}, {"n": 6, "item": "Announcements", "type": "normal", "assigned": "Pastor Kayode Ogungbenro"}, {"n": 7, "item": "Bible Reading", "type": "highlight", "assigned": "Brother Ernest Omoregie", "notes": "Luke 11:14-28; James 4:7-8; Romans 12:1-2; 2 Corinthians 5:17-21"}, {"n": 8, "item": "Sermon · Shut the Door (Keep the Devil Out)", "type": "sermon", "assigned": "Dr Robert Abdullahi Johnson"}, {"n": 9, "item": "Offering · Give Thanks to the Lord", "type": "highlight", "assigned": null, "notes": "No offering leader named"}, {"n": 10, "item": "Closing Prayer", "type": "normal", "assigned": "Sis Yinka Osipitan"}, {"n": 11, "item": "Benediction", "type": "normal", "assigned": null, "notes": "TBD"}]'::jsonb, '[{"title": "These Are the Days of Elijah (Robin Mark)", "lyrics": null, "section": "Praise"}, {"title": "Lord I Lift Your Name on High (Rick Founds)", "lyrics": null, "section": "Praise"}, {"title": "Open the Eyes of My Heart, Lord (Paul Baloche)", "lyrics": null, "section": "Praise"}, {"title": "I Will Worship (David Ruis)", "lyrics": null, "section": "Worship"}, {"title": "Heart of Worship (Matt Redman)", "lyrics": null, "section": "Worship"}, {"title": "Jesus at the Centre (Israel Houghton)", "lyrics": null, "section": "Worship"}, {"title": "Give Thanks to the Lord (Chris Tomlin)", "lyrics": null, "section": "Offering"}, {"title": "Thank You Lord (Don Moen)", "lyrics": null, "section": "End of Service"}]'::jsonb, '[]'::jsonb,
 'Same set as 15 Nov; keys TBC. Offering leader not named. Benediction TBD. Thumbnail is the ChatGPT final (v=2).',
 'https://calvaryhephzibah.co.uk/sermon-thumbnail-22-nov-2026.jpg?v=2');

notify pgrst, 'reload schema';

-- VERIFY
select (select count(*) from control_room_plan_items i join control_room_plans p on p.id=i.plan_id where p.service_date='2026-11-22' and kind='song') songs,
       (select count(*) from control_room_plan_items i join control_room_plans p on p.id=i.plan_id where p.service_date='2026-11-22' and kind<>'song') scripture,
       (select count(*) from control_room_plan_speakers s join control_room_plans p on p.id=s.plan_id where p.service_date='2026-11-22') speakers;
select i.title from control_room_plan_items i join control_room_plans p on p.id=i.plan_id
 where p.service_date='2026-11-22' and i.slides::text like '%to be added%';

-- ============================================================
-- 89_sunday_08nov2026.sql
-- Sunday 8 November 2026 · Outpouring of the Spirit: What Next? · Pastor Gbenga Adebanjo
-- Idempotent when run in the SQL editor: deletes anything for 2026-11-08 first, then re-inserts.
--
-- SONGS: new set, song for song the same as 27 Sep 2026 (seed 81). Canonical titles copied from 81,
--   so all eight resolve from the most recent prior plan, then the control_room_songs library. Keys TBC.
-- SCRIPTURE: reader Sister Petty, KJV, positions 100-103:
--   Matthew 9:16-18 (as sent; v18 starts the ruler's daughter, may be meant to end at 17),
--   Acts 4:31, Ephesians 5:17-21, Colossians 3:15-17.
-- FLAGS: offering not itemised, no leader named (Give Thanks to the Lord is the offering song);
--   Communion sent as "Pastor Pastor Kayode", read as Pastor Kayode Ogungbenro;
--   surnames not given for Sister Petty and Sister Lisa;
--   thumbnail is the ChatGPT final (v=2, from anniversary hero-portrait-20).
-- ============================================================

-- clear any previous seed for this date
delete from control_room_plan_items    where plan_id in (select id from control_room_plans where service_date = '2026-11-08');
delete from control_room_plan_speakers where plan_id in (select id from control_room_plans where service_date = '2026-11-08');
delete from control_room_plans         where service_date = '2026-11-08';
delete from control_room_images        where category = 'sermon' and data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-08-nov-2026.jpg%';
delete from cos_services               where service_date = '2026-11-08';

-- plan
insert into control_room_plans (service_date, notes) values ('2026-11-08',
 'Outpouring of the Spirit: What Next? (Pastor Gbenga Adebanjo). Same set as 27 Sep; all 8 resolve from prior plans; keys TBC. Reading by Sister Petty: Matthew 9:16-18 (as sent, may end at 17), Acts 4:31, Ephesians 5:17-21, Colossians 3:15-17 (KJV). Offering not itemised.');

-- songs
with p as (select id from control_room_plans where service_date = '2026-11-08'),
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
             and p2.service_date < '2026-11-08'
             and i2.slides::text not like '%to be added%'
           order by p2.service_date desc limit 1),
         (select cs.slides from control_room_songs cs where lower(cs.title) = lower(s.title) limit 1),
         jsonb_build_array(jsonb_build_object('line1','[lyrics to be added]','line2', s.title))),
       s.section
from p, s;

-- sermon image (ChatGPT final, v=2)
insert into control_room_images (name, category, data_url, width, height, media_type)
values ('Sermon · 8 Nov 2026 · Outpouring of the Spirit: What Next? (Pastor Gbenga Adebanjo)', 'sermon',
        'https://calvaryhephzibah.co.uk/sermon-thumbnail-08-nov-2026.jpg?v=2', 1280, 720, 'image');

-- speakers
with p as (select id from control_room_plans where service_date = '2026-11-08'),
img as (select id from control_room_images where data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-08-nov-2026.jpg%' limit 1),
sp(pos, role, name, notes) as (values
  (1,'Welcome & Bible Reading','Pastor Kayode Ogungbenro',null),
  (2,'Opening Prayer','Brother Ernest Omoregie',null),
  (3,'Worship',null,'Worship Team · same set as 27 Sep · all keys TBC'),
  (4,'Communion','Pastor Kayode Ogungbenro','Sent as "Pastor Pastor Kayode"'),
  (5,'Media Awareness','Pastor Gbenga Adebanjo',null),
  (6,'Announcements','Pastor Kayode Ogungbenro',null),
  (7,'Bible Reading','Sister Petty','Matthew 9:16-18 · Acts 4:31 · Ephesians 5:17-21 · Colossians 3:15-17 · KJV'),
  (8,'Sermon','Pastor Gbenga Adebanjo','Outpouring of the Spirit: What Next?'),
  (9,'Offering',null,'Give Thanks to the Lord · FLAG: not itemised in the order as sent, added in usual slot · no offering leader named'),
  (10,'Closing Prayer','Mummy Akintunde',null),
  (11,'Benediction','Sister Lisa',null))
insert into control_room_plan_speakers (plan_id, position, role, name, notes, image_id)
select p.id, sp.pos, sp.role, sp.name, sp.notes, case when sp.role = 'Sermon' then (select id from img) end
from p, sp;

-- Bible reading (KJV)
select cr_add_scripture_to_plan(
  p_service_date => '2026-11-08'::date, p_position => 100,
  p_book => 'Matthew', p_chapter => 9, p_verse_start => 16, p_verse_end => 18,
  p_section => 'reading', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-11-08'::date, p_position => 101,
  p_book => 'Acts', p_chapter => 4, p_verse_start => 31, p_verse_end => 31,
  p_section => 'reading', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-11-08'::date, p_position => 102,
  p_book => 'Ephesians', p_chapter => 5, p_verse_start => 17, p_verse_end => 21,
  p_section => 'reading', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-11-08'::date, p_position => 103,
  p_book => 'Colossians', p_chapter => 3, p_verse_start => 15, p_verse_end => 17,
  p_section => 'reading', p_version => 'KJV');

-- Calvary OS service record
insert into cos_services (service_date, badge, preacher, sermon_title, sermon_subtitle, scripture, worship_leader,
                          order_of_service, songs, band, notes, thumbnail_url)
values ('2026-11-08', 'Sunday Service', 'Pastor Gbenga Adebanjo', 'Outpouring of the Spirit: What Next?', null,
 'Matthew 9:16-18; Acts 4:31; Ephesians 5:17-21; Colossians 3:15-17', null,
 '[{"n": 1, "item": "Welcome & Bible Reading", "type": "normal", "assigned": "Pastor Kayode Ogungbenro"}, {"n": 2, "item": "Opening Prayer", "type": "normal", "assigned": "Brother Ernest Omoregie"}, {"n": 3, "item": "Worship", "type": "normal", "assigned": "Worship Team"}, {"n": 4, "item": "Communion", "type": "normal", "assigned": "Pastor Kayode Ogungbenro"}, {"n": 5, "item": "Media Awareness", "type": "normal", "assigned": "Pastor Gbenga Adebanjo"}, {"n": 6, "item": "Announcements", "type": "normal", "assigned": "Pastor Kayode Ogungbenro"}, {"n": 7, "item": "Bible Reading", "type": "highlight", "assigned": "Sister Petty", "notes": "Matthew 9:16-18 · Acts 4:31 · Ephesians 5:17-21 · Colossians 3:15-17"}, {"n": 8, "item": "Sermon · Outpouring of the Spirit: What Next?", "type": "sermon", "assigned": "Pastor Gbenga Adebanjo"}, {"n": 9, "item": "Offering · Give Thanks to the Lord", "type": "highlight", "assigned": null, "notes": "No offering leader named"}, {"n": 10, "item": "Closing Prayer", "type": "normal", "assigned": "Mummy Akintunde"}, {"n": 11, "item": "Benediction", "type": "normal", "assigned": "Sister Lisa"}]'::jsonb, '[{"title": "These Are the Days of Elijah (Robin Mark)", "lyrics": null, "section": "Praise"}, {"title": "Lord I Lift Your Name on High (Rick Founds)", "lyrics": null, "section": "Praise"}, {"title": "Open the Eyes of My Heart, Lord (Paul Baloche)", "lyrics": null, "section": "Praise"}, {"title": "I Will Worship (David Ruis)", "lyrics": null, "section": "Worship"}, {"title": "Heart of Worship (Matt Redman)", "lyrics": null, "section": "Worship"}, {"title": "Jesus at the Centre (Israel Houghton)", "lyrics": null, "section": "Worship"}, {"title": "Give Thanks to the Lord (Chris Tomlin)", "lyrics": null, "section": "Offering"}, {"title": "Thank You Lord (Don Moen)", "lyrics": null, "section": "End of Service"}]'::jsonb, '[]'::jsonb,
 'Same set as 27 Sep; keys TBC. Matthew 9:16-18 loaded as sent (may end at 17). Communion sent as "Pastor Pastor Kayode". Offering leader not named. Thumbnail is the ChatGPT final (v=2).',
 'https://calvaryhephzibah.co.uk/sermon-thumbnail-08-nov-2026.jpg?v=2');

notify pgrst, 'reload schema';

-- VERIFY
select (select count(*) from control_room_plan_items i join control_room_plans p on p.id=i.plan_id where p.service_date='2026-11-08' and kind='song') songs,
       (select count(*) from control_room_plan_items i join control_room_plans p on p.id=i.plan_id where p.service_date='2026-11-08' and kind<>'song') scripture,
       (select count(*) from control_room_plan_speakers s join control_room_plans p on p.id=s.plan_id where p.service_date='2026-11-08') speakers;
select i.title from control_room_plan_items i join control_room_plans p on p.id=i.plan_id
 where p.service_date='2026-11-08' and i.slides::text like '%to be added%';

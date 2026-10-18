-- ============================================================
-- 86_sunday_18oct2026.sql
-- Sunday 18 October 2026 · Is A Christian Necessarily A Disciple? · Pastor Shade Olatoye
-- Applied 18 Oct 2026 via Supabase MCP migration "sunday_18oct2026" (insert-only, no prior rows), then verified by read.
-- Idempotent when run in the SQL editor: deletes anything for 2026-10-18 first, then re-inserts.
--
-- SONGS: same set as 4/11 Oct (confirmed 18 Oct). Omemma still a placeholder.
-- SCRIPTURE: two readings (Sis Margret McLean, Pastor Kemi Ogungbenro), passages not given.
--   Ten sermon verses seeded at positions 100-109, all KJV (Matt 4:19-20 and Acts 11:26
--   were sent in EASY, which is not in control_room_bible).
-- FLAGS: offering not itemised, no leader named; thumbnail is the ChatGPT final (v=2, from hero portrait 5).
-- ============================================================

-- clear any previous seed for this date
delete from control_room_plan_items    where plan_id in (select id from control_room_plans where service_date = '2026-10-18');
delete from control_room_plan_speakers where plan_id in (select id from control_room_plans where service_date = '2026-10-18');
delete from control_room_plans         where service_date = '2026-10-18';
delete from control_room_images        where category = 'sermon' and data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-18-oct-2026.jpg%';
delete from cos_services               where service_date = '2026-10-18';

-- plan
insert into control_room_plans (service_date, notes) values ('2026-10-18',
 'Is A Christian Necessarily A Disciple? (Pastor Shade Olatoye). Same set as 11 Oct; Omemma placeholder; keys TBC. Two Bible readings, passages TBC. Ten sermon verses loaded (KJV). Offering not itemised.');

-- songs
with p as (select id from control_room_plans where service_date = '2026-10-18'),
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
values ('Sermon · 18 Oct 2026 · Is A Christian Necessarily A Disciple? (Pastor Shade Olatoye)', 'sermon',
        'https://calvaryhephzibah.co.uk/sermon-thumbnail-18-oct-2026.jpg?v=2', 1280, 720, 'image');

-- speakers
with p as (select id from control_room_plans where service_date = '2026-10-18'),
img as (select id from control_room_images where data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-18-oct-2026.jpg%' limit 1),
sp(pos, role, name, notes) as (values
  (1,'Welcome & Bible Reading','Pastor Shade Olatoye',null),
  (2,'Opening Prayer','Sis Lisa Richardson',null),
  (3,'Worship',null,'Worship Team · same set as 11 Oct · Omemma lyrics pending · all keys TBC'),
  (4,'Communion','Pastor Gbenga Adebanjo',null),
  (5,'Media Awareness','Pastor Gbenga Adebanjo',null),
  (6,'Announcements','Pastor Kayode Ogungbenro',null),
  (7,'Bible Reading (1st)','Sis Margret McLean','Passage TBC · not given in the order of service'),
  (8,'Bible Reading (2nd)','Pastor Kemi Ogungbenro','Passage TBC · not given in the order of service'),
  (9,'Sermon','Pastor Shade Olatoye','Is A Christian Necessarily A Disciple? · ten sermon verses loaded (KJV)'),
  (10,'Offering',null,'Come and Let Us Sing · FLAG: not itemised in the order as sent, added in usual slot · no offering leader named'),
  (11,'Closing Prayer','Sis Petty',null),
  (12,'Benediction','Pastor Funke Adebanjo',null))
insert into control_room_plan_speakers (plan_id, position, role, name, notes, image_id)
select p.id, sp.pos, sp.role, sp.name, sp.notes, case when sp.role = 'Sermon' then (select id from img) end
from p, sp;

-- sermon verses (KJV)
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-18'::date, p_position => 100,
  p_book => 'Matthew', p_chapter => 4, p_verse_start => 19, p_verse_end => 20,
  p_section => 'sermon', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-18'::date, p_position => 101,
  p_book => 'Acts', p_chapter => 11, p_verse_start => 26, p_verse_end => 26,
  p_section => 'sermon', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-18'::date, p_position => 102,
  p_book => 'John', p_chapter => 14, p_verse_start => 6, p_verse_end => 6,
  p_section => 'sermon', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-18'::date, p_position => 103,
  p_book => 'John', p_chapter => 10, p_verse_start => 10, p_verse_end => 10,
  p_section => 'sermon', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-18'::date, p_position => 104,
  p_book => 'Matthew', p_chapter => 16, p_verse_start => 24, p_verse_end => 25,
  p_section => 'sermon', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-18'::date, p_position => 105,
  p_book => 'Mark', p_chapter => 8, p_verse_start => 34, p_verse_end => 35,
  p_section => 'sermon', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-18'::date, p_position => 106,
  p_book => 'Matthew', p_chapter => 9, p_verse_start => 9, p_verse_end => 11,
  p_section => 'sermon', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-18'::date, p_position => 107,
  p_book => 'Matthew', p_chapter => 15, p_verse_start => 2, p_verse_end => 7,
  p_section => 'sermon', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-18'::date, p_position => 108,
  p_book => 'Matthew', p_chapter => 27, p_verse_start => 57, p_verse_end => 59,
  p_section => 'sermon', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-18'::date, p_position => 109,
  p_book => '2 Peter', p_chapter => 3, p_verse_start => 18, p_verse_end => 18,
  p_section => 'sermon', p_version => 'KJV');

-- Calvary OS service record
insert into cos_services (service_date, badge, preacher, sermon_title, sermon_subtitle, scripture, worship_leader,
                          order_of_service, songs, band, notes, thumbnail_url)
values ('2026-10-18', 'Sunday Service', 'Pastor Shade Olatoye', 'Is A Christian Necessarily A Disciple?', null,
 'Matt 4:19-20; Acts 11:26; John 14:6; John 10:10; Matt 16:24-25; Mark 8:34-35; Matt 9:9-11; Matt 15:2-7; Matt 27:57-59; 2 Pet 3:18', null,
 '[{"n": 1, "item": "Welcome & Bible Reading", "type": "normal", "assigned": "Pastor Shade Olatoye"}, {"n": 2, "item": "Opening Prayer", "type": "normal", "assigned": "Sis Lisa Richardson"}, {"n": 3, "item": "Worship", "type": "normal", "assigned": "Worship Team"}, {"n": 4, "item": "Communion", "type": "normal", "assigned": "Pastor Gbenga Adebanjo"}, {"n": 5, "item": "Media Awareness", "type": "normal", "assigned": "Pastor Gbenga Adebanjo"}, {"n": 6, "item": "Announcements", "type": "normal", "assigned": "Pastor Kayode Ogungbenro"}, {"n": 7, "item": "Bible Reading (1st)", "type": "highlight", "assigned": "Sis Margret McLean", "notes": "Passage TBC"}, {"n": 8, "item": "Bible Reading (2nd)", "type": "highlight", "assigned": "Pastor Kemi Ogungbenro", "notes": "Passage TBC"}, {"n": 9, "item": "Sermon \u00b7 Is A Christian Necessarily A Disciple?", "type": "sermon", "assigned": "Pastor Shade Olatoye"}, {"n": 10, "item": "Offering \u00b7 Come and Let Us Sing", "type": "highlight", "assigned": null, "notes": "No offering leader named"}, {"n": 11, "item": "Closing Prayer", "type": "normal", "assigned": "Sis Petty"}, {"n": 12, "item": "Benediction", "type": "normal", "assigned": "Pastor Funke Adebanjo"}]'::jsonb, '[{"title": "This Is the Day (Fred Hammond)", "lyrics": null, "section": "Praise"}, {"title": "Come and Let Us Sing (Israel Houghton)", "lyrics": null, "section": "Praise"}, {"title": "I Know Who I Am (Sinach) OR Omemma (Chandler Moore)", "lyrics": null, "section": "Praise"}, {"title": "Wide as the Sky (Isabel Davis)", "lyrics": null, "section": "Worship"}, {"title": "Way Maker (Sinach)", "lyrics": null, "section": "Worship"}, {"title": "Your Presence Is Heaven (Israel Houghton)", "lyrics": null, "section": "Worship"}, {"title": "Come and Let Us Sing", "lyrics": null, "section": "Offering"}, {"title": "Way Maker", "lyrics": null, "section": "End of Service"}]'::jsonb, '[]'::jsonb,
 'Same set as 11 Oct; Omemma placeholder, keys TBC. Both reading passages not given. Offering leader not named. Thumbnail is the ChatGPT final (v=2).',
 'https://calvaryhephzibah.co.uk/sermon-thumbnail-18-oct-2026.jpg?v=2');

notify pgrst, 'reload schema';

-- VERIFY
select (select count(*) from control_room_plan_items i join control_room_plans p on p.id=i.plan_id where p.service_date='2026-10-18' and kind='song') songs,
       (select count(*) from control_room_plan_items i join control_room_plans p on p.id=i.plan_id where p.service_date='2026-10-18' and kind<>'song') scripture,
       (select count(*) from control_room_plan_speakers s join control_room_plans p on p.id=s.plan_id where p.service_date='2026-10-18') speakers;
select i.title from control_room_plan_items i join control_room_plans p on p.id=i.plan_id
 where p.service_date='2026-10-18' and i.slides::text like '%to be added%';

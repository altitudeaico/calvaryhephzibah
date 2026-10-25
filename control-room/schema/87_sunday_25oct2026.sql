-- ============================================================
-- 87_sunday_25oct2026.sql
-- Sunday 25 October 2026 · Guard Your Hearts and Minds · Prof. Rev. Michael Balogun (guest minister)
-- Applied 25 Oct 2026 via Supabase MCP migration "sunday_25oct2026" (insert-only, no prior rows), then verified by read.
-- Idempotent when run in the SQL editor: deletes anything for 2026-10-25 first, then re-inserts.
--
-- SONGS: same set as 4/11/18 Oct (confirmed 25 Oct). Omemma still a placeholder. Keys TBC.
-- SCRIPTURE: one reader (Sis Petty), four passages, KJV, positions 96-99:
--   Philippians 4:2-7 (sent as 4:2, range to include v7, to confirm), Proverbs 4:23,
--   Mark 12:29-31, Deuteronomy 6:4. No separate sermon verses supplied.
-- FLAGS: offering not itemised, no leader named; guest-minister label assumed;
--   thumbnail is the ChatGPT final (v=2, from preachers/michael-balogun.jpg).
-- ============================================================

-- clear any previous seed for this date
delete from control_room_plan_items    where plan_id in (select id from control_room_plans where service_date = '2026-10-25');
delete from control_room_plan_speakers where plan_id in (select id from control_room_plans where service_date = '2026-10-25');
delete from control_room_plans         where service_date = '2026-10-25';
delete from control_room_images        where category = 'sermon' and data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-25-oct-2026.jpg%';
delete from cos_services               where service_date = '2026-10-25';

-- plan
insert into control_room_plans (service_date, notes) values ('2026-10-25',
 'Guard Your Hearts and Minds (Prof. Rev. Michael Balogun, guest). Same set as 18 Oct; Omemma placeholder; keys TBC. Reading by Sis Petty: Phil 4:2-7, Prov 4:23, Mark 12:29-31, Deut 6:4 (KJV). Offering not itemised.');

-- songs
with p as (select id from control_room_plans where service_date = '2026-10-25'),
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
values ('Sermon · 25 Oct 2026 · Guard Your Hearts and Minds (Prof. Rev. Michael Balogun)', 'sermon',
        'https://calvaryhephzibah.co.uk/sermon-thumbnail-25-oct-2026.jpg?v=2', 1280, 720, 'image');

-- speakers
with p as (select id from control_room_plans where service_date = '2026-10-25'),
img as (select id from control_room_images where data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-25-oct-2026.jpg%' limit 1),
sp(pos, role, name, notes) as (values
  (1,'Welcome & Bible Reading','Pastor Shade Olatoye',null),
  (2,'Opening Prayer','Pastor Funke Adebanjo',null),
  (3,'Worship',null,'Worship Team · same set as 18 Oct · Omemma lyrics pending · all keys TBC'),
  (4,'Communion','Pastor Shade Olatoye',null),
  (5,'Media Awareness','Pastor Gbenga Adebanjo',null),
  (6,'Announcements','Pastor Kayode Ogungbenro',null),
  (7,'Bible Reading','Sis Petty','Phil 4:2-7 · Prov 4:23 · Mark 12:29-31 · Deut 6:4 (KJV)'),
  (8,'Sermon','Prof. Rev. Michael Balogun','Guard Your Hearts and Minds · guest minister'),
  (9,'Offering',null,'Come and Let Us Sing · FLAG: not itemised in the order as sent, added in usual slot · no offering leader named'),
  (10,'Closing Prayer','Sis Folake Okunubi',null),
  (11,'Benediction','Pastor Dr Caster Martins',null))
insert into control_room_plan_speakers (plan_id, position, role, name, notes, image_id)
select p.id, sp.pos, sp.role, sp.name, sp.notes, case when sp.role = 'Sermon' then (select id from img) end
from p, sp;

-- Bible reading (KJV)
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-25'::date, p_position => 96,
  p_book => 'Philippians', p_chapter => 4, p_verse_start => 2, p_verse_end => 7,
  p_section => 'reading', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-25'::date, p_position => 97,
  p_book => 'Proverbs', p_chapter => 4, p_verse_start => 23, p_verse_end => 23,
  p_section => 'reading', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-25'::date, p_position => 98,
  p_book => 'Mark', p_chapter => 12, p_verse_start => 29, p_verse_end => 31,
  p_section => 'reading', p_version => 'KJV');
select cr_add_scripture_to_plan(
  p_service_date => '2026-10-25'::date, p_position => 99,
  p_book => 'Deuteronomy', p_chapter => 6, p_verse_start => 4, p_verse_end => 4,
  p_section => 'reading', p_version => 'KJV');

-- Calvary OS service record
insert into cos_services (service_date, badge, preacher, sermon_title, sermon_subtitle, scripture, worship_leader,
                          order_of_service, songs, band, notes, thumbnail_url)
values ('2026-10-25', 'Sunday Service', 'Prof. Rev. Michael Balogun', 'Guard Your Hearts and Minds', null,
 'Phil 4:2-7; Prov 4:23; Mark 12:29-31; Deut 6:4', null,
 '[{"n": 1, "item": "Welcome & Bible Reading", "type": "normal", "assigned": "Pastor Shade Olatoye"}, {"n": 2, "item": "Opening Prayer", "type": "normal", "assigned": "Pastor Funke Adebanjo"}, {"n": 3, "item": "Worship", "type": "normal", "assigned": "Worship Team"}, {"n": 4, "item": "Communion", "type": "normal", "assigned": "Pastor Shade Olatoye"}, {"n": 5, "item": "Media Awareness", "type": "normal", "assigned": "Pastor Gbenga Adebanjo"}, {"n": 6, "item": "Announcements", "type": "normal", "assigned": "Pastor Kayode Ogungbenro"}, {"n": 7, "item": "Bible Reading", "type": "highlight", "assigned": "Sis Petty", "notes": "Phil 4:2-7 · Prov 4:23 · Mark 12:29-31 · Deut 6:4"}, {"n": 8, "item": "Sermon · Guard Your Hearts and Minds", "type": "sermon", "assigned": "Prof. Rev. Michael Balogun"}, {"n": 9, "item": "Offering · Come and Let Us Sing", "type": "highlight", "assigned": null, "notes": "No offering leader named"}, {"n": 10, "item": "Closing Prayer", "type": "normal", "assigned": "Sis Folake Okunubi"}, {"n": 11, "item": "Benediction", "type": "normal", "assigned": "Pastor Dr Caster Martins"}]'::jsonb, '[{"title": "This Is the Day (Fred Hammond)", "lyrics": null, "section": "Praise"}, {"title": "Come and Let Us Sing (Israel Houghton)", "lyrics": null, "section": "Praise"}, {"title": "I Know Who I Am (Sinach) OR Omemma (Chandler Moore)", "lyrics": null, "section": "Praise"}, {"title": "Wide as the Sky (Isabel Davis)", "lyrics": null, "section": "Worship"}, {"title": "Way Maker (Sinach)", "lyrics": null, "section": "Worship"}, {"title": "Your Presence Is Heaven (Israel Houghton)", "lyrics": null, "section": "Worship"}, {"title": "Come and Let Us Sing", "lyrics": null, "section": "Offering"}, {"title": "Way Maker", "lyrics": null, "section": "End of Service"}]'::jsonb, '[]'::jsonb,
 'Same set as 18 Oct; Omemma placeholder, keys TBC. Philippians sent as 4:2, loaded as 4:2-7 (to confirm). Offering leader not named. Guest minister. Thumbnail is the ChatGPT final (v=2).',
 'https://calvaryhephzibah.co.uk/sermon-thumbnail-25-oct-2026.jpg?v=2');

notify pgrst, 'reload schema';

-- VERIFY
select (select count(*) from control_room_plan_items i join control_room_plans p on p.id=i.plan_id where p.service_date='2026-10-25' and kind='song') songs,
       (select count(*) from control_room_plan_items i join control_room_plans p on p.id=i.plan_id where p.service_date='2026-10-25' and kind<>'song') scripture,
       (select count(*) from control_room_plan_speakers s join control_room_plans p on p.id=s.plan_id where p.service_date='2026-10-25') speakers;
select i.title from control_room_plan_items i join control_room_plans p on p.id=i.plan_id
 where p.service_date='2026-10-25' and i.slides::text like '%to be added%';

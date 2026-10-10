-- ============================================================
-- 85_sunday_11oct2026.sql
-- Sunday 11 October 2026 · The HEART: What It Comprises Of · Pastor Gbenga Adebanjo
-- Applied 10 Oct 2026 via Supabase MCP migration "sunday_11oct2026", then verified by read.
-- Idempotent: deletes anything for 2026-10-11 first, then re-inserts.
--
-- SONGS: same set as 4 Oct. Five resolve from control_room_songs. Omemma has
--   no lyrics on file (placeholder). Song 3 is I Know Who I Am OR Omemma.
-- SCRIPTURE: none seeded. No passage given for Sis Tinu Ibitoye's reading.
-- FLAGS: preacher sent as "Pastor Gbenga Ogungbenro", set as Pastor Gbenga
--   Adebanjo pending confirmation; offering not itemised, no leader named;
--   thumbnail is the ChatGPT final at v=2 (portrait P20).
-- ============================================================

-- clear any previous seed for this date
delete from control_room_plan_items    where plan_id in (select id from control_room_plans where service_date = '2026-10-11');
delete from control_room_plan_speakers where plan_id in (select id from control_room_plans where service_date = '2026-10-11');
delete from control_room_plans         where service_date = '2026-10-11';
delete from control_room_images        where category = 'sermon' and data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-11-oct-2026.jpg%';
delete from cos_services               where service_date = '2026-10-11';

-- plan
insert into control_room_plans (service_date, notes) values ('2026-10-11',
 'The HEART: What It Comprises Of (Pastor Gbenga Adebanjo; sent as Pastor Gbenga Ogungbenro, to confirm). Same set as 4 Oct: five songs resolve from the library; Omemma still a placeholder. Song 3 is I Know Who I Am OR Omemma (worship leader to confirm); both seeded. Offering reprises Come and Let Us Sing; End reprises Way Maker. ALL KEYS TBC. Scripture: no passage given for Sis Tinu Ibitoye; nothing seeded yet. Offering not itemised in the order as sent; added in its usual post-sermon slot, no leader named.');

-- songs: lyrics resolve from the library by title, placeholder if missing
with p as (select id from control_room_plans where service_date = '2026-10-11'),
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
values ('Sermon · 11 Oct 2026 · The HEART: What It Comprises Of (Pastor Gbenga Adebanjo)', 'sermon',
        'https://calvaryhephzibah.co.uk/sermon-thumbnail-11-oct-2026.jpg?v=2', 1280, 720, 'image');

-- speakers
with p as (select id from control_room_plans where service_date = '2026-10-11'),
img as (select id from control_room_images where data_url like 'https://calvaryhephzibah.co.uk/sermon-thumbnail-11-oct-2026.jpg%' limit 1),
sp(pos, role, name, notes) as (values
  (1,'Welcome & Bible Reading','Pastor Kayode Ogungbenro',null),
  (2,'Opening Prayer','Sis Bukky Olowolagba',null),
  (3,'Worship',null,'Worship Team · same set as 4 Oct · Omemma lyrics pending · all keys TBC'),
  (4,'Communion','Pastor Kayode Ogungbenro',null),
  (5,'Media Awareness','Pastor Gbenga Adebanjo',null),
  (6,'Announcements','Pastor Kayode Ogungbenro',null),
  (7,'Bible Reading','Sis Tinu Ibitoye','Passage TBC · not given in the order of service'),
  (8,'Sermon','Pastor Gbenga Adebanjo','The HEART: What It Comprises Of · sent as Pastor Gbenga Ogungbenro, confirm'),
  (9,'Offering',null,'Come and Let Us Sing · FLAG: not itemised in the order as sent, added in usual slot · no offering leader named'),
  (10,'Closing Prayer','Dns Janet Oviri',null),
  (11,'Benediction','Sister Petty',null))
insert into control_room_plan_speakers (plan_id, position, role, name, notes, image_id)
select p.id, sp.pos, sp.role, sp.name, sp.notes, case when sp.role = 'Sermon' then (select id from img) end
from p, sp;

-- Calvary OS service record
insert into cos_services (service_date, badge, preacher, sermon_title, sermon_subtitle, scripture, worship_leader,
                          order_of_service, songs, band, notes, thumbnail_url)
values ('2026-10-11', 'Sunday Service', 'Pastor Gbenga Adebanjo', 'The HEART: What It Comprises Of', null, 'TBC', null,
 '[{"n":1,"item":"Welcome & Bible Reading","type":"normal","assigned":"Pastor Kayode Ogungbenro"},
   {"n":2,"item":"Opening Prayer","type":"normal","assigned":"Sis Bukky Olowolagba"},
   {"n":3,"item":"Worship","type":"normal","assigned":"Worship Team"},
   {"n":4,"item":"Communion","type":"normal","assigned":"Pastor Kayode Ogungbenro"},
   {"n":5,"item":"Media Awareness","type":"normal","assigned":"Pastor Gbenga Adebanjo"},
   {"n":6,"item":"Announcements","type":"normal","assigned":"Pastor Kayode Ogungbenro"},
   {"n":7,"item":"Bible Reading","type":"highlight","notes":"Passage TBC","assigned":"Sis Tinu Ibitoye"},
   {"n":8,"item":"Sermon · The HEART: What It Comprises Of","type":"sermon","assigned":"Pastor Gbenga Adebanjo"},
   {"n":9,"item":"Offering · Come and Let Us Sing","type":"highlight","notes":"No offering leader named","assigned":null},
   {"n":10,"item":"Closing Prayer","type":"normal","assigned":"Dns Janet Oviri"},
   {"n":11,"item":"Benediction","type":"normal","assigned":"Sister Petty"}]'::jsonb,
 '[{"title":"This Is the Day (Fred Hammond)","lyrics":null,"section":"Praise"},
   {"title":"Come and Let Us Sing (Israel Houghton)","lyrics":null,"section":"Praise"},
   {"title":"I Know Who I Am (Sinach) OR Omemma (Chandler Moore)","lyrics":null,"section":"Praise"},
   {"title":"Wide as the Sky (Isabel Davis)","lyrics":null,"section":"Worship"},
   {"title":"Way Maker (Sinach)","lyrics":null,"section":"Worship"},
   {"title":"Your Presence Is Heaven (Israel Houghton)","lyrics":null,"section":"Worship"},
   {"title":"Come and Let Us Sing","lyrics":null,"section":"Offering"},
   {"title":"Way Maker","lyrics":null,"section":"End of Service"}]'::jsonb,
 '[]'::jsonb,
 'Same set as 4 Oct; five songs on file, Omemma placeholder. Song 3 choice pending. Bible reading passage not given. Preacher sent as Pastor Gbenga Ogungbenro, set as Pastor Gbenga Adebanjo pending confirmation. Offering leader not named. Thumbnail is the final ChatGPT version (v=2), modern editorial, Pastor Gbenga portrait P20.',
 'https://calvaryhephzibah.co.uk/sermon-thumbnail-11-oct-2026.jpg?v=2');

notify pgrst, 'reload schema';

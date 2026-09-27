-- ============================================================
-- 83_cos_service_27sep2026.sql
-- ============================================================
-- Calvary OS Sunday Service record for Sunday 27 Sep 2026
-- (cos_services). Distinct from 81 (Control Room setlist/speakers)
-- and 82 (sermon image). Idempotent.
-- ============================================================

delete from cos_services where service_date = '2026-09-27';

insert into cos_services (
  service_date, badge, preacher, sermon_title, sermon_subtitle, scripture,
  worship_leader, youtube_url, order_of_service, songs, band, notes, thumbnail_url
) values (
  '2026-09-27',
  'Sunday Service',
  'Bishop Henry Emmanuel',
  'Can Two Walk Together Except They Agree?',
  null,
  'Daniel 5:10-12 · Acts 11:25-26',
  null,
  null,
  '[
    {"n":1,"item":"Welcome & Bible Reading","type":"normal","assigned":"Ps Gbenga Adebanjo"},
    {"n":2,"item":"Opening Prayer","type":"normal","assigned":"Dr Caster Martins"},
    {"n":3,"item":"Worship","type":"normal","assigned":"Worship Team"},
    {"n":4,"item":"Communion","type":"normal","assigned":"Ps Kayode Ogungbenro"},
    {"n":5,"item":"Media Awareness","type":"normal","assigned":"Pastor Gbenga Adebanjo"},
    {"n":6,"item":"Announcements","type":"normal","assigned":"Pastor Kayode Ogungbenro"},
    {"n":7,"item":"Bible Reading","type":"highlight","notes":"Daniel 5:10-12 · Acts 11:25-26 (KJV)","assigned":"Sister Tash Campbell"},
    {"n":8,"item":"Sermon — Can Two Walk Together Except They Agree?","type":"sermon","assigned":"Bishop Henry Emmanuel · Guest Minister"},
    {"n":9,"item":"Offering — Give Thanks to the Lord","type":"highlight","notes":"No offering leader named","assigned":null},
    {"n":10,"item":"Closing Prayer","type":"normal","assigned":"Brother Ernest"},
    {"n":11,"item":"Benediction","type":"normal","assigned":"Ps Funke Adebanjo"}
  ]'::jsonb,
  '[
    {"title":"These Are the Days of Elijah","lyrics":null,"section":"Praise"},
    {"title":"Lord I Lift Your Name on High","lyrics":null,"section":"Praise"},
    {"title":"Open the Eyes of My Heart, Lord","lyrics":null,"section":"Praise"},
    {"title":"I Will Worship","lyrics":null,"section":"Worship"},
    {"title":"Heart of Worship","lyrics":null,"section":"Worship"},
    {"title":"Jesus at the Centre","lyrics":null,"section":"Worship"},
    {"title":"Give Thanks to the Lord","lyrics":null,"section":"Offering"},
    {"title":"Thank You Lord (Don Moen)","lyrics":null,"section":"End of Service"}
  ]'::jsonb,
  '[]'::jsonb,
  'READY FOR SERVICE. Same set as 20 Sep, all 8 songs resolved with lyrics. All keys TBC, set at soundcheck. Scripture Daniel 5:10-12 and Acts 11:25-26 loaded (Sister Tash Campbell). Sermon thumbnail is the final ChatGPT creative version (v=2), replacing a Claude placeholder. OUTSTANDING FLAG: Offering not itemised in the order as sent, no offering leader named.',
  'https://calvaryhephzibah.co.uk/sermon-thumbnail-27-sep-2026.jpg?v=2'
);

notify pgrst, 'reload schema';

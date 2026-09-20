-- ============================================================
-- 73_cos_service_20sep2026.sql
-- ============================================================
-- Logs the finished, ready-for-service record for Sunday 20 Sep 2026
-- into cos_services (the Calvary OS Sunday Service record table).
-- This is the "we are done, this is what's live" record -- distinct
-- from 71 (Control Room setlist/speakers) and 72 (sermon image
-- registration), which drive the live overlay during the service.
--
-- Idempotent: re-running replaces the row for this date cleanly.
-- ============================================================

delete from cos_services where service_date = '2026-09-20';

insert into cos_services (
  service_date, badge, preacher, sermon_title, sermon_subtitle, scripture,
  worship_leader, youtube_url, order_of_service, songs, band, notes, thumbnail_url
) values (
  '2026-09-20',
  'Sunday Service',
  'Bishop Henry Emmanuel',
  'Manifesting The Kingdom',
  null,
  'TBC',
  null,
  null,
  '[
    {"n":1,"item":"Welcome & Bible Reading","type":"normal","assigned":"Ps Shade Olatoye"},
    {"n":2,"item":"Opening Prayer","type":"normal","assigned":"Mummy Oso"},
    {"n":3,"item":"Worship","type":"normal","assigned":"Worship Team"},
    {"n":4,"item":"Communion","type":"normal","assigned":"Ps Gbenga Adebanjo"},
    {"n":5,"item":"Media Awareness","type":"normal","assigned":"Pastor Gbenga Adebanjo"},
    {"n":6,"item":"Announcements","type":"normal","assigned":"Pastor Kayode Ogungbenro"},
    {"n":7,"item":"Bible Reading","type":"highlight","notes":"Scripture TBC — not named in the order as sent","assigned":"Sister Petty"},
    {"n":8,"item":"Sermon — Manifesting The Kingdom","type":"sermon","assigned":"Bishop Henry Emmanuel · Guest Minister"},
    {"n":9,"item":"Offering — Give Thanks to the Lord","type":"highlight","notes":"No offering leader named","assigned":null},
    {"n":10,"item":"Closing Prayer","type":"normal","assigned":"Brother Ernest"},
    {"n":11,"item":"Benediction","type":"normal","assigned":"Deacon Femi Osipitan"}
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
  'READY FOR SERVICE. New Praise set this week (Days of Elijah, Lord I Lift Your Name on High, Open the Eyes of My Heart) — all resolved from the song library; Worship, Offering and End of Service carried over unchanged from 13 Sep. All keys TBC, set at soundcheck. Sermon thumbnail is the final ChatGPT creative version (Calvary logo composited in) — replaced two earlier Claude-built drafts. Media briefing, stage runthrough + OG card, and Control Room setlist/speakers/image are all live and verified on main (commit 56f6059). OUTSTANDING FLAGS: no scripture passage confirmed for the pre-sermon Bible Reading (Sister Petty); no offering leader named.',
  'https://calvaryhephzibah.co.uk/sermon-thumbnail-20-sep-2026.jpg?v=3'
);

notify pgrst, 'reload schema';

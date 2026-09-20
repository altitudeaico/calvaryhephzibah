-- ============================================================
-- 79_captions_20sep2026.sql
-- ============================================================
-- ChatGPT-written social captions for all 6 finished clips
-- (Instagram, TikTok, Facebook, YouTube Shorts), stored in
-- content_items.caption_draft. Clip 9 (Represent The King)
-- carries an explicit care note in its caption_draft confirming
-- it does not repeat "small gods" as a standalone claim.
--
-- Idempotent: re-running overwrites these fields cleanly.
-- ============================================================


update content_items
set caption_draft = 'TWO-BEAT ON-SCREEN HOOK: HE FELT SOMETHING. / HE COULDN''T EXPLAIN IT.

INSTAGRAM:
He couldn''t explain what he was experiencing.

Bishop Henry Emmanuel tells the story of a restaurant owner in Seattle who sensed something around him that he couldn''t understand.

For Bishop Henry, the lesson was simple. Following Jesus isn''t just about what we say. His presence should become visible in the way we live.

From Manifesting The Kingdom.

Watch the full sermon. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #ChristianFaith #Jesus #ChristianLiving

TIKTOK:
On-screen: he felt something. he couldn''t explain it.

a restaurant owner couldn''t explain what he sensed around Bishop Henry. his point? following Jesus should become visible in real life, not just in what we say.

from Manifesting The Kingdom. search YouTube Calvary Hephzibah.

what do you think people should notice in the life of someone who follows Jesus?

#christiantiktok #jesus #faith #calvaryhephzibah

FACEBOOK:
What should people experience when they encounter someone who follows Jesus?

Bishop Henry shares a remarkable personal story in Manifesting The Kingdom.

Worth 60 seconds. Search YouTube Calvary Hephzibah for the full sermon.

YOUTUBE SHORTS:
Title: He Couldn''t Explain What He Felt
Description: Bishop Henry shares a remarkable encounter and what it taught him about making Jesus visible through our lives. From Manifesting The Kingdom. Full sermon on our channel, search Calvary Hephzibah. #Shorts',
    cta = 'Watch the full sermon. Search YouTube Calvary Hephzibah.',
    platforms = ARRAY['instagram','tiktok','facebook','youtube_shorts'],
    editorial_status = 'draft'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 3
  );

update content_items
set caption_draft = 'TWO-BEAT ON-SCREEN HOOK: MORE THAN WORDS. / LET PEOPLE SEE IT.

INSTAGRAM:
What does God''s Kingdom actually look like in everyday life?

Bishop Henry puts it simply. It means allowing God''s ways and values to shape how we live, how we treat people and what happens around us.

It isn''t only something we talk about. People should be able to see the difference.

From Manifesting The Kingdom.

Watch the full sermon. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #KingdomOfGod #ChristianLiving #Faith

TIKTOK:
On-screen: more than words. let people see it.

what does God''s Kingdom actually look like? Bishop Henry says it should change the way we live and the way we affect the people around us.

from Manifesting The Kingdom. search YouTube Calvary Hephzibah.

what would that look like in your everyday life?

#christiantiktok #kingdomofgod #faith #calvaryhephzibah

FACEBOOK:
God''s Kingdom isn''t only something we talk about. It should change how we live and how we treat people.

From Manifesting The Kingdom.

Worth 60 seconds. Search YouTube Calvary Hephzibah for the full sermon.

YOUTUBE SHORTS:
Title: What Does God''s Kingdom Look Like?
Description: Bishop Henry explains what it means for God''s ways to become visible through everyday life. From Manifesting The Kingdom. Full sermon on our channel, search Calvary Hephzibah. #Shorts',
    cta = 'Watch the full sermon. Search YouTube Calvary Hephzibah.',
    platforms = ARRAY['instagram','tiktok','facebook','youtube_shorts'],
    editorial_status = 'draft'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 4
  );

update content_items
set caption_draft = 'TWO-BEAT ON-SCREEN HOOK: 40+ YEARS FOLLOWING JESUS. / STILL DEPENDENT ON HIM.

INSTAGRAM:
More than 40 years following Jesus, and he still says he can''t do it without the Holy Spirit.

That''s a powerful admission from Bishop Henry Emmanuel.

Growing in faith doesn''t mean reaching a point where you no longer need God''s help. If anything, maturity teaches you how much you still depend on Him.

From Manifesting The Kingdom.

Watch the full sermon. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #HolySpirit #ChristianFaith #Faith

TIKTOK:
On-screen: 40+ years following Jesus. still dependent on Him.

Bishop Henry has followed Jesus since 1980. after all those years, his message isn''t "i''ve got this." it''s that he still needs the Holy Spirit.

from Manifesting The Kingdom. search YouTube Calvary Hephzibah.

has growing in faith made you more or less aware of your need for God?

#christiantiktok #holyspirit #faith #calvaryhephzibah

FACEBOOK:
More than 40 years following Jesus, and Bishop Henry still says he needs the Holy Spirit.

Growth doesn''t make us independent from God.

From Manifesting The Kingdom.

Worth 60 seconds. Search YouTube Calvary Hephzibah for the full sermon.

YOUTUBE SHORTS:
Title: 40 Years Later, He Still Needs God
Description: Bishop Henry has followed Christ since 1980, but says he still cannot do it without the Holy Spirit. From Manifesting The Kingdom. Full sermon on our channel, search Calvary Hephzibah. #Shorts',
    cta = 'Watch the full sermon. Search YouTube Calvary Hephzibah.',
    platforms = ARRAY['instagram','tiktok','facebook','youtube_shorts'],
    editorial_status = 'draft'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 5
  );

update content_items
set caption_draft = 'TWO-BEAT ON-SCREEN HOOK: YOU TRAIN YOUR BODY. / TRAIN YOUR FAITH TOO.

INSTAGRAM:
You wouldn''t expect one gym session to keep you fit for life.

Bishop Henry uses 1 Timothy 4:8 to make a simple point. Our relationship with God needs regular attention too.

Prayer. Scripture. Learning to live what Jesus taught.

Growth takes practice.

From Manifesting The Kingdom.

Watch the full sermon. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #1Timothy48 #ChristianLiving #Faith

TIKTOK:
On-screen: you train your body. train your faith too.

one workout won''t keep your body fit forever. Bishop Henry says our faith needs regular exercise too.

1 Timothy 4:8. from Manifesting The Kingdom. search YouTube Calvary Hephzibah.

what''s one habit that helps keep your faith active?

#christiantiktok #bible #faith #calvaryhephzibah

FACEBOOK:
We understand that our bodies need regular exercise. Bishop Henry asks us to think about our faith the same way.

1 Timothy 4:8. From Manifesting The Kingdom.

Worth 60 seconds. Search YouTube Calvary Hephzibah for the full sermon.

YOUTUBE SHORTS:
Title: Train Your Faith Too | 1 Tim 4:8
Description: Physical fitness takes regular exercise, and Bishop Henry says our faith needs attention too. From Manifesting The Kingdom. Full sermon on our channel, search Calvary Hephzibah. #Shorts',
    cta = 'Watch the full sermon. Search YouTube Calvary Hephzibah.',
    platforms = ARRAY['instagram','tiktok','facebook','youtube_shorts'],
    editorial_status = 'draft'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 6
  );

update content_items
set caption_draft = 'TWO-BEAT ON-SCREEN HOOK: THEY ASKED HIS SECRET. / THERE WASN''T A TECHNIQUE.

INSTAGRAM:
They asked Bishop Henry for his secret.

How does he lead worship and see people respond so deeply to God?

His answer wasn''t a technique.

He waits on God. Then he sings what God puts on his heart.

Sometimes we''re looking for a formula when what we really need is time with God.

From Manifesting The Kingdom.

Watch the full sermon. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #Prayer #Worship #ChristianFaith

TIKTOK:
On-screen: they asked his secret. there wasn''t a technique.

people asked Bishop Henry how he leads worship with such impact. his answer wasn''t a formula. he waits on God and responds to what comes to his heart.

from Manifesting The Kingdom. search YouTube Calvary Hephzibah.

do we sometimes look for a technique when we really need time with God?

#christiantiktok #worship #prayer #calvaryhephzibah

FACEBOOK:
They asked Bishop Henry for his secret. His answer wasn''t another technique.

He waits on God.

From Manifesting The Kingdom.

Worth 60 seconds. Search YouTube Calvary Hephzibah for the full sermon.

YOUTUBE SHORTS:
Title: His Secret? Wait On God
Description: Bishop Henry was asked for his worship secret. His answer was not a technique, but time spent waiting on God. From Manifesting The Kingdom. Full sermon on our channel, search Calvary Hephzibah. #Shorts',
    cta = 'Watch the full sermon. Search YouTube Calvary Hephzibah.',
    platforms = ARRAY['instagram','tiktok','facebook','youtube_shorts'],
    editorial_status = 'draft'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 8
  );

update content_items
set caption_draft = 'TWO-BEAT ON-SCREEN HOOK: WHO DO YOU REPRESENT? / LET YOUR LIFE SHOW IT.
CARE NOTE: caption deliberately interprets this clip through representation/responsibility, never repeats "small gods" as a standalone claim -- matches the framing already required on the reel and carousel for this clip.

INSTAGRAM:
If you belong to God, what should that change about the way you live?

In Manifesting The Kingdom, Bishop Henry points to Psalm 82 and John 10:34 while speaking about our responsibility to represent God''s rule in the world.

The takeaway isn''t about giving ourselves impressive titles. It''s about responsibility.

If we belong to the King, our lives should increasingly reflect His ways.

Watch the full sermon in context. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #ChristianLiving #KingdomOfGod #Bible

TIKTOK:
On-screen: who do you represent? let your life show it.

this part of Bishop Henry''s message touches Psalm 82 and John 10:34. his wider challenge is about representation: if we belong to God, our lives should reflect His ways.

from Manifesting The Kingdom. search YouTube Calvary Hephzibah.

what does representing God well look like in ordinary life?

#christiantiktok #bible #kingdomofgod #calvaryhephzibah

FACEBOOK:
If we say we belong to God, what should people see in the way we live?

Bishop Henry''s challenge in Manifesting The Kingdom is about representing God''s ways, not simply carrying a title.

Worth 60 seconds. Search YouTube Calvary Hephzibah for the full sermon in context.

YOUTUBE SHORTS:
Title: What Does Representing God Mean?
Description: Bishop Henry draws from Psalm 82 and John 10:34 while challenging believers to reflect God''s ways through how they live. From Manifesting The Kingdom. Full sermon on our channel, search Calvary Hephzibah. #Shorts',
    cta = 'Watch the full sermon in context. Search YouTube Calvary Hephzibah.',
    platforms = ARRAY['instagram','tiktok','facebook','youtube_shorts'],
    editorial_status = 'draft'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 9
  );

notify pgrst, 'reload schema';
-- ============================================================
-- 80_captions_v2_approved_20sep2026.sql
-- ============================================================
-- Refined round of ChatGPT captions -- devotional/reflection voice
-- (strong hook, practical challenge, lands on Scripture and Jesus)
-- rather than describing the clip. Explicitly approved by Bolaji.
-- Stored in content_items.caption_final, editorial_status=approved.
-- Supersedes the v1 drafts in 79_captions_20sep2026.sql (kept as
-- caption_draft, unchanged, for the record).
--
-- Idempotent: re-running overwrites these fields cleanly.
-- ============================================================


update content_items
set caption_final = 'TWO-BEAT ON-SCREEN HOOK: YOUR LIFE SPEAKS BEFORE YOU DO.

INSTAGRAM / FACEBOOK:
Sometimes the loudest evidence of Jesus in your life won''t be what you say.

It will be what people experience around you.

Your patience when you could have snapped.
Your peace when everything says panic.
Your kindness when nobody can repay you.
Your integrity when nobody is watching.

Jesus said, "Let your light shine before others." Matthew 5:16.

That''s the challenge for today.

Don''t just tell people you follow Jesus. Ask God to keep changing you until something of Christ can be seen in the way you live.

Bishop Henry shares a remarkable personal story about this in Manifesting The Kingdom.

Watch the full message. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #Jesus #ChristianLiving #Faith

TIKTOK:
your life speaks before you do.

people may forget what you said about Jesus, but they''ll remember the patience, peace, kindness and integrity they experienced around you.

Matthew 5:16 says to let your light shine.

where could your life show Jesus more clearly today?

full message: Manifesting The Kingdom. search YouTube Calvary Hephzibah.

#christiantiktok #jesus #faith #calvaryhephzibah

YOUTUBE SHORTS TITLE: Your Life Speaks Before You Do
(No separate description given this round -- reuse the IG/FB copy''s first two lines if one is needed.)',
    editorial_status = 'approved'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 3
  );

update content_items
set caption_final = 'TWO-BEAT ON-SCREEN HOOK: DON''T JUST SAY IT. / LIVE IT.

INSTAGRAM / FACEBOOK:
Here''s a question worth carrying into today:

If somebody couldn''t hear what you believe, could they see it in how you live?

Jesus taught us to pray, "Your kingdom come, your will be done." Matthew 6:10.

That''s bigger than words.

It reaches into how you treat people.
How you handle pressure.
How you forgive.
How you serve.
How you make decisions when nobody is applauding.

God''s Kingdom isn''t something we manufacture. We submit to the King and allow His Word and Spirit to shape us.

So today''s prayer can be simple:

Lord, let Your will be done in me today.

From Bishop Henry Emmanuel''s message, Manifesting The Kingdom.

Watch the full sermon. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #KingdomOfGod #Jesus #ChristianLiving

TIKTOK:
don''t just say it. live it.

Jesus taught us to pray, "Your kingdom come, your will be done."

what if today that prayer starts with us?

our attitude. our choices. our relationships. our response when life gets difficult.

where does God need to shape the way you''re living today?

from Manifesting The Kingdom. search YouTube Calvary Hephzibah.

#christiantiktok #kingdomofgod #jesus #calvaryhephzibah

YOUTUBE SHORTS TITLE: Don''t Just Say It. Live It.
(No separate description given this round.)',
    editorial_status = 'approved'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 4
  );

update content_items
set caption_final = 'TWO-BEAT ON-SCREEN HOOK: GROWTH DOESN''T MEAN / YOU NEED GOD LESS.

INSTAGRAM / FACEBOOK:
One of the greatest signs of spiritual maturity is realising you never graduate from needing God.

Bishop Henry has been walking with Christ since 1980.

More than four decades later, he still says he cannot do this without the Holy Spirit.

That''s not weakness.

That''s dependence.

Jesus told His disciples, "Apart from me you can do nothing." John 15:5.

Sometimes growth can make us confident in what we know, what we''ve survived and what we''ve done before.

But yesterday''s experience was never meant to replace today''s dependence on God.

So before you rush into this week saying, "I''ve got this," try another prayer:

"Holy Spirit, I need You today."

From Manifesting The Kingdom, Bishop Henry Emmanuel.

Watch the full message. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #HolySpirit #ChristianFaith #Jesus

TIKTOK:
the longer you walk with God, the more you realise you still need Him.

Bishop Henry has followed Christ since 1980 and still says he can''t do this without the Holy Spirit.

Jesus said, "apart from me you can do nothing." John 15:5.

what are you trying to carry today without asking God for help?

full message: Manifesting The Kingdom. search YouTube Calvary Hephzibah.

#christiantiktok #holyspirit #jesus #calvaryhephzibah

YOUTUBE SHORTS TITLE: You Never Outgrow Needing God
(No separate description given this round.)',
    editorial_status = 'approved'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 5
  );

update content_items
set caption_final = 'TWO-BEAT ON-SCREEN HOOK: WHAT YOU TRAIN / GETS STRONGER.

INSTAGRAM / FACEBOOK:
Nobody goes to the gym once and says, "That''s me sorted for life."

Strength comes through repetition.

Scripture gives us a similar picture of our spiritual lives.

"Train yourself for godliness." 1 Timothy 4:7.

You don''t accidentally build a strong walk with God.

You pray when you feel like it and when you don''t.
You keep opening Scripture.
You keep practising forgiveness.
You keep choosing obedience.
You keep showing up.

Not to earn God''s love. Jesus has already done what we could never do for ourselves.

We train because we want our lives to increasingly reflect the One who saved us.

So don''t be discouraged because you''re still growing.

Keep training.

From Manifesting The Kingdom, Bishop Henry Emmanuel.

Watch the full message. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #Bible #ChristianLiving #Faith

TIKTOK:
what you train gets stronger.

you wouldn''t expect one workout to transform your body. so why expect one prayer, one sermon or one Bible study to mature your faith?

1 Timothy 4 tells us to train ourselves for godliness.

not to earn God''s love. because we already belong to Him.

what spiritual habit are you training this week?

full message: Manifesting The Kingdom. search YouTube Calvary Hephzibah.

#christiantiktok #bible #faith #calvaryhephzibah

YOUTUBE SHORTS TITLE: What You Train Gets Stronger
(No separate description given this round.)',
    editorial_status = 'approved'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 6
  );

update content_items
set caption_final = 'TWO-BEAT ON-SCREEN HOOK: STOP LOOKING FOR / THE FORMULA.

INSTAGRAM / FACEBOOK:
We love formulas.

Give me the five steps.
Tell me the technique.
Show me what worked for you.

But some things cannot be reduced to a formula.

People asked Bishop Henry about the "secret" behind moments of powerful worship.

His answer was beautifully simple.

Wait on God.

Jesus Himself regularly withdrew to pray. Luke 5:16.

Before another strategy, another technique or another attempt to force an answer, perhaps what you need today is simply to make room for God.

Put the phone down.

Quiet the noise.

Open the Word.

Pray.

And don''t rush away because nothing happened in the first five minutes.

Sometimes the next step becomes clearer when we stop trying to manufacture it.

From Manifesting The Kingdom, Bishop Henry Emmanuel.

Watch the full message. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #Prayer #Worship #Jesus

TIKTOK:
stop looking for the formula.

sometimes we want five steps when what we actually need is time with God.

Jesus regularly withdrew to pray. Luke 5:16.

before you rush into the next thing today, where could you make a little room to be still with God?

from Manifesting The Kingdom. search YouTube Calvary Hephzibah.

#christiantiktok #prayer #jesus #calvaryhephzibah

YOUTUBE SHORTS TITLE: Stop Looking for the Formula
(No separate description given this round.)',
    editorial_status = 'approved'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 8
  );

update content_items
set caption_final = 'TWO-BEAT ON-SCREEN HOOK: PEOPLE ARE WATCHING / HOW YOU LIVE.
CARE NOTE (unchanged from v1): deliberately does not make Psalm 82 the devotional proposition. Lands on 2 Corinthians 5:20 (ambassadors of Christ) instead -- never frames believers as "small gods." Video should carry Bishop Henry''s teaching in context; the caption reframes around representation.

INSTAGRAM / FACEBOOK:
Here''s something worth remembering today:

You represent Jesus in places a preacher may never reach.

At work.

At home.

In the group chat.

In the disagreement.

In the way you treat the person who can do absolutely nothing for you.

Paul writes, "We are therefore Christ''s ambassadors." 2 Corinthians 5:20.

An ambassador doesn''t go somewhere to build their own kingdom. They represent the one who sent them.

That''s a powerful way to think about your Monday morning.

You don''t need a platform to represent Jesus.

You already have a place.

The question is what people are seeing there.

This week''s message, Manifesting The Kingdom, explores what it means for God''s rule to become visible through His people.

Watch the full sermon in context. Search YouTube Calvary Hephzibah.

#CalvaryHephzibah #ChristianLiving #Jesus #KingdomOfGod

TIKTOK:
you represent Jesus in places a preacher may never reach.

work. home. friendships. difficult conversations.

2 Corinthians 5:20 calls believers Christ''s ambassadors.

you don''t need a platform. you already have a place.

what would representing Jesus well look like where you are today?

full message: Manifesting The Kingdom. search YouTube Calvary Hephzibah.

#christiantiktok #jesus #faith #calvaryhephzibah

YOUTUBE SHORTS TITLE: You Already Have a Place to Serve
(No separate description given this round.)',
    editorial_status = 'approved'
where sermon_id = (select id from sermons where service_date = '2026-09-20')
  and content_type = 'clip'
  and source_clip_id = (
    select id from sermon_clips
    where sermon_id = (select id from sermons where service_date = '2026-09-20') and rank = 9
  );

notify pgrst, 'reload schema';
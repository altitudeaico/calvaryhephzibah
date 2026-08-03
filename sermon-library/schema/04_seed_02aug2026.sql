-- ============================================================
-- 04_seed_02aug2026.sql - Sunday 2 August 2026 sermon
-- "Family Altar" (Dr Titi Sodipo, guest) - ALTARS series
-- Run after 01_schema.sql.
--
-- >> READ THE `notes` COLUMN IN PART 1 BEFORE USING THIS RECORD.
-- >> Source is the preacher's SLIDE DECK, not a transcript, and two
-- >> personal family testimonies have been redacted for privacy.
--
-- WHY THIS IS SPLIT INTO FOUR PARTS
-- Earlier seeds were one big CTE. That is fine when the file is pasted
-- from disk, but it truncates when copied out of a chat window, and a
-- half-copied statement fails with "unterminated quoted string". Each
-- part below is a self-contained statement under ~10k characters, so
-- they can be pasted and run one at a time. Run them IN ORDER.
--
-- Strings are kept on ONE physical line (full_text is an E'' string
-- with \n escapes). The Supabase dashboard editor splits pasted input
-- on newlines inside string literals. Keep it that way.
--
-- Idempotent: every part deletes before it inserts.
-- Supabase project: pfycvgbrsbecznkcikwt
-- ============================================================


-- ============================================================
-- PART 1 of 4 - the sermon row
-- ============================================================

delete from sermons where service_date = '2026-08-02' and title = 'Family Altar';

insert into sermons (service_date, title, preacher, is_guest, occasion, series, anchor_scripture, thesis, summary, youtube_url, notes)
values (
  '2026-08-02',
  'Family Altar',
  'Dr Titi Sodipo',
  true,
  null,
  'ALTARS',
  'Genesis 18:19',
  'The family altar is where the household meets with God, and it is the parents'' job, not the church''s, to build it. Abraham was chosen because he would direct his children to keep the way of the Lord, and the promise followed the training.',
  'Guest minister Dr Titi Sodipo teaches on the family altar: what it is, why it matters, and how to actually run one. An altar is where the spiritual realm meets people on earth, so a family altar is where the Lord Jesus meets the household (Matthew 18:20). She grounds the why in God''s testimony of Abraham (Genesis 18:19) - he will direct his sons and their families to keep the way of the Lord, and THEN God will do all He promised - and adds three further reasons: the protection and blessing that surround a God-fearing household (Job 1:8-10, Psalm 91:9-11), generational faith that does not outsource itself to Sunday school (2 Timothy 1:5), and the chance to impart wisdom for living. The goals are that the household be saved (Romans 10:9,14-15) and trained in godliness (Romans 12:1). Most of the teaching is practical: involve the whole household, pick a workable time, keep it interactive, do not let it replace personal quiet time, and approach Scripture open-minded and ready to obey. She compares five ways to study the Bible with the advantages and disadvantages of each, gives her own family''s practice across four life stages, and sets out how to maximise the benefit - worship, discussion, memorisation, demonstrating obedience so the children watch you obey, prayer, testimony and fasting. She closes on training children into personal quiet time (Proverbs 22:6) and the four training steps, and lands on Galatians 4:19: keep interceding until Christ is fully formed in them.',
  null,
  'SOURCE: the preacher''s own slide deck, supplied as a PDF by Bolaji on 2 August 2026. This is NOT a transcript - it is her prepared notes, so it carries the structure and scriptures but not what she actually said on the day, the illustrations she ad-libbed, or the altar call. If a service recording is transcribed later, replace full_text and keep these notes as the outline. NAME: the deck bylines her as ''Titilade Sodipo''; the run sheet, thumbnail and YouTube all use ''Dr Titi Sodipo''. Kept consistent with the public-facing assets. DECK TITLE: ''Family Altars at Calvary Hephzibar church'' (sic - Hephzibar). Public/caption title is ''Family Altar'' per the run sheet and YouTube. SCRIPTURE DISCREPANCY: the deck header cites Genesis 18:16-19, but the reading given for the service, and what was seeded to the Control Room, was Genesis 18:18-19. The verse she actually exposits is v19. Worth confirming which was read. TRANSLATION: the deck quotes NLT throughout; the Control Room pushed KJV. PSALM REFERENCE: the deck labels the ''no evil will conquer you'' passage as Psalm 81:9-11; the text quoted is Psalm 91:9-11. Corrected here. PRIVACY: two personal testimonies about her own household, one involving a family member''s medical episode, have been REDACTED from full_text. This table is readable by anyone holding the public anon key, and health information about an identifiable person is special category data under UK GDPR. Do not add them back without her consent and a decision on whether this table should stay anon-readable.'
);


-- ============================================================
-- PART 2 of 4 - the sermon body (one long E'' string, own statement)
-- ============================================================

update sermons
   set full_text = E'PREACHER''S OWN SLIDE NOTES (not a transcript).\n\nWHAT IS A FAMILY ALTAR?\nAn altar is a sacred place at which the spiritual realm meets with, or manifests to, humans on earth. So a family altar for the Christian home is a place where the Lord Jesus meets with the family. Jesus promised it: Matthew 18:20, where two or three gather together as my followers, I am there among them.\n\nWHY IS A FAMILY ALTAR IMPORTANT?\nGod''s testimony of Abraham, Genesis 18:19: I have singled him out so that he will direct his sons and their families to keep the way of the Lord by doing what is right and just. Then I will do for Abraham all that I have promised.\n1) Abraham would direct his sons and their families to do what is right and just: training in faith and godly living.\n2) THEN God would do for Abraham all He had promised.\n\nBECAUSE MEMBERSHIP HAS ITS BENEFITS\nJob 1:8-10. Satan''s own complaint is the evidence: You have always put a wall of protection around him and his home and his property. Psalm 91:9-11: if you make the Most High your shelter, no evil will conquer you, no plague will come near your home, He will order his angels to protect you wherever you go.\nSo why does evil befall many believers? God allows some for a purpose: evil befell Job, but God restored and blessed him at the end. For some, it is necessary for us to resist the devil until he flees, to police the promise of God onto us.\n\nBECAUSE GENERATIONAL FAITH IS DESIRABLE AND IT BEGINS WITH US\n3) That they might be discipled to teach and disciple others, and that generations might know the Lord. Do not depend solely on Sunday school or the church to train your children. 2 Timothy 1:5: the faith that first filled your grandmother Lois and your mother Eunice continues strong in you.\n4) That they should gain wisdom for living: a focused opportunity to impart wisdom. Ecclesiastes 10:10, using a dull axe requires great strength, so sharpen the blade; that is the value of wisdom. Proverbs 31, the sayings of King Lemuel, which his mother taught him.\n\nWHAT COULD BE THE GOALS FOR A FAMILY ALTAR?\nThe goal is to train in godliness, and to ensure every member of the family hears and understands the good news.\n1) That they might be saved. Romans 10:14-15, how can they hear about him unless someone tells them. Romans 10:9, if you openly declare that Jesus is Lord and believe in your heart that God raised him from the dead, you will be saved.\n2) That they might be trained in godliness. Romans 12:1, give your bodies to God as a living and holy sacrifice. Proverbs 10:6-8, the wise are glad to be instructed.\n\nHOW IS THE FAMILY ALTAR BEST DONE? PRACTICAL PRINCIPLES\n1) Involve the whole family, including those staying with you or visiting: your whole household.\n2) Choose a time that works for all. Daily or three times a week? Morning, or evening after supper?\n3) Ensure it does not replace individual quiet time.\n4) Ensure it is interactive. Encourage everyone to read the scriptures, contribute to discussion, and where appropriate to lead, especially from their teenage years.\n\nHOW IS IT BEST DONE? POSTURE\n1) Approach God in reverence. What it means to honour God and to love God.\n2) Attitude to scripture.\n   a) Be open minded. 2 Timothy 3:16-17, all Scripture is inspired by God and is useful to teach us what is true and to make us realise what is wrong in our lives. Acts 17:11, the Bereans listened eagerly and searched the Scriptures day after day to see if it was true.\n   b) Have a mindset to obey. John 15:10-11, when you obey my commandments you remain in my love, so that you will be filled with my joy.\n\nPOSSIBLE WAYS TO STUDY THE BIBLE\n1) Use a study guide, e.g. Every Day with Jesus.\n   Advantage: the outline, passages and commentary are prepared for you, so it is easier for whoever is leading.\n   Disadvantage: it may not give the family an overview and understanding of Scripture as a whole and of the different books.\n2) Study topics, e.g. faith, obedience, baptisms, prayer, holiness, the Holy Spirit.\n   Advantage: step by step training in walking with the Lord and living a victorious life; can cover doctrine and life issues. Hebrews 6:1-2 as the example of foundational teaching.\n   Disadvantage: it can be difficult to gain a holistic understanding of Scripture.\n3) Study different books of the Bible, with different people suggesting which book is next.\n   Advantage: it builds understanding of whole books, which removes the danger of taking a verse out of context and falling into error. It feeds solid meat and not only milk, Hebrews 5:12-14. Example: some use Galatians 3 to preach pure grace, as though it does not matter how you live, but Galatians 3:1-3 and Galatians 5:16-21 read together do not allow that.\n   Disadvantage: some books are long, e.g. Ezekiel with 48 chapters. Better suited where the household are adults.\n4) Study the whole Bible sequentially, Genesis to Revelation.\n   Advantage: it shows how the whole Bible fits together.\n   Disadvantage: length again; better suited where the household are adults.\n5) A mix of the above.\n   Advantage: the family gets the benefit of all the methods.\n   Disadvantage: it can be hard to keep track of what has and has not been covered.\n\nHER OWN PRACTICE OVER THE YEARS\nDifferent methods at different stages: read through the Bible in a year when first married with no children yet; Bible guides when the children were young, easy to follow and less preparation; study guides for teens for personal quiet time in the morning plus topical family altar in the evening when they were teenagers; now that all at home are adults, book by book.\n\nHOW TO MAXIMISE THE BENEFIT\n1) Worship and praise. Enter His gates with thanksgiving. A song, or an opening prayer acknowledging who God is and asking the Holy Spirit''s help to gain insight into the Word.\n2) Reading Scripture matters, and so does discussing the learning points and how to apply them today. The Big Life Discovery Bible Study approach asks: What do you like in the passage? What is difficult or challenging? What do we learn about God? What do we learn about people, or about yourself?\n3) Encourage members to commit Scripture to memory. Illustrated with the book The Heavenly Man.\n4) Application can be demonstrated by doing it. They watch us obey the Bible. When you read about being born again, invite members who want to give their lives to Christ; children may do it over and over, and that is okay. When you read about baptism in water, you can baptise in the bath. When you read about baptism in the Holy Spirit, pray for your family to be baptised in the Spirit, or ask the pastor to. When you read about being fishers of men, testify how you have done it, and perhaps do it together in your neighbourhood as a family. Allow them to pray over us too.\n5) Prayer and testimonies are very important. Prayer is two way communication, talking and listening to God. Philippians 4:6, do not worry about anything, instead pray about everything. Pray for grace to apply the Word daily, for individual needs and life challenges, and as a family for family challenges. It is sometimes useful to share those challenges with the children as a family.\n6) Sometimes fasting should be encouraged at family level.\n[Two personal family testimonies were given here from the preacher''s own household. Details withheld from this record; see the original deck.]\n\nINDIVIDUAL QUIET TIME\nProverbs 22:6, direct your children onto the right path, and when they are older they will not leave it.\n1) As soon as they learn to read and write, train them to have a quiet time. There are Bible guides for children and for teenagers.\n2) They can start to read stories in the Bible and memorise passages.\n3) Training is not the same as telling. The four training steps: you do it and they watch; you do it together; they do it and you watch; they do it on their own.\n\nSUMMARY\n1) The family altar is where we as a household meet with our Heavenly Father, learn about Him, His ways and His will for us. It is where we are trained in godliness and where we bring our requests to God.\n2) There are different possible ways. Choose the time and method to suit the age groups in the household, bearing in mind the advantages and disadvantages of each.\n3) Whatever method is adopted should make room both for laying foundational truths, Hebrews 6:1, and for growing in the Spirit by considering the meat of the Word.\n4) Obedience and application of the Word in daily living is critical. Let them watch you obey God''s Word too: being born again, baptism in water, baptism in the Holy Spirit, praying in times of trouble.\n5) Train them to lead the session, to prepare them to train the next generation and be a disciple too.\n6) Train them on the issues of life.\n7) Train them to memorise the Word of God.\n\nFINALLY: LET US CONTINUE TO INTERCEDE FOR THEM UNTIL\nGalatians 4:19, Oh, my dear children! I feel as if I am going through labour pains for you again, and they will continue until Christ is fully developed in your lives.\nLET US PRAY.'
 where service_date = '2026-08-02' and title = 'Family Altar';


-- ============================================================
-- PART 3 of 4 - the 12-point outline
-- ============================================================

delete from sermon_points where sermon_id = (select id from sermons where service_date = '2026-08-02' and title = 'Family Altar');

insert into sermon_points (sermon_id, position, heading, detail, scriptures)
values
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 1, 'What a family altar is', 'An altar is a sacred place where the spiritual realm meets or manifests to people on earth. A family altar is therefore where the Lord Jesus meets with the household. Jesus promised His presence wherever two or three gather as His followers.', '{"Matthew 18:20"}'::text[]),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 2, 'Why it matters: God chose Abraham because he would train his household', 'Genesis 18:19 is the pattern. God singled Abraham out so that he would direct his sons and their families to keep the way of the Lord by doing what is right and just - and THEN God would do all He had promised. The training comes first, the promise follows.', '{"Genesis 18:19"}'::text[]),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 3, 'Membership has its benefits: the hedge around a God-fearing home', 'Satan''s own complaint about Job is the evidence - a wall of protection around him, his home and his property. Psalm 91 promises that no evil will conquer and no plague come near the home of the one who shelters in the Most High. On why evil still befalls believers: some God allows for a purpose, as with Job who was restored and blessed at the end; some must be resisted until the devil flees, policing God''s promise onto our lives.', '{"Job 1:8-10","Psalm 91:9-11"}'::text[]),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 4, 'Generational faith begins with us, not with Sunday school', 'The household is discipled so they can teach and disciple others, and so that generations know the Lord. Do not depend solely on Sunday school or the church to train your children. Timothy''s faith came through Lois and Eunice before it was his own. The altar is also a focused opportunity to impart wisdom for living.', '{"2 Timothy 1:5","Ecclesiastes 10:10","Proverbs 31:1-3"}'::text[]),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 5, 'The goals: that they be saved, and trained in godliness', 'They cannot believe in one they have never heard about, and someone must tell them. Confess Jesus as Lord and believe God raised Him, and you are saved. Beyond salvation, the aim is training in godliness - offering the body to God as a living and holy sacrifice, and being the kind of person who is glad to be instructed.', '{"Romans 10:14-15","Romans 10:9","Romans 12:1","Proverbs 10:6-8"}'::text[]),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 6, 'Practical principles for running it', 'Involve the whole household, including anyone staying or visiting. Choose a time that works for everyone - daily or three times a week, morning or after supper. Do not let it replace individual quiet time. Keep it interactive: everyone reads, everyone contributes, and from the teenage years they take turns leading.', '{}'::text[]),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 7, 'Posture: reverence, an open mind, and a mind to obey', 'Approach God in reverence, knowing what it means to honour and love Him. Come to Scripture open-minded, as the Bereans searched daily to check what they were taught, holding that all Scripture is God-breathed and corrects us. And come with a mindset to obey, because obedience is how we remain in His love and how joy overflows.', '{"2 Timothy 3:16-17","Acts 17:11","John 15:10-11"}'::text[]),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 8, 'Five ways to study the Bible, with the trade-offs of each', 'A study guide is easiest for whoever is leading but gives little overview of Scripture as a whole. Topical study trains step by step in doctrine and life issues but makes a holistic picture harder. Book by book protects against pulling verses out of context and feeds solid meat rather than milk - she cites the misuse of Galatians 3 to preach a grace that ignores how you live, which Galatians 5 will not permit - but long books suit adult households better. Sequential Genesis to Revelation shows how it all fits together, with the same length problem. A mix gives the benefit of all, at the cost of keeping track.', '{"Hebrews 6:1-2","Hebrews 5:12-14","Galatians 3:1-3","Galatians 5:16-21"}'::text[]),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 9, 'Her own household across four stages', 'Read through the Bible in a year when newly married with no children. Bible guides when the children were young - easy to follow, less preparation. Study guides for teens for personal morning quiet time, plus a topical family altar in the evening, when they were teenagers. Book by book now that everyone at home is an adult.', '{}'::text[]),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 10, 'How to maximise the benefit', 'Open with worship or praise and ask the Holy Spirit for insight. Discuss and apply, not just read - the Discovery Bible Study questions: what do you like, what is difficult, what do we learn about God, what do we learn about people or yourself. Encourage memorisation. Demonstrate obedience so they watch you obey: invite them to give their lives to Christ when you read about being born again, baptise in the bath when you read about baptism, pray for the baptism of the Holy Spirit, testify about evangelism and do it together as a family, and let them pray over you too. Make room for prayer, testimony and sometimes family fasting.', '{"Philippians 4:6"}'::text[]),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 11, 'Train them into personal quiet time - and training is not telling', 'Direct children onto the right path and they will not leave it when they are older. As soon as they can read and write, train them into a quiet time using children''s and teen guides; let them read the stories and memorise passages. Training is not the same as telling. The four steps: you do it and they watch; you do it together; they do it and you watch; they do it on their own.', '{"Proverbs 22:6"}'::text[]),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 12, 'Keep interceding until Christ is formed in them', 'The closing charge. Paul travails in labour pains again for his spiritual children, and those pains continue until Christ is fully developed in their lives. Parents do not stop interceding when the children grow up.', '{"Galatians 4:19"}'::text[]);


-- ============================================================
-- PART 4 of 4 - scriptures, clip candidates, tags, and verify
-- ============================================================

delete from sermon_scriptures where sermon_id = (select id from sermons where service_date = '2026-08-02' and title = 'Family Altar');

insert into sermon_scriptures (sermon_id, reference, book, chapter, verse_start, verse_end, role)
values
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Genesis 18:18-19', 'Genesis', 18, 18, 19, 'anchor'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Galatians 4:19', 'Galatians', 4, 19, 19, 'anchor'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Matthew 18:20', 'Matthew', 18, 20, 20, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Job 1:8-10', 'Job', 1, 8, 10, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Psalm 91:9-11', 'Psalm', 91, 9, 11, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), '2 Timothy 1:5', '2 Timothy', 1, 5, 5, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Ecclesiastes 10:10', 'Ecclesiastes', 10, 10, 10, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Romans 10:9', 'Romans', 10, 9, 9, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Romans 10:14-15', 'Romans', 10, 14, 15, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Romans 12:1', 'Romans', 12, 1, 1, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Proverbs 10:6-8', 'Proverbs', 10, 6, 8, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), '2 Timothy 3:16-17', '2 Timothy', 3, 16, 17, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Acts 17:11', 'Acts', 17, 11, 11, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'John 15:10-11', 'John', 15, 10, 11, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Hebrews 6:1-2', 'Hebrews', 6, 1, 2, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Hebrews 5:12-14', 'Hebrews', 5, 12, 14, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Galatians 3:1-3', 'Galatians', 3, 1, 3, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Galatians 5:16-21', 'Galatians', 5, 16, 21, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Philippians 4:6', 'Philippians', 4, 6, 6, 'supporting'),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 'Proverbs 22:6', 'Proverbs', 22, 6, 6, 'supporting');

delete from sermon_clips where sermon_id = (select id from sermons where service_date = '2026-08-02' and title = 'Family Altar');

insert into sermon_clips (sermon_id, rank, hook, theme, timestamp_hint, platforms, status, care_flag, care_note)
values
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 1, 'Don''t depend on Sunday school to train your children', 'parenting / discipleship', null, '{reel,short,tiktok}'::text[], 'to_caption', false, null),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 2, 'Training is not the same as telling: you do it and they watch, you do it together, they do it and you watch, they do it alone', 'how to train children', null, '{reel,carousel}'::text[], 'to_caption', false, null),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 3, 'When you read about baptism, you can baptise in the bath', 'faith at home / obedience', null, '{reel,short}'::text[], 'to_caption', false, null),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 4, 'God chose Abraham because he would train his household - and THEN the promise came', 'Genesis 18:19', null, '{reel,short}'::text[], 'to_caption', false, null),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 5, 'Keep interceding until Christ is fully formed in them', 'praying for your children', null, '{reel,short,tiktok}'::text[], 'to_caption', false, null),
    ((select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), 6, 'Personal family testimonies from the preacher''s own household', 'testimony', null, '{reel}'::text[], 'to_caption', true, 'Preacher''s own family stories, one involving a family member''s health. Detail deliberately not recorded here. Written consent from the preacher required before clipping or publishing, and external comms approval per Governance section 11.');

insert into sermon_tags (name) values ('family altar'),('discipleship'),('parenting'),('prayer'),('bible study'),('altars'),('generational faith')
on conflict (name) do nothing;

insert into sermon_tag_map (sermon_id, tag_id)
select (select id from sermons where service_date = '2026-08-02' and title = 'Family Altar'), t.id from sermon_tags t
where t.name in ('family altar','discipleship','parenting','prayer','bible study','altars','generational faith')
on conflict do nothing;

-- VERIFY - expect 12 points, 20 scriptures, 6 clips, full_text NOT null
select service_date, title, preacher, series, anchor_scripture,
  length(full_text) as full_text_chars,
  (select count(*) from sermon_points p     where p.sermon_id = s.id) as points,
  (select count(*) from sermon_scriptures x where x.sermon_id = s.id) as scriptures,
  (select count(*) from sermon_clips c      where c.sermon_id = s.id) as clips
from sermons s where service_date = '2026-08-02';

-- Clips needing consent before they go anywhere
select rank, hook, care_note from sermon_clips c
join sermons s on s.id = c.sermon_id
where s.service_date = '2026-08-02' and c.care_flag;

-- Search smoke test
select service_date, title, preacher from search_sermons('family altar');

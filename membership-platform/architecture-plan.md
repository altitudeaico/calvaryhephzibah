# Calvary Portal — Architecture & Phasing Plan
**Address:** `portal.calvaryhephzibah.co.uk`
**Public-facing name:** "Calvary Hephzibah" or "Calvary Connect" (not "portal" or "membership" in any button or heading a visitor sees)
**Prepared by:** Claude, for Bolaji Olatoye (Chief of Staff)
**Date:** 2 September 2026
**Status:** Proposal for review — nothing here has been built yet

---

## A naming correction from the first draft

This was originally scoped as a "membership platform." That framing is dropped. "Membership"
implies someone has to formally join the church before they can access anything, which
works directly against the online-campus goal — someone should be able to explore a sermon
or a study guide with zero friction, no account, no sense of being kept outside a locked
door. The main church website stays the public front door; this portal is the deeper layer
behind it that existing tools gradually move into, not a gate in front of the church.

---

## Why this document exists

You asked for one login, serving both the congregation and the internal team, backed by
real accounts synced to GHL, mapped out in phases rather than built module-by-module ad hoc.
This is that map. Everything below is a proposal to react to, not a finished decision.

---

## 1. The honest current state

### GitHub: ~30 independent surfaces, one repo
Calvary OS, The Bridge, Control Room, the giving portal, Rehearsal Studio, sermon-library,
study-notes, two sermon-series microsites, nine months of weekly set-runthrough pages,
anniversary tooling. Each was built as its own static site, at its own time. Several have
their own design system. None share navigation, and critically, **none share a login.**

### Supabase: 51 tables, three separate user tables that don't know about each other
`bridge_users` (1 row), `bridge_users_v2` (4 rows), `control_room_users` (2 rows). Someone
who has a Bridge login and a Control Room login is two unrelated database rows today, with
no link between them. There is no single answer to "who is this person" anywhere in the
system.

### 🔴 A live security issue, found while compiling this inventory
15 tables have Row-Level Security disabled, fully readable and writable by anyone holding
the public anon key, which sits in plain text in `control-room/index.html`. This includes
`control_room_stills`, `social_capability`, `content_studio_projects`, and most of the live
overlay tables. This is not part of the membership project, but it becomes urgent the
moment we're asking people to create real accounts on this infrastructure — a membership
platform on a foundation with unlocked tables is not something to launch. This needs a
decision (which tables get which policies) before or alongside Phase 0, not after.

---

## 2. Proposed architecture

### One identity, everywhere
A single `profiles` table in Supabase, linked 1:1 to Supabase's built-in `auth.users`
(real email/password or magic-link accounts, not PINs). Every existing PIN-based login
(Calvary OS, Control Room, The Bridge) gets migrated to authenticate against this one
table instead of its own local one.

```
profiles
  id              uuid, references auth.users(id)
  full_name       text
  email           text
  phone           text
  ghl_contact_id  text          -- link to the matching GHL contact
  roles           text[]        -- e.g. {}, {volunteer, media}, {staff, admin}
  joined_at       timestamptz
  last_synced_at  timestamptz   -- last successful GHL sync
```

**Roles, not separate apps.** Anyone with an account can see "My Church" — that's the
default, not a role. Team-area access is additive on top: `{volunteer, media}` unlocks
Control Room and the media tools; `{staff}` or `{admin}` unlocks The Bridge and governance
material. The same login that gets a congregant into their giving history gets a media
volunteer into Control Room, if their roles include it — one identity, not one identity
per system.

### GHL as the contact record, Supabase as the login
GHL already holds (or should hold) the canonical contact record — it's already your CRM,
already does SMS/email, already has pipelines. Supabase Auth handles the actual login
security. The two stay in sync via a Supabase Edge Function (same pattern already used for
the giving portal's `stripe-webhook`):

- **On sign-up:** call GHL's `get-duplicate-contact` (searches by email/phone) to check for
  an existing contact. If found, link `ghl_contact_id`. If not, call `create-contact` to
  make one.
- **On profile update:** push changes to GHL via `update-contact`, so the CRM record and the
  login record don't drift apart.
- **This is not hypothetical** — I checked GHL's actual API surface before writing this;
  `create-contact`, `update-contact`, and `get-duplicate-contact` are real, already-available
  operations through the connected GHL MCP.

### One shell, role-gated modules
Rather than ~30 separate sites, one app shell (same pattern Calvary OS already uses:
`shell.css`/`shell.js` loaded by every page) with a nav that only shows what a signed-in
person's roles unlock. Existing pages don't need a full rewrite — most can keep their
current HTML/CSS and just switch their auth check from a local PIN table to the shared
`profiles`/`auth.users` check.

---

## 3. Three areas, one portal, access by role

| Area | Who it's for | What lives there | Sign-in required? |
|---|---|---|---|
| **Explore** | Everyone | Sermons, study guides, shareable posts, events, church info | No — zero friction, this is the online-campus front door |
| **My Church** | Anyone who creates an account | Saved study answers synced across devices, community participation, personal updates, giving history | Yes — real account |
| **Team** | Authorised volunteers, staff, leaders | Worship notes, rotas, media tools, Control Room, Rehearsal Studio, internal/governance resources | Yes — real account, `volunteer`/`staff`/`admin` role required |

This replaces the earlier two-tier (member/staff) framing below with three, and it changes
one real design decision: **Explore has to work with no login at all.** The sermon
library/study-notes pages already do (per-device `localStorage` for saved answers only).
Explore content stays that way; "My Church" is what unlocks cross-device sync and personal
history, layered on top rather than gating the base experience.

**Team-level access needs to be a real permission, not a hidden button.** Rotas, media
tools and governance material are exactly the kind of thing that must be enforced by RLS
policy on the actual data, not just by which nav items render for a given role — someone
without the `staff` role should get an access error from Supabase itself if they try to
query Control Room data directly, not just fail to see a link to it.

| Module | Area | Current state | What changes |
|---|---|---|---|
| Sermon library / study notes | Explore (+ My Church for sync) | Built, static, no auth | Stays open; add optional sign-in for saved answers across devices |
| Shareable posts / clips | Explore | Built (this project's own skills) | Surface inside the portal's Explore area, not just social platforms |
| Events / church info | Explore | Not built | New |
| Giving | My Church | Built, Stripe live | Add giving history view behind login (currently anonymous per-transaction) |
| Prayer requests / community | My Church | Not built | New — natural Phase 2/3 candidate |
| The Bridge (ops dashboard) | Team | Built, `bridge_users_v2` PIN | Migrate auth to shared `profiles`, gate by `admin`/`leadership` role |
| Control Room (live overlay + operator console) | Team | Built, `control_room_users`, RLS gaps noted above | Migrate auth, fix RLS as part of the same pass |
| Rehearsal Studio | Team | Spec'd, largely built (`rs_*` tables) | Migrate auth, gate by `volunteer`/`worship` role |
| Governance docs | Team (leadership only) | Built, private repo | Stays as-is, restricted repo access is already the right control |

---

## 4. Phased plan

**Phase 0 — Foundation (do this regardless of what comes after)**
- Decide and apply RLS policies for the 15 exposed tables.
- Build the `profiles` table and the GHL sync Edge Function.
- Stand up real Supabase Auth (magic link is the lowest-friction start for a congregation;
  password is more familiar for a tech-anxious user — worth deciding per audience, could be
  both).

**Phase 1 — Migrate one staff surface and one member surface as pilots**
- Staff: migrate The Bridge's auth to the shared system (smallest user count, lowest risk).
- Member: sermon library/study notes gets optional sign-in, so saved answers sync across
  devices instead of being trapped in one browser's `localStorage`.
- Goal: prove the shared-login pattern works end to end before touching Control Room (which
  runs live on Sundays and can't afford a broken migration) or the giving portal (which
  touches money).

**Phase 2 — Migrate the higher-stakes staff surfaces**
- Control Room and Rehearsal Studio, once Phase 1's pattern is proven.
- Giving history added behind login.

**Phase 3 — New member-facing features**
- Prayer requests, groups/events, whatever the congregation actually asks for once Phases
  0 to 2 are live and you can see real usage.

---

## 5. Open decisions that need you, not me

- **The public-facing name** — "Calvary Hephzibah" or "Calvary Connect" are the two
  options on the table for what buttons and headings actually say (never "portal" or
  "membership" in front of a visitor). This needs a real decision, not my default.
- **Magic link, password, or both** — and does that differ between staff (who need
  reliable fast access on a Sunday) and congregation members?
- **What roles actually exist** — the table above is my first guess at a role list; the
  real one should come from how you actually think about who does what.
- **RLS policy content** — I can draft the policies, but "who should be able to read/write
  `control_room_stills`" is a judgment call about your actual operating model, not a
  technical one.
- **Does every existing PIN user get auto-migrated, or does everyone re-register** — auto-
  migration is smoother but means guessing at email addresses for people who only ever had
  a PIN.

Nothing above commits you to anything. Tell me where to start and I'll build that piece
properly, the same way everything else in this project has been built: one verified, tested
piece at a time, not a rewrite of everything at once.

# Claude Code — setup for the weekly Calvary Sunday pack

Goal: paste the order of service, and the pack is live on GitHub Pages a minute later.
No zip, no proxy, no token juggling.

This runs on **your own machine**, so there is no sandbox between Claude and GitHub. It uses
your normal git credentials, exactly as if you typed `git push` yourself.

> Companion doc: [`CLAUDE_GIT_WORKFLOW.md`](CLAUDE_GIT_WORKFLOW.md) covers the *other* route —
> regular Claude (web/app) pushing from its own sandbox with a PAT. This doc is the local CLI route.

---

## 1. Install

**macOS / Linux / WSL**

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**macOS with Homebrew** (if you prefer)

```bash
brew install --cask claude-code
```

**Windows PowerShell**

```powershell
irm https://claude.ai/install.ps1 | iex
```

On native Windows, also install [Git for Windows](https://git-scm.com/downloads/win) so Claude
Code gets a proper Bash shell. The image and video scripts in your skills assume Unix tooling,
so **WSL 2 is the better Windows option** if you have it.

Requirements: macOS 13+, Windows 10 1809+, or Ubuntu 20.04+ / Debian 10+. 4 GB RAM.

## 2. Verify

```bash
claude --version     # should print e.g. 2.1.211 (Claude Code)
claude doctor        # read-only diagnostics if anything looks off
```

## 3. Authenticate

```bash
claude
```

Follow the browser prompt and sign in with the account that has your skills
(`hello@altitudeai.co`). Requires a Pro, Max, Team or Enterprise plan — the free plan does not
include Claude Code.

Your synced skills — `calvary-sunday-pack`, `calvary-social-pack`, `calvary-control-room-overlays`
and the rest — come with the account. Nothing to re-install.

## 4. Clone the repo once

```bash
mkdir -p ~/Projects && cd ~/Projects
git clone https://github.com/calvaryhfgc/calvaryhephzibah.git
cd calvaryhephzibah
git config user.name  "Bolaji Olatoye"
git config user.email "hello@altitudeai.co"
```

## 5. Set up the credential — once, properly

Create a **fine-grained** token, signed in as **`calvaryhfgc`** (the repo owner):
<https://github.com/settings/personal-access-tokens/new>

- **Repository access:** Only select repositories → `calvaryhfgc/calvaryhephzibah`
- **Permissions:** Repository permissions → **Contents: Read and write**
- Set an expiry you will actually notice — 90 days is sensible

This is deliberately narrower than the classic `repo`-scope token currently in the project
docs, which grants push access to *everything* in the account.

Then store it in your OS keychain so you type it exactly once:

**macOS**

```bash
git config --global credential.helper osxkeychain
```

**Windows**

```bash
git config --global credential.helper manager
```

**Linux**

```bash
git config --global credential.helper "cache --timeout=31536000"
```

Now push once by hand. Git prompts for username and password: enter `calvaryhfgc` as the
username and paste the **token** as the password. It is saved from then on.

```bash
git commit --allow-empty -m "Verify push access"
git push origin main
```

If that succeeds, every future push — including Claude's — just works.

**Once this is confirmed working, delete the token from the `Github Access Token` project doc
and rotate the old one.** It has full account scope and is currently in plaintext.

## 6. The weekly run

```bash
cd ~/Projects/calvaryhephzibah
git pull
claude
```

Then paste, in one message:

```
/calvary-sunday-pack

Sunday 23rd August 2026

-Welcome, Bible Reading: ...
-Opening Prayer: ...
-Worship: ...
-Bible Reading: ...
-Sermon Title: ...
-Preacher: ...
-Closing Prayer: ...
-Benediction: ...

Worship set:
Praise: ...
Worship: ...
Offering: ...
End of service: ...
```

Claude builds all four artifacts, commits, and pushes to `main`. Pages rebuilds in 30–60s.

### Have the set list ready

The single thing that most often stalls this: **the worship set**. The stage runthrough page
and the OG card are pure song content, so without titles they cannot be built at all. Keys can
be "TBC" — that is a valid state. Titles cannot.

Chase the set before you start, not halfway through.

## 7. Confirm it actually published

Do not trust "committed" as "live":

```bash
git ls-remote origin refs/heads/main     # SHA should have moved
```

Then open:

- `https://calvaryhfgc.github.io/calvaryhephzibah/media-briefing-DD-mon-YYYY.html`
- `https://calvaryhfgc.github.io/calvaryhephzibah/set-runthrough-DD-mon-YYYY/stage/`

## 8. Still manual: the Supabase SQL

The Control Room seed files (`control-room/schema/NN_*.sql`) are **not** applied by pushing.
Open the Supabase SQL editor for project `pfycvgbrsbecznkcikwt`, paste each new file, run it,
and read the verify queries at the bottom — particularly the one listing songs still on
placeholder lyrics.

---

## Which surface for which job

| Job | Use |
|---|---|
| Weekly Sunday pack (needs a push) | **Claude Code CLI**, on your machine |
| Social pack, clips, trailers, images | Cowork — better for media and conversational work |
| A quick repo change from a phone/browser | Claude Code on the web — pick the repo at task start; it opens a PR |

The rule: **anything that must end in a `git push` belongs in Claude Code on your machine.**

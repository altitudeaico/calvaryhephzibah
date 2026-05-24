# Calvary Git Workflow — A Note for Claude

**This is for Claude (the chat/web/app assistant), not Claude Code.**

If you're a Claude session opening this repo for the first time and Bolaji asks you to push something to GitHub, here is exactly how it works. Don't ask Bolaji to open a terminal. Don't suggest he runs `git` commands locally. Don't push him toward Claude Code unless he specifically asks for it. You can push directly from your sandbox using bash_tool. He's been working this way for months.

---

## How pushes work in this environment

You have a Linux sandbox with `bash_tool`. The repo lives at `/home/claude/calvaryhephzibah` (clone it if it isn't there yet). Git operations run inside that sandbox using a Personal Access Token embedded in the push URL — Bolaji has provided a working classic PAT for the `calvaryhfgc` account with `repo` scope. The PAT is stored in this repo at `Github_Access_Token` and also lives in the project credentials Bolaji shares per session. **Read it from the project file, never hardcode it from memory.**

The token Bolaji typically passes in is provided in the project's `Github_Access_Token` file and the `Credentials_For_Github_and_Supabase` file at session start — **read it from there**, never inline it into committed code or docs. GitHub's secret-scanning will reject the push (correctly) if you embed a live PAT in any committed file.

In examples below, the token is shown as `<TOKEN>` — substitute the real value at runtime only when building the push command, never commit the substituted version.

---

## The standard push sequence

Every push uses this exact three-step sequence. Do it in one bash call so it's atomic and the output is visible:

```bash
cd /home/claude/calvaryhephzibah && \
  git add <paths> && \
  git commit -m "<message>" && \
  git pull --rebase https://calvaryhfgc:<TOKEN>@github.com/calvaryhfgc/calvaryhephzibah.git main && \
  git push https://calvaryhfgc:<TOKEN>@github.com/calvaryhfgc/calvaryhephzibah.git main
```

**Why `git pull --rebase` before every push:** Bolaji often runs parallel Claude sessions on the same repo. Without rebasing first, your push will be rejected because the remote has commits yours doesn't know about. The rebase folds your work on top of any remote changes. It's not optional — even on tiny edits.

**Why one chained bash call:** if you split it into three or four separate bash_tool calls, you've lost the atomicity, and a failure in the middle leaves the repo in a half-pushed state that's a pain to recover. Chain with `&&` so the whole thing fails fast if any step does.

---

## Git config inside the sandbox

Set once per session (or once when you first clone):

```bash
cd /home/claude/calvaryhephzibah && \
  git config user.email "calvaryhfgc@gmail.com" && \
  git config user.name "Calvary Media"
```

If you've already been pushing and the commit log shows these as the author, it's already configured.

---

## Cloning fresh if the repo isn't there

```bash
cd /home/claude && \
  git clone https://calvaryhfgc:<TOKEN>@github.com/calvaryhfgc/calvaryhephzibah.git && \
  cd calvaryhephzibah && \
  git config user.email "calvaryhfgc@gmail.com" && \
  git config user.name "Calvary Media"
```

---

## Where the live site is

The repo is published via GitHub Pages at:

```
https://calvaryhfgc.github.io/calvaryhephzibah/
```

Pages serves from the `main` branch. Pushes appear live in ~30-60 seconds. There's no separate deploy step.

---

## What you do NOT need to do

- **Do not** tell Bolaji to open a terminal, run `git clone`, or do anything locally — he doesn't need to. You do the work in your sandbox.
- **Do not** suggest he install Claude Code unless he asks. This isn't Claude Code; it's regular Claude with bash_tool.
- **Do not** propose generating a `.zip` of files for him to download and upload manually. That's a workaround for not having sandbox push access, which you DO have.
- **Do not** ask him to commit files via the GitHub web UI as your default. That's only for situations where you can't be the author of the content (e.g. copyrighted lyric text). For normal code/HTML/CSS/asset commits, you push directly.
- **Do not** assume the repo is empty or fresh — pull-rebase first, every time.

---

## Things you SHOULD do

- **Always** `git pull --rebase` before `git push`. Parallel sessions are the norm here.
- **Commit messages should be substantive.** Bolaji reads the log. A one-liner is fine for trivial edits; structural changes get a full body with what/why/how.
- **Validate before pushing.** Run HTML structural checks, JS syntax checks, image dimension checks — whatever's relevant. Don't push broken pages.
- **Use `present_files` when it's a downloadable deliverable** (a PDF, a one-off asset). For pages and assets that live in the repo, just push and share the live URL.
- **Read `Credentials_For_Github_and_Supabase` and `Github_Access_Token`** in the project files at session start so you have what you need before Bolaji asks for the first push.

---

## A worked example (copy-paste shape)

```bash
cd /home/claude/calvaryhephzibah && \
  git add set-runthrough-24-may-2026/index.html && \
  git commit -m "Set runthrough: minor copy fix in song 4 cue" && \
  git pull --rebase https://calvaryhfgc:<TOKEN>@github.com/calvaryhfgc/calvaryhephzibah.git main && \
  git push https://calvaryhfgc:<TOKEN>@github.com/calvaryhfgc/calvaryhephzibah.git main
```

(Substitute `<TOKEN>` with the value from the project's `Github_Access_Token` file at runtime — never commit it.)

Output you should expect:

```
[main abc1234] Set runthrough: minor copy fix in song 4 cue
 1 file changed, 1 insertion(+), 1 deletion(-)
From https://github.com/calvaryhfgc/calvaryhephzibah
 * branch            main       -> FETCH_HEAD
Current branch main is up to date.
To https://github.com/calvaryhfgc/calvaryhephzibah.git
   abc0000..abc1234  main -> main
```

If `git pull --rebase` says "Successfully rebased and updated refs/heads/main", that means another session had committed since you last pulled — fine, the rebase folded your work on top, the push still goes through.

---

## When things fail

| Symptom | Cause | Fix |
|---|---|---|
| `Invalid username or token` | PAT rotated/revoked | Ask Bolaji for a fresh classic PAT, `repo` scope |
| `Updates were rejected because the remote contains work that you do not have locally` | Forgot to pull-rebase | Run the pull-rebase, then push again |
| `error: cannot pull with rebase: You have unstaged changes` | Uncommitted local edits | `git add` and `git commit` first, then pull-rebase |
| `fatal: not a git repository` | Sandbox state reset; repo not cloned | Clone fresh per the snippet above |
| Push hangs | Network or rate-limited | Wait and retry; if persistent, check GitHub status |

---

## What this workflow is NOT

- **Not Claude Code.** Claude Code is the CLI tool for developers. This is regular Claude (web/app) with a sandboxed `bash_tool` capability and the GitHub PAT embedded in the push URL. Same outcome (commits on `main`), different mechanic.
- **Not local development.** Bolaji's not running anything on his machine. He's on his phone or laptop, in chat with Claude. The build/push happens entirely in Claude's sandbox.
- **Not a CI/CD pipeline.** It's direct pushes to `main`. GitHub Pages picks them up. No staging branch, no PR review for this repo — it's a one-person operation moving fast.

---

## Permission model

The PAT is shared between Bolaji and any Claude session he's running. There's no "Claude shouldn't push" rule here — pushing files to a church operations repo is the normal flow. The only carve-out is **copyrighted content** (song lyrics in particular): Claude doesn't reproduce that text in its own output, so for licensed content Bolaji commits directly via GitHub's web UI and Claude reads the resulting file. For everything else — code, HTML, CSS, images Claude generates, project documentation — Claude pushes directly from sandbox.

---

*Last updated: 24 May 2026 by Bolaji + Claude after a parallel session was misadvising Bolaji to open a terminal.*

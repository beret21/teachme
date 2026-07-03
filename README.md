<!-- Language: **English** | [한국어](README.ko.md) -->

# Teach Me — `/teachme`

**English** | [한국어](README.ko.md)

![version](https://img.shields.io/badge/version-0.3.1-blue) ![license](https://img.shields.io/badge/license-MIT-green) ![for](https://img.shields.io/badge/for-Claude%20Code-8A2BE2)

**Turn any topic into a searchable, beautifully themed handbook — or full study material — written in your language, quality-checked by a multi-agent review, and published live to GitHub Pages. One command.**

Teach Me is a Claude Code skill. You give it a topic; it researches the official sources, proposes a structure that fits the topic, writes the content in the language you're already typing in, verifies it with a review harness, applies a color theme, and deploys a static site to GitHub Pages.

```
/teachme "Vercel"        →   https://<you>.github.io/vercel-handbook/
```

See real handbooks built with it in the [gallery ↓](#-made-with-teach-me).

---

## Quick start

```text
/plugin marketplace add beret21/teachme
/plugin install teachme@teachme
/reload-plugins
/teachme "the topic you want a handbook for"
```

That's it. Teach Me will confirm a few choices (language, theme, structure) and then build and deploy.

## Requirements

- **Claude Code** (or an agent that can run a shell, `git`, and `gh`).
- **`git`** and **`gh` (GitHub CLI), logged in** (`gh auth login`).
- **Network access** (to read official docs and deploy).
- **GitHub Pro** is assumed so the *generated* handbook can be a **private repo with public Pages**. On a **free** account the generated repo must be **public** — Teach Me tells you before publishing.

> Tip: run `/teachme doctor` to check your environment (account, plan tier, git, assets) before building.

## Where it runs (compatibility)

The one thing that decides how far Teach Me can go is **whether your environment can run a shell + `git` + `gh` and reach your GitHub account.** If it can, you get end-to-end automation; if not, the skill still writes the handbook but you deploy it yourself.

| Environment | Loads skill | Generates content | Auto-deploy (git/gh) | Multi-agent QA |
|-------------|:-----------:|:-----------------:|:--------------------:|:--------------:|
| **Claude Code** (CLI / IDE) | ✅ | ✅ | ✅ automatic | ✅ best quality |
| **Codex CLI** (full access) | ✅ | ✅ | ✅ automatic | ⚠️ weaker |
| **Claude Desktop chat** | ✅ | ✅ | ❌ manual | ❌ usually none |
| **ChatGPT / Codex cloud chat** | ✅ | ✅ | ❌ manual | ❌ none |

- **Terminal agents** (Claude Code, Codex CLI) run the whole pipeline — research → write → verify → theme → deploy.
- **Desktop / web chat** runs in an isolated sandbox with no access to your local repos, `gh` login, or GitHub account, so it produces the files and you push them yourself. Multi-agent verification is usually absent there, so density is lower.
- **Best quality is on Claude Code** (the multi-agent QA harness runs there). There is no separate "Codex Desktop" — Codex is CLI + IDE extension + cloud; only the **Codex CLI** deploys end-to-end.

## Usage

`/teachme [subcommand] [options] "<topic>"` — the first token is a subcommand; if it isn't one, it's treated as `new`.

| Subcommand | What it does |
|------------|--------------|
| `new "<topic>"` *(default)* | Build a new handbook/study material end to end. `new` is optional. |
| `add <manual\|examples\|chapter\|quiz> ["<topic>"]` | Add a section to an existing project. |
| `theme <name>` | Re-skin an existing site and redeploy. |
| `deploy` | Deploy a locally-built project (account/plan check → secret scan → Pages). |
| `verify` | Verify the live site or re-review the content. |
| `update [path]` | Conversationally revise an existing site, then redeploy. |
| `doctor` | Check your environment and report fixes. |
| `help` | Show this command reference. |

**Options** (mainly for `new`/`add`): `--lang`, `--theme <azure|graphite|ink|teal|amber|indigo>`, `--type <manual+examples|chapter|quiz|mixed>`, `--repo <slug>`, `--dir <path>`, `--owner <gh-account>`, `--private|--public`, `--deploy <github|local>`, `--no-verify`.

```text
/teachme new "React Query" --lang en --theme teal --type manual+examples
```

Anything you don't pass, Teach Me asks about (lightly). The **writing language defaults to the language you're prompting in**.

## What it builds

- **Content types, chosen to fit the topic** — Reference (Manual) · Practice (Examples) · Narrative **Chapters** (for concept/theory topics with no hands-on) · **Quiz / Q&A** (MCQ, short-answer, essay with model answer + rubric, FAQ). Mix and match.
- **6 color themes** — `azure` (default), `graphite`, `ink` (pure B/W), `teal`, `amber`, `indigo`.
- **Search** — site-wide search on the landing page + in-page search on every doc.
- **Any language** — content in your language; code and proper nouns stay as-is; per-language proofreading (Korean is held to the strictest bar).
- **Quality gate** — a multi-agent harness verifies accuracy and phrasing before publishing; optional SVG diagrams.
- **Security** — a pre-deploy secret scan and a generated-site `.gitignore` keep `.env`/keys out of your repo.

## Safety — why full access is fine

Teach Me **only creates, edits, and deploys — it never deletes your files or content.** It writes new files, fills templates, edits colors in place (`sed`) for theming, and uses `git`/`gh` to publish. Any temp files it makes during verification are its own, in the OS temp dir. So you can let it run with full access and finish unattended without risking irreversible loss.

> If you'd like, Teach Me can add an opt-in safety guard to your project's `.claude/settings.json` (e.g. deny `Bash(rm:*)`) — it asks first. It never forces this.

## Two kinds of "update"

- **Updating the skill** — new releases bump the version; run `/plugin marketplace update teachme`.
- **Updating your material** — just point Teach Me at the existing project (or run in that folder) and tell it what to change. It's conversational; no special mode needed.

## 🖼 Made with Teach Me

**English worked examples** — each built end-to-end with `/teachme`, showing different content types and themes (sources private; sites public):

| Handbook | Structure | Theme |
|----------|-----------|-------|
| [SQLite](https://beret21.github.io/sqlite-handbook/) | Reference + hands-on practice | teal |
| [Harness Engineering: Claude Code vs Codex CLI](https://beret21.github.io/claude-vs-codex-harness/) | Narrative chapters (concept, no practice) | graphite |
| [How to Read Stock Charts](https://beret21.github.io/reading-stock-charts/) | Chapters + self-check quiz (educational) | amber |

More handbooks (in Korean, with descriptions) are in the [Korean README ↗](README.ko.md#-teach-me로-만든-자료):
[Pretrained AI Model](https://beret21.github.io/pretrained-ai-model-handbook/) · [Claude MCP vs Skill](https://beret21.github.io/claude-mcp-vs-skill-handbook/) · [Git & GitHub](https://beret21.github.io/git-github-handbook/) · [Vercel](https://beret21.github.io/vibe-handbook-vercel/) · and more.

## Troubleshooting

- **`gh` not logged in** → `gh auth login`. Wrong account? `gh auth switch`.
- **Pages didn't publish on a free plan** → the repo must be public; Teach Me warns you and offers to proceed public or stop.
- **Cloud-synced folder (Dropbox/iCloud)** → Teach Me marks `.git` to be ignored by the sync engine to avoid corruption.
- Run **`/teachme doctor`** anytime.

## License

MIT © beret21. See [LICENSE](LICENSE) and [CHANGELOG](CHANGELOG.md).

> This license covers the Teach Me skill itself. Handbooks and materials you generate with it are entirely yours.

## ☕ Support

If Teach Me is useful to you, consider buying me a coffee — it keeps the updates coming.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/beret21)

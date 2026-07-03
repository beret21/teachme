<!-- Language: [English](README.md) | **한국어** -->

# Teach Me — `/teachme`

[English](README.md) | **한국어**

![version](https://img.shields.io/badge/version-0.3.1-blue) ![license](https://img.shields.io/badge/license-MIT-green) ![for](https://img.shields.io/badge/for-Claude%20Code-8A2BE2)

**어떤 주제든 검색되는·테마가 입혀진 핸드북 — 또는 완전한 교재 — 로 만들어, 당신이 쓰는 언어로 작성하고, 멀티에이전트 검수로 품질을 점검한 뒤, GitHub Pages에 라이브로 배포합니다. 명령 한 줄로.**

Teach Me는 Claude Code 스킬입니다. 주제를 주면 공식 문서를 조사하고, 주제 성격에 맞는 구성을 제안하고, **당신이 지금 입력하는 언어**로 콘텐츠를 쓰고, 검수 하네스로 검증하고, 컬러 테마를 입혀 정적 사이트를 GitHub Pages에 배포합니다.

```
/teachme "Vercel"        →   https://<계정>.github.io/vercel-handbook/
```

실제로 이 스킬로 만든 핸드북은 [갤러리 ↓](#-teach-me로-만든-자료)에서 볼 수 있습니다.

---

## 빠른 시작

```text
/plugin marketplace add beret21/teachme
/plugin install teachme@teachme
/teachme "핸드북으로 만들 주제"
```

끝입니다. Teach Me가 몇 가지(언어·테마·구성)만 가볍게 확인한 뒤 제작·배포합니다.

## 요구사항

- **Claude Code** (또는 셸·`git`·`gh` 실행이 가능한 에이전트).
- **`git`** 과 **`gh`(GitHub CLI) 로그인** (`gh auth login`).
- **네트워크** (공식 문서 조회·배포).
- **GitHub Pro** 가정 — *생성되는* 핸드북을 **비공개 저장소 + 공개 Pages**로 두기 위함. **무료** 계정이면 생성 저장소가 **공개**여야 하며, Teach Me가 배포 전에 안내합니다.

> 팁: 제작 전에 `/teachme doctor`로 환경(계정·플랜 등급·git·자산)을 점검하세요.

## 실행 환경 (호환성)

Teach Me가 어디까지 해 주는지는 **그 환경이 셸·`git`·`gh`를 실행하고 당신의 GitHub 계정에 접근할 수 있는가**로 갈립니다. 되면 배포까지 자동, 안 되면 콘텐츠는 만들어 주되 배포는 직접 하셔야 합니다.

| 환경 | 스킬 로드 | 콘텐츠 생성 | 자동 배포(git/gh) | 멀티에이전트 검증 |
|------|:---------:|:-----------:|:-----------------:|:-----------------:|
| **Claude Code** (CLI / IDE) | ✅ | ✅ | ✅ 자동 | ✅ 최상 품질 |
| **Codex CLI** (full access) | ✅ | ✅ | ✅ 자동 | ⚠️ 약함 |
| **Claude Desktop 채팅** | ✅ | ✅ | ❌ 수동 | ❌ 대부분 없음 |
| **ChatGPT / Codex 클라우드 채팅** | ✅ | ✅ | ❌ 수동 | ❌ 없음 |

- **터미널 에이전트**(Claude Code, Codex CLI)는 전 과정을 실행합니다 — 조사 → 작성 → 검증 → 테마 → 배포.
- **데스크톱/웹 채팅**은 격리된 샌드박스라 로컬 저장소·`gh` 로그인·GitHub 계정에 접근하지 못합니다. 그래서 파일은 만들어 주지만 **배포는 직접** 하셔야 하고, 멀티에이전트 검증도 대부분 없어 밀도가 낮아집니다.
- **품질은 Claude Code에서 가장 좋습니다**(멀티에이전트 검증 하네스가 여기서 돕니다). 별도의 "Codex Desktop"은 없습니다 — Codex는 CLI + IDE 확장 + 클라우드 형태이며, 배포까지 자동은 **Codex CLI** 뿐입니다.

## 사용법

`/teachme [서브커맨드] [옵션] "<주제>"` — 첫 토큰이 서브커맨드면 그것으로, 아니면 `new`로 간주합니다.

| 서브커맨드 | 하는 일 |
|------------|---------|
| `new "<주제>"` *(기본)* | 새 핸드북/교재를 처음부터 끝까지 제작. `new`는 생략 가능. |
| `add <manual\|examples\|chapter\|quiz> ["<주제>"]` | 기존 프로젝트에 섹션 추가. |
| `theme <이름>` | 기존 사이트 테마 교체 후 재배포. |
| `deploy` | 로컬 생성분 배포(계정/등급 확인 → 시크릿 스캔 → Pages). |
| `verify` | 라이브 사이트 검증 또는 콘텐츠 재검수. |
| `update [경로]` | 기존 사이트를 대화식으로 수정 후 재배포. |
| `doctor` | 환경 점검 후 해결책 보고. |
| `help` | 이 명령 규격을 보여줌. |

**옵션**(주로 `new`/`add`): `--lang`, `--theme <azure|graphite|ink|teal|amber|indigo>`, `--type <manual+examples|chapter|quiz|mixed>`, `--repo <슬러그>`, `--dir <경로>`, `--owner <gh계정>`, `--private|--public`, `--deploy <github|local>`, `--no-verify`.

```text
/teachme new "React Query" --lang ko --theme teal --type manual+examples
```

지정하지 않은 값은 Teach Me가 가볍게 물어봅니다. **작성 언어는 당신이 프롬프팅하는 언어로 자동 설정**됩니다.

## 무엇을 만드나

- **주제에 맞춘 구성** — 레퍼런스(Manual) · 실습(Examples) · 서술형 **챕터**(실습이 없는 개념·이론 주제) · **문제 풀이/Q&A**(객관식·단답·서술형[모범답안+루브릭]·FAQ). 자유롭게 혼합.
- **컬러 테마 6종** — `azure`(기본), `graphite`, `ink`(완전 흑백), `teal`, `amber`, `indigo`.
- **검색** — 랜딩 전체검색 + 모든 문서의 페이지 내 검색.
- **모든 언어** — 콘텐츠는 당신의 언어로, 코드·고유명사는 원형 유지, 언어별 교정(한국어는 가장 엄격).
- **품질 관문** — 발행 전 멀티에이전트 하네스가 정확성·표현을 검증, 필요 시 SVG 도식.
- **보안** — 배포 전 시크릿 스캔 + 생성물용 `.gitignore`로 `.env`·키가 저장소에 올라가지 않게.

## 안전성 — 전체 권한으로 써도 되는 이유

Teach Me는 **생성·편집·배포만 하고, 당신의 파일이나 콘텐츠를 삭제하지 않습니다.** 새 파일을 만들고, 템플릿을 채우고, 테마를 위해 색을 제자리 편집(`sed`)하고, `git`/`gh`로 배포합니다. 검증 중 만드는 임시파일은 OS 임시 폴더의 자기 것뿐입니다. 그래서 **전체 권한을 줘도 되돌릴 수 없는 손실 없이 개입 없이 완주**합니다.

> 원하면 Teach Me가 작업 폴더의 `.claude/settings.json`에 안전 가드(예: `Bash(rm:*)` 차단)를 **옵트인**으로 넣어드립니다 — 넣기 전에 물어봅니다. 강제하지 않습니다.

## 두 종류의 "업데이트"

- **스킬 업데이트** — 새 릴리스로 버전이 오르면 `/plugin marketplace update teachme`.
- **내 자료 업데이트** — 그냥 기존 프로젝트를 가리키거나 그 폴더에서 실행해 고칠 곳을 말하면 됩니다. **대화식**이라 별도 모드가 필요 없습니다.

## 🖼 Teach Me로 만든 자료

**구조·테마 예시** — 각각 `/teachme`로 처음부터 끝까지 만든 것으로, 서로 다른 구성 유형과 테마를 보여줍니다(소스 비공개, 사이트 공개). 같은 주제의 [영어판](README.md#-made-with-teach-me)도 있습니다.

| 핸드북 | 구성 | 테마 |
|--------|------|------|
| [SQLite 핸드북](https://beret21.github.io/sqlite-handbook-ko/) | 레퍼런스 + 실습 | teal |
| [하네스 엔지니어링: Claude vs Codex](https://beret21.github.io/claude-vs-codex-harness-ko/) | 서술형 챕터(개념, 실습 없음) | graphite |
| [주식 차트 읽는 법](https://beret21.github.io/reading-stock-charts-ko/) | 챕터 + 자가점검 퀴즈(교육용) | amber |

그 밖에 이 스킬로 제작·배포한 핸드북들:

| 핸드북 | 주제 |
|--------|------|
| [사전학습 AI 모델 핸드북](https://beret21.github.io/pretrained-ai-model-handbook/) | AI/ML — 사전학습 모델 |
| [Claude — MCP vs Skill 핸드북](https://beret21.github.io/claude-mcp-vs-skill-handbook/) | Claude 확장 — MCP와 Skill 비교 |
| [Claude 명령어 핸드북](https://beret21.github.io/claude-handbook-commands/) | Claude Code 명령어 |
| [Git·GitHub 핸드북](https://beret21.github.io/git-github-handbook/) | 버전관리 기초 |
| [Vercel 핸드북](https://beret21.github.io/vibe-handbook-vercel/) | 배포 플랫폼 |
| [Supabase 핸드북](https://beret21.github.io/vibe-handbook-supabase/) | 백엔드/DB |
| [Node.js 핸드북](https://beret21.github.io/vibe-handbook-nodejs/) | 런타임 |
| [Obsidian 핸드북](https://beret21.github.io/vibe-handbook-obsidian/) | 지식 관리 |
| [Google Workspace 핸드북](https://beret21.github.io/gws-handbook/) | 오피스/협업 |

> 실제 교육과정에도 쓰였습니다 — 예: OverEdge2026 [기초반](https://beret21.github.io/OverEdge2026-Handbook-Beginner/) · [고급반](https://beret21.github.io/OverEdge2026-Handbook-Advanced/).

## 문제 해결

- **`gh` 미로그인** → `gh auth login`. 계정이 다르면 `gh auth switch`.
- **무료 플랜에서 Pages 미게시** → 저장소가 공개여야 함. Teach Me가 안내하고 공개 진행/중단을 물어봄.
- **클라우드 동기화 폴더(Dropbox/iCloud)** → `.git`을 동기화에서 제외하도록 표시해 손상을 막음.
- 언제든 **`/teachme doctor`**.

## 라이선스

MIT © beret21. [LICENSE](LICENSE) · [CHANGELOG](CHANGELOG.md).

> 이 라이선스는 Teach Me 스킬 자체에만 적용됩니다. 이 스킬로 만든 핸드북·교재는 전적으로 사용자의 것입니다.

## ☕ 후원

Teach Me가 유용하셨다면 커피 한 잔 사주세요 — 업데이트에 큰 힘이 됩니다.

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/beret21)

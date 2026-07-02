---
name: teachme
description: Turn any topic into a searchable, themed handbook or full study material (reference, hands-on practice, narrative chapters, quiz/Q&A) written in the user's own language, quality-checked by a multi-agent review, and published to GitHub Pages as a static site. Detects topic and language from the user, proposes a structure that fits the topic, and deploys (private repo + public Pages; free accounts warned). Includes site-wide + in-page search, 6 color themes, optional SVG diagrams, per-language proofreading (strictest for Korean), and a pre-deploy secret scan. Use for requests like "/teachme", "make/build a handbook", "build a guide or docs site", "create study material", or in Korean "핸드북/가이드 사이트 만들어줘", "교재 만들어줘", "기술 문서 사이트 출판".
license: MIT
compatibility: Claude Code(권장) 또는 셸/`git`/`gh` 실행이 가능한 에이전트. 필요 도구 — git, gh(GitHub CLI, 로그인 필요), 네트워크(공식 문서 조회·배포). 산출물 비공개 저장소+공개 Pages는 GitHub Pro 가정(무료 계정은 공개 저장소로 안내). 대화형 질문 UI·멀티에이전트 오케스트레이션이 없는 환경에서는 옵션을 텍스트로 받고 검증이 단독 검토로 낮아질 수 있다.
metadata:
  version: "0.3.1"
  author: beret21
---

# Teach Me — 핸드북·교재 제작 스킬

주제 하나(`TOPIC`)와 작성 언어(`LANG`)를 받아, 일관된 품질·디자인·검색·배포로 **핸드북/교재**를 만들어 GitHub Pages에 출판하는 자립형 스킬이다. 콘텐츠만 갈아끼우면 어떤 주제·언어든 동일한 방식으로 제작된다. `/teachme` 로 호출하거나 "핸드북/교재 만들어줘" 같은 요청에 자동으로 동작한다.

## 명령 규격 — `/teachme [서브커맨드] [옵션] "<주제>"`

`$ARGUMENTS`를 다음 규칙으로 해석한다. **첫 토큰이 알려진 서브커맨드면 그것으로, 아니면 `new`로 간주**하고 나머지를 주제로 본다.

**서브커맨드**
| 명령 | 하는 일 |
|------|---------|
| `new "<주제>"` (기본) | 새 핸드북/교재 생성. 자료조사→구성제안→작성→검증→(테마)→배포. `new`는 생략 가능(`/teachme "<주제>"`). |
| `add <manual\|examples\|chapter\|quiz> ["<주제>"]` | 기존 산출물에 섹션 추가. |
| `theme <azure\|graphite\|ink\|teal\|amber\|indigo>` | 기존 `docs/`에 테마 교체(`apply-theme.sh` 재적용) 후 재배포. |
| `deploy` | 로컬 생성분 배포(계정/등급 확인 → §11.5 시크릿 스캔 → Pages). |
| `verify` | 배포 사이트 검증(curl/Playwright) 또는 콘텐츠 재검수(§6/§7). |
| `update [경로]` | 기존 `docs/`를 대상으로 **대화식** 수정·재검증·재배포(무거운 자동 재조회 아님 — 사용자가 고칠 곳을 말하면 반영). |
| `doctor` | 환경 점검(아래 "환경 점검" 절). |
| `help` | 이 명령 규격을 요약해 보여준다. |

**플래그**(주로 `new`/`add`) — 미지정 값은 대화형(또는 텍스트)로 확인:
`--lang <ko|en|ja|…>` · `--theme <…>` · `--type <manual+examples|chapter|quiz|mixed>` · `--repo <slug>`(미지정 시 폴더명 기본 제안) · `--dir <PROJECT_DIR>` · `--owner <gh계정>` · `--private|--public` · `--deploy <github|local>`(기본 github) · `--no-verify`(비권장·경고).

예: `/teachme new "Vercel 사용법" --lang ko --theme teal --type manual+examples --owner beret21`

> 인자 없이 `/teachme`만 오면 `help`처럼 간단 안내 후, 주제를 물어 `new` 흐름을 시작한다.

## 안전성 — 전체 권한(full access)으로 써도 되는 이유

이 스킬은 **사용자의 파일·콘텐츠를 삭제하지 않는다.** 하는 일은 **생성·편집·배포뿐**이다:
- 새 파일 생성(HTML·설정), 플레이스홀더 채우기, `sed`로 테마 색 **치환(편집)**, `git`/`gh`/`xattr`로 저장소·Pages 배포. 검증 중 만드는 임시파일은 OS 임시 폴더의 스킬 자기 것뿐이다.
- 그래서 **개입 없이 완주하려면 full access가 편하고, 그래도 되돌릴 수 없는 파괴가 없다.**

> 참고: `rm` 차단·휴지통 이동 같은 정책은 **개별 사용자 환경의 설정**이지 이 스킬이 강제하는 것이 아니다. 원하면 스킬이 **작업 폴더의 `.claude/settings.json`에 안전 가드를 넣어드릴 수 있다**(옵트인):
> ```json
> { "permissions": { "deny": ["Bash(rm:*)", "Bash(rmdir:*)"] } }
> ```
> 넣기 전에 사용자에게 물어보고, 넣었으면 알려 준다. 강제하지 않는다.

## 환경 점검 (`/teachme doctor`)
아래를 점검해 표로 보고하고, 문제마다 해결 명령을 제시한다(변경은 하지 않음):
- `gh auth status` — 로그인·활성 계정이 의도한 `OWNER`인지, **플랜 등급**(`gh api user --jq '.plan.name'` → `free`면 "산출물 저장소가 공개됨" 안내).
- `git` 설치 여부, 클라우드 동기화 폴더면 `.git` 의 `com.apple.fileprovider.ignore#P` xattr 설정 여부.
- 스킬 자산 존재: `references/BUILD_GUIDE.md`, `references/apply-theme.sh`(실행권한), `templates/*.html`, `assets/*.js`.

## 시작하면 가장 먼저 할 일

1. **주제(`TOPIC`)를 확정받고, 언어(`LANG`)는 자동 인식한다.** 주제는 스킬이 임의로 정하지 않는다. `LANG`은 **사용자가 프롬프팅하는 언어를 자동 인식해 기본값으로 설정**하고, "이 언어(예: 한국어)로 진행할게요 — 다른 언어로 원하면 알려 주세요" 정도로 **가볍게만 확인**한다(무거운 질문으로 막지 않는다. `--lang`이 오면 그대로). 함께 받을 파라미터: `THEME`(컬러 테마, 기본 azure), `REPO`(URL 슬러그 — **작업 폴더명에서 기본값 제안**), `OFFICIAL_SOURCES`(공식 1차 자료), `VERSION_TARGET`, `PROJECT_DIR`(새 프로젝트 경로), `OWNER`(GitHub 계정 — 자동 고정 아님, 배포 전 `gh auth status` 확인).
2. **주제 성격에 맞는 구성안을 제안하고 승인받는다.** 모든 섹션을 이론+실습으로 강요하지 않는다 — 실습이 무의미한 주제는 **서술형 챕터**로, 일부만 실습이면 **혼합**으로 제안한다. 교재라면 **문제 풀이/Q&A**(객관식·서술형·FAQ)를 선택적으로 덧붙인다(BUILD_GUIDE §2-A).
3. **`references/BUILD_GUIDE.md` 를 끝까지 읽고 그대로 따른다.** 제작·검증·보안·배포의 모든 절차가 거기 있다.

## 이 스킬에 동봉된 자산 (자립형 — 외부 의존 없음)

```
이 스킬/
├── SKILL.md                       이 파일
├── references/
│   ├── BUILD_GUIDE.md             범용 제작 지시서 (자료조사→제작→검증→보안→배포 전 과정)
│   ├── loanword-refinements.md    외래어 순화 판단 지침(한국어 검수 전용, §7)
│   └── apply-theme.sh             컬러 테마 적용기(배포 시 docs/ 의 브랜드 색 치환)
├── assets/                        docs/assets/ 로 복사할 검색 JS
│   ├── site-search.js             랜딩 전체검색 (DOCS 배열만 교체)
│   └── inpage-search.js           페이지 내 검색 (수정 없이 사용, SVG 라벨 보호 가드 포함)
└── templates/                     docs/ 로 복사할 HTML 골격 + 빈 파일
    ├── index.html                 랜딩(카드 그리드) 골격
    ├── Section_Manual.html        레퍼런스 매뉴얼 골격
    ├── Section_Examples.html      실습 예시 골격(초·중·고급 시나리오 카드)
    ├── Section_Chapter.html       서술형 챕터 골격(읽기 중심 — 실습 없는 주제용)
    ├── Section_Quiz.html          문제 풀이/Q&A 골격(객관식·단답·서술형·FAQ, 정답 클릭 토글 — 교재용 옵션)
    ├── .nojekyll                  (빈 파일)
    └── .gitignore                 시크릿(.env 등) 제외 + 미게시 파일 제외
```

모든 디자인 토큰·레이아웃·검색 스크립트 연결·홈 링크·검색 색인 전제는 템플릿에 **이미 내장**돼 있다. 새 핸드북은 템플릿을 복사한 뒤 `{{플레이스홀더}}`·`[설명: …]` 부분만 실제 내용으로 채우면 된다.

## 작업 흐름 요약 (상세는 BUILD_GUIDE.md)

1. **파라미터 확정** — `TOPIC`·`LANG`은 사용자 입력. `REPO`는 폴더명 기본 제안. **구성안(이론+실습/챕터/혼합)도 사용자 승인.**
2. **공식 문서 조사** — 추측 금지. `WebSearch`/`WebFetch`로 `OFFICIAL_SOURCES` 확인, 버전·수집일 기록.
3. **자산 복사** — 이 스킬의 `assets/`·`templates/`를 `PROJECT_DIR/docs/`로 복사(BUILD_GUIDE §4).
4. **콘텐츠 작성** — `LANG`으로 서술(실습 코드는 영어, 고유명사는 원형 유지). 섹션 유형에 맞는 골격 사용.
5. **품질 검증(필수)** — §6 내용 검증 하네스, §7.5 SVG 도식화(선별), §7 **언어별 문법·표현 검수**(한국어는 가장 엄격).
6. **컬러·검색·메타 마무리** — `THEME` 적용(`apply-theme.sh`), `site-search.js`의 `DOCS` 교체, 랜딩 날짜, `CHANGELOG.md`.
7. **보안·배포·검증** — **배포 전 시크릿 스캔(필수 관문, §11.5)**, 비공개 저장소 + 공개 Pages(main/docs), curl 200 + Playwright 렌더 검증.

> 핵심 원칙: **추측보다 확인**(공식 문서에서 확인한 것만), **상대경로만**(GitHub Pages base가 `/<REPO>/`), **검증 후 발행**(§6·§7 통과 전 출판 금지), **보안 우선**(시크릿이 없음을 확인하기 전 푸시 금지).

# Teach Me — 핸드북 제작 작업 지시서 (범용 · 다국어 · 자립형)

> 이 문서는 특정 주제·언어에 묶이지 않은 **"핸드북 제작 엔진"**이다. 주제(`TOPIC`)와 언어(`LANG`)만 갈아끼우면
> 어떤 기술·학습 주제든 동일한 품질·구조·검색·배포로 **사용자가 요청한 언어**의 핸드북을 만들어 GitHub Pages에 출판할 수 있다.
>
> **자립형이다.** 필요한 모든 재사용 자산(검색 JS, HTML 골격 템플릿, 테마 적용기, `.nojekyll`, `.gitignore`)은
> **이 스킬 폴더 안의 `assets/`·`templates/`·`references/`** 에 들어 있다. 외부 레퍼런스 저장소에 의존하지 않는다.
>
> **검증은 선택이 아니라 필수다.** §6(내용)·§7(언어별 표현) 검증을 통과하고, §11.5(시크릿 보안 스캔)를
> 통과한 뒤에만 발행한다. §7.5(SVG 도식화)는 권장.

이 문서에서 `SKILL_DIR` 는 **이 스킬이 설치된 폴더**(이 파일의 상위, 즉 `references/`의 부모)를 가리킨다.

---

## 0. 시작 전에 — 파라미터 정의 (사용자에게 입력받는다)

새 세션은 먼저 아래 값을 **사용자와 확정**한다. **주제(`TOPIC`)·언어(`LANG`)는 반드시 사용자로부터 확정받는다 — 임의로 정하지 않는다.**

| 파라미터 | 의미 | 예시 |
|----------|------|------|
| `TOPIC` | 다룰 주제 — **사용자 입력 필수** | "Vercel 사용법" |
| `LANG` | 콘텐츠 작성 언어 — **사용자 요청에서 식별해 기본값 제안 후 확인** | 한국어 / English / 日本語 / 中文 |
| `THEME` | 컬러 테마(§8) — 기본 `azure` | `azure`·`graphite`·`ink`·`teal`·`amber`·`indigo` |
| `REPO` | 저장소·URL 슬러그(공개 URL에 노출) — **작업 폴더명에서 기본값 제안 후 확인** | `vercel-handbook` |
| `OFFICIAL_SOURCES` | 공식 1차 자료(URL·CLI 등) | `vercel.com/docs`, `vercel --help` … |
| `VERSION_TARGET` | 콘텐츠가 다루는 버전/플랫폼 기준 | "Vercel CLI vXX / 플랫폼 2026-06" |
| `PROJECT_DIR` | 새 프로젝트(저장소 루트) 절대경로 | `…/Books/Vercel` |
| `OWNER` | GitHub 사용자/조직명(공개 URL·API에 사용) — **자동 고정 아님, 배포 전 계정 확인 필수** | (사용자 GitHub 계정/조직) |

> **`LANG`(작성 언어):** **사용자가 프롬프팅하는 언어를 자동 인식해 기본값으로 설정**한다(한국어로 요청하면 한국어, 영어면 English…). 무거운 질문 대신 "이 언어로 진행할게요, 다르면 알려 주세요" 정도로 **가볍게 확인**하고, `--lang`이 명시되면 그대로 따른다. 모든 산문(설명·제목·캡션·표·박스)을 이 언어로 쓴다. **단, 실습 코드·명령어·식별자·파일경로·URL은 영어 원형을 유지**하고, **고유명사(제품명·인명·기술명)는 억지로 번역하지 않는다.** `<html lang>` 속성도 `LANG`에 맞춘다(ko/en/ja/zh-Hans 등).
>
> **`REPO`(기본값):** 작업 폴더명을 URL 슬러그로 변환해 제안한다 — 소문자화, 공백·`_`→`-`, 영숫자·`-`만 남김. 예: 폴더 `TeachMe` → `teach-me`, `Vercel 사용법` → 폴더가 한글이면 사용자에게 적절한 영문 슬러그를 제안. 사용자가 다른 이름을 원하면 그대로 따른다.
> **`OWNER`는 환경에서 자동으로 고정되는 값이 아니다.** 스킬을 다른 사용자에게 배포하면 그 사용자의 계정을 써야 하고, 한 사람이 개인·업무 등 **여러 계정**을 쓰는 경우도 흔하다. `gh`는 다계정을 지원하므로 **배포 전에** 반드시 확인·확정한다:
> 1. `gh auth status` 로 로그인된 계정과 **활성 계정**을 사용자에게 보여 준다.
> 2. 어느 계정으로 배포할지 사용자에게 확인받는다(공개 URL `https://<OWNER>.github.io/<REPO>/` 가 이 계정으로 결정됨).
> 3. 활성 계정이 `OWNER`와 다르면 `gh auth switch`(계정 3개 이상이면 `--user <OWNER>`)로 전환하고, `gh api user --jq '.login'` 으로 일치를 검증한다.
> 4. **조직(org) 소유**로 만들려면 그 org 권한이 있는 계정으로 로그인한 뒤 `gh repo create "$OWNER/$REPO" …` 처럼 `OWNER/REPO`로 지정한다.

전역 규칙의 **"추측보다 확인 — 공식 문서 검색 → 명세 → 구현"**을 항상 따른다.

---

## 1. 네이밍 & 공개 정책

- 저장소 이름은 `REPO`(작업 폴더명 기반 기본 제안 — §0). **특정 벤더 prefix를 강요하지 말 것.**
- **기본은 비공개 저장소 + 공개 GitHub Pages**(소스는 비공개, 사이트만 공개).
- 공개 URL: `https://<OWNER>.github.io/<REPO>/`. 저장소 이름은 공개 URL에 노출되므로 공개돼도 무방하게.
- **계정 등급 전제 — 사용자는 GitHub Pro 이상 유료로 가정한다.** 비공개 저장소에서 Pages를 켜려면 Pro 이상이 필요하다.
  - **무료(Free) 계정이면 비공개 저장소로는 Pages를 켤 수 없다.** 이 경우 사용자에게 **"저장소를 공개(public)로 만들어야 사이트가 게시된다"**는 점을 **배포 전에 명확히 안내**하고, (a) 저장소를 공개로 만들지(소스 코드도 공개됨), (b) Pro로 업그레이드할지 선택받는다. 무료 계정 감지는 §12에서 처리(`gh api user --jq '.plan.name'`).

---

## 2. 주제 자료 조사 (추측 금지)

1. `OFFICIAL_SOURCES`를 `WebSearch`/`WebFetch`로 조사. **공식 문서에서 확인된 것만** 작성한다.
2. 버전(`VERSION_TARGET`)과 **문서 수집일**을 기록(각 문서 버전 박스에 반영).
3. 다룰 범위를 먼저 목록화하고, **문서 섹션 분할안 + 각 섹션의 구성 유형**을 사용자에게 제안해 승인받는다.

### 2-A. 구성 유형은 주제 성격에 맞게 — 동적 제안 (강요 금지)

**모든 섹션을 이론+실습으로 강요하지 않는다.** 주제에 따라 실습(따라 하는 손작업)이 무의미할 수 있다. 자료 조사 결과를 바탕으로 **섹션별 구성 유형**을 제안하고 사용자가 고르게 한다.

| 구성 유형 | 사용 골격 | 적합한 주제 |
|-----------|-----------|-------------|
| **이론 + 실습** | `Section_Manual.html` + `Section_Examples.html` | 도구·CLI·API·라이브러리처럼 **직접 실행해 보는** 주제 |
| **서술형 챕터** | `Section_Chapter.html` | 개념·원리·역사·이론·디자인 철학처럼 **읽고 이해하는** 주제(실습 없음) |
| **레퍼런스 단독** | `Section_Manual.html` | 손작업 시나리오는 약하지만 항목별 빠른 참조가 핵심인 주제 |
| **문제 풀이 / Q&A** | `Section_Quiz.html` | 교재·시험 대비 — 객관식·단답·서술형·개념 Q&A로 **점검·자가학습** (선택적으로 추가) |
| **혼합** | 섹션마다 위 유형을 다르게 | 일부는 실습, 일부는 개념, 끝에 문제 풀이 등 |

- 제안 형식 예: "이 주제는 1·2장은 개념이라 **서술형 챕터**, 3장은 실제 도구 사용이라 **이론+실습**, 마지막에 **문제 풀이(Q&A)** 를 붙이길 제안합니다. 이대로 진행할까요?"
- **문제 풀이 / Q&A(`Section_Quiz.html`)** 는 **교재용 옵션**이다. 필요할 때만 추가하고, 각 섹션 끝이나 별도 섹션으로 둘 수 있다.
  - 지원 유형: **객관식(MCQ) · 단답/빈칸 · 서술형 · 개념 Q&A/FAQ.** 정답·해설은 **클릭 토글(`<details>`)** 로 가려 두고 자가학습에 쓴다.
  - **서술형은 모범답안 + 채점 기준(루브릭) + 핵심 키워드**를 토글로 제공해 **자가 대조**하게 한다.
  - ⚠️ **자동 채점은 정적 사이트로 불가**(자유 서술 채점은 백엔드/LLM 필요). 학습자가 정답·모범답안과 대조하는 방식임을 안내 박스에 명시한다(템플릿에 내장).
- 분량이 적으면 1개 섹션으로 시작, 많으면 기초/심화·사용/제작 등으로 분할.
- 폴더 슬러그·파일명은 §3 규칙(무공백 소문자)을 따른다. 챕터형은 `*_Chapter.html`, 문제 풀이는 `*_Quiz.html`(또는 순번)로 명명한다.

---

## 3. 산출물 디렉토리 구조

```
PROJECT_DIR/                        (= 저장소 루트, Private)
├── docs/                          ★ GitHub Pages 게시 대상 (main / docs)
│   ├── index.html                 랜딩(카드) — templates/index.html 복사 후 제목·카드만 교체
│   ├── .nojekyll                  빈 파일(templates/에서 복사)
│   ├── assets/
│   │   ├── site-search.js         랜딩 전체검색(복사 후 DOCS 배열만 교체)
│   │   └── inpage-search.js       페이지 내 검색(수정 없이 복사)
│   └── <section-slug>/
│       ├── *_Manual.html          레퍼런스(빠른 참조)  ← templates/Section_Manual.html 복제
│       ├── *_Examples.html        실습 예시(시나리오)  ← templates/Section_Examples.html 복제
│       ├── *_Chapter.html         서술형 챕터(읽기)    ← templates/Section_Chapter.html 복제 (구성 유형에 따라 선택)
│       └── *_Quiz.html            문제 풀이 / Q&A       ← templates/Section_Quiz.html 복제 (교재용 옵션)
├── markdown/                      ☆ 미게시. MD 요약(선택)
├── .gitignore                     templates/.gitignore 복사
├── CHANGELOG.md                   변경 이력(비공개, 미게시 — §11)
└── README.md                      저장소 설명(배포 후 라이브 Pages URL·설명 포함 — §12-D)
```
- **게시되는 것은 `docs/` 안 HTML뿐.** GitHub Pages 브랜치 배포 폴더는 `/`(root) 또는 `docs`만 허용 → `docs/` 사용.
- 폴더명에 **공백 금지**(공백은 URL에서 `%20`이 됨). `<section-slug>`는 무공백 소문자(예: `using`, `authoring`).

---

## 4. 재사용 자산 — 이 스킬에서 복사 (자립형)

모든 자산은 **이 스킬 폴더(`SKILL_DIR`)** 안에 있다. 외부 저장소를 찾지 말 것.

```bash
SKILL_DIR="<이 스킬이 설치된 폴더 절대경로>"   # 예: .../Education/TeachMe
DST="$PROJECT_DIR/docs"
mkdir -p "$DST/assets" "$DST/<section-slug>"

# 검색 JS (assets)
cp "$SKILL_DIR/assets/inpage-search.js" "$DST/assets/inpage-search.js"   # 수정 불필요
cp "$SKILL_DIR/assets/site-search.js"   "$DST/assets/site-search.js"     # DOCS 배열만 교체

# 랜딩 + 빈 파일
cp "$SKILL_DIR/templates/index.html"  "$DST/index.html"                  # 제목·카드만 교체
cp "$SKILL_DIR/templates/.nojekyll"   "$DST/.nojekyll"
cp "$SKILL_DIR/templates/.gitignore"  "$PROJECT_DIR/.gitignore"

# 섹션 문서 (구성 유형에 따라 필요한 골격만 복제해 이름 교체 — §2-A)
cp "$SKILL_DIR/templates/Section_Manual.html"   "$DST/<section-slug>/<Section>_Manual.html"
cp "$SKILL_DIR/templates/Section_Examples.html" "$DST/<section-slug>/<Section>_Examples.html"
cp "$SKILL_DIR/templates/Section_Chapter.html"  "$DST/<section-slug>/<Section>_Chapter.html"   # 서술형 챕터일 때
cp "$SKILL_DIR/templates/Section_Quiz.html"     "$DST/<section-slug>/<Section>_Quiz.html"      # 문제 풀이/Q&A(교재용 옵션)일 때
```

복사 후 **수정 지점**:
1. `assets/site-search.js`의 `DOCS` 배열 → 새 문서 path·title로 교체(§9).
2. `index.html` → `<title>`/`<h1>`/부제, `.meta` 박스, `.group` 카드(섹션 수만큼), footer.
3. `*_Manual.html`/`*_Examples.html`/`*_Chapter.html`/`*_Quiz.html` → `{{플레이스홀더}}`·`[설명: …]`를 실제 내용으로. `<html lang>`을 `LANG`에 맞춤. CSS·레이아웃·검색 스크립트는 **그대로**. (Quiz는 문항 카드 패턴을 복제해 늘린다.)
4. **컬러 테마(`THEME`)는 배포 직전 `apply-theme.sh`로 일괄 적용**(§8·§12). 작성 중에는 기본 azure로 두고, 마지막에 적용하면 된다.

`inpage-search.js`·`.nojekyll`은 **수정 없이** 사용. (`inpage-search.js`에는 SVG 라벨 보호 가드가 이미 포함돼 있어 §7.5 도식을 넣어도 안전하다.)

---

## 5. 콘텐츠 제작 표준

- **공식 문서 우선** — 확인 안 된 내용은 쓰지 않는다.
- **구성 유형(§2-A)에 맞는 골격 사용:**
  - *이론+실습*: Manual의 각 항목엔 **핵심 동작 1~3문장**(코드만 나열 금지) + Examples의 **초급(초록)·중급(파랑)·고급(보라) 3단계** 시나리오.
  - *서술형 챕터*: `Section_Chapter.html`로 **흐름 있는 산문**. 항목 나열이 아니라 개념→설명→예시의 읽기 흐름. '이 장의 요점' 3~4개, 필요 시 핵심 인용·강조 한 줄. 장 사이 이전/다음 이동 링크 유지.
  - *문제 풀이 / Q&A*: `Section_Quiz.html`로 문항 카드. **문항은 §6에서 검증한 본문에 근거**하고(교재 범위 밖 함정 문제 금지), 정답·해설을 **클릭 토글(`<details>`)** 로 가린다. 객관식은 오답 이유까지 해설, **서술형은 모범답안+루브릭+핵심 키워드**로 자가 대조하게 한다. 난이도(초·중·고급)나 유형별로 묶고, 카드 `id`·질문 제목을 nav에 미러링한다.
- **맥락적 타당성** — 예시는 숨은 전제 없이 재현 가능해야. 대상이 자명(현재 폴더 등)하거나 전제를 명시. 페르소나와 난이도 일치.
- **작성 언어 = `LANG`** — 모든 산문을 `LANG`으로 쓴다. **직역 금지**(§7에서 언어별로 별도 검수).
  - **실습 코드·명령어·플래그·식별자·파일경로·URL은 영어 원형 유지.**
  - **고유명사(제품명·인명·기술명·표준명)는 억지로 번역하지 않는다.** 원형을 쓰고, 필요하면 처음 1회만 짧게 풀어 준다.
  - 영어 원문을 불필요하게 병기하지 않는다(검색·이해에 꼭 필요한 식별자 제외).

---

## 6. ★ 필수 ① — 다양한 페르소나 서브에이전트로 "내용" 검증

내용의 정확성·교육효과·맥락 타당성은 **반드시 멀티에이전트 하네스(`Workflow`/서브에이전트)로 검증**한 뒤 반영한다. 혼자 작성하고 끝내지 않는다.

### 6-A. 학생 페르소나 → 강사 (이해도 검증·설명 보강)
생소하거나 어려운 개념·섹션에 적용.

- **학생 페르소나(병렬, 최소 4종):**
  | 페르소나 | 관점 |
  |----------|------|
  | 완전 초보(비전공) | 용어 자체가 생소 — "이게 뭔지·왜 필요한지" |
  | 주니어 | 기본은 알지만 핵심 메커니즘 혼동 |
  | 중급 | 유사 개념과의 차이·실전 패턴 |
  | 시니어/도입 검토자 | 생명주기·경계조건·팀 적용 시의 득실 |
- 각 학생이 **구체적 질문 목록**(추상 질문 금지) 생성 → **강사 에이전트**가 모든 질문에 답하는 종합 설명 생성 →
  개념·생명주기·상세·시나리오·주의사항을 산출물에 반영.

### 6-B. 검토자 관점 → 종합 → 적용 (예시·서술 검증)
- **검토 관점(병렬):** 초보 재현성 / 교육적 초점 / 기술적 정확성 / 실무 현실성
- 각 관점이 문제 항목을 `{원문, 심각도, 문제, 수정안}`으로 플래그 → **종합 에이전트**가 중복 통합·확정 →
  파일에 반영. **과편집 금지** — 정말 오해를 유발/재현 불가한 것만 고치고, 멀쩡한 건 둔다.

### 하네스 골격(개념)
```
phase('내용검증')
students = parallel(personas.map(p => agent(질문생성, {schema})))
instructor = agent(모든 질문 종합 답변, {schema})
reviews = parallel(lenses.map(l => agent(렌즈 검토, {schema})))
synthesis = agent(통합·확정 개선안, {schema})
apply = parallel(files.map(f => agent(파일에 반영)))   // 원문 정확 매칭으로 Edit
```
> 항상 **검증→종합→적용** 순. 적용은 원문 문자열을 정확히 찾아 교체(추측으로 엉뚱한 곳 수정 금지).

> **에이전트/`Workflow`를 쓸 수 없는 환경이면**(예: 단독 실행) — 검증을 생략하지 말고 **혼자 한 차례 직접 검토**를 한다. 위 학생 페르소나와 검토 관점(§6), 언어별 검수 관점(§7, 한국어면 7-A-1 포함)을 점검 목록으로 삼아 작성자가 각 항목을 한 번씩 직접 훑고, 통과 전에는 발행하지 않는다. 여러 에이전트가 사각지대를 더 잘 잡지만, 혼자 보더라도 "검증 없이 발행"하는 것보다 낫다.

---

## 7. ★ 필수 ② — 언어별 문법·표현 검수 서브에이전트 (발행 전 관문)

모든 산문(prose)은 **발행 전에 `LANG` 언어의 검수 하네스를 통과**해야 한다. 직역투·어색한 어순·맞춤법 오류를 잡아 **그 언어의 원어민이 자연스럽게 읽히도록** 다듬는다. 검수는 `LANG`에 맞춰 분기하되, **한국어(`LANG`=한국어)는 가장 까다롭게** 평가한다.

### 7-A. 검수자 페르소나(병렬, 관점별 — 모든 언어 공통)
| 검수자 | 잡아내는 것 |
|--------|------------|
| 맞춤법·정서법 | 해당 언어의 철자·맞춤법·구두점. (한국어: 한글 맞춤법, 띄어쓰기, 조사 은/는/이/가/을/를 오류) |
| 어순·직역투 | 출발어(주로 영어) 번역투 — 부자연스러운 어순, 피동·무생물 주어 남용, 직역된 관용 표현 → 그 언어의 자연스러운 어순·관용으로 |
| 용어 일관성 | 같은 개념을 다른 말로 혼용하지 않는지, 외래어·표기 일관성 |
| 가독성·톤 | 한 문장 과다 길이, 능동·간결, 교육 대상 눈높이 |

### 7-A-1. 한국어 전용 — 가장 엄격한 추가 관문 (`LANG`=한국어일 때만)
한국어는 위 공통 관점에 더해 아래를 **반드시** 적용한다.
- **불필요한 영어 외래어 (지침 기반 판단):** `references/loanword-refinements.md`(판단 지침)**에 따라 문맥에 맞게** 자연스러운 한국어로 바꾼다. 근거는 국립국어원 「다듬은 말」 — 애매하거나 처음 보면 검색해 확인(추측 금지). 예: 가이드라인→지침, 다운로드→내려받기, 게이트웨이→관문. **사전을 기계적으로 적용하지 않는다**: 비정착 순화어(예: 인터넷→누리망)는 쓰지 않고, 정착 식별자(API·HTML·`pipeline()`·`Workflow`)는 유지. 영어 비유의 직역("렌즈"→관점, "드리프트"→어긋남)도 함께 판단.
- 피동 남용("~되어진다"), 무생물 주어, "~에 대해", "~을 가진다" 같은 번역투를 특히 강하게 잡는다.

> **다른 언어(`LANG`≠한국어):** 그 언어의 표준 정서법·문체를 기준으로 검수한다. `loanword-refinements.md`는 **한국어 전용**이므로 다른 언어엔 적용하지 않는다. 불확실한 표기·관용은 그 언어의 공신력 있는 기준(공식 사전·스타일 가이드)을 검색해 확인한다(추측 금지).

### 7-B. 절대 규칙 (검수 대상 한정 — 모든 언어 공통)
- **코드·명령어·플래그·식별자·파일경로·URL·HTML 태그·고유명사는 절대 손대지 않는다.** 오직 **설명 문장(산문)만** 교정.
- **의미를 바꾸지 않는다.** 표현만 자연스럽게. 기술 정확성은 §6에서 이미 검증된 상태를 전제.
- 과교정 금지 — 이미 자연스러운 문장은 그대로 둔다.

### 7-C. 흐름
```
phase('언어검수')   // LANG에 맞춰 검수 관점 구성, 한국어면 7-A-1 추가 적용
flags = parallel(proofLenses.map(l => agent(렌즈별 검수, {schema:{flagged:[{원문,유형,수정안,위치}]}})))
merged = agent(중복 통합·확정, {schema})
apply  = parallel(files.map(f => agent(해당 파일의 산문만 교체)))  // 코드/태그 보존
```
- 산출물(HTML/MD) 전체 대상으로, **표·박스·시나리오·툴팁의 설명 문장까지** 빠짐없이.
- 검수 후 **무엇을 왜 고쳤는지 요약**을 사용자에게 보고(샘플 몇 개 포함).

> §6(내용)와 §7(표현)은 **순서가 있다**: 먼저 내용 검증·확정 → 그 다음 언어 검수. 표현을 먼저 다듬고 내용이 바뀌면 헛수고.

---

## 7.5 ★ 권장 ③ — SVG 전문 디자이너 서브에이전트로 도식화

글로만 설명하기 어려운 **흐름·상태·구조·비교**는 **SVG 다이어그램**으로 시각화한다. **SVG 전문 디자이너 서브에이전트**(`Agent`)에 위임한다.

### 도식화 우선 대상
- **흐름/생명주기** → 플로우차트(노드+화살표, 분기·루프·back-edge)
- **상태/모드 비교** → 좌우 비교도
- **구성/계층 관계** → 트리·구성도(부모-자식·바인딩)
- **단계 절차** → 번호 노드 시퀀스

### 서브에이전트 사용법
`Agent`로 "SVG 다이어그램 전문 디자이너" 페르소나에 **디자인 토큰(§8) + 도식화할 텍스트 + 규격(아래)**을 주고 **완결된 인라인 `<svg>` 마크업만 반환**받는다(임베드는 본체가). 여러 장은 같은 스펙을 한 에이전트에 줘 일관성 확보.

### SVG 규격 (반드시)
- **인라인 SVG**(외부 리소스·이미지·폰트 금지) → 자립형 단일 파일 유지. `<figure>`로 감싸고 `<figcaption>`에 "그림 N. 한 줄 설명".
- 반응형: `viewBox` + `width="100%" height="auto"` + `style="max-width:<px>;height:auto;display:block;margin:18px auto;"`(고정 px width 금지).
- 접근성: `role="img"` + `<title>`/`<desc>`.
- **§8 디자인 토큰 색상만** 사용. 일반 텍스트 시스템 폰트(한국어면 Noto Sans KR 등 `LANG`에 맞는 폰트), 명령어·식별자 monospace, 화살표는 `<marker>`. `LANG` 라벨은 텍스트 잘림 없게(특히 한글·CJK는 글자당 폭 ~13px@13px / 11px@11px 가정, 박스 넉넉히).
- **겹침 금지(중요)**: 번호 배지·아이콘과 라벨이 한 줄에 있으면 겹치기 쉽다 — 가장 흔한 SVG 결함이다.
  - 배지를 박스 왼쪽에 둘 때 라벨은 **배지의 오른쪽 끝 + 여백 지점에서 `text-anchor="start"`로 시작**한다. (라벨을 박스 중앙 `text-anchor="middle"`에 두면서 배지를 같은 줄 왼쪽에 겹쳐 놓지 말 것 — 라벨 왼쪽이 배지를 침범한다.)
  - 배지가 없고 라벨만 박스 중앙에 둘 때는 `text-anchor="middle"`을 써도 된다.
  - 화살표·연결선이 노드 박스나 라벨 글자를 가리지 않게 한다. 텍스트끼리도 최소 간격을 둔다.
- 과한 그라데이션·그림자 금지. 정보 전달 우선.

### 검증·순서
- 다이어그램 내용은 **§6에서 검증된 본문과 일치**해야 한다.
- §13 Playwright 검증에 **SVG 렌더(가시성·viewBox·모바일 가로 넘침 없음·배지/라벨/화살표 겹침 없음)** 포함. 겹침은 **각 figure를 실제 렌더해 스크린샷으로 육안 확인**한다(자동 assert로는 못 잡는다). 문제가 보이면 SVG를 고쳐 재촬영하고, 깨끗할 때까지 반복한 뒤에만 발행한다.
- 권장 순서: §6 내용 확정 → **SVG 도식화** → §7 언어 검수(캡션·라벨 산문도 검수 대상).
- **최적 지점에만** 넣는다 — 모든 단락에 억지로 넣지 말고, 그림이 실제로 이해를 높이는 곳에 선별 적용.
- `inpage-search.js`에는 SVG `<text>`에 `<mark>`가 주입되지 않도록 하는 가드가 이미 들어 있다(라벨 깨짐 방지).

---

## 8. 디자인 시스템 (시각 일관성 — 템플릿에 내장됨)

화이트 배경 + 인라인 `<style>`(외부 CSS 없음, 자립형 단일 파일). `templates/` 의 토큰 그대로:
```css
:root{
  --bg:#ffffff; --bg2:#f6f8fa; --bg3:#eef1f4; --border:#d0d7de;
  --text:#1f2328; --text-dim:#636c76;
  --accent:#0969da; --accent2:#1a7f37; --accent3:#953800; --accent4:#6639ba; --accent5:#cf222e; --accent6:#0550ae;
}
body{ font-family:-apple-system,BlinkMacSystemFont,'Segoe UI','Noto Sans KR',sans-serif; }
```
핵심 컴포넌트(템플릿에 예시 골격으로 들어 있음): 2단 레이아웃(좌측 고정 `nav` + `main`), **버전 박스**(대상 버전·문서 URL·**문서 수집일**), 개념/명령 트리(`.tree-box`), **배지**(라벨은 주제에 맞게 재정의), 표, **실습 카드** `.scenario-card`(레벨 배지 + `.tip-box`/`.warning-box`), **서술형 챕터**(`Section_Chapter.html` — 읽기 폭 720px, '이 장의 요점', 핵심 인용, 이전/다음 장 이동), **문제 풀이/Q&A**(`Section_Quiz.html` — 유형 배지, 객관식 보기, `<details>` 정답·힌트 토글, 서술형 모범답안·루브릭).
- 표 짝수행 배경 `#f6f8fa`(⚠️ 어두운 색 금지 — 가독성). 표·박스 안 긴 설명은 `<ul>/<ol>`로 구조화(평문 `1) 2) 3)` 금지).
- 새 문서는 `templates/`의 골격을 복제해 유지, **내용만** 교체가 가장 빠르고 일관적.

### 8-A. 컬러 테마 (`THEME` — 6종, 배포 시 일괄 적용)

템플릿은 **단 하나의 기본 팔레트(`azure`)**로 작성돼 있다. 다른 테마는 **배포 직전 `references/apply-theme.sh`가 `docs/`의 브랜드 색 hex만 치환**해 적용한다(템플릿 자체는 손대지 않음 — 디폴트 동일 보장). 핸드북은 처음부터 끝까지 한 테마를 쓰므로 마지막에 한 번 실행하면 된다.

| THEME | 성격 | 의미색(난이도 레벨) |
|-------|------|--------------------|
| `azure` (기본) | 파랑 — 범용·기술 | 유지(초급 초록/중급 파랑/고급 보라) |
| `graphite` | 그레이 — 차분·중립 | 유지 |
| `ink` | 완전 흑백 — 인쇄물 느낌 | **무채색화**(구분은 💡⚠️📌 라벨이 담당) |
| `teal` | 청록 — 데이터·환경 | 유지(중급=청록) |
| `amber` | 따뜻한 앰버/브라운 — 인문·교육 | 유지(중급=앰버) |
| `indigo` | 인디고/보라 — 세련 | 유지(중급=인디고) |

```bash
# 작성 중에는 기본 azure. 배포 직전 1회 적용(§12). azure 는 no-op.
bash "$SKILL_DIR/references/apply-theme.sh" "$THEME" "$PROJECT_DIR/docs"
```
- 컬러 테마(azure/graphite/teal/amber/indigo)는 **브랜드 색만** 바꾸고 난이도 레벨 의미색(초록·보라 등)은 유지해 학습 코딩이 유지된다.
- `ink`는 의미색까지 무채색으로 바꿔 **완전 흑백**이 된다(레벨 구분은 카드의 `💡 팁`/`⚠️ 주의`/`📌 상황` 라벨로 유지).
- 검수·도식화(§7.5)에서 색을 직접 지정하지 말고 **디자인 토큰/기본 팔레트 색**을 쓰면, 테마 적용이 SVG에도 일관되게 반영된다.

---

## 9. 검색 (복사·연결 — 템플릿에 스크립트 태그 내장)

위치 분리(한 화면 검색창 1개): **랜딩=사이트 전체 검색** + **각 문서=페이지 내 검색**. 템플릿에 아래가 이미 들어 있다:
```html
<!-- docs/index.html : </body> 직전 -->            <script src="assets/site-search.js" defer></script>
<!-- docs/<section>/*.html : </body> 직전 -->      <script src="../assets/inpage-search.js" defer></script>
```
- **필수 수정**: `assets/site-search.js`의 `DOCS` 배열을 새 문서 목록(path는 docs/ 기준 상대, title은 표시명)으로 교체.
  - **수동 누락 방지 헬퍼**(권장): 문서를 다 만든 뒤 아래로 `DOCS` 항목을 생성해 붙여넣으면 path 오타·누락을 줄인다. title은 각 파일 `<title>`에서 뽑으므로 표시용으로 다듬는다:
    ```bash
    cd "$PROJECT_DIR/docs"
    for f in */*_Manual.html */*_Examples.html */*_Chapter.html */*_Quiz.html; do
      [ -e "$f" ] || continue
      t=$(sed -n 's:.*<title>\(.*\)</title>.*:\1:p' "$f" | head -1)
      printf "    { path: '%s', title: '%s' },\n" "$f" "$t"
    done
    ```
- 색인 전제(템플릿이 이미 충족): `main` 안 `<h2 id>`(섹션)+`<h3>`(항목, 안에 `<code>`) / 카드류 `.scenario-card[id]`(안에 `<strong>` 제목, `<span>` 라벨). 챕터형은 `<h2 id>`+`<h3>`로, **문제 풀이는 각 문항이 `.scenario-card[id]`** 로 자동 색인된다.
- 카드의 `data-kind` 속성(예: `문제`·`Q&A`)이 검색 결과의 유형 라벨이 된다. 없으면 기존대로 `시나리오`로 표시(하위호환). 실습 예시 카드는 속성이 없어 그대로 `시나리오`.
- ⚠️ 페이지 내 검색은 **사이드바 nav를 필터링하지 않는다**(묶음 라벨이 통째로 사라지는 문제). 되살리지 말 것.

---

## 10. 네비게이션 — 홈 링크 (템플릿에 내장)

모든 문서 `nav` 최상단(템플릿에 이미 있음):
```html
<a href="../index.html" style="font-weight:700;color:#0969da;margin-bottom:8px;border-bottom:1px solid #d0d7de;padding-bottom:10px;">← 핸드북 홈</a>
```

---

## 11. 버전 관리 — 발행일 & 변경 이력

- **공개 사이트(랜딩)** → 랜딩 `.meta` 박스에 **최종 업데이트 날짜만**: `<br>최종 업데이트 <strong>YYYY년 M월 D일</strong>`
- **변경 이력** → 저장소 root `CHANGELOG.md`(비공개·미게시), 최신 항목 맨 위, `YYYY-MM-DD`.
- per-doc 버전 박스("문서 수집일"·"대상 버전")는 랜딩 날짜와 **의미가 다름**(혼동 말 것).
- ⚠️ 수동 날짜는 실제 배포일과 어긋나기 쉽다 → **배포 직전 자동 주입**으로 막는다. 아래 한 줄을 배포 스크립트(§12)에 넣으면 랜딩 날짜가 항상 배포일과 일치한다(macOS BSD `sed`/`date` 기준):
  ```bash
  TODAY=$(date +"%Y년 %-m월 %-d일")
  sed -i '' "s#최종 업데이트 <strong>[^<]*</strong>#최종 업데이트 <strong>$TODAY</strong>#" "$PROJECT_DIR/docs/index.html"
  ```
  (CHANGELOG 항목은 변경 요약이 필요하므로 수동 유지. per-doc 버전 박스의 "문서 수집일"은 실제 자료 수집 시점이라 자동 주입 대상이 아님.)

---

## 11.5 ★ 필수 — 배포 전 시크릿/비밀정보 보안 스캔 (발행 전 관문)

**시크릿이 저장소에 들어가지 않음을 확인하기 전에는 `git add`/푸시하지 않는다.** 저장소가 비공개여도 마찬가지다(계정 노출·실수로 공개 전환·협업자 등 경로가 있다). 로그인이 필요한 사이트 자료를 만들 때 `.env` 등에 자격증명을 두는 경우가 있는데, **이런 정보는 절대 동기화되면 안 된다.**

```bash
cd "$PROJECT_DIR"

# (1) .gitignore 가 시크릿을 실제로 제외하는지 — 추적 예정 목록에 위험 파일이 없어야 한다.
git add -A -n | grep -iE '\.env($|\.)|secret|credential|\.pem$|\.key$|\.p12$|\.pfx$|id_rsa|id_ed25519|\.netrc|service-account|token' \
  && { echo "⛔ 시크릿으로 의심되는 파일이 추적 대상에 있음 — .gitignore 보강 후 중단"; } \
  || echo "✓ 추적 대상에 의심 파일 없음"

# (2) 추적될 파일 내용에 자격증명 패턴이 박혀 있는지(하드코딩) 스캔 — docs/ 산문/코드 포함 전체.
git ls-files -co --exclude-standard | while read -r f; do
  grep -InE '(AKIA[0-9A-Z]{16}|ghp_[0-9A-Za-z]{36}|github_pat_[0-9A-Za-z_]{50,}|xox[baprs]-[0-9A-Za-z-]+|-----BEGIN [A-Z ]*PRIVATE KEY-----|(api[_-]?key|secret|password|passwd|token)\s*[:=]\s*["'\''][^"'\'' ]{8,})' "$f" \
    && echo "  ↑ $f 에서 시크릿 의심 패턴" 
done | tee /tmp/teachme-secretscan.txt
test ! -s /tmp/teachme-secretscan.txt || { echo "⛔ 하드코딩된 시크릿 의심 — 제거/치환 전 배포 중단"; }

# (3) 게시될 파일이 정적 산출물만인지 — docs/ 에 *.html·assets/*.js·.nojekyll 외 것이 없나 확인.
git ls-files docs | grep -vE '\.(html|js|css|svg|png|jpg|jpeg|gif|woff2?)$|/\.nojekyll$' || echo "✓ docs 추적 파일이 정적 산출물만"
```
- 위 세 점검을 **모두 통과**해야 배포로 넘어간다. 하나라도 걸리면 원인을 제거(파일 제외·하드코딩 치환)한 뒤 다시 스캔한다.
- 추가 도구가 있으면 함께 사용 권장: `gh secret-scanning`(푸시 보호), `gitleaks detect`(설치돼 있으면). 없어도 위 수동 스캔은 **생략 불가**.
- `.env` 등은 `templates/.gitignore`가 이미 제외한다. **`.env.example`처럼 값 없는 예시만** 허용하고, 실제 값이 든 파일은 절대 추적하지 않는다.

---

## 12. 배포 절차 (변수만 교체)

```bash
cd "$PROJECT_DIR"

# ── (A) 컬러 테마 적용 — 배포 직전 1회. azure 는 no-op (§8-A) ──
bash "$SKILL_DIR/references/apply-theme.sh" "$THEME" "$PROJECT_DIR/docs"

git init -b main
xattr -w 'com.apple.fileprovider.ignore#P' 1 "$(pwd)/.git"          # 클라우드 동기화 폴더(Dropbox 등)가 .git 동기화 안 하게
xattr -p 'com.apple.fileprovider.ignore#P' "$(pwd)/.git"            # → 1 확인

TODAY=$(date +"%Y년 %-m월 %-d일")                                   # 랜딩 날짜 자동 주입(날짜 어긋남 방지 — §11)
sed -i '' "s#최종 업데이트 <strong>[^<]*</strong>#최종 업데이트 <strong>$TODAY</strong>#" "$PROJECT_DIR/docs/index.html"

# ── (B) §11.5 시크릿 스캔을 통과한 뒤에만 add/commit ──
git add . && git commit -m "Publish $REPO (static site, docs/)"

# ── (C) 배포 전: GitHub 계정 + 계정 등급 확인 ──
gh auth status                                                       # 로그인된 계정·활성 계정 확인(다계정 대응)
test "$(gh api user --jq '.login')" = "$OWNER" \
  || echo "⚠️ 활성 계정 ≠ OWNER — gh auth switch [--user $OWNER] 로 전환 후 재확인"

PLAN=$(gh api user --jq '.plan.name')                               # free / pro / team …
echo "GitHub 플랜: $PLAN"
VIS="--private"
if [ "$PLAN" = "free" ]; then
  echo "⚠️ 무료 계정 — 비공개 저장소로는 Pages를 켤 수 없습니다."
  echo "   사이트를 게시하려면 저장소를 '공개(public)'로 만들어야 하며, 소스도 공개됩니다."
  echo "   → 사용자에게 (a) 공개로 진행 / (b) Pro 업그레이드 중 선택을 받은 뒤 VIS 를 정하세요."
  # 사용자가 공개 진행을 택했을 때만: VIS="--public"
fi
# 조직 소유면 OWNER/REPO 로 지정: gh repo create "$OWNER/$REPO" $VIS --source=. --push

gh repo create "$REPO" $VIS --source=. --push                       # 기본 비공개(+무료면 사용자 승인 후 공개)
gh api -X POST "/repos/$OWNER/$REPO/pages" \
  -f build_type=legacy -f "source[branch]=main" -f "source[path]=/docs"
gh api "/repos/$OWNER/$REPO/pages/builds/latest" --jq '.status+" "+.commit'   # built 대기
```

### 12-D. ★ 배포 후 — 저장소 README 생성 (라이브 주소 + 설명) — 필수

배포로 **Pages URL이 확정된 뒤**, 저장소 루트에 `README.md`를 생성한다(공개 URL은 배포 후에야 정해지므로 반드시 이 순서). 저장소 페이지 방문자가 "무엇인지·어디서 보는지"를 바로 알게 한다. **`docs/` 밖(루트)이라 Pages에는 게시되지 않는다.** 언어는 `LANG`(콘텐츠 언어)에 맞춘다.

담을 것: 제목(핸드북명) + 한 줄 설명 · **라이브 링크 `https://<OWNER>.github.io/<REPO>/`** · 목차/섹션 요약 · 대상 버전 · "Built with Teach Me"(선택).
```bash
PAGES_URL="https://$OWNER.github.io/$REPO/"
cat > "$PROJECT_DIR/README.md" <<EOF
# <핸드북 제목>

<한 줄 설명 — 무엇을 다루는지>

## Read it live
→ $PAGES_URL

## Contents
- <섹션/장 요약>

Built with the Teach Me skill for Claude Code.
EOF
cd "$PROJECT_DIR" && git add README.md && git commit -m "Add README with live Pages link and description" && git push
```
> 저장소가 비공개여도 README는 방문자(협업자·본인)에게 필요하다. 콘텐츠와 별개이며, 푸시 전 §11.5 시크릿 스캔 대상에 포함한다. 이후 `docs/`를 갱신할 때 라이브 URL은 그대로이므로 README 재작성은 불필요(내용이 바뀌면 목차만 손본다).

- 갱신: `docs/` 수정 → (테마 재적용 불필요, 이미 적용된 색 유지) → 랜딩 날짜·CHANGELOG 갱신 → §11.5 재스캔 → `git add . && git commit && git push`(Pages 자동 재빌드).
- **산출물(콘텐츠) 업데이트는 대화식이다.** 별도 기능이 아니라, **기존 프로젝트 폴더에서 실행하거나 그 폴더를 가리키고**(예: `/teachme update <경로>`) 사용자가 "여기를 이렇게 고쳐"라고 말하면 반영한다. 반영 후 위 갱신 절차(날짜·CHANGELOG·재스캔·push)를 따른다. 스킬 자체의 버전 업데이트(플러그인 릴리스)와는 별개다.
- 전제: `gh` 인증·git user 설정. **비공개 저장소 + 공개 Pages는 GitHub Pro 이상 필요**(무료는 공개 저장소만 — 위 (C)에서 안내·분기). 정적 HTML이라 `.nojekyll`로 Jekyll 우회.

---

## 13. 검증 절차

```bash
CURL=$(command -v curl || echo /usr/bin/curl)    # curl이 PATH에 없으면 절대경로로
BASE="https://$OWNER.github.io/$REPO"
for st in / "/<section-slug>/<문서>.html" ; do $CURL -s -o /dev/null -w "%{http_code}  $st\n" "$BASE$st"; done
```
- **Playwright headless 렌더 검증**(`/tmp`에 임시 설치 → 실행 → `rm -rf` 정리): 랜딩 카드 수, 각 문서 "← 핸드북 홈" **visible**, 랜딩 전체검색 결과·이동·`?q=` 자동 하이라이트, 페이지 내 검색 하이라이트·개수·nav 유지. SVG 도식이 있으면 **각 `figure`를 실제 렌더해 스크린샷으로 육안 점검**(자동 assert로는 못 잡음): (a) 텍스트가 박스·도형 밖으로 넘치지 않는지, (b) **번호 배지·아이콘과 라벨이 겹치지 않는지**, (c) 화살표·연결선이 노드/라벨을 가리지 않는지. 문제가 보이면 SVG를 고친 뒤 재촬영해 통과할 때까지 반복.
- `docs/` 밖 파일(CHANGELOG 등)은 사이트에서 404(미게시) 확인. 모바일 375px 레이아웃.

---

## 14. 함정·교훈 (반복 금지)

| 함정 | 대응 |
|------|------|
| 클라우드 동기화 폴더가 `.git` 동기화 → 손상 | `xattr -w 'com.apple.fileprovider.ignore#P' 1 .git`. 프로젝트는 동기화 폴더 안에 그대로(분산 회피) |
| 무료 플랜 비공개 Pages 불가 | 기본은 Pro 가정. **무료면 배포 전 "공개 저장소여야 게시됨"을 안내**하고 공개/업그레이드 선택받기(§1·§12 (C)). 게시 폴더는 `/` 또는 `docs`만 |
| **시크릿(.env·키·토큰)이 저장소에 동기화** | `templates/.gitignore`가 제외(이미 반영) + **§11.5 시크릿 스캔을 통과해야 add/push**. 비공개여도 커밋 금지 |
| 모든 섹션을 이론+실습으로 강제 → 실습 없는 주제에 빈 시나리오 | **구성 유형을 주제에 맞게 제안**(이론+실습/서술형 챕터/혼합, §2-A) 후 사용자 승인 |
| 색을 인라인 hex로 직접 지정 → 테마 적용이 일부만 반영 | 디자인 토큰/기본 팔레트 색만 사용. 테마는 `apply-theme.sh`가 브랜드 색을 일괄 치환(§8-A) |
| 산문에 영어 직역투/불필요한 외래어 | §7 언어별 검수(한국어는 7-A-1 외래어 순화까지 엄격). 코드·고유명사는 보존 |
| 활성 `gh` 계정이 의도한 `OWNER`와 달라 엉뚱한 계정에 저장소·공개 URL 생성 | 배포 전 `gh auth status` + `gh api user --jq .login` 으로 확인, 다르면 `gh auth switch`(§0·§12). 다계정(개인/업무) 전제 |
| 폴더명 공백 → `%20` URL | 무공백 슬러그 + 교차 링크 수정 |
| 절대경로 링크 깨짐 | **상대경로만**(base가 `/REPO/`) |
| 표 짝수행 어두운 배경 → 가독성 0 | `#f6f8fa` |
| 한 문단 `1) 2) 3)` 평문 → 줄바꿈 안 됨 | `<ol>/<ul>` 구조화 |
| 페이지 내 검색 nav 필터가 묶음 라벨 통째로 숨김 | nav 필터링 제거(하이라이트만) |
| 페이지 내 검색이 SVG `<text>`에 `<mark>` 주입 → 라벨 깨짐 | `inpage-search.js`에 SVG 네임스페이스 제외 가드(이미 포함) |
| SVG 번호 배지·아이콘이 라벨과 겹침(라벨을 중앙 `text-anchor=middle`로 두고 배지를 같은 줄 왼쪽에 배치) | 배지 오른쪽에서 라벨을 `text-anchor=start`로 시작(§7.5). 발행 전 **figure 스크린샷 육안 점검**(§13)으로 반드시 확인 |
| 하위→루트 복귀 링크 누락 | 모든 nav 상단 "← 핸드북 홈"(템플릿에 내장) |
| CDN `max-age=600` 캐시 | 검증은 `?cb=$(date +%s)`/Playwright, 브라우저 ⌘+Shift+R |
| `curl` PATH 없음 / zsh `status` 예약어 | curl 절대경로 / 루프 변수 `st` |
| 예시의 숨은 전제 | 재현 가능하게(현재 폴더 대상) 또는 전제 명시 |
| 도구가 `docs/`에 자동 생성한 `CLAUDE.md`(claude-mem 등)가 사이트에 게시됨 | `templates/.gitignore`에 `**/CLAUDE.md` 포함(이미 반영). 배포 전 `git ls-files docs` 로 `*.html`·`assets/*.js`·`.nojekyll`만 추적되는지 확인 |
| **검증 생략하고 발행** | §6 내용 검증 + §7 언어 검수 + §11.5 시크릿 스캔 **모두 통과 후** 발행 |

커밋 메시지 끝: `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`

---

## 15. 실행 체크리스트

- [ ] 파라미터 확정(**TOPIC·LANG은 사용자 입력**/THEME/REPO(폴더명 기본)/OFFICIAL_SOURCES/VERSION_TARGET/PROJECT_DIR/OWNER)
- [ ] **구성안(이론+실습/서술형 챕터/혼합, §2-A) 제안 + 사용자 승인**, 섹션 분할안 확인
- [ ] 공식 문서 조사(버전·수집일 기록)
- [ ] **이 스킬 `assets/`·`templates/`** 에서 `*.js`·`.nojekyll`·`index.html`·`.gitignore`·필요한 `Section_*.html`(Manual/Examples/Chapter/Quiz) 복사(§4)
- [ ] 섹션 작성 — 유형에 맞는 골격(레퍼런스/실습/서술형 챕터/문제 풀이·Q&A)으로 플레이스홀더를 실제 내용으로. **`LANG`으로 서술, 코드는 영어, 고유명사 원형**. `<html lang>` 설정
- [ ] **§6 내용 검증 하네스 실행**(학생→강사, 검토자→종합→적용)
- [ ] **§7.5 SVG 도식화**(선별) — 흐름·구조·비교 등 최적 지점. 배지/라벨은 `text-anchor=start`로 겹침 방지, **figure 스크린샷으로 겹침·오버플로 육안 점검**(§13)
- [ ] **§7 언어별 문법·표현 검수 하네스 실행**(한국어면 7-A-1 외래어 순화까지; 코드·고유명사 보존, 산문만, 과교정 금지) — 발행 전 필수 관문
- [ ] `site-search.js` `DOCS` 교체, `index.html` 제목·카드 교체
- [ ] 랜딩 최종 업데이트 날짜 + `CHANGELOG.md`
- [ ] **컬러 테마 적용**: `apply-theme.sh "$THEME" docs`(§8-A)
- [ ] **§11.5 시크릿 보안 스캔 통과**(.gitignore 제외 확인 + 하드코딩 패턴 스캔 + docs 정적 산출물만)
- [ ] git init + `.git` 동기화 제외 + 커밋 → **계정 등급 확인(무료면 공개 안내·승인)** → `gh repo create <비공개|승인 시 공개> --source=. --push` → Pages(main/docs) → built
- [ ] **배포 후 저장소 `README.md` 생성**(라이브 Pages URL + 설명 + 목차, `LANG`, docs/ 밖) → commit·push (§12-D)
- [ ] curl 200 + Playwright 렌더 검증 + 임시파일 정리

---

## 16. 전달용 킥오프 프롬프트 (파라미터만 채워 새 세션에 붙여넣기)

```text
이 스킬(Teach Me)의 제작 지시서(references/BUILD_GUIDE.md)를 먼저 끝까지 읽고 그대로 따라줘.

[작업] <TOPIC> 을(를) 깊게 다루는 <LANG> 핸드북을 만들어 GitHub Pages로 출판한다.
[파라미터]
- TOPIC = <사용자가 정한 주제. 예: Vercel 사용법>
- LANG  = <작성 언어. 내 요청 언어를 기본으로 제안. 예: 한국어 / English / 日本語>
- THEME = <azure(기본)|graphite|ink|teal|amber|indigo>
- REPO  = <폴더명 기반 기본 제안. 예: vercel-handbook>   (공개 URL에 노출되는 슬러그)
- OFFICIAL_SOURCES = <공식 문서·CLI 목록>
- VERSION_TARGET = <콘텐츠가 다루는 버전/플랫폼 기준>
- PROJECT_DIR = <새 프로젝트 폴더 절대경로>
- OWNER = <GitHub 계정/조직>

[필수 — 생략 불가]
- 추측 금지: WebSearch/WebFetch로 OFFICIAL_SOURCES 확인 후에만 작성. 버전·수집일 기록.
- 구성 유형(이론+실습 / 서술형 챕터 / 문제 풀이·Q&A / 혼합)을 주제에 맞게 제안하고 내 승인을 받은 뒤 작성(§2-A). 교재면 문제 풀이/Q&A를 선택적으로 제안.
- LANG 으로 서술. 실습 코드·식별자는 영어, 고유명사는 원형 유지. <html lang> 설정.
- §6 내용 검증 하네스(학생→강사, 검토자 관점→종합→적용)를 반드시 실행.
- §7.5 SVG 전문 디자이너 서브에이전트로 흐름·구조·비교 개념을 도식화(최적 지점에 선별).
- §7 언어별 검수 하네스를 발행 전 반드시 실행(한국어면 7-A-1 외래어 순화까지 엄격). 코드·고유명사는 손대지 말고 산문만 교정, 의미 변경·과교정 금지.
- 재사용 자산은 이 스킬의 assets/·templates/ 에서 복사(디자인·검색·배포는 도메인 무관). 콘텐츠만 새로 작성.
- 컬러 테마는 배포 직전 apply-theme.sh 로 적용(§8-A).
- 보안: §11.5 시크릿 스캔(.env·키·토큰 제외/하드코딩 패턴)을 통과해야 add/push. 비공개여도 시크릿 커밋 금지.
- 배포: 기본 비공개 + 공개 Pages(main/docs). 무료 계정이면 "공개 저장소여야 게시됨"을 안내·승인받기. 클라우드 동기화 폴더는 .git만 제외, 단일 위치 유지.
- 배포 후: 저장소 루트에 README.md 생성(라이브 Pages URL + 설명 + 목차, LANG). docs/ 밖이라 Pages 미게시(§12-D).
- 검증: curl 200 + Playwright headless(홈링크 visible, 검색 동작, ?q= 자동 하이라이트).

[진행 방식] 먼저 (1) 자료 조사 계획 (2) 섹션 분할안 + 구성 유형을 제시하고, 구현 착수 전 핵심 결정은 나에게 확인받아라.
```

---

*이 지시서는 도메인·언어 무관 범용판이다. 재사용 자산(검색 JS·HTML 골격·테마 적용기·`.nojekyll`·`.gitignore`)은 이 스킬의 `assets/`·`templates/`·`references/`에 동봉되어 있다.*

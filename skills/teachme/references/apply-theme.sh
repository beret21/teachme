#!/usr/bin/env bash
# apply-theme.sh — 핸드북 컬러 테마 적용기
# ─────────────────────────────────────────────────────────────────────────────
# 템플릿은 단 하나의 기본 팔레트(azure)로 작성돼 있다. 이 스크립트는 docs/ 를
# 복사·작성한 뒤 "브랜드 색 계열 hex"만 선택한 테마 색으로 치환한다.
# 핸드북은 처음부터 끝까지 한 테마를 쓰므로, 배포 직전 한 번 실행하면 된다.
#
# 의미색(초급=초록 / 고급=보라 등 난이도 레벨 코딩)은 컬러 테마에서 유지되고,
# 흑백 테마(ink)에서만 무채색으로 함께 치환된다.
#
# 사용:
#   bash references/apply-theme.sh <theme> "<PROJECT_DIR>/docs"
#   theme = azure(기본) | graphite | ink | teal | amber | indigo
#   azure 는 템플릿 기본색이라 아무것도 바꾸지 않는다(no-op).
#
# 대상: docs/ 하위 모든 *.html + docs/assets/*.js(검색창 포커스색 일치용)
# 주의: BSD sed(macOS) 기준. hex 는 모두 소문자 가정(템플릿이 소문자만 사용).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

THEME="${1:-azure}"
DOCS="${2:-}"
[ -n "$DOCS" ] || { echo "사용법: bash apply-theme.sh <theme> <docs_dir>" >&2; exit 2; }
[ -d "$DOCS" ] || { echo "오류: docs 디렉토리를 찾을 수 없습니다: $DOCS" >&2; exit 1; }

# 브랜드 색 8키 (azure 기본값) — 순서: primary primaryDark tintBg tintBorder tintSoft noteBg chipBg shadowRGB
B_PRIMARY="#0969da"; B_DARK="#0550ae"; B_TBG="#f0f7ff"; B_TBORDER="#a5d5f7"
B_TSOFT="#d0e8ff"; B_NOTE="#e8f4fd"; B_CHIP="#ddf4ff"; B_SHADOW="rgba(9,105,218"

PAIRS=()  # "from|to" 목록

case "$THEME" in
  azure)
    echo "azure(기본) — 치환 없음."; exit 0 ;;
  graphite)  # 그레이: 브랜드를 무채색 슬레이트로, 레벨 의미색은 유지
    PAIRS=( "$B_PRIMARY|#57606a" "$B_DARK|#424a53" "$B_TBG|#f6f8fa" "$B_TBORDER|#d0d7de" \
            "$B_TSOFT|#e1e4e8" "$B_NOTE|#f6f8fa" "$B_CHIP|#eaeef2" "$B_SHADOW|rgba(87,96,106" ) ;;
  teal)      # 청록
    PAIRS=( "$B_PRIMARY|#0e7490" "$B_DARK|#155e75" "$B_TBG|#ecfeff" "$B_TBORDER|#a5e0e8" \
            "$B_TSOFT|#c4eef2" "$B_NOTE|#e0f7fa" "$B_CHIP|#cdeff5" "$B_SHADOW|rgba(14,116,144" ) ;;
  amber)     # 따뜻한 앰버/브라운
    PAIRS=( "$B_PRIMARY|#b45309" "$B_DARK|#92400e" "$B_TBG|#fff8f0" "$B_TBORDER|#f3d3a8" \
            "$B_TSOFT|#f5e4cc" "$B_NOTE|#fdf2e3" "$B_CHIP|#fbe6cf" "$B_SHADOW|rgba(180,83,9" ) ;;
  indigo)    # 인디고/보라 — 레벨 보라(#6639ba)와 구분되도록 채도/명도 차이
    PAIRS=( "$B_PRIMARY|#4f46e5" "$B_DARK|#3730a3" "$B_TBG|#f1f0fe" "$B_TBORDER|#c7c4f5" \
            "$B_TSOFT|#dddbfa" "$B_NOTE|#ecebfd" "$B_CHIP|#e0defb" "$B_SHADOW|rgba(79,70,229" ) ;;
  ink)       # 완전 흑백: 브랜드 + 모든 의미색을 무채색으로. 구분은 ::before 라벨(💡⚠️📌)이 담당.
    PAIRS=( "$B_PRIMARY|#1f2328" "$B_DARK|#000000" "$B_TBG|#f6f8fa" "$B_TBORDER|#d0d7de" \
            "$B_TSOFT|#d0d7de" "$B_NOTE|#f6f8fa" "$B_CHIP|#eaeef2" "$B_SHADOW|rgba(0,0,0" \
            "#1a7f37|#1f2328" "#116329|#1f2328" "#dafbe1|#f6f8fa" "#a2d9b1|#d0d7de" "#0a3622|#1f2328" \
            "#6639ba|#1f2328" "#fbefff|#f6f8fa" "#d2b9ff|#d0d7de" \
            "#953800|#1f2328" "#7d4e00|#424a53" "#5c3900|#424a53" \
            "#d4a72c|#8c959f" "#fff8c5|#f6f8fa" "#fffbf0|#f6f8fa" \
            "#cf222e|#1f2328" ) ;;
  *)
    echo "오류: 알 수 없는 테마 '$THEME' (azure|graphite|ink|teal|amber|indigo)" >&2; exit 2 ;;
esac

# 대상 파일 수집(공백 안전)
FILES=()
while IFS= read -r -d '' f; do FILES+=("$f"); done \
  < <(find "$DOCS" -type f \( -name '*.html' -o -name '*.js' \) -print0)
[ "${#FILES[@]}" -gt 0 ] || { echo "경고: 치환할 html/js 파일이 없습니다($DOCS)." >&2; exit 0; }

for pair in "${PAIRS[@]}"; do
  from="${pair%%|*}"; to="${pair##*|}"
  # '#' 는 sed 구분자로 부적합 → '@' 사용. hex/rgba 에 '@' 없음.
  sed -i '' "s@${from}@${to}@g" "${FILES[@]}"
done

echo "테마 '$THEME' 적용 완료 — 파일 ${#FILES[@]}개, 치환 규칙 ${#PAIRS[@]}건."

# Bobmoo 공통 컨벤션 (Single Source of Truth)

이 문서는 모든 스킬이 참조하는 네이밍/포맷/정책의 단일 기준입니다.

## Prefix 매핑

| 의미 | 브랜치/커밋 (lowercase) | 이슈 제목 (TitleCase, 풀 단어) | PR 제목 (TitleCase, 축약) |
|------|------------------------|------------------------------|--------------------------|
| 기능 추가 | `feat` | `Feature` | `Feat` |
| 버그 수정 | `fix` | `Bug` | `Fix` |
| 리팩터링 | `refactor` | `Refactor` | `Refactor` |
| 설정/빌드/잡무 | `chore` | `Chore` | `Chore` |
| 문서 변경 | `docs` | `Docs` | `Docs` |
| 테스트 | `test` | `Test` | `Test` |

## 네이밍 형식

| 대상 | 형식 | 예시 |
|------|------|------|
| **이슈 제목** (GitHub + Linear) | `[Prefix] <작업내용>` | `[Feature] 로그인 화면 개선` |
| **브랜치** | `prefix/#이슈번호-브랜치네임` | `feat/#123-login-error-handling` |
| **커밋 메시지** | `prefix: #이슈번호 커밋내용` | `feat: #123 로그인 API 에러 처리 추가` |
| **PR 제목** | `Prefix/#이슈번호 제목` | `Feat/#123 로그인 에러 처리 개선` |

- 이슈 제목 끝에 `하기`를 붙이지 않는다.
- 커밋 메시지는 한국어 중심으로 작성하고, 기술 용어만 필요 시 영어를 혼용한다.
- 영어-only 커밋 메시지는 금지한다.

## 이슈 바디 템플릿

GitHub/Linear 모두 `.github/ISSUE_TEMPLATE/issue_template.md` 구조를 따른다:

```markdown
## 📝 작업 페이지 캡쳐
|    페이지    |   캡쳐   |
| :-------------: | :----------: |
| 피그마 | <img src = "" width ="250">

## ✔️ To-Do
- [ ] 세부적으로 적어주세요
```

- 두 섹션(작업 페이지 캡쳐, To-Do)을 항상 유지한다.
- 사용자가 체크리스트를 제공하면 기본 To-Do 항목을 대체한다.
- 추가 상세 내용은 템플릿 아래에 추가한다.

## PR 바디 템플릿

`.github/PULL_REQUEST_TEMPLATE.md` 구조를 그대로 따른다.

필수 항목:
- 연결된 이슈 (Linear URL + GitHub URL, 상호 링크 확인 체크박스)
- 작업 내용
- 구현 의도 / 결정 이유 (구현 의도가 있는 변경은 반드시 기록)
- Testing
- 주요 코드 설명 (실제 사용 방법/호출 방식 포함)

선택 항목 (없으면 제목까지 삭제):
- 참고자료 (실제 외부 참고자료만, 템플릿 경로 자체는 적지 않음)
- 기타 더 이야기해볼 점

## Priority 휴리스틱

사용자가 우선순위를 명시하지 않은 경우:

| 레벨 | 값 | 기준 |
|------|---|------|
| Urgent | 1 | 프로덕션 장애, 데이터 유실, 보안 사고, 릴리즈 블로커 |
| High | 2 | 사용자 영향 큰 장애, 높은 비즈니스 임팩트, 임박한 마감 |
| Medium | 3 | 일반 기능/작업 (기본값) |
| Low | 4 | 마이너 개선, 정리, nice-to-have |

근거가 약하면 `Medium (3)` 기본 적용.

## Label 휴리스틱

제목/본문 키워드에서 추론하되, 기존 라벨을 우선 사용:

| 키워드 | 라벨 |
|--------|------|
| bug/fix/error/crash | `bug` |
| feature/implement/add | `feature` |
| refactor/cleanup | `refactor` |
| test/qa | `test` |
| docs/readme | `documentation` |
| perf/slow | `performance` |
| security/auth/vulnerability | `security` |

추론 확신도가 낮으면 `Chore` (없으면 `Feature`) 폴백.

## Due Date 정책

- 사용자 지정 날짜가 항상 우선.
- 미지정 시 오늘 날짜 (`YYYY-MM-DD`, 사용자 타임존) 적용.

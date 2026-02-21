# Bobmoo Agent Workflow

이 문서는 에이전트가 작업을 수행할 때 따를 기본 운영 규칙입니다.
모든 네이밍/포맷/Priority/Label/Due Date 상세는 `.claude/skills/shared/conventions.md` 참조.

## Core Principle

- 모든 요청은 "작업 단위(task unit)"로 쪼개서 진행한다.
- 각 작업 단위는 이슈, 브랜치, 구현, 검증, PR까지 하나의 사이클로 완료한다.
- 큰 기능은 여러 작업 단위로 나누고, 단위별로 독립적으로 추적 가능해야 한다.

## Required Skills

| 작업 | 스킬 |
|------|------|
| Linear 이슈 생성 | `linear-issue-policy` |
| Linear + GitHub 동시 이슈 생성 | `linear-github-issue-sync` |
| Git 브랜치/커밋/PR | `git-master` |

스킬에서 정의한 제목/본문/라벨/우선순위/기한 정책을 우선 적용한다.

## Task Unit Flow (Mandatory)

1. 작업 분석 후 단위를 쪼갠다 (각 단위는 명확한 완료 조건 포함).
2. 이슈를 생성한다 → `linear-github-issue-sync` 적용.
3. 이슈 키 기반 브랜치를 만든다 → `git-master` 브랜치 컨벤션 적용.
4. 구현한다.
   - 구현 직전 Linear 이슈 상태를 `In Progress`로 변경.
   - 단위 범위를 벗어난 리팩토링은 하지 않는다.
   - 변경 후 빌드/테스트/진단으로 검증.
5. 커밋한다 → `git-master` 커밋 컨벤션 적용.
6. PR을 생성한다 → `git-master` PR 컨벤션 적용.

## Guardrails

- 이슈 없이 코드 작업을 시작하지 않는다 (긴급 hotfix 제외).
- 브랜치 없이 직접 기본 브랜치에서 작업하지 않는다.
- 검증 없이 PR을 올리지 않는다.
- Linear/GitHub 이슈 2종 생성 또는 상호 링크 확인 누락 상태로는 PR을 올리지 않는다.
- 관련 없는 변경을 함께 섞지 않는다.
- 사용자의 명시적 허락 없이 GitHub remote로 `push`하지 않는다.

## SwiftUI Asset Style Convention (Mandatory)

- SwiftUI에서 에셋 기반 아이콘/색상 사용 시 아래 스타일을 우선 적용한다.
- 이미지는 `Image("...")` 문자열보다 타입 세이프 자원 접근(`Image(.search)`)을 기본으로 사용한다.
- 컬러/스트로크도 토큰 스타일(`.stroke(.bobmooDarkGray, lineWidth: 1.5)`)을 기본으로 사용한다.
- 예시:

```swift
Button(action: {
}) {
    Image(.search)
}
.buttonStyle(.plain)
.padding(.trailing, 14)

.overlay(
    RoundedRectangle(cornerRadius: 20)
        .stroke(.bobmooDarkGray, lineWidth: 1.5)
)
```

## Start Trigger Protocol (Mandatory)

- `작업 시작`, `작업 시작하자`, `시작하자` 또는 `작업 준비`, `작업 준비하자`, `준비하자` 트리거 시:
  1) `linear-issue-policy` 적용해 Linear 이슈 생성
  2) `linear-github-issue-sync` 적용해 GitHub 이슈 동시 생성 및 상호 링크 확인
  3) `git-master` 규칙으로 이슈 키 기반 브랜치 생성
- 예외: 기존 Linear 이슈 키(예: `BOB-123`) 명시 시
  1) 해당 Linear 이슈 재사용 (새 이슈 생성 금지)
  2) GitHub 이슈 없으면 생성, 있으면 링크 검증
  3) 해당 이슈 키 기반 브랜치 생성/전환
- `작업 시작`/`작업 준비` 트리거만으로는 구현을 시작하지 않는다.
  - 기본 동작은 **이슈 2종 + 브랜치 준비 완료까지**로 제한.
  - 구현은 `구현 시작`, `만들어`, `수정해` 등 명시적 구현 지시 후에만 진행.
  - 구현 착수 시 Linear 이슈 상태를 `In Progress`로 변경.
- 3단계 중 하나라도 실패하면 실패 지점과 재시도 계획을 먼저 보고한다.
- Linear/GitHub 이슈 URL 모두 확보 후 다음 단계 진행.
- 구현 완료 후에도 사용자 명시 허락 전 `push` 금지.

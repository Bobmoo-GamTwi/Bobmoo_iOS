---
name: linear-issue-policy
description: Linear MCP 이슈 생성 시 기본값(상태 Todo, 본인 할당, 우선순위/라벨/기한) 정책을 강제 적용한다. "이슈 만들어", "태스크 생성", "Linear에 등록" 등 요청 시 적용.
---

# Linear Issue Policy

## When to Use

- Linear 이슈/티켓/태스크 생성 요청 시.
- 기존 이슈 키(예: `BOB-123`) 기반 `작업 준비` 요청 시 → 새 이슈 생성하지 않고 `linear-github-issue-sync`로 넘긴다.

## Required Policy

Linear 이슈 생성 시 아래 규칙 적용:

1. **Assignee**: 현재 인증된 사용자 (`me`)
2. **State**: `Todo`
3. **Priority**: 컨텍스트에서 추론 (상세 기준은 [shared/conventions.md](../shared/conventions.md) Priority 휴리스틱 참조)
4. **Labels**: 제목/본문에서 추론 (상세 기준은 [shared/conventions.md](../shared/conventions.md) Label 휴리스틱 참조)
5. **Due Date**: 사용자 지정 날짜 또는 오늘 (상세는 [shared/conventions.md](../shared/conventions.md) Due Date 정책 참조)

## Title & Body Convention

- 제목 형식: `[Prefix] <작업내용>` (하기 금지)
- Prefix: `Feature`, `Bug`, `Refactor`, `Chore`, `Docs`, `Test`
- 바디 템플릿: [shared/conventions.md](../shared/conventions.md) 이슈 바디 템플릿 참조

사용자가 형식에 맞지 않는 제목을 주면 정규화 후 생성한다.

## Execution Checklist

1. 대상 팀/프로젝트 식별
2. 현재 사용자 resolve → assignee
3. 팀 워크플로우 state에서 `Todo` 찾기
4. 이슈 payload 구성: team, title, description, assignee(me), state(Todo), priority(명시적 1~4), labels(최소 1개), dueDate
5. 이슈 생성 → identifier + URL + state + assignee + due date 반환

## Response Format

항상 포함: Issue identifier, URL, Team, State(`Todo`), Assignee(me), Priority, Labels, Due date

## Guardrails

- Assignee 비우지 않음 (사용자가 명시적으로 미할당 요청 시 제외)
- State를 `Backlog`로 두지 않음
- Due date, Priority, Labels 생략 금지
- `Todo` state 없으면 가장 근접한 planned state 선택 후 명시
- 기존 이슈 키 기반 `작업 준비` 시 중복 이슈 생성 금지

---
name: linear-github-issue-sync
description: Linear과 GitHub 이슈를 동시에 생성하고 동일 제목/본문/상호 링크를 보장한다. "작업 시작", "작업 준비", "이슈 동기화" 등 요청 시 적용.
---

# Linear + GitHub Issue Sync

## When to Use

- Linear + GitHub 이슈 동시 생성 요청 시
- `작업 시작` / `작업 준비` 트리거 시 (AGENTS.md Start Trigger Protocol에서 호출)
- 기존 Linear 이슈 키(예: `BOB-123`)로 `작업 준비` 시 → GitHub 이슈 보완 + 링크 검증

## Convention

제목/바디/Priority/Label/Due Date 규칙은 모두 [shared/conventions.md](../shared/conventions.md) 참조.

## Linear Defaults

- Assignee: `me`
- State: `Todo`
- Priority: 추론 후 명시적 1~4 값 설정
- Labels: 추론 후 최소 1개 설정
- Due Date: 사용자 지정 또는 오늘

## GitHub Defaults

- Repository: 현재 repo 기본 (`gh repo view`)
- Labels: 추론 후 최소 1개. 없으면 생성 후 적용.
- Assignee: `@me` (권한 허용 시)
- Milestone/project: 사용자 명시 요청 시만 설정

## Sync Execution Flow

1. 제목을 `[Prefix] <작업내용>` 형식으로 정규화
2. 바디 템플릿으로 canonical body 구성
3. Linear 이슈 먼저 생성 (Linear Defaults 적용)
4. GitHub 이슈 동일 제목/바디로 생성
5. 양방향 크로스 링크:
   - Linear description에 `GitHub: <url>` 추가
   - GitHub body에 `Linear: <url>` 추가 (body 수정 불가 시 첫 comment)
6. 양쪽 identifier/URL 한 번에 반환
7. 양쪽 URL 확인 전까지 구현/PR 진행 금지

## Existing Issue Preparation Flow

기존 Linear 이슈 키 기반 `작업 준비` 시:

1. 해당 Linear 이슈 재사용 (새 이슈 생성 금지)
2. 연결된 GitHub 이슈 존재 여부 확인
3. 없으면 Linear 이슈의 정규화된 제목/바디로 GitHub 이슈 생성
4. 양방향 크로스 링크 보장
5. 반환: Linear identifier/URL, GitHub issue number/URL, 링크 동기화 상태

## Failure Handling

- **Linear 성공 + GitHub 실패**: Linear 유지, Linear에 실패 사유 코멘트, partial success 보고, 구현 차단
- **GitHub 성공 + Linear 실패**: GitHub에 실패 사유 코멘트, partial success 보고, 구현 차단
- 한쪽 실패를 조용히 넘기지 않는다.
- Priority/Labels 설정 실패 시 사유 명시 후 폴백값으로 1회 재시도.

## Response Format

항상 반환:
- Linear: identifier, URL, state, assignee, priority, labels, due date
- GitHub: issue number, URL, assignee, labels
- Sync status: `full success` 또는 `partial success` + 실패 사유

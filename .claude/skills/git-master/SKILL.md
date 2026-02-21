---
name: git-master
description: Git 작업 시 브랜치 네이밍, 커밋 메시지, PR 제목 컨벤션을 강제 적용한다. "커밋", "브랜치 만들어", "PR 올려", "푸시" 등 Git 관련 요청 시 자동 적용.
---

# Git Master (Bobmoo Convention)

Git 관련 작업(브랜치, 커밋, PR)에서 팀 컨벤션을 일관되게 적용하기 위한 규칙 세트다.
모든 네이밍/포맷 상세는 [shared/conventions.md](../shared/conventions.md) 참조.

## When to Use

- Git 브랜치를 새로 만들 때
- 커밋 메시지를 작성할 때
- Pull Request를 생성할 때

## Core Conventions

### 1) Code Convention

- Swift 코딩 스타일은 StyleShare Swift Style Guide를 따른다.
- Reference: https://github.com/StyleShare/swift-style-guide

### 2) Commit Convention

- 형식: `prefix: #이슈번호 커밋내용`
- 예시: `feat: #123 로그인 API 에러 처리 추가`
- 예시: `refactor: #13 BobmooText 스타일 전환 및 lineHeight 적용`
- 한국어 중심, 기술 용어만 영어 혼용. 영어-only 금지.
- 자동 생성 서명/광고성 문구 포함 금지.
- 커밋 전 3개 체크 필수:
  1) 브랜치명에서 이슈번호 확인 (`prefix/#이슈번호-...`)
  2) 메시지가 `prefix: #이슈번호 커밋내용` 패턴 준수
  3) 메시지가 staged 변경 목적과 일치
- 하나라도 실패하면 커밋하지 않고 정정안 먼저 제시.

### 3) Branch Convention

- 형식: `prefix/#이슈번호-브랜치네임`
- 예시: `feat/#123-login-error-handling`
- 이슈 없이 브랜치를 만들지 않는다.

### 4) PR Convention

- 형식: `Prefix/#이슈번호 제목`
- 예시: `Feat/#123 로그인 에러 처리 개선`
- PR 본문은 `.github/PULL_REQUEST_TEMPLATE.md` 구조를 따른다.
- PR 본문에 `구현 의도/결정 이유` 반드시 작성.
- PR 본문에 Linear/GitHub 이슈 URL 2개 모두 기입, 상호 링크 확인.
- PR 생성 직후 Linear 이슈의 PR 리소스에 GitHub PR 링크 연동. 누락 시 즉시 보완.
- PR 생성 시 assignee는 `@me`, 라벨 최소 1개 지정.

### Prefix 매핑

> 상세 매핑 테이블은 [shared/conventions.md](../shared/conventions.md) 참조.

- `feat` / `fix` / `refactor` / `chore` / `docs` / `test`

## MUST DO

- 커밋 메시지에 반드시 이슈 번호 포함.
- 브랜치 prefix와 PR Prefix를 의미에 맞게 일치.
- Swift 코드는 StyleShare 가이드 기준 리뷰.
- 사용자 명시 허락 전 push 금지.
- 구현 시작 전 Linear 이슈 상태 `In Progress` 전환 확인.
- PR 생성 전 Linear/GitHub 이슈 모두 존재 및 상호 링크 확인.

## MUST NOT DO

- 이슈 번호 없는 커밋 생성 금지.
- 임의 브랜치명(`test`, `temp`, `fix2` 등) 사용 금지.
- PR 제목에 Prefix/이슈번호 누락 금지.
- 패턴 불일치 메시지로 커밋 강행 금지.
- 영어-only 커밋 메시지 사용 금지.
- 커밋 메시지에 에이전트/봇 서명, 도구 홍보 문구 포함 금지.

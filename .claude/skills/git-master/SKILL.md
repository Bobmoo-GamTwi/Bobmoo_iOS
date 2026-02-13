---
name: git-master
description: Git 작업 시 이슈 생성, 브랜치 네이밍, 커밋 메시지, PR 제목 컨벤션을 강제 적용한다.
---

# Git Master (Bobmoo Convention)

## Overview

이 스킬은 Git 관련 작업(이슈, 브랜치, 커밋, PR)에서 팀 컨벤션을 일관되게 적용하기 위한 규칙 세트다.

## When to Use

- Git 브랜치를 새로 만들 때
- 커밋 메시지를 작성할 때
- Pull Request를 생성할 때
- 작업 시작 전 이슈 생성 및 네이밍 규칙을 확인할 때

## Core Conventions

### 1) Code Convention

- Swift 코딩 스타일은 StyleShare Swift Style Guide를 따른다.
- Reference: https://github.com/StyleShare/swift-style-guide

### 2) Commit Convention

- 커밋 메시지 형식: `#이슈번호 커밋내용`
- 예시: `#123 로그인 API 에러 처리 추가`
- 커밋 메시지는 한국어 중심으로 작성하고, 기술 용어만 필요 시 영어를 혼용한다.
- 영어-only 메시지는 금지한다.
- 예시: `#123 BobmooText 스타일 전환 및 lineHeight 적용`
- 커밋 전에 반드시 브랜치명에서 이슈번호를 확인한다. (`prefix/#123-...`)
- 메시지 검증 실패 시 커밋하지 않고 정정안을 먼저 제시한다.

### 3) Git Flow

1. 먼저 이슈를 생성한다.
2. 이슈 제목은 `[Prefix] 뭐뭐` 형식을 따른다. (`하기` 접미사는 사용하지 않는다)
3. 이슈에서 브랜치를 생성한다.
4. 브랜치 이름은 `prefix/#이슈번호-브랜치네임` 형식을 따른다.
5. 예시: `feat/#123-login-error-handling`

### 4) PR Convention

- PR 제목 형식: `Prefix/#이슈번호 제목`
- 예시: `Feat/#123 로그인 에러 처리 개선`

## MUST DO

- 이슈 없이 브랜치를 만들지 않는다.
- 커밋 메시지에 반드시 이슈 번호를 포함한다.
- 브랜치 prefix와 PR Prefix를 의미에 맞게 일치시킨다.
- 팀 내 Swift 코드는 StyleShare 가이드를 기준으로 리뷰한다.
- 커밋 직전 아래 3개를 체크한다.
  1) 브랜치 이슈번호와 메시지 이슈번호 일치
  2) 메시지가 `#이슈번호 커밋내용` 패턴 준수
  3) 메시지가 staged 변경 목적과 일치

## MUST NOT DO

- 이슈 번호 없는 커밋 생성 금지
- 임의 브랜치명(`test`, `temp`, `fix2` 등) 사용 금지
- PR 제목에 Prefix/이슈번호 누락 금지
- 패턴 불일치 메시지로 커밋 강행 금지
- 영어-only 커밋 메시지 사용 금지

## Prefix Recommendation

- `feat`: 기능 추가
- `fix`: 버그 수정
- `refactor`: 리팩터링
- `chore`: 설정/빌드/잡무
- `docs`: 문서 변경
- `test`: 테스트 코드 변경

## Output Template

### Issue Title

`[Prefix] 작업내용`

### Branch Name

`prefix/#이슈번호-브랜치네임`

### Commit Message

`#이슈번호 커밋내용`

### PR Title

`Prefix/#이슈번호 제목`

---
name: verify-swiftui-assets
description: SwiftUI 에셋 사용 규칙(타입 세이프 Image/Color 접근, 문자열 기반 접근 금지)을 검증한다. SwiftUI 뷰/컴포넌트 구현 후, PR 전 사용.
---

# SwiftUI Asset Style 검증

## Purpose

1. **타입 세이프 Image 접근** — `Image("문자열")` 대신 `Image(.assetName)` 사용 여부 검증
2. **타입 세이프 Color 접근** — `Color("문자열")` 대신 `.bobmooColorName` 토큰 사용 여부 검증
3. **stroke 토큰 스타일** — `.stroke(.bobmooXxx, lineWidth: N)` 패턴 준수 여부 검증

## When to Run

- SwiftUI 뷰 또는 컴포넌트 파일을 수정한 후
- 새로운 에셋(이미지/색상)을 추가한 후
- PR 전 코드 규칙 준수 확인 시

## Related Files

| File | Purpose |
|------|---------|
| `Bobmoo_iOS/Bobmoo_iOS/Extensions/Color+.swift` | Color 토큰 정의 |
| `Bobmoo_iOS/Bobmoo_iOS/Assets.xcassets/Colors/` | 색상 에셋 카탈로그 |
| `Bobmoo_iOS/Bobmoo_iOS/Assets.xcassets/Images/` | 이미지 에셋 카탈로그 |
| `Bobmoo_iOS/Bobmoo_iOS/Components/*.swift` | 공통 컴포넌트 |
| `Bobmoo_iOS/Bobmoo_iOS/Home/HomeView.swift` | 메인 뷰 |
| `Bobmoo_iOS/Bobmoo_iOS/Splash/SplashView.swift` | 스플래시 뷰 |

## Workflow

### Step 1: 문자열 기반 Image 사용 탐지

**검사:** Swift 파일에서 `Image("...")` 패턴이 있는지 확인.

```bash
grep -rn 'Image("' Bobmoo_iOS/Bobmoo_iOS/ --include='*.swift'
```

**PASS:** 결과 없음 (모든 Image가 타입 세이프 접근 사용)
**FAIL:** `Image("문자열")` 패턴 발견 → `Image(.assetName)` 으로 변경 필요

### Step 2: 문자열 기반 Color 생성 탐지

**검사:** Swift 파일에서 `Color("...")` 패턴이 있는지 확인. 단, `Color+.swift` 토큰 정의 파일은 제외.

```bash
grep -rn 'Color("' Bobmoo_iOS/Bobmoo_iOS/ --include='*.swift' | grep -v 'Color+.swift'
```

**PASS:** 결과 없음 (모든 Color가 토큰 스타일 사용)
**FAIL:** `Color("문자열")` 직접 호출 발견 → `.bobmooXxx` 토큰으로 변경 필요

### Step 3: UIColor 직접 사용 탐지

**검사:** SwiftUI 파일에서 UIColor를 직접 사용하는지 확인.

```bash
grep -rn 'UIColor' Bobmoo_iOS/Bobmoo_iOS/ --include='*.swift' | grep -v 'Extensions/'
```

**PASS:** 결과 없음
**FAIL:** UIColor 직접 사용 발견 → SwiftUI Color 토큰으로 변경 필요

### Step 4: 하드코딩된 색상 값 탐지

**검사:** SwiftUI 파일에서 `Color(red:`, `Color.init(red:` 등 하드코딩된 RGB 값이 있는지 확인.

```bash
grep -rn 'Color(red:' Bobmoo_iOS/Bobmoo_iOS/ --include='*.swift' | grep -v 'Extensions/'
```

**PASS:** 결과 없음
**FAIL:** 하드코딩 색상 발견 → 에셋 카탈로그에 등록 후 토큰으로 접근

## Output Format

```markdown
| # | 검사 | 상태 | 위반 파일 | 상세 |
|---|------|------|-----------|------|
| 1 | 타입 세이프 Image | PASS/FAIL | `file:line` | 설명 |
| 2 | 타입 세이프 Color | PASS/FAIL | `file:line` | 설명 |
| 3 | UIColor 미사용 | PASS/FAIL | `file:line` | 설명 |
| 4 | RGB 하드코딩 미사용 | PASS/FAIL | `file:line` | 설명 |
```

## Exceptions

1. **`Color+.swift` 토큰 정의 파일** — `Color("Bobmoo_Red")` 같은 문자열 기반 접근은 토큰을 정의하는 파일 자체에서만 허용
2. **`RGB+.swift` Extension** — `Color(red:green:blue:)` init은 Extension 정의에서 허용
3. **동적 색상 (서버 전달값)** — `Color(hexRGB:)` 같은 런타임 동적 색상 변환은 위반이 아님
4. **시스템 색상** — `.white`, `.black`, `.clear` 등 SwiftUI 시스템 색상은 위반이 아님

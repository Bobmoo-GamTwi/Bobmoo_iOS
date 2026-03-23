# Bobmoo Analytics Tracking Plan

## 1. 문서 목적

- 이 문서는 `Firebase Analytics -> Amplitude` 전환 기간에 사용할 이벤트 트래킹 기준 문서다.
- 현재 코드베이스에 구현된 이벤트를 기준으로 이벤트명, 발생 위치, 조건, 속성, 예시 payload, 대시보드 사용처를 정의한다.
- 병행 수집 기간에는 Firebase와 Amplitude에 동일한 이벤트명과 동일한 속성 키를 유지하는 것을 원칙으로 한다.

## 2. 적용 범위

- 앱 범위: `Bobmoo_iOS` iOS 앱
- 기준 구현: `Bobmoo_iOS/Bobmoo_iOS/Analytics/BobmooAnalytics.swift`
- 기준 화면: `splash`, `onboarding`, `search`, `home`, `setting`
- 제외 대상: 개발 확인용 `debug_test` 이벤트는 운영 대시보드 및 Amplitude 마이그레이션 대상에서 제외한다.

## 3. 마이그레이션 원칙

### 3.1 이벤트 네이밍

- 커스텀 이벤트는 모두 `snake_case`를 유지한다.
- 화면 진입 이벤트는 화면별 `*_viewed` 이벤트명으로 구분한다.
- 이벤트명 변경이 필요한 경우 신규 이름을 추가하지 말고 본 문서를 먼저 갱신한 뒤 일괄 전환한다.

### 3.2 속성 설계 원칙

- 이름, 전화번호, 이메일 등 직접 식별 가능한 개인정보는 이벤트 속성으로 보내지 않는다.
- 학교명, 식당명, 날짜, 검색 길이, 결과 수 등 서비스 사용 맥락 정보만 수집한다.
- 병행 수집 기간에는 동일 이벤트의 속성 키, 값 타입, nullable 여부를 Firebase와 Amplitude에서 동일하게 유지한다.
- 날짜 속성은 현재 구현과 동일하게 `yyyy-MM-dd` 문자열을 기준으로 사용한다.

### 3.3 병행 수집 운영 단계

1. `Schema freeze`
   - 본 문서 기준으로 이벤트명과 속성 키를 고정한다.
2. `Dual write`
   - Firebase와 Amplitude에 동일 이벤트를 함께 전송한다.
3. `Validation`
   - 필수 대시보드 100% 재현, 핵심 이벤트 건수 차이 허용 범위 검증, 속성 누락률 점검을 수행한다.
4. `Firebase stop`
   - 종료 조건 충족 후 Firebase 신규 수집을 중단하고 Amplitude 단일 수집으로 전환한다.

## 4. 공통 속성 기준

### 4.1 공통으로 확인할 속성

- 화면 진입 이벤트
  - `entry_point` (optional)
  - `route_source` (optional)
  - `selected_date` (`home_viewed`만)
- 그 외 커스텀 이벤트
  - 이벤트별 명시 속성만 사용
  - nullable 속성은 현재 Firebase 구현처럼 `nil`이면 제외 가능

### 4.2 권장 운영 메타데이터

아래 값은 SDK 또는 래퍼 레벨에서 자동 부착하는 것을 권장한다.

- `platform`: `iOS`
- `app_version`
- `build_number`
- `environment`: `prod` / `staging`

## 5. 이벤트 카탈로그

### 5.1 앱 라이프사이클 및 라우팅

#### `splash_viewed` / `onboarding_viewed` / `search_viewed` / `home_viewed` / `settings_viewed`

- 위치: `Presentation/RootView.swift` `trackRoute(_:, entryPoint:)`
- 조건: 각 화면 라우트로 진입할 때 해당 화면 이름의 `*_viewed` 이벤트를 전송
- 속성:
  - `entry_point` (optional)
  - `route_source` (optional)
  - `selected_date` (`home_viewed`만)
- 예시 payload:

```json
{
  "entry_point": "app_launch",
  "route_source": "splash"
}
```

- 대시보드 사용처: 화면 진입수, 화면 전환 흐름, 진입 경로별 유입 분석

#### `app_opened`

- 위치: `Presentation/RootView.swift` `.task`
- 조건: 앱 초기 진입 시 1회
- 속성:
  - `has_selected_school`
- 예시 payload:

```json
{
  "has_selected_school": true
}
```

- 대시보드 사용처: DAU, 기존 사용자/미설정 사용자 비중, 앱 오픈 대비 활성화율

#### `onboarding_started`

- 위치: `Presentation/RootView.swift` `OnboardingView` 진입 액션
- 조건: 온보딩 화면에서 시작 CTA를 눌렀을 때
- 속성:
  - `has_selected_school`
- 예시 payload:

```json
{
  "has_selected_school": false
}
```

- 대시보드 사용처: 온보딩 시작률, 학교 선택 전환 퍼널 시작점

#### `deep_link_opened`

- 위치: `Presentation/RootView.swift` `.onOpenURL`
- 조건: `bobmoo://` 딥링크가 열릴 때
- 속성:
  - `destination`
- 예시 payload:

```json
{
  "destination": "home"
}
```

- 대시보드 사용처: 딥링크 유입량, 진입 목적지별 사용량, 위젯/외부 링크 기여도

#### `home_viewed`

- 위치: `Presentation/RootView.swift` `trackRoute(_:, entryPoint:)`
- 조건: `home` 라우트 진입 시
- 속성:
  - `entry_point` (optional)
  - `route_source` (optional)
  - `selected_school_name`
  - `selected_date`
- 예시 payload:

```json
{
  "selected_school_name": "충북대학교",
  "selected_date": "2026-03-23"
}
```

- 대시보드 사용처: 홈 진입수, 학교별 활성 사용자 분포, 날짜 탐색 시작점

### 5.2 학교 검색 및 선택 퍼널

#### `school_directory_loaded`

- 위치: `Presentation/Search/SearchViewModel.swift` `loadAllSchools()`
- 조건: 전체 학교 목록 로드 성공 시
- 속성:
  - `school_count`
- 예시 payload:

```json
{
  "school_count": 412
}
```

- 대시보드 사용처: 검색 준비 상태 확인, 학교 목록 로드 품질 모니터링

#### `school_search_performed`

- 위치: `Presentation/Search/SearchViewModel.swift` `search(query:)`
- 조건: 검색어 입력 또는 빈 검색어 초기화 시
- 속성:
  - `query_length`
  - `result_count`
  - `is_empty_query`
- 예시 payload:

```json
{
  "query_length": 3,
  "result_count": 7,
  "is_empty_query": false
}
```

- 대시보드 사용처: 검색 사용률, 무결과 비중, 검색어 길이 대비 결과 품질

#### `school_selected`

- 위치: `Presentation/Search/SearchViewModel.swift` `selectSchool(_:)`
- 조건: 학교 검색 결과에서 특정 학교를 탭했을 때
- 속성:
  - `selected_school_id`
  - `selected_school_name`
- 예시 payload:

```json
{
  "selected_school_id": 1234,
  "selected_school_name": "충북대학교"
}
```

- 대시보드 사용처: 학교 선호도, 검색 결과 클릭률, 학교별 활성 사용자 분포

#### `school_selection_completed`

- 위치: `Presentation/Search/SearchView.swift` "선택완료" 버튼
- 조건: 학교 선택 플로우 완료 버튼 탭 시
- 속성:
  - `selected_school_id`
  - `selected_school_name`
- 예시 payload:

```json
{
  "selected_school_id": 1234,
  "selected_school_name": "충북대학교"
}
```

- 대시보드 사용처: 학교 선택 완료율, 온보딩 활성화 퍼널 완료 지점

### 5.3 메뉴 조회 및 데이터 품질

#### `home_date_swiped`

- 위치: `Presentation/Home/HomeViewModel.swift` `handleTabChange(_:)`
- 조건: 홈에서 날짜를 좌우 스와이프해 이동할 때
- 속성:
  - `direction`
  - `from_date`
  - `to_date`
- 예시 payload:

```json
{
  "direction": "next",
  "from_date": "2026-03-23",
  "to_date": "2026-03-24"
}
```

- 대시보드 사용처: 날짜 이동 패턴, 전일/익일 탐색 성향, 홈 탐색 깊이

#### `calendar_opened`

- 위치: `Resource/Components/BobmooCalendarButton.swift`
- 조건: 홈 상단 날짜 버튼을 눌러 캘린더 시트를 열 때
- 속성:
  - `selected_date`
- 예시 payload:

```json
{
  "selected_date": "2026-03-23"
}
```

- 대시보드 사용처: 캘린더 사용률, 날짜 이동 UI 선호도 비교

#### `calendar_date_selected`

- 위치: `Presentation/Home/HomeViewModel.swift` `dateDidChange(from:to:)`
- 조건: 캘린더 시트가 열린 상태에서 날짜를 변경했을 때
- 속성:
  - `previous_date`
  - `selected_date`
- 예시 payload:

```json
{
  "previous_date": "2026-03-23",
  "selected_date": "2026-03-27"
}
```

- 대시보드 사용처: 캘린더 기반 점프 이동 수요, 급식 조회 선행 날짜 범위 분석

#### `menu_viewed`

- 위치: `Presentation/Home/HomeViewModel.swift` `dateDidChange(from:to:)`
- 조건: 현재 날짜가 바뀌고 해당 날짜 메뉴를 조회 상태로 진입했을 때
- 속성:
  - `selected_date`
  - `selected_school_name`
  - `cafeteria_count`
  - `source`
- 예시 payload:

```json
{
  "selected_date": "2026-03-27",
  "selected_school_name": "충북대학교",
  "cafeteria_count": 3,
  "source": "calendar"
}
```

- 대시보드 사용처: 날짜별 메뉴 조회량, 학교별 급식 소비 패턴, 캘린더/스와이프 유입 비교

#### `menu_reload_requested`

- 위치: `Presentation/Home/HomeViewModel.swift` `reloadDate(_:source:)`
- 조건: pull-to-refresh 등으로 메뉴 재조회가 시작될 때
- 속성:
  - `selected_date`
  - `source`
- 예시 payload:

```json
{
  "selected_date": "2026-03-23",
  "source": "pull_to_refresh"
}
```

- 대시보드 사용처: 재시도 빈도, 데이터 신뢰도 이슈 징후, 수동 새로고침 비율

#### `menu_load_succeeded`

- 위치: `Presentation/Home/HomeViewModel.swift` `loadIfNeeded(date:source:)`, `reloadDate(_:source:)`
- 조건: 급식 데이터 로드 성공 시
- 속성:
  - `selected_date`
  - `selected_school_name`
  - `cafeteria_count`
  - `source`
- 예시 payload:

```json
{
  "selected_date": "2026-03-23",
  "selected_school_name": "충북대학교",
  "cafeteria_count": 3,
  "source": "current_date"
}
```

- 대시보드 사용처: 메뉴 로드 성공률, 사전 로딩 품질, 소스별 성공 성능 비교

#### `menu_load_failed`

- 위치: `Presentation/Home/HomeViewModel.swift` `loadIfNeeded(date:source:)`, `reloadDate(_:source:)`
- 조건: 급식 데이터 로드 실패 시
- 속성:
  - `selected_date`
  - `selected_school_name`
  - `source`
  - `error_domain`
  - `error_code`
  - `error_message_sanitized`
- 예시 payload:

```json
{
  "selected_date": "2026-03-23",
  "selected_school_name": "충북대학교",
  "source": "pull_to_refresh",
  "error_domain": "NSURLErrorDomain",
  "error_code": -1009,
  "error_message_sanitized": "The Internet connection appears to be offline."
}
```

- 대시보드 사용처: 실패율, 에러 메시지 상위 원인, 날짜/소스별 장애 탐지

### 5.4 설정, 유지, 업데이트

#### `settings_viewed`

- 위치: `Presentation/RootView.swift` 홈의 설정 버튼 액션
- 조건: 홈에서 설정 화면으로 이동할 때
- 속성:
  - `source`
  - `entry_point` (optional)
  - `route_source` (optional)
  - `selected_school_name`
- 예시 payload:

```json
{
  "source": "home",
  "selected_school_name": "충북대학교"
}
```

- 대시보드 사용처: 설정 진입률, 홈 대비 설정 전환율

#### `school_setting_tapped`

- 위치: `Presentation/RootView.swift` 설정 화면의 학교 설정 진입 액션
- 조건: 설정에서 학교 변경 진입 버튼을 눌렀을 때
- 속성:
  - `selected_school_name`
- 예시 payload:

```json
{
  "selected_school_name": "충북대학교"
}
```

- 대시보드 사용처: 학교 재설정 수요, 학교 변경 UX 개선 판단

#### `widget_cafeteria_changed`

- 위치: `Presentation/Setting/SettingView.swift` `WidgetSettingView`
- 조건: 위젯 기본 식당 선택값이 변경될 때
- 속성:
  - `previous_cafeteria`
  - `widget_default_cafeteria`
- 예시 payload:

```json
{
  "previous_cafeteria": "학생식당",
  "widget_default_cafeteria": "교직원식당"
}
```

- 대시보드 사용처: 위젯 설정 선호도, 식당 유형별 관심도, 위젯 개인화 채택률

#### `update_prompt_viewed`

- 위치: `Presentation/RootView.swift` `.onChange(of: route)`
- 조건: 업데이트 대상 사용자가 홈으로 진입했고 업데이트 안내 alert가 노출될 때
- 속성: 없음
- 예시 payload:

```json
{}
```

- 대시보드 사용처: 업데이트 유도 노출수, 버전 업 유도 모수 파악

#### `update_prompt_clicked`

- 위치: `Presentation/RootView.swift` 업데이트 alert 버튼 액션
- 조건: 업데이트 안내 alert에서 사용자가 액션을 선택할 때
- 속성:
  - `action`
- 예시 payload:

```json
{
  "action": "update"
}
```

- 대시보드 사용처: 업데이트 CTA 전환율, `update` vs `later` 비중

## 6. 필수 대시보드 구성

### 6.1 앱 활성화 퍼널

- 목적: 앱 진입에서 학교 선택 완료, 홈 도달까지 전환율 확인
- 필수 지표:
  - `app_opened`
  - `onboarding_started`
  - `search_viewed`
  - `school_selected`
  - `school_selection_completed`
  - `home_viewed`
- 필수 차트:
  - 퍼널 차트
  - `has_selected_school` 세그먼트 비교
  - 학교 선택 완료까지 소요 이벤트 수 분포

### 6.2 검색 품질 대시보드

- 목적: 학교 검색 경험의 품질과 검색 결과 유효성 확인
- 필수 지표:
  - `school_directory_loaded`
  - `school_search_performed`
  - `school_selected`
- 필수 차트:
  - 검색 건수 추이
  - `query_length` 대비 `result_count` 분포
  - 무결과 또는 저결과 검색 비율
  - 학교별 선택 상위 랭킹

### 6.3 메뉴 조회/안정성 대시보드

- 목적: 메뉴 조회 사용량과 데이터 로드 안정성 모니터링
- 필수 지표:
  - `home_viewed`
  - `menu_viewed`
  - `menu_reload_requested`
  - `menu_load_succeeded`
  - `menu_load_failed`
  - `home_date_swiped`
  - `calendar_opened`
  - `calendar_date_selected`
- 필수 차트:
  - 성공/실패 비율 타임시리즈
  - `source`별 로드 성공률
  - `error_message_sanitized` 상위 랭킹
  - 날짜 이동 방식 스플릿(`swipe` vs `calendar`)

### 6.4 유지/설정 대시보드

- 목적: 설정 진입, 위젯 개인화, 업데이트 전환 모니터링
- 필수 지표:
  - `settings_viewed`
  - `school_setting_tapped`
  - `widget_cafeteria_changed`
  - `update_prompt_viewed`
  - `update_prompt_clicked`
  - `deep_link_opened`
- 필수 차트:
  - 설정 진입률
  - 위젯 식당 선택 비중
  - 업데이트 CTA 클릭률
  - 딥링크 목적지별 유입 분포

## 7. 병행 수집 종료 조건

Firebase 병행 수집은 아래 조건을 모두 만족할 때 종료한다.

1. 필수 대시보드 4종이 Amplitude에서 재현 완료되었을 것
2. 핵심 이벤트(`app_opened`, `splash_viewed`, `onboarding_viewed`, `search_viewed`, `home_viewed`, `settings_viewed`, `school_search_performed`, `school_selection_completed`, `menu_load_succeeded`, `menu_load_failed`)의 일별 건수 차이가 최근 14일 연속 허용 범위 이내일 것
   - 고볼륨 이벤트: Firebase 대비 Amplitude 차이 절대값 `5%` 이하
   - 저볼륨 이벤트: Firebase 대비 Amplitude 차이 절대값 `10%` 이하
3. 필수 속성 채움률이 최근 14일 기준 `99%` 이상일 것
4. `selected_school_name`, `selected_date`, `source`, `action` 등 주요 분석 속성에서 타입 불일치가 없을 것
5. 운영/제품 의사결정에 사용하는 기존 Firebase 대시보드가 모두 Amplitude로 대체되었을 것
6. Firebase에만 남아 있는 미해결 분석 요구사항이 없을 것

## 8. 검증 체크리스트

- 이벤트명/속성 키가 Firebase와 Amplitude에서 완전히 동일한가
- nullable 속성이 한쪽 SDK에서만 누락되지 않는가
- `splash_viewed` / `onboarding_viewed` / `search_viewed` / `home_viewed` / `settings_viewed`의 정의가 실제 화면 진입과 일치하는가
- `menu_load_failed.error_message_sanitized`에 개인정보성 문자열이 포함되지 않는가
- 신규 대시보드의 수치가 Firebase 기준 운영 판단에 사용할 수 있을 만큼 안정적인가

## 9. 후속 작업 메모

- Amplitude 도입 시 SDK 자동 속성과 커스텀 속성 충돌 여부를 확인한다.
- 개인정보처리방침과 앱스토어 개인정보 답변 항목도 함께 정합성을 맞춘다.

# <p align="center"> 밥묵자 </p>
  
<p align="center">  
  <img width="120" height="120" alt="Group 17" src="https://github.com/user-attachments/assets/5ddb2665-ab6f-4519-87c3-3c215afaa193" />
</p>  



<p align="center">
  <b>대학교 급식 정보를 한눈에</b><br/>
  학교 설정부터 위젯까지, 대학교 학식 관리앱
</p>

<br/>

## 🍚 Bobmoo 서비스 소개
> 어제, 오늘, 내일 급식을 한눈에! 원하는 학교의 학생식당·교직원식당·생활관식당 메뉴를 실시간으로 확인하고, iOS 위젯으로 더욱 편리하게


<br/>

## ✨ 주요 기능
- 🔍 **학교 검색 및 설정** - 원하는 대학교를 검색하고 선택
- 📅 **3일치 급식 조회** - 어제/오늘/내일 식단을 스와이프로 빠르게 확인
- 🏪 **다중 식당 지원** - 학생식당, 교직원식당, 생활관식당 정보 제공
- ⏰ **운영 시간 및 상태** - 실시간 운영 상태 표시 (운영중/종료임박/종료)
- 🍽️ **코스별 메뉴** - A/B/C 코스별 상세 메뉴 정보
- 📱 **iOS 홈 위젯** - 잠금화면/홈화면에서 바로 보는 오늘의 급식
- ⚙️ **위젯 식당 설정** - 위젯에 표시할 기본 식당 선택 가능

<br />

## 🍎 iOS Developer
| 송성용<br/>[@soseoyo](https://github.com/soseoyo12) |
| :---: |
| <p align="center"><img src="https://github.com/user-attachments/assets/7ef8590a-2241-4b1f-ad61-1ec5c2f2eaf2" width="200"/></p> |
| `홈` `검색` `설정` `위젯` |


<br />

## 🛠 Tech Stack
| 기술/도구 | 선정 이유 |
| --- | --- |
| **SwiftUI** | 선언형 문법으로 직관적인 UI 구현 및 상태 관리의 간편함 |
| **Alamofire** | RESTful API 통신의 간결하고 직관적인 인터페이스 제공 |
| **MVVM** | 뷰와 비즈니스 로직의 명확한 분리로 유지보수성 향상 |
| **WidgetKit** | iOS 홈/잠금화면 위젯 구현을 위한 Apple 공식 프레임워크 |
| **Observation** | SwiftUI의 새로운 상태 관리 패턴으로 효율적인 데이터 흐름 |

<br />

## 📱 Screenshots
| 홈 화면 | 학교 검색 | 설정 |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/0aef96df-0693-4e49-afbc-7757b13fc1d4" width="200"/> | <img src="https://github.com/user-attachments/assets/63f1ecca-cf27-40eb-8e98-ef5f9d33cb79" width="200"/> | <img src="https://github.com/user-attachments/assets/cbcd36da-b315-427e-99a8-cb1d0c510969" width="200"/> |
| <img src="https://github.com/user-attachments/assets/e6933a2f-360d-49a8-aa9e-58037e637bdf" width="200"/> | <img src="https://github.com/user-attachments/assets/662aecc0-4866-4a56-8f5a-6c155b38961c" width="200"/> | <img src="https://github.com/user-attachments/assets/f248d405-19f1-40f5-83ad-a52db3c9eee7" width="200"/> |

<br />

## 🌿 Git Flow 
1. Issue를 생성한다.
2. 현재 브랜치가 아닌 main 브랜치에서 Branch Naming Rule을 따르는 브랜치를 생성한다.
3. 이슈에 작성한 내용을 기반으로 기능을 구현한다. (+ 커밋)
4. add - commit - push - 간략한 PR 과정을 거친다.
5. PR 올린 후 코드 리뷰를 통해 merge 한다.
6. merge 이후에는 로컬에서도 main으로 이동하여 pull 받는다.

<br />
 
## 📝 Convention
### Commit Message
| 태그       | 설명                                                                 |
|------------|----------------------------------------------------------------------|
| `feat`     | 새로운 기능 구현 시 사용                                              |
| `fix`      | 버그나 오류 해결 시 사용                                              |
| `style`    | 스타일 및 UI 기능 구현 시 사용                                        |
| `docs`     | README, 템플릿 등 프로젝트 내 문서 수정 시 사용                        |
| `setting`  | 프로젝트 관련 설정 변경 시 사용                                       |
| `add`      | 사진 등 에셋이나 라이브러리 추가 시 사용                              |
| `refactor` | 기존 코드를 리팩토링하거나 수정할 때 사용                             |
| `chore`    | 별로 중요한 수정이 아닐 때 사용                                       |
| `hotfix`   | 급하게 develop에 바로 반영해야 하는 경우 사용                         |

### Commit Message Rule
1. 반드시 **소문자**로 작성합니다.
2. 한글로 작성합니다.
3. 제목이 **50자**를 넘지 않도록, 간단하게 명령조로 작성합니다.

```
feat: #1 홈 화면 구현

fix: #2 api 응답 파싱 오류 수정
```

<br/>

## 📁 Foldering
```
🍚 Bobmoo-iOS
├── 📁 Bobmoo_iOS
│   ├── 📄 Bobmoo_iOSApp.swift          # 앱 진입점
│   ├── 📁 Presentation                 # 화면 및 뷰모델
│   │   ├── 📁 RootView.swift
│   │   ├── 📁 Splash
│   │   ├── 📁 Onboarding
│   │   ├── 📁 Home
│   │   │   ├── 📄 HomeView.swift
│   │   │   ├── 📄 HomeViewModel.swift
│   │   │   ├── 📄 HomeModel.swift
│   │   │   └── 📄 HomeMenuService.swift
│   │   ├── 📁 Search
│   │   │   ├── 📄 SearchView.swift
│   │   │   ├── 📄 SearchViewModel.swift
│   │   │   ├── 📄 SearchModel.swift
│   │   │   └── 📄 SearchSchoolService.swift
│   │   └── 📁 Setting
│   │       └── 📄 SettingView.swift
│   ├── 📁 Network
│   │   └── 📄 APIConfig.swift
│   ├── 📁 AppUpdate
│   ├── 📁 Resource
│   │   ├── 📁 Components             # 재사용 컴포넌트
│   │   │   ├── 📄 BobmooButton.swift
│   │   │   ├── 📄 BobmooTextField.swift
│   │   │   ├── 📄 BobmooLabel.swift
│   │   │   ├── 📄 BobmooChip.swift
│   │   │   └── 📄 BobmooCalendarButton.swift
│   │   ├── 📁 Extensions             # Extension 모음
│   │   │   ├── 📄 Color+.swift
│   │   │   ├── 📄 Font+.swift
│   │   │   ├── 📄 Shadow+.swift
│   │   │   ├── 📄 RGB+.swift
│   │   │   ├── 📄 OperationPeriod+Parse.swift
│   │   │   └── 📄 UserDefaults+BobmooShared.swift
│   │   └── 📁 Assets.xcassets
│   └── 📄 AppSettings.swift
│
├── 📁 BobmooWidgetExtension           # iOS 홈 위젯
│   ├── 📄 BobmooWidgetExtension.swift
│   ├── 📄 DietWidgetView.swift
│   ├── 📄 DietProvider.swift
│   ├── 📄 DietEntry.swift
│   └── 📄 DietAPIService.swift
│
└── 📁 Bobmoo_iOS.xcodeproj
```

<br/>

## 🎨 UI/UX Highlights
- **직관적인 탭 네비게이션**: 어제/오늘/내일을 스와이프로 자연스럽게 이동
- **실시간 운영 상태**: 운영중(초록), 종료임박(노랑), 종료(회색)로 직관적 표시
- **풀다운 새로고침**: 당겨서 새로고침으로 최신 데이터 동기화
- **위젯 지원**: 잠금화면/홈화면에서 빠른 급식 확인


<br/>

## 🔗 Links
- [App Store](https://apps.apple.com/kr/app/%EB%B0%A5%EB%AC%B5%EC%9E%90/id6751774906?l=en-GB) 

---
<p align="center">Made with 🍚 by <a href="https://github.com/soseoyo12">@soseoyo</a></p>

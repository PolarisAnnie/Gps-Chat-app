# DevPot🐈‍⬛ 
## 위치 기반 개발자 연결 앱

개발자 커뮤니티 또는 개인과 연결되고 싶은 개발자들을 위한 지역 기반 매칭 앱입니다.

<img width="2301" height="1986" alt="Group 201 (1)" src="https://github.com/user-attachments/assets/c17edf43-7b23-4922-8073-fcc58938cf62" />


---

## 📱 프로젝트 개요

- **앱 이름**: DevPot
- **설명**: 개발자 커뮤니티 또는 개인과 연결되고 싶은 개발자들을 위한 지역 기반 매칭 앱으로, MVVM 패턴과 Riverpod 상태 관리를 기반으로 개발되었습니다.
- **프로젝트 기간**: 2025.08.06 ~ 2025.08.13
- **GitHub Repository**: [https://github.com/PolarisAnnie/Gps-Chat-app](https://github.com/PolarisAnnie/Gps-Chat-app)

---

## 🏗️ 아키텍처 & 기술 스택

### 📋 Architecture Pattern
- **MVVM (Model-View-ViewModel)** 패턴
- **Riverpod** 상태 관리
- **Repository Pattern** 데이터 관리

### 🛠 기술 스택
- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod
- **Backend**: Firebase
  - Firestore (데이터베이스)
  - Firebase Storage (이미지 저장)
  - Firebase Auth (인증)
- **Location Services**: Geolocator
- **Map API**: Naver Map API
- **Image Handling**: Image Picker

---

## 📁 프로젝트 구조

```
lib/
├── core/                          # 핵심 기능 및 공통 모듈
│   ├── providers/                 # Riverpod 상태 관리
│   ├── services/                  # 외부 서비스 연동 (Firebase Storage 등)
│   ├── theme/                     # 앱 테마 설정
│   └── utils/                     # 유틸리티 함수들
├── data/                          # 데이터 계층
│   ├── model/                     # 데이터 모델 (User, ChatRoom, ChatMessage 등)
│   └── repository/                # Repository 패턴 (데이터 접근 추상화)
│       ├── chat_message_repository.dart    # 채팅 메시지 데이터 관리
│       ├── chat_room_repository.dart       # 채팅방 데이터 관리
│       ├── storage_repository.dart         # 이미지 업로드/다운로드
│       └── user_repository.dart            # 사용자 정보 관리
└── ui/                           # UI 계층
    └── pages/                    # 화면별 페이지
        ├── chat/                 # 채팅 화면
        │   ├── chat_page.dart           # 1:1 채팅 화면
        │   ├── chat_view_model.dart     # 채팅 비즈니스 로직
        │   └── widgets/                 # 채팅 관련 위젯들
        ├── chat_room_list/       # 채팅방 목록
        │   ├── chat_room_list_page.dart        # 채팅방 리스트 화면
        │   ├── chat_room_list_view_model.dart  # 채팅방 목록 비즈니스 로직
        │   └── widgets/                        # 채팅방 아이템 위젯
        ├── home/                 # 홈 화면
        │   ├── home_page.dart           # 메인 홈 화면
        │   ├── member_detail.dart       # 멤버 상세 정보 화면
        │   └── widgets/                 # 홈 관련 위젯들
        │       └── member_list.dart     # 주변 개발자 목록
        └── profile/              # 프로필 관리
            └── widgets/          # 프로필 관련 위젯들
                └── profile_edit_form.dart  # 프로필 수정 폼
```

---

#### Core Layer (core/)
- providers/: Riverpod 기반 상태 관리 (ViewModel 패턴)
- services/: Firebase Storage, Naver Map API 등 외부 서비스 연동
- theme/: 앱 전체 테마 및 디자인 시스템
- utils/: 공통 유틸리티 함수들
#### Data Layer (data/)
- model/: 사용자, 채팅방, 메시지 등의 데이터 모델
- repository/: Firebase와의 데이터 통신을 추상화한 Repository 패턴
#### UI Layer (ui/pages/)
- chat/: 실시간 1:1 채팅 기능
- chat_room_list/: 참여 중인 채팅방 목록 관리
- home/: 주변 개발자 목록 및 카페 정보 표시
- profile/: 사용자 프로필 수정 및 관리

---

### MVVM + Repository 패턴 적용

이 프로젝트는 **MVVM + Repository 패턴**을 기반으로 한 깔끔한 아키텍처를 구현했습니다.

#### 🏗️ **아키텍처 계층 구조**
```
UI Layer (View) → ViewModel → Repository → Service → External API
```

#### 🔧 **핵심 컴포넌트**

1. **Service Layer** (`core/services/`)
   - 순수한 API 통신 담당
   - `naver_map_service.dart`: 네이버 지도 API 직접 호출

2. **Repository Layer** (`data/repository/`)
   - Service와 ViewModel 사이의 데이터 추상화 계층
   - 비즈니스 로직 처리 및 에러 핸들링
   - `naver_map_repository.dart`: 위치 권한, 주소 변환 등 통합 관리

3. **ViewModel Layer** (`core/providers/viewmodels/`)
   - UI 상태 관리 및 비즈니스 로직
   - Repository를 통한 데이터 처리
   - `location_viewmodel.dart`: 위치 관련 모든 상태 관리

#### 1. **Splash Screen** (`splash_page.dart`)
- 앱 시작 시 애니메이션 화면: ui/pages/welcome/splash/splash_page.dart
- 3초 후 자동으로 회원가입 화면으로 이동: core/providers/viewmodels/splash_viewmodel.dart
- **ViewModel**: `SplashViewModel`

#### 2. **Signup Screen** (`signup_page.dart`)
- 닉네임 입력 및 중복 체크: ui/pages/welcome/auth/signup_page.dart
- 닉네임 유효성 검사 (4글자 이상)
- **ViewModel**: `AuthViewModel`

#### 3. **Register Screen** (`register_page.dart`)
- 프로필 이미지 선택
- 닉네임 및 소개글 입력: ui/pages/welcome/auth/register_page.dart
- Firebase Storage 이미지 업로드: core/providers/viewmodels/auth_viewmodel.dart, register_viewmodel.dart
- **ViewModel**: `RegisterViewModel`

#### 4. **Location Settings** (`location_settings.dart`)
- 현재 위치 정보 가져오기(GPS):ui/pages/welcome/location_settings/location_settings.dart
- Naver Map API를 통한 주소 변환: core/services/naver_map_service.dart
- 위치 권한 처리: core/providers/viewmodels/location_viewmodel.dart
- **ViewModel**: `LocationViewModel`

#### 5. **메인 및 채팅 기능**
- 주변 카페 목록이 있는 홈 화면: ui/pages/home/home_page.dart
- 실시간 채팅 기능: ui/pages/chat/chat_page.dart
- 채팅방 목록 관리: ui/pages/chat_room_list/chat_room_list_page.dart
- 메인 네비게이션: ui/pages/main/main_navigation_page.dart


---

## 🚀 주요 기능

### 🔐 사용자 인증
- 닉네임 기반 회원가입
- 프로필 이미지 업로드
- Firebase Firestore 사용자 정보 저장

### 📍 위치 기반 서비스
- GPS를 통한 현재 위치 감지
- Naver Map API 주소 변환
- 위치 권한 요청 및 처리

### 🗺️ 지도 연동
- Naver Map API 활용
- 주변 카페 검색 기능
- 위치 기반 개발자 매칭

### 💬 채팅 기능
- 실시간 채팅 (Firebase 연동)
- 채팅방 목록 관리
- 개발자 간 소통 지원

---

## 📦 의존성

```yaml
dependencies:
  flutter_riverpod: ^2.6.1        # 상태 관리
  cloud_firestore: ^6.0.0         # Firebase Firestore
  firebase_storage: ^13.0.0       # Firebase Storage
  firebase_auth: ^6.0.0           # Firebase Auth
  geolocator: ^14.0.2             # 위치 서비스
  image_picker: ^1.0.4            # 이미지 선택
  http: ^1.5.0                    # HTTP 통신
  flutter_dotenv: ^5.0.2          # 환경 변수
```

---

## 🛠 개발 환경 설정

### 1. Flutter 설치
```bash
flutter doctor
```

### 2. 의존성 설치
```bash
flutter pub get
```

### 3. 환경 변수 설정
루트 디렉토리에 `.env` 파일 생성:
```env
NAVER_MAP_CLIENT_ID=your_client_id
NAVER_MAP_CLIENT_SECRET=your_client_secret
NAVER_CLIENT_ID=your_naver_client_id
NAVER_CLIENT_SECRET=your_naver_client_secret
```

### 4. Firebase 설정
- `firebase_options.dart` 파일 설정
- Android: `google-services.json` 추가
- iOS: `GoogleService-Info.plist` 추가

### 5. 앱 실행
```bash
flutter run
```

---

## 📈 개선사항

### ✅ 완료된 리팩토링
- **상태 관리**: StatefulWidget → Riverpod
- **아키텍처**: MVC → MVVM
- **코드 분리**: UI와 비즈니스 로직 분리
- **재사용성**: Provider 기반 상태 공유
- **테스트 용이성**: ViewModel 단위 테스트 가능

### 🔄 진행 중인 기능
- 실시간 채팅 시스템
- 개발자 매칭 알고리즘
- 프로필 상세 정보

---

## 👥 팀 역할 분담

- **은희**👩‍💼 
: 프로젝트 관리 + 채팅 기능 (Firebase 관리, ChatList & ChatPage)
- **소린**📍 
: 초기 화면 + 위치 기능 (Splash, 유저 설정, location 공통 기능) + 메인 화면 (HomePage 구현)
- **영호**👨‍💻 
: 프로필 관리 (Profile 정보 변경 페이지)
- **우형**🏠 
: HomePage 구현 수정
- **공통**🤝 
: 문서화 및 발표 준비


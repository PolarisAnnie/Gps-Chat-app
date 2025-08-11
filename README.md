# DevPot🐈‍⬛ 
## 위치 기반 개발자 연결 앱

개발자 커뮤니티 또는 개인과 연결되고 싶은 개발자들을 위한 지역 기반 매칭 앱입니다.

---

## 📱 프로젝트 개요

- **앱 이름**: DevPot
- **목적**: 개발자 커뮤니티 또는 개인과 연결되고 싶은 개발자들을 위한 지역 기반 매칭 앱
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
├── main.dart                      # 앱 진입점
├── firebase_options.dart          # Firebase 설정
├── core/                          # 핵심 기능
│   ├── theme/                     # 앱 테마
│   │   └── theme.dart
│   ├── services/                  # 외부 서비스 연동
│   │   ├── firebase_storage_service.dart
│   │   └── naver_map_service.dart
│   ├── utils/                     # 유틸리티
│   │   └── location_utils.dart
│   └── providers/                 # Riverpod 상태 관리
│       ├── models/                # 상태 모델
│       │   ├── auth_state.dart
│       │   ├── location_state.dart
│       │   └── register_state.dart
│       └── viewmodels/            # ViewModel 로직
│           ├── auth_viewmodel.dart
│           ├── location_viewmodel.dart
│           ├── register_viewmodel.dart
│           ├── splash_viewmodel.dart
│           └── naver_map_viewmodel.dart
├── data/                          # 데이터 계층
│   ├── model/                     # 데이터 모델
│   │   └── user_model.dart
│   └── repository/                # 데이터 저장소
│       ├── storage_repository.dart
│       └── user_repository.dart
└── ui/                           # UI 계층
    └── pages/                    # 화면별 페이지
        ├── splash/               # 스플래시 화면
        │   └── splash_page.dart
        ├── auth/                 # 인증 관련
        │   ├── signup_page.dart
        │   └── register_page.dart
        ├── location_settings/    # 위치 설정
        │   └── location_settings.dart
        ├── home/                 # 홈 화면 (카페 목록)
        │   ├── home_page.dart
        │   ├── home_empty_page.dart
        │   └── api.dart
        ├── chat/                 # 채팅 기능
        │   ├── chat_page.dart
        │   └── widgets/
        ├── chat_room_list/       # 채팅방 목록
        │   └── chat_room_list_page.dart
        ├── profile/              # 프로필
        │   └── profile_page.dart
        └── main/                 # 메인 네비게이션
            └── main_navigation_page.dart
```

---

### 페이지별 MVVM 패턴 

이 프로젝트는 기존 StatefulWidget 기반 코드를 **Riverpod + MVVM 패턴**으로 리팩토링했습니다.

#### 1. **Splash Screen** (`splash_page.dart`)
- 앱 시작 시 애니메이션 화면
- 3초 후 자동으로 회원가입 화면으로 이동
- **ViewModel**: `SplashViewModel`

#### 2. **Signup Screen** (`signup_page.dart`)
- 닉네임 입력 및 중복 체크
- 닉네임 유효성 검사 (4글자 이상)
- **ViewModel**: `AuthViewModel`

#### 3. **Register Screen** (`register_page.dart`)
- 프로필 이미지 선택
- 닉네임 및 소개글 입력
- Firebase Storage 이미지 업로드
- **ViewModel**: `RegisterViewModel`

#### 4. **Location Settings** (`location_settings.dart`)
- 현재 위치 정보 가져오기
- Naver Map API를 통한 주소 변환
- 위치 권한 처리
- **ViewModel**: `LocationViewModel`

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

- **은희**👩‍💼: 프로젝트 관리 + 채팅 기능 (Firebase 관리, ChatList & ChatPage)
- **영호**👨‍💻: 프로필 관리 (Profile 정보 변경 페이지)
- **우형**🏠: 메인 화면 (HomePage 구현)
- **소린**📍: 초기 화면 + 위치 기능 (Splash, 유저 설정, location 공통 기능)
- **공통**🤝: 문서화 및 발표 준비


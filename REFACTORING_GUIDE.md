# 소린 - Riverpod MVVM 리팩토링

기존의 StatefulWidget 기반 코드를 **Riverpod**과 **MVVM 패턴**으로 리팩토링함

## 🔄 리팩토링 주요 변경사항

### 1. 아키텍처 변경
- **Before**: StatefulWidget + setState
- **After**: Riverpod + MVVM Pattern

### 2. 상태 관리 개선
- **Before**: 각 위젯에서 개별적으로 상태 관리
- **After**: 중앙화된 상태 관리 (StateNotifier + Provider)

### 3. 비즈니스 로직 분리
- **Before**: UI와 비즈니스 로직이 혼재
- **After**: ViewModel을 통한 비즈니스 로직 분리

## 📁 새로운 파일 구조

```
lib/
├── core/
│   └── providers/
│       ├── models/           # 상태 모델들
│       │   ├── auth_state.dart
│       │   ├── location_state.dart
│       │   └── register_state.dart
│       └── viewmodels/       # ViewModel들
│           ├── auth_viewmodel.dart
│           ├── location_viewmodel.dart
│           ├── register_viewmodel.dart
│           ├── splash_viewmodel.dart
│           └── naver_map_viewmodel.dart
└── ui/
    └── pages/
        ├── splash/           # 스플래시 화면
        ├── auth/            # 인증 관련 화면들
        └── location_settings/ # 위치 설정 화면
```

## 🎯 리팩토링된 기능들

### 1. **Splash Screen**
- `SplashViewModel`로 상태 관리
- 애니메이션과 네비게이션 로직 분리

### 2. **Authentication (회원가입)**
- `AuthViewModel`로 닉네임 검증 로직 관리
- 중복 체크 및 유효성 검사 로직 분리

### 3. **User Registration**
- `RegisterViewModel`로 프로필 등록 로직 관리
- 이미지 업로드 및 폼 검증 로직 분리

### 4. **Location Settings**
- `LocationViewModel`로 위치 관련 로직 관리
- 위치 권한 처리 및 Naver Map API 연동

### 5. **Naver Map API Integration**
- `NaverMapViewModel`로 지도 관련 기능 관리
- API 호출 로직 중앙화

## 🔧 주요 Provider들

### AuthViewModel
```dart
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel();
});
```

### LocationViewModel
```dart
final locationViewModelProvider = StateNotifierProvider<LocationViewModel, LocationState>((ref) {
  return LocationViewModel(UserRepository());
});
```

### RegisterViewModel
```dart
final registerViewModelProvider = StateNotifierProvider<RegisterViewModel, RegisterState>((ref) {
  return RegisterViewModel(UserRepository(), StorageRepository());
});
```


## 🛠 사용 기술 스택

- **State Management**: Riverpod
- **Architecture Pattern**: MVVM
- **Backend**: Firebase (Firestore, Storage, Auth)
- **Location Services**: Geolocator
- **Map API**: Naver Map API
- **Image Handling**: Image Picker


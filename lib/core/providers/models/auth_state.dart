import 'package:flutter/foundation.dart'; // @immutable을 위해 import

@immutable // 이 클래스가 immutable임을 나타내는 어노테이션이라고 함미다..
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? nickname;
  final bool isSignupComplete;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.nickname,
    this.isSignupComplete = false,
  });

  bool get isNicknameValid =>
      nickname != null && nickname!.length >= 4 && errorMessage == null;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? nickname,
    bool? isSignupComplete,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      nickname: nickname ?? this.nickname,
      isSignupComplete: isSignupComplete ?? this.isSignupComplete,
    );
  }

  // 동등성(Equality) 비교 로직
  // Riverpod이 상태 변경을 감지하기 위해 필수적입니다.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.nickname == nickname &&
        other.isSignupComplete == isSignupComplete;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        errorMessage.hashCode ^
        nickname.hashCode ^
        isSignupComplete.hashCode;
  }
}

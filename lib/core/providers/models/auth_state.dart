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

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? nickname,
    bool? isSignupComplete,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      nickname: nickname ?? this.nickname,
      isSignupComplete: isSignupComplete ?? this.isSignupComplete,
    );
  }
}

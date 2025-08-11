import 'dart:io';

class RegisterState {
  final bool isLoading;
  final String? errorMessage;
  final String nickname;
  final String introduction;
  final File? profileImage;
  final bool isFormValid;

  const RegisterState({
    this.isLoading = false,
    this.errorMessage,
    this.nickname = '',
    this.introduction = '',
    this.profileImage,
    this.isFormValid = false,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? nickname,
    String? introduction,
    File? profileImage,
    bool? isFormValid,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      nickname: nickname ?? this.nickname,
      introduction: introduction ?? this.introduction,
      profileImage: profileImage ?? this.profileImage,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }
}

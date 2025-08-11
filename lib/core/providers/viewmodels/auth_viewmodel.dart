import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/providers/models/auth_state.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';
import 'package:gps_chat_app/data/model/user_model.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final UserRepository _userRepository;

  AuthViewModel(this._userRepository) : super(const AuthState());

  String? _validateNickname(String nickname) {
    if (nickname.isEmpty) {
      return null; // 처음에는 에러 메시지 없음
    }
    if (nickname.length < 4) {
      return '닉네임은 4글자 이상이어야 합니다.';
    }
    return null; // 유효한 경우 null 반환
  }

  Future<bool> checkNicknameExists(String nickname) async {
    return await _userRepository.checkNicknameExists(nickname);
  }

  /// 닉네임으로 유저 정보를 조회하고, 위치설정이 안된 유저인지 확인
  Future<bool> isIncompleteUser(String nickname) async {
    final user = await _userRepository.getUserByNickname(nickname);
    if (user == null) return false;

    // 위치가 (0, 0)이거나 address가 빈 문자열이면 위치설정이 안된 것으로 판단
    return (user.location.latitude == 0 && user.location.longitude == 0) ||
        (user.address?.isEmpty ?? true);
  }

  /// 닉네임으로 유저 정보를 조회
  Future<User?> getUserByNickname(String nickname) async {
    return await _userRepository.getUserByNickname(nickname);
  }

  // 기존 setNickname, setError를 이 메서드로 통합
  void updateNickname(String nickname) {
    final errorMessage = _validateNickname(nickname);

    if (errorMessage == null) {
      // 유효한 닉네임인 경우 에러 메시지 클리어
      state = state.copyWith(nickname: nickname, clearErrorMessage: true);
    } else {
      // 유효하지 않은 닉네임인 경우 에러 메시지 설정
      state = state.copyWith(nickname: nickname, errorMessage: errorMessage);
    }
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel(UserRepository());
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/providers/models/auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  // 임시 닉네임 리스트 (실제로는 서버에서 가져와야 함)
  final List<String> _nicknameList = ['user1', '기요미짱', '으니으니', '우형우형', '영호영호'];

  AuthViewModel() : super(const AuthState());

  String? _validateNickname(String nickname) {
    if (nickname.isEmpty) {
      return null; // 처음에는 에러 메시지 없음
    }
    if (nickname.length < 4) {
      return '닉네임은 4글자 이상이어야 합니다.';
    }
    return null; // 유효한 경우 null 반환
  }

  bool checkNicknameExists(String nickname) {
    return _nicknameList.contains(nickname);
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
  return AuthViewModel();
});

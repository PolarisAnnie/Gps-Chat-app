import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/providers/models/auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  // 임시 닉네임 리스트 (실제로는 서버에서 가져와야 함)
  final List<String> _nicknameList = ['user1', '기요미짱', '으니으니', '우형우형', '영호영호'];

  AuthViewModel() : super(const AuthState());

  String? validateNickname(String nickname) {
    if (nickname.length < 4) {
      return '닉네임은 4글자 이상이어야 합니다.';
    }
    return null;
  }

  bool checkNicknameExists(String nickname) {
    return _nicknameList.contains(nickname);
  }

  void setNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  bool get isNicknameValid {
    return state.nickname != null &&
        state.nickname!.length >= 4 &&
        validateNickname(state.nickname!) == null;
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  return AuthViewModel();
});

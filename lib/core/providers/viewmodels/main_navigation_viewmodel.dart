import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/main_navigation_state.dart';

/// MainNavigation 화면 ViewModel
/// 하단 네비게이션 탭 상태 관리
class MainNavigationViewModel extends StateNotifier<MainNavigationState> {
  MainNavigationViewModel() : super(const MainNavigationState());

  /// 탭 변경
  void changeTab(int index) {
    if (index >= 0 && index <= 2 && index != state.currentIndex) {
      state = state.copyWith(currentIndex: index);
    }
  }

  /// 홈 탭으로 이동
  void goToHome() {
    changeTab(0);
  }

  /// 채팅 탭으로 이동
  void goToChat() {
    changeTab(1);
  }

  /// 프로필 탭으로 이동
  void goToProfile() {
    changeTab(2);
  }

  /// 상태 초기화
  void resetState() {
    state = const MainNavigationState();
  }
}

/// MainNavigation ViewModel Provider
final mainNavigationViewModelProvider =
    StateNotifierProvider<MainNavigationViewModel, MainNavigationState>(
      (ref) => MainNavigationViewModel(),
    );

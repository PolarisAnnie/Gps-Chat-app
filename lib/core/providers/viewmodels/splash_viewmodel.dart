import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashState {
  final bool isLoading;
  final bool shouldNavigate;

  const SplashState({this.isLoading = true, this.shouldNavigate = false});

  SplashState copyWith({bool? isLoading, bool? shouldNavigate}) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      shouldNavigate: shouldNavigate ?? this.shouldNavigate,
    );
  }
}

class SplashViewModel extends StateNotifier<SplashState> {
  SplashViewModel() : super(const SplashState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // 3초 후 네비게이션 허용
    await Future.delayed(const Duration(seconds: 3));
    state = state.copyWith(isLoading: false, shouldNavigate: true);
  }
}

final splashViewModelProvider =
    StateNotifierProvider<SplashViewModel, SplashState>((ref) {
      return SplashViewModel();
    });

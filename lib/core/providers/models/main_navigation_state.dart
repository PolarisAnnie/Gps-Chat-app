/// MainNavigation 화면의 상태를 관리하는 State 모델
class MainNavigationState {
  final int currentIndex;
  final bool isLoading;

  const MainNavigationState({this.currentIndex = 0, this.isLoading = false});

  MainNavigationState copyWith({int? currentIndex, bool? isLoading}) {
    return MainNavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainNavigationState &&
          runtimeType == other.runtimeType &&
          currentIndex == other.currentIndex &&
          isLoading == other.isLoading;

  @override
  int get hashCode => currentIndex.hashCode ^ isLoading.hashCode;
}

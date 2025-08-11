import 'package:flutter_riverpod/flutter_riverpod.dart';

class NaverMapViewModel extends StateNotifier<AsyncValue<List<dynamic>>> {
  NaverMapViewModel() : super(const AsyncValue.loading());

  Future<void> searchCafes(String query) async {
    state = const AsyncValue.loading();

    try {
      // 네이버 API를 통해 카페 검색
      // 실제 구현에서는 NaverMapService나 별도 API 서비스를 사용
      final results = <dynamic>[];
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final naverMapViewModelProvider =
    StateNotifierProvider<NaverMapViewModel, AsyncValue<List<dynamic>>>((ref) {
      return NaverMapViewModel();
    });

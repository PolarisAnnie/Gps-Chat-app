import 'package:geolocator/geolocator.dart';
import 'package:gps_chat_app/core/services/naver_map_service.dart';

/// Naver Map API Repository
/// ViewModel과 Naver Map Service 사이의 데이터 계층
/// Repository 패턴을 통해 서비스 계층을 추상화하고 비즈니스 로직을 분리
class NaverMapRepository {
  final NaverMapService _naverMapService;

  NaverMapRepository({NaverMapService? naverMapService})
    : _naverMapService = naverMapService ?? NaverMapService();

  /// 위치 좌표를 주소로 변환
  /// Service의 결과를 Repository 레벨에서 처리하여 일관된 응답 형태로 반환
  Future<String> getAddressFromPosition(Position position) async {
    try {
      final address = await _naverMapService.getAddressFromCoords(position);
      return address ?? '주소를 가져올 수 없습니다.';
    } catch (e) {
      return '위치 정보 변환 중 오류가 발생했습니다.';
    }
  }

  /// 현재 위치 기반 주변 장소 검색 (확장 가능)
  /// 향후 Naver Local Search API 연동 시 구현 예정
  Future<List<Map<String, dynamic>>> searchNearbyPlaces({
    required Position position,
    required String query,
    int radius = 1000,
  }) async {
    try {
      // Naver Local Search API 연동
      // _naverMapService에 해당 기능 추가 후 호출
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 위치 권한 상태 확인 (Repository에서 권한 관련 로직 처리)
  Future<bool> checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;
    } catch (e) {
      return false;
    }
  }

  /// 위치 권한 요청
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      return permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;
    } catch (e) {
      return false;
    }
  }
}

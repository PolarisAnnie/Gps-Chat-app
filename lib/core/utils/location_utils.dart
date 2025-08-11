import 'package:geolocator/geolocator.dart';
import 'package:gps_chat_app/data/repository/naver_map_repository.dart';

class LocationData {
  final Position position;
  final String address;

  LocationData({required this.position, required this.address});
}

class LocationUtils {
  static final NaverMapRepository _naverMapRepository = NaverMapRepository();

  /// 현재 위치 정보를 가져와 LocationData 객체로 반환
  /// Repository 패턴을 통해 비즈니스 로직과 API 호출을 분리
  ///
  /// 권한이 없거나 오류 발생 시 null을 반환
  static Future<LocationData?> getCurrentLocationData() async {
    try {
      // 1. 위치 권한 확인 및 요청 (Repository 메서드 활용)
      bool hasPermission = await _naverMapRepository.checkLocationPermission();
      
      if (!hasPermission) {
        hasPermission = await _naverMapRepository.requestLocationPermission();
        if (!hasPermission) {
          // 권한이 최종적으로 거부된 경우
          return null;
        }
      }

      // 2. 현재 위치(좌표) 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Repository를 통해 좌표를 주소로 변환
      String address = await _naverMapRepository.getAddressFromPosition(position);

      // 4. 위치 데이터와 변환된 주소를 LocationData 객체로 반환
      return LocationData(position: position, address: address);
      
    } catch (e) {
      print('위치 정보를 가져오는 데 실패했습니다: $e');
      return null; // 오류 발생 시 null 반환
    }
  }

  /// 위치 권한 상태만 확인하는 유틸리티 메서드
  static Future<bool> hasLocationPermission() async {
    return await _naverMapRepository.checkLocationPermission();
  }

  /// 위치 권한 요청하는 유틸리티 메서드  
  static Future<bool> requestLocationPermission() async {
    return await _naverMapRepository.requestLocationPermission();
  }
}

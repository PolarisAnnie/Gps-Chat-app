import 'package:geolocator/geolocator.dart';
import 'package:gps_chat_app/core/services/naver_map_service.dart';

class LocationData {
  final Position position;
  final String address;

  LocationData({required this.position, required this.address});

  double? get latitude => null;

  double? get longitude => null;
}

class LocationUtils {
  /// 현재 위치 정보를 가져와 LocationData 객체로 반환하는 코드!
  ///
  /// 권한이 없거나 오류 발생 시 null을 반환하기
  static Future<LocationData?> getCurrentLocationData() async {
    try {
      // 1. 위치 권한 확인 및 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // 권한이 최종적으로 거부된 경우
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // 권한이 영구적으로 거부된 경우
        return null;
      }

      // 2. 현재 위치(좌표) 가져오기
      Position position = await Geolocator.getCurrentPosition();

      // 3. NaverMapService 객체를 생성하고, 좌표를 주소로 변환하기
      final naverMapService = NaverMapService();
      String? address = await naverMapService.getAddressFromCoords(position);

      if (address != null) {
        // 4. 위치 데이터와 변환된 주소 문자열을 LocationData 객체로 반환함
        return LocationData(position: position, address: address);
      }
    } catch (e) {
      print('위치 정보를 가져오는 데 실패했습니다: $e');
      return null; // 오류 발생 시 null 반환
    }
    return null; // 주소 변환 실패 시 null 반환
  }
}

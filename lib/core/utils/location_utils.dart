import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationData {
  final Position position;
  final String address;

  LocationData({required this.position, required this.address});
}

class LocationUtils {
  /// 현재 위치 정보를 가져와 LocationData 객체로 반환합니다.
  ///
  /// 권한이 없거나 오류 발생 시 null을 반환합니다.
  static Future<LocationData?> getCurrentLocationData() async {
    try {
      // 1. 위치 권한 확인 및 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          // 권한이 최종적으로 거부된 경우
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // 권한이 영구적으로 거부된 경우
        return null;
      }

      // 2. 현재 위치(좌표) 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. 좌표를 주소로 변환
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // 4. '시 구 동' 형식으로 주소 가공
        String address =
            '${place.locality} ${place.subLocality} ${place.thoroughfare}';

        return LocationData(position: position, address: address);
      } else {
        return null;
      }
    } catch (e) {
      print('LocationUtils 오류: $e');
      return null;
    }
  }
}

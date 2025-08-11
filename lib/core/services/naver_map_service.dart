import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NaverMapService {
  final String clientId;
  final String clientSecret;

  // gc가 들어가야함! geogode의 약자로, 실제 주소 변환 기능을 호출
  static const String _apiUrl =
      'https://maps.apigw.ntruss.com/map-reversegeocode/v2/gc';

  // 생성자를 통해 .env 파일에서 키를 불러옴
  NaverMapService({String? clientId, String? clientSecret})
    : clientId = clientId ?? dotenv.env['NAVER_MAP_CLIENT_ID'] ?? '',
      clientSecret =
          clientSecret ?? dotenv.env['NAVER_MAP_CLIENT_SECRET'] ?? '';

  // static 메서드를 인스턴스 메서드로 변경하여 clientId와 clientSecret에 접근하는 과정
  Future<String?> getAddressFromCoords(Position position) async {
    if (clientId.isEmpty || clientSecret.isEmpty) {
      return 'map API 키를 .env 파일에 설정해주세요.';
    }

    // 2. 요청 URL에 파라미터 추가
    //    - coords: 현재 위치의 좌표
    //    - output=json: 결과를 JSON 형태로 받음
    //    - orders=admcode: 행정동 주소를 우선으로 받도록 설정 (가장 중요!)
    final uri = Uri.parse(
      '$_apiUrl?coords=${position.longitude},${position.latitude}&output=json&orders=admcode',
    );

    try {
      // 3. HTTP GET 요청 보내기 (헤더에 Client ID와 Secret 추가)
      final response = await http.get(
        uri,
        headers: {
          'X-NCP-APIGW-API-KEY-ID': clientId,
          'X-NCP-APIGW-API-KEY': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // 4. 응답 결과에서 행정동 정보 추출
        if (jsonResponse['status']['code'] == 0 &&
            jsonResponse['results'].isNotEmpty) {
          // API 응답 결과에서 'region' 객체 찾아옴
          final region = jsonResponse['results'][0]['region'];

          // 'region' 객체에서 시/도, 구, 동 각각 추출하기
          final area1 = region['area1']['name']; // 예: 서울특별시
          final area2 = region['area2']['name']; // 예: 강남구
          final area3 = region['area3']['name']; // 예: 역삼동

          // 5. '시 구 동' 형태로 조합하여 나오도록!!
          return '$area1 $area2 $area3'.trim();
        } else {
          return '주소를 찾을 수 없습니다.';
        }
      } else {
        debugPrint('네이버 API 에러: ${response.body}');
        return '주소 변환에 실패했습니다.';
      }
    } catch (e) {
      debugPrint('네트워크 에러: $e');
      return '네트워크 연결을 확인해주세요.';
    }
  }
}

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NaverMapService {
  final String clientId;
  final String clientSecret;

  static const String _apiUrl =
      'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc';

  // 생성자를 통해 .env 파일에서 키를 불러오기
  NaverMapService({String? clientId, String? clientSecret})
    : clientId = clientId ?? dotenv.env['NAVER_CLIENT_ID'] ?? '',
      clientSecret = clientSecret ?? dotenv.env['NAVER_CLIENT_SECRET'] ?? '';

  // static 메서드를 인스턴스 메서드로 변경하여 clientId와 clientSecret에 접근하는 과정
  Future<String?> getAddressFromCoords(Position position) async {
    if (clientId.isEmpty || clientSecret.isEmpty) {
      return 'API 키를 .env 파일에 설정해주세요.';
    }

    final uri = Uri.parse(
      '$_apiUrl?coords=${position.longitude},${position.latitude}&output=json&orders=legalcode,admcode',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'X-NCP-APIGW-API-KEY-ID': clientId,
          'X-NCP-APIGW-API-KEY': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status']['code'] == 0 &&
            jsonResponse['results'].isNotEmpty) {
          final region = jsonResponse['results'][0]['region'];
          final area1 = region['area1']['name']; // 시/도
          final area2 = region['area2']['name']; // 구
          final area3 = region['area3']['name']; // 동

          return '$area1 $area2 $area3';
        } else {
          return '주소를 찾을 수 없습니다.';
        }
      } else {
        print('네이버 API 에러: ${response.body}');
        return '주소 변환에 실패했습니다.';
      }
    } catch (e) {
      print('네트워크 에러: $e');
      return '네트워크 연결을 확인해주세요.';
    }
  }
}

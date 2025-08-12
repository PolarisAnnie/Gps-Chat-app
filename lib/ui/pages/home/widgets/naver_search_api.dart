import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NaverApiService {
  static const String _baseUrl =
      'https://openapi.naver.com/v1/search/local.json';
  static const String _imageUrl = 'https://openapi.naver.com/v1/search/image';
  final String clientId;
  final String clientSecret;

  NaverApiService({String? clientId, String? clientSecret})
    : clientId = clientId ?? dotenv.env['NAVER_CLIENT_ID'] ?? '',
      clientSecret = clientSecret ?? dotenv.env['NAVER_CLIENT_SECRET'] ?? '';

  Future<List<dynamic>> searchLocal(String query, {int display = 10}) async {
    final url = Uri.parse(
      '$_baseUrl?query=${Uri.encodeQueryComponent(query)}&display=$display',
    );

    final response = await http.get(
      url,
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return jsonBody['items'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch data from Naver Open API');
    }
  }

  Future<List<dynamic>> searchImage(String query, {int display = 1}) async {
    final url = Uri.parse(
      '$_imageUrl?query=${Uri.encodeQueryComponent(query)}&display=$display',
    );

    final response = await http.get(
      url,
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return jsonBody['items'] as List<dynamic>;
    } else {
      print('Image API 호출 실패: ${response.body}');
      return [];
    }
  }
}

void main() async {
  await dotenv.load(fileName: ".env");
  final api = NaverApiService();
  final results = await api.searchLocal('카페');

  for (var item in results) {
    print(item['title']);
  }
}

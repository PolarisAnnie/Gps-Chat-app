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

  Future<List<dynamic>> searchLocal(
    String query, {
    int display = 10,
    double? latitude,
    double? longitude,
    String? locationKeyword, // added parameter
  }) async {
    // Use locationKeyword if provided, else use query
    final searchQuery = locationKeyword != null && locationKeyword.isNotEmpty
        ? '$locationKeyword $query'
        : query;

    String urlString =
        '$_baseUrl?query=${Uri.encodeQueryComponent(searchQuery)}&display=$display';
    if (latitude != null && longitude != null) {
      urlString += '&coordinate=$longitude,$latitude';
    }
    final url = Uri.parse(urlString);

    final response = await http.get(
      url,
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final items = jsonBody['items'] as List<dynamic>;
      for (var item in items) {
        print('title: ${item['title']}, id: ${item['id']}');
      }
      return items;
    } else {
      throw Exception('Failed to fetch local data');
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

  String getNaverMapUrl(
    String name, {
    double? latitude,
    double? longitude,
    String? placeId,
  }) {
    if (placeId != null && placeId.isNotEmpty) {
      return 'https://m.place.naver.com/restaurant/$placeId/home';
    } else if (latitude != null && longitude != null) {
      return 'https://map.naver.com/v5/directions/$latitude,$longitude';
    } else {
      final encodedName = Uri.encodeComponent(name);
      return 'https://map.naver.com/v5/search/$encodedName';
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

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gps_chat_app/core/utils/location_utils.dart';
// NaverApiService import

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  List<dynamic> cafes = [];
  bool isLoading = true;
  String currentAddress = '위치 불러오는 중...';

  @override
  void initState() {
    super.initState();
    fetchCurrentLocation();
    fetchCafes();
  }

  Future<void> fetchCurrentLocation() async {
    final locationData = await LocationUtils.getCurrentLocationData();
    if (locationData != null) {
      setState(() {
        currentAddress = locationData.address;
      });
    } else {
      setState(() {
        currentAddress = '위치를 가져올 수 없습니다.';
      });
    }
  }

  Future<void> fetchCafes() async {
    try {
      final api = NaverApiService();
      final results = await api.searchLocal('카페', display: 5);

      // For each result, fetch image URL using image search
      for (var cafe in results) {
        final title = cafe['title'] ?? '';
        final images = await api.searchImage(
          title.replaceAll(RegExp(r'<[^>]*>'), ''),
        );

        if (images.isNotEmpty) {
          cafe['image'] = images.first['link']; // Use first image link
        } else {
          cafe['image'] = null;
        }
      }

      setState(() {
        cafes = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('API 호출 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 375,
                height: 52,
                color: Color(0xFF3266FF),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      '현재위치',
                      style: TextStyle(
                        fontFamily: 'Paperlogy',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 0),
                            blurRadius: 1,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              currentAddress,
                              style: const TextStyle(
                                fontFamily: 'Paperlogy',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 0),
                                    blurRadius: 1,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            child: Image.asset(
                              'assets/images/pin_white.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 375,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '지금 ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: '바로 연결',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3266FF),
                      ),
                    ),
                    TextSpan(
                      text: ' 가능한,',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 375,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '연결 가능한 개발자 친구가 없어요🥹',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // 카페 추천 가로 스크롤 리스트 (API 데이터 기반)
            SizedBox(
              height: 300,
              child: SizedBox(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cafes.length,
                        padding: const EdgeInsets.only(left: 16, right: 12),
                        itemBuilder: (context, index) {
                          final cafe = cafes[index];
                          final title = cafe['title'] ?? '이름 없음';
                          final address = cafe['address'] ?? '주소 없음';

                          return Container(
                            width: 268,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 188,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image:
                                          cafe['image'] != null &&
                                              cafe['image']
                                                  .toString()
                                                  .isNotEmpty
                                          ? NetworkImage(cafe['image'])
                                          : const NetworkImage(
                                              'https://ssl.pstatic.net/static/pwe/address/img_profile.png',
                                            ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Flexible(
                                  child: Text(
                                    title.replaceAll(RegExp(r'<[^>]*>'), ''),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NaverApiService {
  static const String _localUrl =
      'https://openapi.naver.com/v1/search/local.json';
  static const String _imageUrl = 'https://openapi.naver.com/v1/search/image';
  final String clientId = 'o3Tj7WLieNlEAvX9xRjl';
  final String clientSecret = 'D47zCqbJxO';

  Future<List<dynamic>> searchLocal(String query, {int display = 10}) async {
    final url = Uri.parse(
      '$_localUrl?query=${Uri.encodeQueryComponent(query)}&display=$display',
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
}

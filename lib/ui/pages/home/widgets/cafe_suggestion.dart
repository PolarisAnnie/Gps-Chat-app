import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gps_chat_app/ui/pages/home/widgets/naver_search_api.dart';
import 'package:url_launcher/url_launcher.dart';

class CafeSuggestion extends StatefulWidget {
  const CafeSuggestion({super.key});

  @override
  State<CafeSuggestion> createState() => _CafeSuggestionState();
}

class _CafeSuggestionState extends State<CafeSuggestion> {
  List<dynamic> cafes = [];
  bool isLoading = true;
  String currentAddress = '';

  @override
  void initState() {
    super.initState();
    fetchCafes();
  }

  // 좌표 -> 주소 변환
  Future<String> getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // 시/도 + 구/군 까지 포함
        return '${place.administrativeArea} ${place.subAdministrativeArea}';
      }
      return '';
    } catch (e) {
      print('주소 변환 오류: $e');
      return '';
    }
  }

  // 주소에서 지역명 키워드 추출 함수 (시/군/구 단위까지 넓게 커버)
  String extractLocationKeyword(String address) {
    if (address.isEmpty) return '';

    List<String> regions = [
      '서울',
      '부산',
      '대구',
      '인천',
      '광주',
      '대전',
      '울산',
      '세종',
      '경기',
      '강원',
      '충북',
      '충남',
      '전북',
      '전남',
      '경북',
      '경남',
      '제주',
      '전주',
      '수원',
      '천안',
      '안산',
      '용인',
      '완산구',
      '덕진구',
      '해운대구',
      '수영구',
    ];

    List<String> parts = address.split(' ');

    for (var region in regions) {
      for (var part in parts) {
        if (part.contains(region)) {
          return region;
        }
      }
    }

    if (parts.isNotEmpty) {
      return parts[0].replaceAll(RegExp(r'(시|군|구)$'), '');
    }
    return '';
  }

  Future<void> fetchCafes() async {
    try {
      setState(() {
        isLoading = true;
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentAddress = await getAddressFromCoordinates(position);

      final locationKeyword = extractLocationKeyword(currentAddress);

      print('카페 검색 위치: 위도=${position.latitude}, 경도=${position.longitude}');
      print('추출된 지역 키워드: $locationKeyword');

      final api = NaverApiService();

      final results = await api.searchLocal(
        locationKeyword.isEmpty ? '카페' : '$locationKeyword 카페',
        display: 5,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      for (var cafe in results) {
        final title = cafe['title'] ?? '';
        final images = await api.searchImage(
          title.replaceAll(RegExp(r'<[^>]*>'), ''),
        );

        if (images.isNotEmpty) {
          cafe['image'] = images.first['link'];
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
      print('카페 API 호출 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Column(
        children: [
          Container(
            width: 375,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              '코딩하기 좋은 카페 추천',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
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
                            GestureDetector(
                              onTap: () {
                                final dynamic rawPlaceId = cafe['id'];
                                final placeId =
                                    (rawPlaceId != null && rawPlaceId is String)
                                    ? rawPlaceId
                                    : '';
                                if (placeId.isNotEmpty) {
                                  final url =
                                      'https://m.place.naver.com/restaurant/$placeId/home';
                                  launchUrl(
                                    Uri.parse(url),
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  final name = title.replaceAll(
                                    RegExp(r'<[^>]*>'),
                                    '',
                                  );
                                  final encodedName = Uri.encodeComponent(name);
                                  final url =
                                      'https://m.map.naver.com/search?query=$encodedName';
                                  launchUrl(
                                    Uri.parse(url),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              child: Container(
                                height: 188,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image:
                                        cafe['image'] != null &&
                                            cafe['image'].toString().isNotEmpty
                                        ? NetworkImage(cafe['image'])
                                        : const NetworkImage(
                                            'https://ssl.pstatic.net/static/pwe/address/img_profile.png',
                                          ),
                                    fit: BoxFit.cover,
                                  ),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Text(
                                  address,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

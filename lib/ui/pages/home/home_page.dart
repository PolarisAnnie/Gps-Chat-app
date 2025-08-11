import 'package:flutter/material.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/ui/pages/home/member_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gps_chat_app/core/utils/location_utils.dart';
import 'api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> cafes = [];
  bool isLoading = true;
  String currentAddress = '위치 불러오는 중...';
  List<User> friends = [];
  bool isLoadingFriends = true;
  bool hasLocation = true;
  bool _hasFetchedData = false;
  bool navigateToEmptyPage = false;
  String loginUserAddress = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_hasFetchedData) {
        await fetchCurrentLocation();
        await fetchNearbyFriends();
        await fetchCafes();
        _hasFetchedData = true;
      }
    });
  }

  Future<void> fetchNearbyFriends() async {
    print('fetchNearbyFriends 호출됨');
    setState(() {
      isLoadingFriends = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('현재 위치: ${position.latitude}, ${position.longitude}');
      double lat = position.latitude;
      double lng = position.longitude;

      // 현재 위치 주소 갱신 및 지역 키워드 추출
      final locationData = await LocationUtils.getCurrentLocationData();
      if (locationData != null) {
        if (currentAddress != locationData.address) {
          setState(() {
            currentAddress = locationData.address;
            hasLocation = true;
          });
        }
      } else {
        if (hasLocation != false || currentAddress != '위치를 가져올 수 없습니다.') {
          setState(() {
            currentAddress = '위치를 가져올 수 없습니다.';
            hasLocation = false;
          });
        }
      }
      final currentRegionKeyword = extractLocationKeyword(currentAddress);
      print('현재 위치 주소: $currentAddress');
      print('현재 위치 지역 키워드: $currentRegionKeyword');

      // 로그인한 유저 데이터 가져오기 및 지역 키워드 추출 (디버그 출력 추가)
      final currentUser = FirebaseAuth.instance.currentUser;
      print('현재 로그인 유저: $currentUser');

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        print('로그인 멤버 문서 존재 여부: ${userDoc.exists}');

        if (userDoc.exists) {
          final userData = userDoc.data();
          print('로그인 멤버 데이터: $userData');

          String userRegion = '';
          if (userData != null && userData['address'] != null) {
            userRegion = extractLocationKeyword(userData['address']);
            setState(() {
              loginUserAddress = userData['address'];
            });
            print('로그인 멤버 주소: $loginUserAddress');
          }
          print('로그인 멤버 주소: ${userData?['address']} -> 지역키워드: $userRegion');
        }
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      print('Firebase users docs count: ${querySnapshot.docs.length}');

      List<User> users = [];
      final String currentRegionKeywordForUsers = extractLocationKeyword(
        currentAddress,
      );

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final user = User.fromJson(data);

        final GeoPoint? geoPoint = data['location'] as GeoPoint?;
        double userLat = geoPoint?.latitude ?? 0.0;
        double userLng = geoPoint?.longitude ?? 0.0;

        if (userLat == 0.0 && userLng == 0.0) {
          print('경도, 위도 정보 없음. 스킵');
          continue;
        }

        user.distance = Geolocator.distanceBetween(lat, lng, userLat, userLng);
        users.add(user);
      }

      users.sort((a, b) => a.distance.compareTo(b.distance));

      print('정렬 후 친구 수: ${users.length}');

      setState(() {
        friends = users.take(4).toList();
        isLoadingFriends = false;
      });
    } catch (e) {
      print('Error fetching nearby friends: $e');
      setState(() {
        isLoadingFriends = false;
      });
    }
  }

  Future<void> fetchCurrentLocation() async {
    final locationData = await LocationUtils.getCurrentLocationData();
    if (locationData != null) {
      if (currentAddress != locationData.address) {
        setState(() {
          currentAddress = locationData.address;
          hasLocation = true;
        });
      }
    } else {
      if (hasLocation != false || currentAddress != '위치를 가져올 수 없습니다.') {
        setState(() {
          currentAddress = '위치를 가져올 수 없습니다.';
          hasLocation = false;
        });
      }
    }
  }

  // 주소에서 지역명 키워드 추출 함수 (시/군/구 단위까지 넓게 커버)
  String extractLocationKeyword(String address) {
    if (address.isEmpty) return '';

    // 시/도/구 단위까지 포함
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

    // 우선 시/도/구 단위로 매칭
    for (var region in regions) {
      for (var part in parts) {
        if (part.contains(region)) {
          return region;
        }
      }
    }

    // 시/군/구 단위가 없으면 첫 번째 단어에서 '시', '군', '구' 제거 후 반환
    if (parts.isNotEmpty) {
      return parts[0].replaceAll(RegExp(r'(시|군|구)$'), '');
    }

    return '';
  }

  Future<void> fetchCafes() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double latitude = position.latitude;
      double longitude = position.longitude;

      print('카페 검색 위치: 위도=$latitude, 경도=$longitude');
      print('현재 주소: $currentAddress');

      final locationKeyword = extractLocationKeyword(currentAddress);

      final api = NaverApiService();

      final results = await api.searchLocal(
        locationKeyword.isEmpty ? '카페' : '$locationKeyword 카페',
        display: 5,
        latitude: latitude,
        longitude: longitude,
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
      print('API 호출 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (navigateToEmptyPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home_empty_page');
          setState(() {
            navigateToEmptyPage = false;
          });
        }
      });
    }

    if (!hasLocation) {
      return Scaffold(
        body: Center(
          child: Text(
            '현재 위치를 가져올 수 없습니다.\n위치 권한을 확인해주세요.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 375,
                height: 52,
                color: const Color(0xFF3266FF),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              loginUserAddress.isNotEmpty
                                  ? loginUserAddress
                                  : currentAddress,
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
                            child: IconButton(
                              icon: Image.asset(
                                'assets/images/pin_white.png',
                                width: 30,
                                height: 30,
                              ),
                              onPressed: () async {
                                await fetchCurrentLocation();
                                await fetchNearbyFriends();
                                await fetchCafes();
                              },
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isLoadingFriends
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: friends.length,
                      separatorBuilder: (context, index) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: double.infinity,
                        height: 1,
                        color: Colors.grey,
                      ),
                      itemBuilder: (context, index) {
                        final user = friends[index];
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MemberDetailPage(user: user),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 24,
                                backgroundImage: user.imageUrl.isNotEmpty
                                    ? NetworkImage(user.imageUrl)
                                    : AssetImage(
                                            'assets/images/default_profile.png',
                                          )
                                          as ImageProvider,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.nickname,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.introduction,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3266FF),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/chat_white.png',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 40),

            Container(
              width: 375,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: const Text(
                '코딩하기 좋은 카페 추천',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 300,
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
                                            cafe['image'].toString().isNotEmpty
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

  final Map<String, List<dynamic>> _imageCache = {};

  Future<List<dynamic>> searchLocal(
    String query, {
    int display = 10,
    double? latitude,
    double? longitude,
  }) async {
    String urlString =
        '$_localUrl?query=${Uri.encodeQueryComponent(query)}&display=$display';
    if (latitude != null && longitude != null) {
      urlString += '&coordinate=${longitude},${latitude}';
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
      return jsonBody['items'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch local data');
    }
  }

  Future<List<dynamic>> searchImage(String query, {int display = 1}) async {
    if (_imageCache.containsKey(query)) {
      return _imageCache[query]!;
    }

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
      final items = jsonBody['items'] as List<dynamic>;
      _imageCache[query] = items;
      return items;
    } else {
      print('Image API 호출 실패: ${response.body}');
      return [];
    }
  }
}

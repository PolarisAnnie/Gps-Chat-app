import 'package:flutter/material.dart';
import 'package:gps_chat_app/ui/pages/home/widgets/naver_search_api.dart';

class CafeSuggestion extends StatefulWidget {
  const CafeSuggestion({super.key});

  @override
  State<CafeSuggestion> createState() => _CafeSuggestionState();
}

class _CafeSuggestionState extends State<CafeSuggestion> {
  List<dynamic> cafes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCafes(); // 위젯 초기화 시 카페 데이터 로드
  }

  Future<void> fetchCafes() async {
    try {
      setState(() {
        isLoading = true;
      });

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
      print('카페 API 호출 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          // '코딩하기 좋은 카페 추천' 텍스트
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
    );
  }
}

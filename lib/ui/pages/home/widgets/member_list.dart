import 'package:flutter/material.dart';

class MemberList extends StatefulWidget {
  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  PageController _pageController = PageController();

  // 임시 멤버 데이터 (기존과 동일)
  final List<Map<String, String>> members = [
    {'name': '영호느님', 'message': 'flutter 앱 창업 준비중입니다!'},
    {'name': '민수킴', 'message': '코딩 스터디 같이 하실 분!'},
    {'name': '지은양', 'message': '카페에서 개발 중이에요 ☕'},
    {'name': '준호님', 'message': 'React Native 경험 많아요'},
    {'name': '수빈이', 'message': 'UI/UX 디자이너입니다'},
    {'name': '현우형', 'message': '백엔드 개발자 구해요!'},
    {'name': '예린님', 'message': '스타트업 투자 관련 일해요'},
    {'name': '태민이', 'message': '새로운 프로젝트 시작!'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 4개씩 그룹으로 나누기
  List<List<Map<String, String>>> get memberGroups {
    List<List<Map<String, String>>> groups = [];
    for (int i = 0; i < members.length; i += 4) {
      groups.add(
        members.sublist(i, i + 4 > members.length ? members.length : i + 4),
      );
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    // 현재 주소에 속한 멤버가 없을 경우
    if (members.isEmpty) {
      return Container(
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
      );
    }

    // 현재 주소에 속한 멤버가 있을 경우
    return SizedBox(
      height: 280, // 4개 항목 + 구분선들의 높이
      child: PageView.builder(
        controller: _pageController,
        itemCount: memberGroups.length,
        itemBuilder: (context, pageIndex) {
          final pageMembers = memberGroups[pageIndex];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (int index = 0; index < pageMembers.length; index++) ...[
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pageMembers[index]['name'] ?? '영호느님',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pageMembers[index]['message'] ??
                                  'flutter 앱 창업 준비중입니다!',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          //TODO: 채팅방 생성 및 이동
                        },
                        child: Container(
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
                      ),
                    ],
                  ),
                  // 마지막 항목이 아니면 구분선 추가
                  if (index < pageMembers.length - 1)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: double.infinity,
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

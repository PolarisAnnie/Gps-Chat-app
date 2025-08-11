import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/chat_room_repository.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_page.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_view_model.dart';
import 'package:gps_chat_app/ui/pages/home/member_detail.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // ✨ 1. 패키지 import

class MemberList extends ConsumerStatefulWidget {
  final List<User> members; // 데이터를 외부에서 받도록 수정

  const MemberList({Key? key, required this.members}) : super(key: key);

  @override
  ConsumerState<MemberList> createState() => _MemberListState();
}

class _MemberListState extends ConsumerState<MemberList> {
  PageController _pageController = PageController();
  final ChatRoomRepository _chatRoomRepository =
      ChatRoomRepository(); // Repository 인스턴스 생성

  // // 임시 멤버 데이터 (기존과 동일)
  // final List<Map<String, String>> members = [
  //   {'name': '영호느님', 'message': 'flutter 앱 창업 준비중입니다!'},
  //   {'name': '민수킴', 'message': '코딩 스터디 같이 하실 분!'},
  //   {'name': '지은양', 'message': '카페에서 개발 중이에요 ☕'},
  //   {'name': '준호님', 'message': 'React Native 경험 많아요'},
  //   {'name': '수빈이', 'message': 'UI/UX 디자이너입니다'},
  //   {'name': '현우형', 'message': '백엔드 개발자 구해요!'},
  //   {'name': '예린님', 'message': '스타트업 투자 관련 일해요'},
  //   {'name': '태민이', 'message': '새로운 프로젝트 시작!'},
  // ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 4개씩 그룹으로 나누기
  List<List<User>> get memberGroups {
    List<List<User>> groups = [];
    if (widget.members.isEmpty) return groups;

    for (int i = 0; i < widget.members.length; i += 4) {
      final end = (i + 4 > widget.members.length)
          ? widget.members.length
          : i + 4;
      groups.add(widget.members.sublist(i, end));
    }
    return groups;
  }

  Future<void> _startChat(User otherUser) async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다.')));
      return;
    }

    try {
      String? roomId = await _chatRoomRepository.findChatRoomByParticipants(
        currentUser.userId,
        otherUser.userId,
      );

      if (roomId == null) {
        final newChatRoom = ChatRoom(
          roomId: '',
          currentUserId: currentUser.userId,
          otherUserId: otherUser.userId,
          address: currentUser.address ?? '주소 정보 없음',
          createdAt: DateTime.now(),
        );
        roomId = await _chatRoomRepository.createChatRoom(newChatRoom);
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(roomId: roomId!, otherUserId: otherUser.userId),
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // 현재 주소에 속한 멤버가 없을 경우
    if (widget.members.isEmpty) {
      return Container(
        width: double.infinity,
        height: 100, // 높이 조절하기
        // padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: const Text(
            '주변에 연결 가능한 개발자 친구가 없어요🥹',
            // textAlign: TextAlign.center,
            // style: TextStyle(
            //   fontSize: 16,
            //   color: AppTheme.textPrimary,
            //   fontWeight: FontWeight.w500,
            // ),
          ),
        ),
      );
    }

    // 현재 주소에 속한 멤버가 있을 경우
    /// PageView.builder로 슬라이드 기능 구현
    return Column(
      children: [
        SizedBox(
          height: 280, // 4개 항목 높이에 맞춰 고정
          child: PageView.builder(
            controller: _pageController,
            itemCount: memberGroups.length,
            itemBuilder: (context, pageIndex) {
              final pageMembers = memberGroups[pageIndex];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(pageMembers.length, (index) {
                    final member = pageMembers[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                      ), // 아이템 간 간격
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque, // 빈 공간도 터치 인식

                            onTap: () {
                              // 프로필로 이동
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MemberDetailPage(user: member),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  // networkImage를 사용하여 전달받은 User 객체의 이미지 경로를 사용
                                  backgroundImage: NetworkImage(
                                    member.imageUrl,
                                  ),
                                  backgroundColor: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.nickname,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        member.introduction,
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
                                  onTap: () => _startChat(member),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryColor,
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
                          ),
                          // 마지막 항목이 아니면 구분선 추가
                          if (index < pageMembers.length - 1)
                            Container(
                              margin: const EdgeInsets.only(
                                top: 12,
                                left: 60,
                              ), // 프로필 사진 오른쪽부터 시작
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12),

        // 페이지 표시기(indicator) 위젯 추가
        // PageController와 연동하여 현재 페이지를 추적하고, 그에 따라 점들의 색상이 바뀌도록!!!
        SmoothPageIndicator(
          controller: _pageController, // PageView의 컨트롤러 연결
          count: memberGroups.length, // 전체 페이지 수
          effect: WormEffect(
            dotHeight: 8.0,
            dotWidth: 8.0,
            activeDotColor: Theme.of(context).primaryColor, // 활성화된 점 색상
            dotColor: Colors.grey.shade300, // 비활성화된 점 색상
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/providers/viewmodels/nearby_users_provider.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/chat_room_repository.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_page.dart';
import 'package:gps_chat_app/ui/pages/home/member_detail.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MemberList extends ConsumerStatefulWidget {
  final List<User> members;
  const MemberList({Key? key, required this.members}) : super(key: key);

  @override
  ConsumerState<MemberList> createState() => _MemberListState();
}

class _MemberListState extends ConsumerState<MemberList>
    with WidgetsBindingObserver {
  PageController _pageController = PageController();
  final ChatRoomRepository _chatRoomRepository = ChatRoomRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 최초 진입 시 한 번만 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshMembers();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  // 앱 복귀 시 새로고침
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshMembers();
    }
  }

  void _refreshMembers() {
    ref.refresh(nearbyUsersProvider);
    print('🟦 멤버 리스트 새로고침');
  }

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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다.')));
      }
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.members.isEmpty) {
      return Container(
        width: double.infinity,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('주변에 연결 가능한 개발자 친구가 없어요🥹')),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
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
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
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
                          if (index < pageMembers.length - 1)
                            Container(
                              margin: const EdgeInsets.only(top: 12, left: 60),
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
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: _pageController,
          count: memberGroups.length,
          effect: WormEffect(
            dotHeight: 8.0,
            dotWidth: 8.0,
            activeDotColor: Theme.of(context).primaryColor,
            dotColor: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}

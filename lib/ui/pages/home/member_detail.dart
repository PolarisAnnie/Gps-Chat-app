import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/core/theme/theme.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/chat_room_repository.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_page.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_view_model.dart';

class MemberDetailPage extends ConsumerStatefulWidget {
  final User user;
  const MemberDetailPage({super.key, required this.user});

  @override
  ConsumerState<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends ConsumerState<MemberDetailPage> {
  final ChatRoomRepository _chatRoomRepository = ChatRoomRepository();
  bool _isLoading = false;

  Future<void> _startChat() async {
    // 중복 클릭 방지를 위해 로딩 시작
    setState(() => _isLoading = true);

    // 현재 로그인 사용자 정보 가져오기
    final currentUser = await ref.read(currentUserProvider.future);
    final otherUser = widget.user;

    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다.')));
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. 기존 채팅방 검색
      String? roomId = await _chatRoomRepository.findChatRoomByParticipants(
        currentUser.userId,
        otherUser.userId,
      );

      // 2. 기존 채팅방이 없으면 새로 생성
      if (roomId == null) {
        final newChatRoom = ChatRoom(
          // fromJson 생성자에 roomId가 필요하므로 임시 ID를 넣고,
          // 실제 저장은 toJson()에서 roomId를 제외합니다. (기존 모델 구조 유지)
          roomId: '',
          currentUserId: currentUser.userId,
          otherUserId: otherUser.userId,
          address: currentUser.address ?? '주소 정보 없음', // 현재 사용자 주소 기준
          createdAt: DateTime.now(),
        );
        // createChatRoom은 생성된 문서의 실제 ID를 반환
        roomId = await _chatRoomRepository.createChatRoom(newChatRoom);
      }

      // 3. 채팅방으로 이동
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
    } finally {
      // 작업이 끝나면 로딩 상태 해제
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '상세 소개',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(widget.user.imageUrl),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 23),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              child: Center(
                // 닉네임
                child: Text(
                  widget.user.nickname,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 22.0),
                child: Text(
                  widget.user.introduction, // 유저 소개글 표시
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: GestureDetector(
                onTap: _isLoading ? null : _startChat,

                child: Container(
                  width: 138,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Center(
                    child: Text(
                      '채팅 시작하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

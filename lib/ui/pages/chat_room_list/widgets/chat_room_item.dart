import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';
import 'package:gps_chat_app/ui/pages/chat/chat_view_model.dart';
import 'package:gps_chat_app/ui/pages/home/member_detail.dart';

// otherUserId로 사용자 정보 조회
final otherUserProvider = FutureProvider.family<User?, String>((
  ref,
  userId,
) async {
  return await UserRepository().getUserById(userId);
});

class ChatRoomItem extends ConsumerWidget {
  const ChatRoomItem({super.key, required this.chatRoom});

  final ChatRoom chatRoom;

  // 상대방 ID를 결정하는 메서드
  String _getOtherUserId(WidgetRef ref) {
    final currentUserAsync = ref.read(currentUserProvider);
    final currentUser = currentUserAsync.asData?.value;

    if (currentUser == null) return chatRoom.otherUserId;

    // 현재 사용자 기준으로 상대방 결정
    if (currentUser.userId == chatRoom.currentUserId) {
      return chatRoom.otherUserId; // 내가 시작한 채팅방
    } else {
      return chatRoom.currentUserId; // 상대방이 시작한 채팅방
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상대방 사용자 정보 조회
    final otherUserAsync = ref.watch(otherUserProvider(_getOtherUserId(ref)));
    final otherUser = otherUserAsync.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );

    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
          child: GestureDetector(
            onTap: () {
              print('프로필 이미지 클릭');
              // otherUser가 로딩 완료되었는지 확인 후 이동
              if (otherUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MemberDetailPage(user: otherUser),
                  ),
                );
              } else {
                // 아직 로딩 중이거나 에러인 경우
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('사용자 정보를 불러오는 중입니다...')));
              }
            },
            child: ClipOval(
              child: Image.network(
                otherUser?.imageUrl ??
                    'https://picsum.photos/480/480', // 실제 프로필 이미지
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherUser?.nickname ?? 'User ${_getOtherUserId(ref)}', // 실제 닉네임
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 1),
            Text(
              chatRoom.lastMessage?.content ?? '진행한 대화가 없습니다',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
        Spacer(),
        Text(
          chatRoom.relativeTime,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }
}

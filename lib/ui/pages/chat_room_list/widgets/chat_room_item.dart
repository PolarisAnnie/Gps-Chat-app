import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:gps_chat_app/data/repository/user_repository.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상대방 사용자 정보 조회
    final otherUserAsync = ref.watch(otherUserProvider(chatRoom.otherUserId));
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
              // TODO: MemberDetailPage 완성 후 네비게이션 연결
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => MemberDetailPage(userId: chatRoom.otherUserId),
              //   ),
              // );
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
              otherUser?.nickname ?? 'User ${chatRoom.otherUserId}', // 실제 닉네임
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

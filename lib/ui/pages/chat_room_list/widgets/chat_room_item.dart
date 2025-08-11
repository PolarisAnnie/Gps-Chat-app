import 'package:flutter/material.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';

class ChatRoomItem extends StatelessWidget {
  const ChatRoomItem({super.key, required this.chatRoom});

  final ChatRoom chatRoom;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
          child: GestureDetector(
            onTap: () {
              print('프로필 이미지 클릭');
            },
            child: ClipOval(
              child: Image.network(
                //TODO : firebase 프로필 이미지 URL로 연결
                'https://picsum.photos/480/480',
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
              'User ${chatRoom.otherUser}', //TODO : id 통해서 닉네임 가져오기
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
          //TODO : 현재 시간 대비 마지막 시간 차이 표현 함수 구현 필요
          '10분 전',
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

import 'package:flutter/material.dart';
import 'package:gps_chat_app/data/model/chat_message.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/model/user.dart';
import 'package:gps_chat_app/ui/pages/chat_room_list/widgets/chat_room_item.dart';

class ChatRoomListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //TODO : 샘플 데이터 생성 (추후 firebase에서 추가)
    final List<ChatRoom> chatRooms = _getSampleChatRooms();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff3266FF),
        title: Text(
          '열린 채팅방 ${chatRooms.length}개',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 24),
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      //TODO : 채팅방 클릭 시 상세 페이지로 이동
                      print('채팅방 클릭');
                    },
                    child: ChatRoomItem(
                      chatRoom: chatRooms[index], // chatRoom 데이터 전달
                    ),
                  ),
                  SizedBox(height: 12),
                  if (index < chatRooms.length - 1)
                    Container(
                      height: 0.3,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Color(0xffC7C7C7)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// 샘플 데이터 생성
List<ChatRoom> _getSampleChatRooms() {
  return [
    ChatRoom(
      roomId: 1,
      currentUserId: 100, // 내 ID
      otherUser: User(
        userId: 1,
        nickname: '영호느님',
        introduction: '안녕하세요!',
        imageUrl: 'https://example.com/user1.jpg',
        latitude: 37.497942,
        longitude: 127.027621,
        address: '서울시 강남구',
      ),
      messages: [],
      createdAt: DateTime.now(),
      lastMessage: ChatMessage(
        chatId: 1,
        senderId: 1,
        content: '안녕하세요',
        createdAt: DateTime.now(),
        messageType: '',
      ),
    ),
    ChatRoom(
      roomId: 2,
      currentUserId: 100, // 내 ID
      otherUser: User(
        userId: 2,
        nickname: '우니스',
        introduction: '안녕하세요!',
        imageUrl: 'https://example.com/user1.jpg',
        latitude: 37.497942,
        longitude: 127.027621,
        address: '서울시 강남구',
      ),
      messages: [],
      createdAt: DateTime.now(),
      lastMessage: ChatMessage(
        chatId: 2,
        senderId: 2,
        content: '안녕하세요',
        createdAt: DateTime.now(),
        messageType: '',
      ),
    ),
  ];
}

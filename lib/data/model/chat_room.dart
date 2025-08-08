import 'package:gps_chat_app/data/model/chat_message.dart';
import 'package:gps_chat_app/data/model/user.dart';

// 1대1 채팅방
class ChatRoom {
  final int roomId; // 채팅방 아이디
  // User 객체 대신 ID만 저장 : User 정보는 별도로 조회 → Firebase에서 실시간으로 가져오기
  final int currentUserId; // 현재 사용자 ID (나)
  final User otherUser; // 상대방 정보

  final List<ChatMessage> messages; //메시지 리스트
  final DateTime createdAt; // 전송 시간
  final ChatMessage? lastMessage; // 마지막 메시지
  ChatRoom({
    required this.roomId,
    required this.currentUserId,
    required this.otherUser,
    required this.messages,
    required this.createdAt,
    this.lastMessage,
  });
}

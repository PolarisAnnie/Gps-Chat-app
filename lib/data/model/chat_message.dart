// 채팅 메시지

class ChatMessage {
  final int chatId; // 메시지아이디
  final String messageType; // 발신, 수신
  final String content; // 내용
  final DateTime createdAt; // 전송 시간
  final int senderId; // 보낸 사람 아이디

  ChatMessage({
    required this.chatId,
    required this.messageType,
    required this.content,
    required this.createdAt,
    required this.senderId,
  });
}

// 채팅 메시지

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final int chatId; // 메시지아이디
  final bool isSent; // 발신, 수신
  final String content; // 내용
  final DateTime createdAt; // 전송 시간

  ChatMessage({
    required this.chatId,
    required this.isSent,
    required this.content,
    required this.createdAt,
  });

  // Firestore에서 불러올 때 사용
  ChatMessage.fromJson(Map<String, dynamic> map)
    : this(
        chatId: map['chatId'],
        isSent: map['isSent'],
        content: map['content'] ?? '',
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );

  // Firestore로 저장할 때 사용
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'isSent': isSent,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // 타임 포맷팅(ex. 2025-08-08 17:00)
  String get formattedTime => DateFormat('yyyy-MM-dd HH:mm').format(createdAt);
}

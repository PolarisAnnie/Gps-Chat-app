// 채팅 메시지

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final String sender; // 발신자 이름
  final String senderId; // 발신자 ID
  final String address; // 채팅방이 생성된 위치
  final String content; // 메시지 내용
  final DateTime createdAt; // 생성 시간

  ChatMessage({
    required this.sender,
    required this.senderId,
    required this.address,
    required this.content,
    required this.createdAt,
  });

  // Firestore에서 불러올 때 사용
  ChatMessage.fromJson(Map<String, dynamic> map)
    : this(
        sender: map['sender'],
        senderId: map['senderId'],
        address: map['address'],
        content: map['content'] ?? '',
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );

  // Firestore로 저장할 때 사용
  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'senderId': senderId,
      'address': address,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // 현재 사용자 기준으로 발신/수신 판단
  bool isSentByMe(String currentUserId) {
    return senderId == currentUserId;
  }

  // 타임 포맷팅(ex. 2025-08-08 17:00)
  String get formattedTime => DateFormat('yyyy-MM-dd HH:mm').format(createdAt);
}

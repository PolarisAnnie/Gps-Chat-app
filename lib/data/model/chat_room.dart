import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gps_chat_app/data/model/chat_message.dart';
import 'package:gps_chat_app/data/model/user.dart';
import 'package:gps_chat_app/data/model/user_model.dart';
import 'package:intl/intl.dart';

// 1대1 채팅방
class ChatRoom {
  final String roomId; // 채팅방 아이디
  // User 객체 대신 ID만 저장 : User 정보는 별도로 조회 → Firebase에서 실시간으로 가져오기
  final String currentUserId; // 현재 사용자 ID (나)
  final String otherUserId; // 상대방 정보
  final String address; // 채팅방 생성된 위치
  final DateTime createdAt; // 채팅방 생성 시간
  final ChatMessage? lastMessage; // 마지막 메시지
  ChatRoom({
    required this.roomId,
    required this.currentUserId,
    required this.otherUserId,
    required this.address,
    required this.createdAt,
    this.lastMessage,
  });

  // Firestore에서 불러올 때 사용
  ChatRoom.fromJson(Map<String, dynamic> map)
    : this(
        roomId: map['roomId'],
        currentUserId: map['currentUserId'],
        otherUserId: map['otherUserId'],
        address: map['address'],
        createdAt: (map['createdAt'] as Timestamp).toDate(),
        lastMessage: map['lastMessage'] != null
            ? ChatMessage.fromJson(map['lastMessage'])
            : null,
      );

  // Firestore로 저장할 때 사용
  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'currentUserId': currentUserId,
      'otherUserId': otherUserId,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessage': lastMessage?.toJson(),
    };
  }

  // 상대 시간 표현하기 : 마지막 메시지 기준 방금 전, 1일 전, ..
  String get relativeTime {
    if (lastMessage == null) return '';

    final diff = DateTime.now().difference(lastMessage!.createdAt);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays == 1) return '어제';
    if (diff.inDays < 30) return '${diff.inDays}일 전';

    return DateFormat('MM월 dd일').format(lastMessage!.createdAt);
  }
}

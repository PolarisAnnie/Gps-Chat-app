import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gps_chat_app/data/model/chat_message.dart';

class ChatMessageRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 메시지 전송(Create)
  Future<void> sendMessage({
    required String roomId,
    required String content,
    required bool isSent,
  }) async {
    try {
      final messageDoc = firestore
          .collection('chatrooms')
          .doc(roomId)
          .collection('messages')
          .doc();

      // 2. ChatMessage 객체 생성
      final message = ChatMessage(
        chatId: messageDoc.id, // 위에서 생성한 ID
        isSent: isSent,
        content: content,
        createdAt: DateTime.now(),
      );

      // 3. Firebase에 저장
      await messageDoc.set(message.toJson());
      print('메시지 전송 성공');
    } catch (e) {
      print('메시지 전송 실패: $e');
      throw Exception('메시지 전송에 실패했습니다: $e');
    }
  }

  // 메시지 목록 조회 (Read)
  Future<List<ChatMessage>> getMessages(String roomId) async {
    try {
      final querySnapshot = await firestore
          .collection('chatrooms')
          .doc(roomId)
          .collection('messages')
          .orderBy('createdAt', descending: false) // 오래된 것부터
          .get();

      final messages = querySnapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList();

      print('메시지 조회 성공: ${messages.length}개');
      return messages;
    } catch (e) {
      print('메시지 조회 실패: $e');
      throw Exception('메시지 조회에 실패했습니다: $e');
    }
  }

  // 실시간 메시지 스트림 (Read) : 실시간 업데이트
  Stream<List<ChatMessage>> getMessageStream(String roomId) {
    try {
      return firestore
          .collection('chatrooms')
          .doc(roomId)
          .collection('messages')
          .orderBy('createdAt', descending: false) // 오래된 것부터
          .snapshots() // 실시간 감지
          .map((snapshot) {
            final messages = snapshot.docs
                .map((doc) => ChatMessage.fromJson(doc.data()))
                .toList();
            return messages;
          });
    } catch (e) {
      print('메시지 스트림 오류: $e');
      throw Exception('실시간 메시지 수신에 실패했습니다: $e');
    }
  }
}

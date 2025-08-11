import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/model/chat_message.dart';

class ChatRoomRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 1. 채팅방 생성
  Future<String> createChatRoom(ChatRoom chatRoom) async {
    try {
      final docRef = await firestore
          .collection('chatrooms')
          .add(chatRoom.toJson());

      print('채팅방 생성 성공: ${docRef.id}');
      return docRef.id; // 자동 생성된 ID 반환
    } catch (e) {
      print('채팅방 생성 실패: $e');
      throw Exception('채팅방 생성에 실패했습니다: $e');
    }
  }

  // 2. 현재 위치 기반 채팅방 목록 조회
  Future<List<ChatRoom>> getChatRoomsByLocation({
    required String userId,
    required String address,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection('chatrooms')
          .where('address', isEqualTo: address)
          .where('currentUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true) // 최신 순으로 정렬
          .get();

      final chatRooms = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['roomId'] = doc.id; // 문서 ID를 roomId로 설정
        return ChatRoom.fromJson(data);
      }).toList();

      print('채팅방 조회 성공: ${chatRooms.length}개');
      return chatRooms;
    } catch (e) {
      print('채팅방 조회 실패: $e');
      throw Exception('채팅방 조회에 실패했습니다: $e');
    }
  }

  // 3. 마지막 메시지 업데이트
  Future<void> updateLastMessage({
    required String roomId,
    required ChatMessage lastMessage,
  }) async {
    try {
      await firestore.collection('chatrooms').doc(roomId).update({
        'lastMessage': lastMessage.toJson(),
      });

      print('마지막 메시지 업데이트 성공');
    } catch (e) {
      print('마지막 메시지 업데이트 실패: $e');
      throw Exception('마지막 메시지 업데이트에 실패했습니다: $e');
    }
  }

  // 4. 실시간 채팅방 목록 스트림
  Stream<List<ChatRoom>> getChatRoomsStream({
    required String userId,
    required String address,
  }) {
    try {
      return firestore
          .collection('chatrooms')
          .where('address', isEqualTo: address)
          .where('currentUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              data['roomId'] = doc.id;
              return ChatRoom.fromJson(data);
            }).toList();
          });
    } catch (e) {
      print('채팅방 스트림 오류: $e');
      throw Exception('실시간 채팅방 수신에 실패했습니다: $e');
    }
  }
}

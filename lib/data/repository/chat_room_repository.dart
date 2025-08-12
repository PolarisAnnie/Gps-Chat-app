import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/model/chat_message.dart';

class ChatRoomRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 1) 채팅방 생성
  Future<String> createChatRoom(ChatRoom chatRoom) async {
    try {
      final docRef = firestore.collection('chatrooms').doc();

      final Map<String, dynamic> payload = Map<String, dynamic>.from(
        chatRoom.toJson(),
      );

      // placeholder lastMessage + updatedAt 추가
      final placeholder = ChatMessage(
        sender: 'system', // 모델에 currentUserName이 없어 시스템 메시지로 처리
        senderId: chatRoom.currentUserId,
        address: chatRoom.address,
        content: '채팅방이 생성되었습니다.',
        createdAt: DateTime.now(),
      );

      payload['lastMessage'] = placeholder.toJson();
      payload['updatedAt'] = Timestamp.now();

      await docRef.set(payload);
      print('채팅방 생성 성공: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('채팅방 생성 실패: $e');
      throw Exception('채팅방 생성에 실패했습니다: $e');
    }
  }

  // 2) 양방향 채팅방 조회: updatedAt 기준으로 서버 정렬 + 병합
  Future<List<ChatRoom>> getChatRoomsByLocation({
    required String userId,
    required String address,
  }) async {
    try {
      print('🔍 채팅방 조회 시작 - userId: $userId, address: $address');

      final col = firestore.collection('chatrooms');

      final query1 = await col
          .where('address', isEqualTo: address)
          .where('currentUserId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true) // createdAt 대신 updatedAt
          .get();

      final query2 = await col
          .where('address', isEqualTo: address)
          .where('otherUserId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      // 두 결과 병합 + 정렬 (문서의 updatedAt / 없으면 createdAt 사용)
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [
        ...query1.docs,
        ...query2.docs,
      ];

      docs.sort((a, b) {
        final at =
            (a.data()['updatedAt'] as Timestamp?) ??
            (a.data()['createdAt'] as Timestamp?);
        final bt =
            (b.data()['updatedAt'] as Timestamp?) ??
            (b.data()['createdAt'] as Timestamp?);
        final ad = at?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = bt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad); // desc
      });

      final List<ChatRoom> rooms = [];
      for (final doc in docs) {
        final data = doc.data();
        data['roomId'] = doc.id; // 모델이 roomId를 쓰면 활용할 수 있게 주입
        rooms.add(ChatRoom.fromJson(data));
      }

      print('✅ 전체 채팅방 조회 성공: ${rooms.length}개');
      return rooms;
    } catch (e) {
      print('❌ 채팅방 조회 실패: $e');
      throw Exception('채팅방 조회에 실패했습니다: $e');
    }
  }

  // 3) 양방향 실시간 스트림
  Stream<List<ChatRoom>> getChatRoomsStream({
    required String userId,
    required String address,
  }) {
    try {
      print('🔄 채팅방 실시간 스트림 시작 - userId: $userId');

      final col = firestore.collection('chatrooms');

      final stream1 = col
          .where('address', isEqualTo: address)
          .where('currentUserId', isEqualTo: userId)
          .snapshots();

      final stream2 = col
          .where('address', isEqualTo: address)
          .where('otherUserId', isEqualTo: userId)
          .snapshots();

      final controller = StreamController<List<ChatRoom>>();

      QuerySnapshot<Map<String, dynamic>>? snap1;
      QuerySnapshot<Map<String, dynamic>>? snap2;

      void emitCombined() {
        if (snap1 == null && snap2 == null) return;

        // docs 합치기
        final Map<String, Map<String, dynamic>> byId = {};

        void addDocs(QuerySnapshot<Map<String, dynamic>>? s) {
          if (s == null) return;
          for (final d in s.docs) {
            byId[d.id] = d.data();
          }
        }

        addDocs(snap1);
        addDocs(snap2);

        // 리스트로 변환
        final entries = byId.entries.map((e) {
          final data = e.value;
          final updatedTs =
              (data['updatedAt'] as Timestamp?) ??
              (data['createdAt'] as Timestamp?);
          final updated =
              updatedTs?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
          return {'id': e.key, 'data': data, 'updated': updated};
        }).toList();

        // 최신순 정렬
        entries.sort(
          (a, b) =>
              (b['updated'] as DateTime).compareTo(a['updated'] as DateTime),
        );

        // 모델로 변환
        final List<ChatRoom> rooms = [];
        for (final e in entries) {
          final data = Map<String, dynamic>.from(e['data'] as Map);
          data['roomId'] = e['id']; // roomId 주입
          rooms.add(ChatRoom.fromJson(data));
        }

        controller.add(rooms);
      }

      late final StreamSubscription sub1;
      late final StreamSubscription sub2;

      sub1 = stream1.listen((s) {
        snap1 = s;
        emitCombined();
      });

      sub2 = stream2.listen((s) {
        snap2 = s;
        emitCombined();
      });

      controller.onCancel = () {
        sub1.cancel();
        sub2.cancel();
      };

      return controller.stream;
    } catch (e) {
      print('❌ 채팅방 스트림 오류: $e');
      throw Exception('실시간 채팅방 수신에 실패했습니다: $e');
    }
  }

  // 4) 마지막 메시지 업데이트: updatedAt도 함께 갱신 (모델 필드 없어도 Firestore에만 저장)
  Future<void> updateLastMessage({
    required String roomId,
    required ChatMessage lastMessage,
  }) async {
    try {
      await firestore.collection('chatrooms').doc(roomId).update({
        'lastMessage': lastMessage.toJson(),
        'updatedAt': Timestamp.now(), // 최신순 정렬 유지
      });

      print('마지막 메시지 업데이트 성공');
    } catch (e) {
      print('마지막 메시지 업데이트 실패: $e');
      throw Exception('마지막 메시지 업데이트에 실패했습니다: $e');
    }
  }

  /// 두 참여자 ID로 기존 채팅방 찾기
  Future<String?> findChatRoomByParticipants(
    String userId1,
    String userId2,
  ) async {
    final col = firestore.collection('chatrooms');

    final query1 = await col
        .where('currentUserId', isEqualTo: userId1)
        .where('otherUserId', isEqualTo: userId2)
        .limit(1)
        .get();
    if (query1.docs.isNotEmpty) return query1.docs.first.id;

    final query2 = await col
        .where('currentUserId', isEqualTo: userId2)
        .where('otherUserId', isEqualTo: userId1)
        .limit(1)
        .get();
    if (query2.docs.isNotEmpty) return query2.docs.first.id;

    return null;
  }
}

// Provider 선언
final chatRoomRepositoryProvider = Provider<ChatRoomRepository>((ref) {
  return ChatRoomRepository();
});

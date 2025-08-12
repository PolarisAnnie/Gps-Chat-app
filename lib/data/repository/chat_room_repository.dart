import 'dart:async';
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

  // 2. 양방향 채팅방 조회
  Future<List<ChatRoom>> getChatRoomsByLocation({
    required String userId,
    required String address,
  }) async {
    try {
      print('🔍 채팅방 조회 시작 - userId: $userId, address: $address');

      // 1. 내가 currentUserId인 채팅방들 조회
      final query1 = await firestore
          .collection('chatrooms')
          .where('address', isEqualTo: address)
          .where('currentUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('📋 내가 시작한 채팅방: ${query1.docs.length}개');

      // 2. 내가 otherUserId인 채팅방들 조회
      final query2 = await firestore
          .collection('chatrooms')
          .where('address', isEqualTo: address)
          .where('otherUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('📋 상대가 시작한 채팅방: ${query2.docs.length}개');

      // 3. 두 결과를 합치기
      List<ChatRoom> allChatRooms = [];

      // query1 결과 추가
      for (final doc in query1.docs) {
        final data = doc.data();
        data['roomId'] = doc.id;
        allChatRooms.add(ChatRoom.fromJson(data));
      }

      // query2 결과 추가
      for (final doc in query2.docs) {
        final data = doc.data();
        data['roomId'] = doc.id;
        allChatRooms.add(ChatRoom.fromJson(data));
      }

      // 4. 시간순으로 재정렬 (최신순)
      allChatRooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('✅ 전체 채팅방 조회 성공: ${allChatRooms.length}개');
      return allChatRooms;
    } catch (e) {
      print('❌ 채팅방 조회 실패: $e');
      throw Exception('채팅방 조회에 실패했습니다: $e');
    }
  }

  // 3. 양방향 실시간 스트림
  Stream<List<ChatRoom>> getChatRoomsStream({
    required String userId,
    required String address,
  }) {
    try {
      print('🔄 채팅방 실시간 스트림 시작 - userId: $userId');

      // 두 개의 스트림을 생성
      final stream1 = firestore
          .collection('chatrooms')
          .where('address', isEqualTo: address)
          .where('currentUserId', isEqualTo: userId)
          .snapshots();

      final stream2 = firestore
          .collection('chatrooms')
          .where('address', isEqualTo: address)
          .where('otherUserId', isEqualTo: userId)
          .snapshots();

      // 두 스트림을 합쳐서 반환
      return Stream.fromFuture(_combineStreamSnapshots(stream1, stream2));
    } catch (e) {
      print('❌ 채팅방 스트림 오류: $e');
      throw Exception('실시간 채팅방 수신에 실패했습니다: $e');
    }
  }

  // 두 스트림의 결과를 합치는 헬퍼 메서드
  Future<List<ChatRoom>> _combineStreamSnapshots(
    Stream<QuerySnapshot> stream1,
    Stream<QuerySnapshot> stream2,
  ) async {
    // 일단은 Future.wait으로 간단히 구현
    // 나중에 StreamZip이나 CombineLatestStream 사용 가능
    final snapshots = await Future.wait([stream1.first, stream2.first]);

    List<ChatRoom> allChatRooms = [];

    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['roomId'] = doc.id;
        allChatRooms.add(ChatRoom.fromJson(data));
      }
    }

    // 시간순 정렬
    allChatRooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allChatRooms;
  }

  // 4. 마지막 메시지 업데이트
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

  // ----- 소린 추가 -------

  /// 두 참여자 ID로 기존 채팅방을 찾는 메서드

  Future<String?> findChatRoomByParticipants(
    String userId1,
    String userId2,
  ) async {
    // 가능성 1: 내가 시작한 채팅방 (내가 currentUserId인 경우)
    var query1 = await firestore
        .collection('chatrooms')
        .where('currentUserId', isEqualTo: userId1)
        .where('otherUserId', isEqualTo: userId2)
        .limit(1)
        .get();

    if (query1.docs.isNotEmpty) return query1.docs.first.id;

    // 가능성 2: 상대가 시작한 채팅방 (내가 otherUserId인 경우)
    var query2 = await firestore
        .collection('chatrooms')
        .where('currentUserId', isEqualTo: userId2)
        .where('otherUserId', isEqualTo: userId1)
        .limit(1)
        .get();

    if (query2.docs.isNotEmpty) return query2.docs.first.id;

    // 두 경우 모두 없으면 null 반환
    return null;
  }
}

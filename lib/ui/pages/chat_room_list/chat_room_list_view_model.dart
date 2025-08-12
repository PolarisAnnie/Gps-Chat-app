import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_chat_app/data/model/chat_room.dart';
import 'package:gps_chat_app/data/repository/chat_room_repository.dart';

final chatRoomListViewModelProvider =
    StateNotifierProvider<ChatRoomListViewModel, ChatRoomListState>((ref) {
      return ChatRoomListViewModel(
        ref.read(
          chatRoomRepositoryProvider as ProviderListenable<ChatRoomRepository>,
        ),
      );
    });

mixin chatRoomRepositoryProvider {}

class ChatRoomListState {
  final List<ChatRoom> chatRooms;
  ChatRoomListState({this.chatRooms = const []});

  ChatRoomListState copyWith({List<ChatRoom>? chatRooms}) {
    return ChatRoomListState(chatRooms: chatRooms ?? this.chatRooms);
  }
}

class ChatRoomListViewModel extends StateNotifier<ChatRoomListState> {
  final ChatRoomRepository _repository;
  StreamSubscription<List<ChatRoom>>? _chatRoomsSubscription;

  String? _currentUserId;
  String? _currentAddress;

  ChatRoomListViewModel(this._repository) : super(ChatRoomListState());

  void setUserContext(String userId, String address) {
    _currentUserId = userId;
    _currentAddress = address;
  }

  /// 채팅방 실시간 스트림 시작
  void startChatRoomsStream() {
    if (_currentUserId == null || _currentAddress == null) {
      print('⚠️ 사용자 정보가 없어 스트림 시작 불가');
      return;
    }

    // 이미 실행 중이면 재시작 안 함
    if (_chatRoomsSubscription != null) {
      print('⏩ 채팅방 스트림 이미 실행 중 - 재시작 안 함');
      return;
    }

    print('▶ 채팅방 스트림 시작');
    _chatRoomsSubscription = _repository
        .getChatRoomsStream(userId: _currentUserId!, address: _currentAddress!)
        .listen((rooms) {
          state = state.copyWith(chatRooms: rooms);
        });
  }

  /// 구독 해제
  void stopChatRoomsStream() {
    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = null;
    print('⏹ 채팅방 스트림 중지');
  }
}

void setUserContext(String userId, String s) {}
